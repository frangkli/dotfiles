// The docs hub: serves every repo's docs/ and internal/docs/, read live from each checkout and
// worktree (unmerged branches included), plus docs that are never committed: each main
// checkout's docs/local folder and the notes folder for docs about no repo. Read-only,
// loopback only.
//
//   node server.mjs [--port 7777] [--root ~/workspace]... [--notes ~/workspace/notes] [--kit <template.html>]
//
// URLs: /<repo>/<branch>/<path> for committed docs, /<repo>/~local/<path> for local docs and
// /~notes/<path> for notes. Git forbids "~" in branch names, so neither collides with a branch.
import { execFile } from "node:child_process";
import { createHash } from "node:crypto";
import { access, lstat, readdir, readFile, realpath, stat } from "node:fs/promises";
import { createServer } from "node:http";
import { homedir } from "node:os";
import { basename, dirname, extname, join, posix, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs, promisify } from "node:util";

const { values: options } = parseArgs({
  options: {
    port: { type: "string", default: "7777" },
    root: { type: "string", multiple: true, default: [join(homedir(), "workspace")] },
    notes: { type: "string", default: join(homedir(), "workspace", "notes") },
    kit: { type: "string", default: join(homedir(), ".agents/skills/visual-doc/assets/template.html") },
  },
});

const here = dirname(fileURLToPath(import.meta.url));
const run = promisify(execFile);
// The folders the hub lists, relative to a checkout. Edit these to add or remove one.
// Committed docs: everything under each of docRoots (internal/docs/ for repos published by an export
// that drops internal/). localRoot is the main checkout's uncommitted folder, listed on its own.
const docRoots = ["docs", "internal/docs"];
const localRoot = "docs/local";
// The kind a document gets when it doesn't declare one, from the first folder under its doc root.
const folders = { plans: "plan", research: "research", specs: "spec" };

// The longest doc root a path sits under, or undefined.
const rootOf = (path) => docRoots.filter((root) => path.startsWith(`${root}/`)).sort((a, b) => b.length - a.length)[0];
const isDocPath = (path) => Boolean(rootOf(path)) && !path.startsWith(`${localRoot}/`) && path.length > rootOf(path).length + 1;
const docPathIn = new RegExp(`(?:^|/)((?:${docRoots.map((root) => root.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|")})/.*)$`);
const folderKind = (path) => {
  const folder = path.slice(rootOf(path).length + 1).split("/")[0];
  return Object.hasOwn(folders, folder) ? folders[folder] : "note";
};
// Every kind the hub knows, in the order it lists them: [one, many]. Any other kind lists after these.
const kinds = {
  plan: ["Plan", "Plans"], spec: ["Spec", "Specs"], research: ["Research", "Research"],
  explainer: ["Explainer", "Explainers"], tradeoff: ["Tradeoff", "Tradeoffs"],
  experiment: ["Experiment", "Experiments"], review: ["Review", "Reviews"], note: ["Note", "Notes"],
};
const types = {
  ".html": "text/html; charset=utf-8", ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8", ".txt": "text/plain; charset=utf-8",
  ".json": "application/json", ".svg": "image/svg+xml", ".png": "image/png",
  ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".gif": "image/gif", ".webp": "image/webp",
};

const git = async (dir, ...args) => (await run("git", ["-C", dir, ...args], { maxBuffer: 1 << 26 })).stdout;
const escapeHtml = (text) =>
  String(text).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
const entities = { amp: "&", lt: "<", gt: ">", quot: '"', nbsp: " " };
const stripTags = (html) =>
  html.replace(/<[^>]+>/g, " ").replace(/&(\w+);/g, (m, name) => entities[name] ?? m).replace(/\s+/g, " ").trim();

function frontMatter(source) {
  const match = /^---\n([\s\S]*?)\n---\n?/.exec(source);
  const fields = Object.fromEntries([...(match?.[1] ?? "").matchAll(/^(\w+):\s*["']?(.*?)["']?\s*$/gm)].map((m) => m.slice(1)));
  return { fields, body: match ? source.slice(match[0].length) : source };
}

// Title, kind, summary and searchable text. Kind comes from <meta name="doc-kind"> or `kind:` front
// matter. The summary is the lede, else the first paragraph after the title.
function parseDocument(source, path) {
  const clip = (text) => (text.length > 280 ? `${text.slice(0, 280).replace(/\s+\S*$/, "")}…` : text);
  if (path.endsWith(".html")) {
    const title = /<title[^>]*>([\s\S]*?)<\/title>/i.exec(source)?.[1] ?? /<h1[^>]*>([\s\S]*?)<\/h1>/i.exec(source)?.[1];
    const kind = /<meta name="doc-kind" content="([^"]+)"/i.exec(source)?.[1];
    const body = source.replace(/<(script|style|head)\b[\s\S]*?<\/\1>/gi, " ");
    const afterTitle = body.slice(Math.max(0, body.search(/<\/h1>/i)));
    const lede = /<p\b[^>]*\blede\b[^>]*>([\s\S]*?)<\/p>/i.exec(body)?.[1] ?? /<p(?![^>]*\beyebrow\b)[^>]*>([\s\S]*?)<\/p>/i.exec(afterTitle)?.[1];
    return { title: stripTags(title ?? ""), kind, summary: clip(stripTags(lede ?? "")), text: stripTags(body) };
  }
  const { fields, body } = frontMatter(source);
  const prose = body.replace(/^```[\s\S]*?^```/gm, "").split(/\n\s*\n/).find((block) => /^\s*[\p{L}*_`[(]/u.test(block) && !/^\s*([-*+] |\d+[.)] |\|)/.test(block));
  const summary = (prose ?? "").replace(/!?\[([^\]]*)\]\([^)]*\)/g, "$1").replace(/[`*_]/g, "").replace(/\s+/g, " ").trim();
  return { title: fields.title || /^# (.+)$/m.exec(body)?.[1] || "", kind: fields.kind, summary: clip(fields.description || summary), text: body };
}

// Each clone's `git worktree list` finds its worktrees wherever they live, so only the clones
// need to sit under a root. The first repo with a given directory name wins. Each repo also gets its
// main checkout's docs/local folder, and the notes folder, when it exists, becomes the "notes" entry.
async function findRepos() {
  const dirs = [];
  for (const root of options.root) {
    for (const entry of await readdir(root, { withFileTypes: true }).catch(() => [])) {
      if (entry.isDirectory()) dirs.push(join(root, entry.name));
    }
  }
  const outputs = await Promise.all(
    dirs.map((dir) => access(join(dir, ".git")).then(() => git(dir, "worktree", "list", "--porcelain", "-z"), () => "")),
  );
  const repos = new Map();
  for (const output of outputs) {
    const records = output.split("\0\0").filter(Boolean).map((record) =>
      Object.fromEntries(record.split("\0").map((field) => [field.split(" ", 1)[0], field.slice(field.indexOf(" ") + 1)])),
    );
    const main = records[0]?.worktree;
    const name = main && basename(main).replace(/\.git$/, "");
    if (!name || repos.has(name)) continue;
    const worktrees = records
      .filter((record) => !("bare" in record) && !("prunable" in record))
      .map((record) => {
        const key = record.branch?.replace("refs/heads/", "") ?? `@${basename(record.worktree)}`;
        return { dir: record.worktree, main: record.worktree === main, key, label: key, url: `/${encodePath(name)}/${encodePath(key)}` };
      });
    const local = { dir: join(main, localRoot), within: main, local: true, key: "~local", label: "local", url: `/${encodePath(name)}/~local` };
    repos.set(name, { name, dir: main, worktrees, local });
  }
  if (await stat(options.notes).then((info) => info.isDirectory(), () => false)) {
    const folder = { dir: options.notes, main: true, local: true, key: "~notes", label: "notes", url: "/~notes" };
    repos.set("~notes", { name: "notes", dir: options.notes, notes: true, worktrees: [folder], local: folder });
  }
  return repos;
}

const docBlobs = async (dir, commit) => {
  const output = await git(dir, "ls-tree", "-r", "-z", commit, "--", ...docRoots);
  return new Map(output.split("\0").filter(Boolean).map((line) => [line.split("\t")[1], line.split(/[ \t]/)[2]]));
};

// The default branch's commit (origin's, else the main checkout's HEAD) and its docs' blob ids.
// Comparing bytes, not just paths, is what marks a merged plan that a branch has since edited as a draft.
async function defaultBranch(dir) {
  for (const ref of ["refs/remotes/origin/HEAD", "HEAD"]) {
    const commit = (await git(dir, "rev-parse", "--verify", "-q", `${ref}^{commit}`).catch(() => "")).trim();
    if (commit) return { commit, blobs: await docBlobs(dir, commit) };
  }
  return { commit: undefined, blobs: new Map() };
}

// Blob ids where a worktree's branch left the default branch. A file still equal to them came from
// the default branch unchanged, so it isn't the branch's draft even when the default branch has moved on.
async function forkBlobs(dir, commit) {
  const base = commit && (await git(dir, "merge-base", "HEAD", commit).catch(() => "")).trim();
  return base ? docBlobs(dir, base) : new Map();
}

// A docs folder counts only if its real path stays inside the worktree.
async function folderRoot(worktreeDir, folder) {
  const [root, dir] = await Promise.all([realpath(worktreeDir), realpath(join(worktreeDir, folder))]).catch(() => []);
  return dir?.startsWith(root + sep) ? dir : undefined;
}

// A worktree's docs, committed or not, minus what .gitignore drops (a docs site's build output or
// node_modules). Git lists a symlinked folder as one entry, so symlinks are never followed.
async function docFiles(dir) {
  const output = await git(dir, "ls-files", "-z", "--cached", "--others", "--exclude-standard", "--deduplicate", "--", ...docRoots).catch(() => "");
  return output.split("\0").filter((path) => /\.(md|html)$/.test(path) && isDocPath(path) && !/(^|\/)\./.test(path));
}

// A folder of uncommitted docs counts only if its real path exists and, for docs/local, stays
// inside the main checkout.
async function flatRoot(folder) {
  const [dir, within] = await Promise.all([realpath(folder.dir), folder.within && realpath(folder.within)]).catch(() => []);
  return dir && (!folder.within || dir.startsWith(within + sep)) ? dir : undefined;
}

// Docs in a folder of uncommitted docs (docs/local or notes), subfolders included: no git status, and
// the kind comes from the document.
async function flatDocs(repo, folder) {
  const root = await flatRoot(folder);
  const entries = root ? await readdir(root, { withFileTypes: true, recursive: true }).catch(() => []) : [];
  const docs = [];
  for (const entry of entries) {
    const path = posix.join(...relative(root, join(entry.parentPath, entry.name)).split(sep));
    if (!entry.isFile() || /(^|\/)\./.test(path) || !/\.(md|html)$/.test(entry.name)) continue;
    const file = join(root, path);
    const [content, info] = await Promise.all([readFile(file, "utf8"), stat(file)]).catch(() => []);
    if (!content) continue;
    const { title, kind, summary, text } = parseDocument(content, entry.name);
    const date = /\d{4}-\d{2}-\d{2}/.exec(entry.name)?.[0] ?? new Date(info.mtimeMs).toISOString().slice(0, 10);
    const place = repo.notes ? `notes/${path}` : `${repo.name} · ${localRoot}/${path}`;
    docs.push({ repo: repo.name, worktree: folder, path, place, title: title || entry.name, summary, text, date, kind: kind?.toLowerCase() || "note", mtime: info.mtimeMs, merged: true, local: true });
  }
  return docs;
}

async function scan(repos) {
  const docs = [];
  for (const repo of repos.values()) {
    docs.push(...(await flatDocs(repo, repo.local)));
    if (repo.notes) continue;
    const { commit, blobs: merged } = await defaultBranch(repo.dir);
    const algorithm = [...merged.values()][0]?.length === 64 ? "sha256" : "sha1";
    for (const worktree of repo.worktrees) {
      const inherited = await forkBlobs(worktree.dir, commit);
      for (const path of await docFiles(worktree.dir)) {
        const file = join(worktree.dir, path);
        const [content, info] = await Promise.all([readFile(file), lstat(file)]).catch(() => []);
        if (!content || !info.isFile()) continue;
        const blob = createHash(algorithm).update(`blob ${content.length}\0`).update(content).digest("hex");
        const { title, kind, summary, text } = parseDocument(content.toString("utf8"), path);
        const date = /\d{4}-\d{2}-\d{2}/.exec(path)?.[0] ?? new Date(info.mtimeMs).toISOString().slice(0, 10);
        const doc = { repo: repo.name, worktree, path, place: `${repo.name} · ${worktree.key} · ${path}`, title: title || basename(path), summary, text, date };
        const isMerged = merged.get(path) === blob || inherited.get(path) === blob;
        docs.push({ ...doc, kind: kind?.toLowerCase() || folderKind(path), mtime: info.mtimeMs, merged: isMerged });
      }
    }
  }
  return docs;
}

// The library: the last scan, refreshed behind the request so pages answer at once. A request that
// finds nothing, like a link to a document saved a moment ago, scans again before it says so.
let snapshot;
let pending;
const rescan = () =>
  (pending ??= (async () => {
    const repos = await findRepos();
    snapshot = { at: Date.now(), repos, docs: await scan(repos) };
    return snapshot;
  })().finally(() => (pending = undefined)));
async function library(fresh) {
  const age = snapshot ? Date.now() - snapshot.at : Infinity;
  if (fresh || age > 30_000) return rescan();
  if (age > 1000) rescan().catch(console.error);
  return snapshot;
}

// A merged document sits in every checkout, some copies behind the default branch; list it once,
// preferring the main checkout's copy.
function unique(docs) {
  const merged = new Map();
  for (const doc of docs.filter((doc) => doc.merged)) {
    const key = `${doc.repo}\0${doc.path}`;
    if (!merged.has(key) || doc.worktree.main) merged.set(key, doc);
  }
  return [...merged.values(), ...docs.filter((doc) => !doc.merged)];
}

// Pages are /<repo>/<branch>/<path> and raw files /raw/<repo>/<branch>/<path>; branch names may
// contain slashes. A link into a removed worktree matches no worktree but keeps its path. Local docs
// and notes are a path under /<repo>/~local or /~notes, subfolders included.
function route(pathname, repos) {
  const [, name, ...rest] = pathname.split("/");
  const repo = repos.get(name);
  if (repo?.notes || rest[0] === "~local") {
    const file = (repo?.notes ? rest : rest.slice(1)).join("/");
    const valid = /\.(md|html)$/.test(file) && posix.normalize(file) === file && !/(^|\/)\./.test(file) && !/[\\\0]/.test(file);
    return { repo, worktree: repo?.local, path: valid ? file : undefined, extra: file !== "" };
  }
  const tail = rest.join("/");
  const worktree = repo?.worktrees
    .toSorted((a, b) => b.key.length - a.key.length)
    .find((candidate) => tail === candidate.key || tail.startsWith(`${candidate.key}/`));
  const path = worktree ? tail.slice(worktree.key.length + 1) : docPathIn.exec(tail)?.[1];
  const valid = isDocPath(path ?? "") && posix.normalize(path) === path && !path.includes("\0");
  return { repo, worktree, path: valid ? path : undefined, extra: tail !== (worktree?.key ?? "") };
}

// Serves only regular files whose real path stays inside the worktree's docs folder, or inside a
// folder of local docs.
async function resolveFile(worktree, path) {
  if (worktree.local) {
    const root = await flatRoot(worktree);
    const file = root && (await realpath(join(root, path)).catch(() => undefined));
    if (!file?.startsWith(root + sep)) return undefined;
    return (await stat(file)).isFile() ? { file, directory: false } : undefined;
  }
  const root = await folderRoot(worktree.dir, rootOf(path));
  const file = root && (await realpath(join(worktree.dir, path)).catch(() => undefined));
  if (!file?.startsWith(root + sep)) return undefined;
  const info = await stat(file);
  return info.isFile() || info.isDirectory() ? { file, directory: info.isDirectory() } : undefined;
}

// The kit names Schibsted Grotesk and Geist Mono and falls back to system faces; the hub loads the two faces
// for every page it serves, so a document stays self-contained on disk.
// The saved theme, set before the page first paints so a page never flashes the system's theme.
const themeScript = '<script>try{const t=localStorage.getItem("theme");if(t==="light"||t==="dark")document.documentElement.dataset.theme=t}catch{}</script>';
const fontLinks = '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Hanken+Grotesk:ital,wght@0,100..900;1,100..900&family=Geist+Mono:wght@400..600&display=swap">';

// The kit's CSS and script, read from the visual-doc template so the hub matches every document.
async function kit(tag) {
  const template = await readFile(options.kit, "utf8").catch(() => "");
  return new RegExp(`<${tag} id="kit(?:-js)?">([\\s\\S]*?)</${tag}>`).exec(template)?.[1] ?? "";
}

function inline(text) {
  const codes = [];
  return escapeHtml(text)
    .replace(/`([^`]+)`/g, (_, code) => `\0${codes.push(code) - 1}\0`)
    .replace(/!\[([^\]]*)\]\(([^)\s]+)\)/g, '<img alt="$1" src="$2">')
    .replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, '<a href="$2">$1</a>')
    .replace(/&lt;(https?:\/\/[^\s&]+)&gt;/g, '<a href="$1">$1</a>')
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/(^|\W)[*_](\S.*?)[*_](?!\w)/g, "$1<em>$2</em>")
    .replace(/~~(.+?)~~/g, "<del>$1</del>")
    .replace(/ {2,}\n|\\\n/g, "<br>\n")
    .replace(/\0(\d+)\0/g, (_, index) => `<code>${codes[index]}</code>`);
}

// The common subset of CommonMark and GitHub's extensions: headings, paragraphs, nested and task
// lists, quotes, fenced code (Mermaid fences become diagrams), tables and rules. Raw HTML shows as text.
function markdown(source) {
  const lines = source.replace(/\r\n?/g, "\n").split("\n");
  const blank = (line) => line.trim() === "";
  const indentOf = (line) => /^ */.exec(line)[0].length;
  const listItem = /^( *)([-*+]|\d+[.)]) +(.*)$/;
  const interrupts = /^ {0,3}(#{1,6} |```|~~~|>|([-*+]|\d+[.)]) )/;
  const cells = (line) =>
    line.trim().replace(/^\||\|$/g, "").split(/(?<!\\)\|/).map((cell) => cell.trim().replaceAll("\\|", "|"));
  const out = [];
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    let match;
    if (blank(line)) {
      i++;
    } else if ((match = /^ {0,3}(`{3,}|~{3,})\s*([\w+-]*)/.exec(line))) {
      const code = [];
      for (i++; i < lines.length && !lines[i].trimStart().startsWith(match[1]); i++) code.push(lines[i]);
      i++;
      const text = escapeHtml(code.join("\n"));
      const language = match[2] ? ` class="language-${match[2].toLowerCase()}"` : "";
      out.push(match[2] === "mermaid" ? `<pre class="mermaid">${text}</pre>` : `<pre><code${language}>${text}</code></pre>`);
    } else if ((match = /^ {0,3}(#{1,6})\s+(.*?)[\s#]*$/.exec(line))) {
      out.push(`<h${match[1].length}>${inline(match[2])}</h${match[1].length}>`);
      i++;
    } else if (/^ {0,3}([-*_])( *\1){2,} *$/.test(line)) {
      out.push("<hr>");
      i++;
    } else if (/^ {0,3}>/.test(line)) {
      const quote = [];
      for (; i < lines.length && !blank(lines[i]); i++) quote.push(lines[i].replace(/^ {0,3}> ?/, ""));
      out.push(`<blockquote>${markdown(quote.join("\n"))}</blockquote>`);
    } else if ((match = listItem.exec(line))) {
      const indent = match[1].length;
      const ordered = /\d/.test(match[2]);
      const items = [];
      for (; i < lines.length; i++) {
        const item = listItem.exec(lines[i]);
        if (item && item[1].length === indent && /\d/.test(item[2]) === ordered) {
          items.push([item[3]]);
        } else if (blank(lines[i])) {
          const next = lines.slice(i + 1).find((candidate) => !blank(candidate));
          if (next === undefined || (indentOf(next) <= indent && !listItem.test(next))) break;
          items.at(-1).push("");
        } else if (indentOf(lines[i]) > indent) {
          items.at(-1).push(lines[i].slice(Math.min(indentOf(lines[i]), indent + 4)));
        } else if (!interrupts.test(lines[i]) && !blank(lines[i - 1])) {
          items.at(-1).push(lines[i]);
        } else {
          break;
        }
      }
      const html = items.map((item) => {
        const task = /^\[([ xX])\] +/.exec(item[0]);
        if (task) item[0] = item[0].slice(task[0].length);
        let body = markdown(item.join("\n"));
        // A list without blank lines between items keeps its text out of paragraphs.
        if (!item.includes("")) body = body.replace(/^<p>([\s\S]*?)<\/p>/, "$1");
        const box = task ? `<input type="checkbox" disabled${task[1] === " " ? "" : " checked"}> ` : "";
        return `<li>${box}${body}</li>`;
      });
      out.push(ordered ? `<ol>${html.join("")}</ol>` : `<ul>${html.join("")}</ul>`);
    } else if (line.includes("|") && /^ *\|? *:?-+:? *(\| *:?-+:? *)*\|? *$/.test(lines[i + 1] ?? "")) {
      const align = cells(lines[i + 1]).map((cell) => (cell.endsWith(":") ? (cell.startsWith(":") ? "center" : "right") : ""));
      const row = (text, tag) =>
        `<tr>${cells(text).map((cell, n) => `<${tag}${align[n] ? ` style="text-align:${align[n]}"` : ""}>${inline(cell)}</${tag}>`).join("")}</tr>`;
      const rows = [];
      for (i += 2; i < lines.length && lines[i].includes("|") && !blank(lines[i]); i++) rows.push(row(lines[i], "td"));
      out.push(`<div class="scroll"><table><thead>${row(line, "th")}</thead><tbody>${rows.join("")}</tbody></table></div>`);
    } else {
      const text = [line];
      for (i++; i < lines.length && !blank(lines[i]) && !interrupts.test(lines[i]); i++) text.push(lines[i]);
      out.push(`<p>${inline(text.join("\n"))}</p>`);
    }
  }
  return out.join("\n");
}

// The offsets of the h2 and h3 that sit inside a component (a card, phase, tab, callout, figure or
// details). Their titles name parts of a figure, not sections, so they stay out of the contents list.
// Comments, styles and scripts are skipped, since the kit's own comments mention tags.
const componentClass = /\bclass="[^"]*\b(arch|box|phases|decisions|tabs|flow|callout|metrics|stack)\b/;
function nestedHeadings(html) {
  const skipped = [...html.matchAll(/<!--[\s\S]*?-->|<(script|style)\b[\s\S]*?<\/\1>/gi)].map((m) => [m.index, m.index + m[0].length]);
  const nested = new Set();
  const open = [];
  for (const match of html.matchAll(/<(\/?)(div|section|ol|ul|details|figure|aside|h[23])\b([^>]*)>/gi)) {
    if (skipped.some(([from, to]) => match.index >= from && match.index < to)) continue;
    const [, close, name, attributes] = match;
    const tag = name.toLowerCase();
    if (tag[0] === "h") {
      if (!close && open.includes(true)) nested.add(match.index);
    } else if (close) {
      open.pop();
    } else {
      open.push(/^(details|figure|aside)$/.test(tag) || componentClass.test(attributes));
    }
  }
  return nested;
}

// Gives every h2 and h3 an id (keeping existing ones), for deep links, and lists the section headings
// for the contents. Tags and badges inside a heading stay out of its text.
function withHeadingIds(html) {
  const used = new Set();
  const headings = [];
  const nested = nestedHeadings(html);
  const out = html.replace(/<h([23])\b([^>]*)>([\s\S]*?)<\/h\1>/gi, (match, level, attributes, inner, offset) => {
    const text = stripTags(inner.replace(/<(span|small)\b[^>]*class="[^"]*\b(tag|badge)\b[^"]*"[^>]*>[\s\S]*?<\/\1>/gi, ""));
    let id = /\sid="([^"]+)"/i.exec(attributes)?.[1];
    if (!id) {
      const base = text.toLowerCase().replace(/[^\p{L}\p{N}]+/gu, "-").replace(/^-|-$/g, "") || "section";
      id = base;
      for (let n = 2; used.has(id); n++) id = `${base}-${n}`;
      match = `<h${level}${attributes} id="${id}">${inner}</h${level}>`;
    }
    used.add(id);
    if (!nested.has(offset)) headings.push({ level, id, text });
    return match;
  });
  return { html: out, headings };
}

// A document as the browser gets it: Markdown rendered with the kit, every heading linkable.
async function documentHtml(file) {
  const source = await readFile(file, "utf8");
  // An HTML document carries a copy of the kit from when it was written; serve the current one instead.
  const [style, script] = await Promise.all([kit("style"), kit("script")]);
  if (extname(file) !== ".md") {
    // Without a kit to serve (the template is missing), the document keeps its own.
    const withFonts = source.replace(/<head\b[^>]*>/i, (head) => head + fontLinks);
    if (!style) return withHeadingIds(withFonts);
    return withHeadingIds(withFonts
      .replace(/(<style id="kit">)[\s\S]*?(<\/style>)/, (_, open, close) => open + style + close)
      .replace(/(<script id="kit-js">)[\s\S]*?(<\/script>)/, (_, open, close) => open + script + close));
  }
  const { fields, body } = frontMatter(source);
  const title = escapeHtml(fields.title || /^# (.+)$/m.exec(body)?.[1] || basename(file));
  const head = `<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${title}</title>${fontLinks}`;
  return withHeadingIds(`<!doctype html><html lang="en"><head>${head}<style>${style}</style></head><body><main>${markdown(body)}</main><script>${script}</script></body></html>`);
}

const encodePath = (path) => path.split("/").map(encodeURIComponent).join("/");
const docUrl = (doc) => `${doc.worktree.url}/${encodePath(doc.path)}`;
const drafts = (docs) => docs.filter((doc) => !doc.merged).length;
const plural = (count, one, many = `${one}s`) => `${count} ${count === 1 ? one : many}`;
const escapeRegExp = (text) => text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const known = (kind) => Object.hasOwn(kinds, kind);
const kindName = (kind, many = false) => (known(kind) ? kinds[kind][many ? 1 : 0] : kind[0].toUpperCase() + kind.slice(1));
const kindsIn = (docs) => {
  const present = new Set(docs.map((doc) => doc.kind));
  return [...new Set([...Object.keys(kinds), ...present])].filter((kind) => present.has(kind));
};
const statusOf = (doc) => (doc.local ? "local" : doc.merged ? "merged" : "draft");
const flag = (doc) =>
  doc.local ? '<span class="hub-flag">Local</span>' : doc.merged ? "" : '<span class="hub-flag draft">Draft</span>';
// Where a document sits, as its own folder shows it.
const shownPath = (doc) => (doc.worktree.key === "~notes" ? `notes/${doc.path}` : doc.local ? `${localRoot}/${doc.path}` : doc.path);

const icon = (name) => `<svg class="hub-i" aria-hidden="true"><use href="#hub-${name}"/></svg>`;
const sprite = `<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>${Object.entries({
  search: '<circle cx="7.25" cy="7.25" r="4.5"/><path d="m10.6 10.6 3.15 3.15"/>',
  branch: '<circle cx="4.75" cy="3.75" r="1.5"/><circle cx="4.75" cy="12.25" r="1.5"/><circle cx="11.25" cy="5.25" r="1.5"/><path d="M4.75 5.25v5.5M11.25 6.75c0 2.75-3.5 2.4-5.4 4.1"/>',
  link: '<path d="M6.75 9.25a2.75 2.75 0 0 0 3.9 0l2-2a2.76 2.76 0 0 0-3.9-3.9l-.6.6"/><path d="M9.25 6.75a2.75 2.75 0 0 0-3.9 0l-2 2a2.76 2.76 0 0 0 3.9 3.9l.6-.6"/>',
}).map(([name, paths]) => `<symbol id="hub-${name}" viewBox="0 0 16 16">${paths}</symbol>`).join("")}</defs></svg>`;

const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
const weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
const dayStart = (ms) => new Date(ms).setHours(0, 0, 0, 0);
const daysAgo = (ms, now = Date.now()) => Math.round((dayStart(now) - dayStart(ms)) / 864e5);
const shortDate = (ms, now = Date.now()) => {
  const date = new Date(ms);
  const year = date.getFullYear() === new Date(now).getFullYear() ? "" : `, ${date.getFullYear()}`;
  return `${months[date.getMonth()].slice(0, 3)} ${date.getDate()}${year}`;
};
const ago = (ms, now = Date.now()) => {
  const minutes = Math.max(0, Math.round((now - ms) / 6e4));
  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes} min ago`;
  if (daysAgo(ms, now) === 0) return `${Math.round(minutes / 60)} h ago`;
  return daysAgo(ms, now) === 1 ? "Yesterday" : shortDate(ms, now);
};
const clock = (ms) => new Date(ms).toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });
const stamp = (ms) => new Date(ms).toLocaleString("en-US", { month: "short", day: "numeric", year: "numeric", hour: "numeric", minute: "2-digit", timeZoneName: "short" });
const time = (ms, text) => `<time datetime="${new Date(ms).toISOString()}" title="${escapeHtml(stamp(ms))}">${text}</time>`;
// A day's heading: its name, then its date.
const dayHeading = (ms, now = Date.now()) => {
  const date = new Date(ms);
  const days = daysAgo(ms, now);
  const full = `${months[date.getMonth()]} ${date.getDate()}${date.getFullYear() === new Date(now).getFullYear() ? "" : `, ${date.getFullYear()}`}`;
  if (days <= 0) return ["Today", `${weekdays[date.getDay()]}, ${full}`];
  if (days === 1) return ["Yesterday", `${weekdays[date.getDay()]}, ${full}`];
  return days < 7 ? [weekdays[date.getDay()], full] : [full, weekdays[date.getDay()]];
};

// Marks search terms in escaped text, outside its entities.
const highlight = (html, terms) =>
  terms.length
    ? html.split(/(&\w+;)/).map((part, i) => (i % 2 ? part : part.replace(new RegExp(`(${terms.map(escapeRegExp).join("|")})`, "gi"), "<mark>$1</mark>"))).join("")
    : html;

// Documents as a list, in groups (days, kinds or folders): each title with its status and when it
// changed, its summary, then what and where it is. A list that is all one kind, or all in one place,
// leaves that out. Search results add the path, where a term may have matched; the timeline shows
// the time of day.
function docList(groups, { terms = [], kind = true, where = true, clockTime = false, allLocal = false } = {}) {
  const mark = (text) => highlight(escapeHtml(text), terms);
  const item = ({ doc, snippet }) => {
    const summary = snippet ?? doc.summary;
    const place = doc.local ? escapeHtml(doc.repo === "notes" ? "Notes" : `${doc.repo}, local`) : `${escapeHtml(doc.repo)}<span class="hub-branch">${icon("branch")}${mark(doc.worktree.key)}</span>`;
    const meta = [kind && escapeHtml(kindName(doc.kind)), where && place, terms.length && `<span class="hub-path">${mark(shownPath(doc))}</span>`].filter(Boolean);
    return `<li class="hub-item"><p class="hub-item-head"><a class="hub-title" href="${docUrl(doc)}" title="${escapeHtml(shownPath(doc))}" data-doc="${docUrl(doc)}" data-mtime="${Math.round(doc.mtime)}">${mark(doc.title)}</a>${allLocal ? "" : flag(doc)}</p>${time(doc.mtime, clockTime ? clock(doc.mtime) : ago(doc.mtime))}${summary ? `<p class="hub-summary">${mark(summary)}</p>` : ""}${meta.length ? `<p class="hub-meta">${meta.map((part) => `<span>${part}</span>`).join("")}</p>` : ""}</li>`;
  };
  return groups
    .map(({ label, note, rows }) => `<section class="hub-group">${label ? `<h2><span>${label}</span>${note ? `<span class="hub-group-note">${note}</span>` : ""}<span class="hub-group-n">${plural(rows.length, "document")}</span></h2>` : ""}<ol class="hub-list">${rows.map(item).join("")}</ol></section>`)
    .join("");
}

function timeline(docs) {
  const days = Map.groupBy(docs, (doc) => dayStart(doc.mtime));
  return docList([...days].map(([day, items]) => {
    const [label, note] = dayHeading(day);
    return { label, note, rows: items.map((doc) => ({ doc })) };
  }), { clockTime: true });
}

// Every term must appear in the title, the location, the kind, the status or the text. Title and
// location matches rank first, then how often the terms occur.
function search(docs, query) {
  const terms = query.toLowerCase().split(/\s+/).filter(Boolean);
  const results = [];
  for (const doc of unique(docs)) {
    const title = doc.title.toLowerCase();
    const where = `${doc.place} ${doc.kind} ${statusOf(doc)}`.toLowerCase();
    const text = doc.text.toLowerCase();
    if (!terms.every((term) => title.includes(term) || where.includes(term) || text.includes(term))) continue;
    const score = terms.reduce(
      (sum, term) => sum + (title.includes(term) ? 20 : 0) + (where.includes(term) ? 10 : 0) + Math.min(text.split(term).length - 1, 25),
      0,
    );
    const at = text.indexOf(terms[0]);
    const start = Math.max(0, at - 80);
    // Markdown's emphasis and code marks would show as symbols, so they go.
    const plain = doc.text.slice(start, at + 180).replace(/\*\*|__|`/g, "").replace(/\s+/g, " ").trim();
    const snippet = at < 0 ? undefined : `${start > 0 ? "…" : ""}${plain}…`;
    results.push({ doc, score, snippet });
  }
  return results.toSorted((a, b) => b.score - a.score || b.doc.mtime - a.doc.mtime);
}

// The docs a worktree's view lists: its own, plus the repo's local docs in the main checkout's view.
const inView = (docs, repo, worktree) =>
  docs.filter((doc) => doc.worktree === worktree || (worktree?.main && doc.worktree === repo.local));

const searchField = (query = "", large = false, keep = {}) =>
  `<form class="hub-search${large ? " hub-search-lg" : ""}" action="/" role="search"><label>${icon("search")}<span class="hub-sr">Search every document</span><input type="search" name="q" value="${escapeHtml(query)}" placeholder="${large ? "Search titles, paths and text" : "Search"}" autocomplete="off" spellcheck="false"><kbd aria-hidden="true">/</kbd></label>${Object.entries(keep).filter(([, value]) => value).map(([name, value]) => `<input type="hidden" name="${name}" value="${escapeHtml(value)}">`).join("")}</form>`;

// A small menu of a repository's branches and worktrees, newest first, each with its drafts and its
// last change.
function branchMenu(repo, docs, shown) {
  const items = repo.worktrees
    .map((candidate) => ({ candidate, own: docs.filter((doc) => doc.worktree === candidate) }))
    .map((item) => ({ ...item, last: Math.max(0, ...item.own.map((doc) => doc.mtime)) }))
    .toSorted((a, b) => b.last - a.last)
    .map(({ candidate, own, last }) => `<li><a href="${candidate.url}"${candidate === shown ? ' aria-current="page"' : ""}><span class="hub-menu-name">${escapeHtml(candidate.key)}</span><span class="hub-menu-meta">${drafts(own) ? `<span class="hub-warn">${plural(drafts(own), "draft")}</span>` : ""}${last ? time(last, ago(last)) : "Empty"}</span></a></li>`);
  return `<details class="hub-menu"><summary class="hub-button">${icon("branch")}<span>${escapeHtml(shown.label)}</span><span class="hub-sr">: switch branch</span><svg class="hub-i hub-chevron" aria-hidden="true" viewBox="0 0 16 16"><path d="M4 6l4 4 4-4"/></svg></summary><ul class="hub-menu-list">${items.join("")}</ul></details>`;
}

// The library: recent documents, then every repository and the notes, with how many documents and
// drafts each holds. Every page shows it at the left; current is the repository shown, or "home".
function libraryIndex(repos, docs, current) {
  const all = unique(docs);
  const item = (repo) => {
    const own = all.filter((doc) => doc.repo === repo.name);
    const count = drafts(own);
    const main = repo.worktrees.find((other) => other.main) ?? repo.worktrees[0];
    return `<li><a href="${main.url}"${repo === current ? ' aria-current="page"' : ""}><span class="hub-index-name">${escapeHtml(repo.notes ? "Notes" : repo.name)}</span><span class="hub-index-n">${own.length}<span class="hub-sr"> documents</span>${count ? `<span aria-hidden="true">/</span><span class="hub-warn"><span class="hub-sr">, </span>${count}<span class="hub-sr"> ${count === 1 ? "draft" : "drafts"}</span></span>` : ""}</span></a></li>`;
  };
  const list = [...repos.values()];
  const notes = list.filter((repo) => repo.notes);
  return `<nav class="hub-nav" aria-label="Library"><ul><li><a href="/"${current === "home" ? ' aria-current="page"' : ""}><span class="hub-index-name">Recent</span></a></li></ul><h2>Repositories</h2><ul>${list.filter((repo) => !repo.notes).map(item).join("")}</ul>${notes.length ? `<h2>Notes</h2><ul>${notes.map(item).join("")}</ul>` : ""}</nav>`;
}

function repoPage(repo, docs, shown) {
  const list = (shown.local ? docs.filter((doc) => doc.worktree === shown) : inView(docs, repo, shown)).toSorted((a, b) => b.mtime - a.mtime);
  const count = drafts(list);
  const picker = !repo.notes && repo.worktrees.length > 1;
  const on = repo.notes ? "" : ` on ${picker ? branchMenu(repo, docs, shown.local ? repo.worktrees.find((candidate) => candidate.main) : shown) : escapeHtml(shown.label)}`;
  const head = `<header class="hub-head"><h1>${escapeHtml(repo.notes ? "Notes" : repo.name)}</h1><div class="hub-sub">${plural(list.length, "document")}${on}${count ? `<span class="hub-warn">, ${plural(count, "draft")}</span>` : ""}</div></header>`;
  if (!list.length) return { head, body: `<div class="hub-empty"><p class="hub-empty-title">No documents here yet</p><p>Anything saved under ${docRoots.map((root) => `<code>${root}/</code>`).join(" or ")} in this checkout shows up here.</p></div>` };
  // Notes and local folders group by folder, and show each note's kind; committed docs group by kind.
  const byFolder = Boolean(repo.notes || shown.local);
  const groups = byFolder ? Map.groupBy(list, (doc) => (doc.path.includes("/") ? doc.path.slice(0, doc.path.lastIndexOf("/")) : "")) : Map.groupBy(list, (doc) => doc.kind);
  const keys = byFolder ? [...groups.keys()].toSorted() : kindsIn(list);
  const body = docList(
    keys.map((key) => ({ label: escapeHtml(byFolder ? (key ? `${key}/` : "Top level") : kindName(key, true)), rows: groups.get(key).map((doc) => ({ doc })) })),
    { kind: byFolder, where: false, allLocal: byFolder },
  );
  return { head, body };
}

// The hub's bar, on every page: home, where you are, search, theme.
function bar({ crumbs = [], doc, home = false, query = "" }) {
  const trail = crumbs
    .map(([text, url], i) => (i < crumbs.length - 1 && url ? `<li><a href="${url}">${escapeHtml(text)}</a></li>` : `<li><span aria-current="page">${escapeHtml(text)}</span></li>`))
    .join("");
  const data = doc ? ` data-doc="${docUrl(doc)}" data-mtime="${Math.round(doc.mtime)}"` : "";
  return `<div class="hub-bar" role="banner"${data}><a class="hub-mark" href="/">Docs</a>${trail ? `<nav class="hub-crumbs" aria-label="Breadcrumb"><ol>${trail}</ol></nav>` : '<span class="hub-crumbs"></span>'}<div class="hub-tools">${home ? "" : searchField(query)}<div data-theme-control></div></div></div>`;
}

// An index page: the bar and the library, then a head and the content in one column.
function indexPage({ title, crumbs, head, body, nav, home = false, query = "" }) {
  return `<!doctype html><html lang="en" data-hub><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtml(title)} · Docs</title>${themeScript}${fontLinks}<link rel="stylesheet" href="/assets/kit.css"><link rel="stylesheet" href="/assets/hub.css"></head>
<body class="hub-body${home ? " hub-home" : ""}"><a class="hub-skip" href="#hub-main">Skip to content</a>${sprite}${bar({ crumbs, home, query })}${nav}
<main class="hub-page" id="hub-main" tabindex="-1">${head}${body}</main>
<script>${hubScript}</script><script src="/assets/kit.js"></script>${speculation}</body></html>`;
}

// The rail beside a document: its contents and Copy link, then what it is and where else it lives.
// Narrow screens show it as a disclosure above the document.
function rail(doc, headings, docs) {
  const toc = headings.length
    ? `<nav class="hub-toc" aria-label="Contents"><h2>Contents</h2><ol>${headings.map((h) => `<li class="h${h.level}"><a href="#${escapeHtml(h.id)}">${escapeHtml(h.text)}</a></li>`).join("")}</ol></nav>`
    : "";
  const state = { draft: ["Draft", "Only on this branch, or changed here"], merged: ["Merged", "On the default branch"], local: ["Local", "Never committed"] }[statusOf(doc)];
  const where = doc.worktree.key === "~notes" ? "Notes" : doc.local ? `${doc.repo}, local` : `${doc.repo}, ${doc.worktree.key}`;
  const others = docs.filter((other) => other.repo === doc.repo && other.path === doc.path && other !== doc).toSorted((a, b) => b.mtime - a.mtime);
  const versions = others.length
    ? `<section class="hub-versions"><h2>Also on</h2><ul>${others.map((other) => `<li><a href="${docUrl(other)}"><span>${escapeHtml(other.worktree.key)}</span>${time(other.mtime, ago(other.mtime))}</a></li>`).join("")}</ul></section>`
    : "";
  const details = `<section class="hub-details"><h2>Details</h2><dl>
<div><dt>Kind</dt><dd>${escapeHtml(kindName(doc.kind))}</dd></div>
<div><dt>Status</dt><dd><span class="hub-state ${statusOf(doc)}">${state[0]}</span><span class="hub-note">${state[1]}</span></dd></div>
<div><dt>Updated</dt><dd>${time(doc.mtime, ago(doc.mtime))}<span class="hub-note">${escapeHtml(stamp(doc.mtime))}</span></dd></div>
<div><dt>Location</dt><dd>${escapeHtml(where)}<code>${escapeHtml(shownPath(doc))}</code></dd></div>
</dl></section>`;
  return `<aside class="hub-rail" aria-label="About this document"><details class="hub-rail-box"><summary>${headings.length ? "Contents and details" : "Details"}</summary>${toc}<button class="hub-button hub-copy" type="button" data-copy>${icon("link")}<span>Copy link</span></button>${details}${versions}</details></aside>`;
}

// A document served as itself: its own page, with the hub's bar and rail added around its content.
function docPage(html, { doc, headings, docs, crumbs, nav }) {
  const date = new Date(doc.mtime);
  const eyebrow = `${escapeHtml(kindName(doc.kind))} · ${months[date.getMonth()].slice(0, 3)} ${date.getDate()}, ${date.getFullYear()}`;
  return html
    .replace(/^([\s\S]*?<main>)(<h1>[\s\S]*?<\/h1>)/, (match, before, title) => (doc.path.endsWith(".md") ? `${before}<header><p class="eyebrow">${eyebrow}</p>${title}</header>` : match))
    .replace(/<html\b([^>]*)>/i, (_, attributes) => `<html data-hub="doc"${attributes}>`)
    .replace(/<\/head>/i, () => `${themeScript}<link rel="stylesheet" href="/assets/hub.css"></head>`)
    .replace(/<body\b[^>]*>/i, (open) => `${open}<a class="hub-skip" href="#hub-main">Skip to content</a>${sprite}${bar({ crumbs, doc })}${nav}${rail(doc, headings, docs)}<span id="hub-main" tabindex="-1"></span>`)
    .replace(/<\/body>(?![\s\S]*<\/body>)/i, () => `<script>${hubScript}</script>${speculation}</body>`);
}

// The hub's behaviour: "/" to search, branch pickers, unread marks, copy link, and on a document the
// rail, its scroll spy and live reload.
// Links to other hub pages prerender while the pointer rests on them, so a click shows a finished page.
const speculation = `<script type="speculationrules">${JSON.stringify({ prerender: [{ where: { and: [{ href_matches: "/*" }, { not: { href_matches: "/raw/*" } }] }, eagerness: "moderate" }] })}</script>`;

const hubScript = `
{
  const bar = document.querySelector(".hub-bar");
  addEventListener("keydown", (event) => {
    if (event.key !== "/" || event.metaKey || event.ctrlKey || event.altKey || event.target.closest("input, select, textarea, [contenteditable]")) return;
    const field = document.querySelector(".hub-search-lg input, .hub-bar input[type=search]");
    if (!field) return;
    event.preventDefault();
    field.focus();
    field.select();
  });
  // Menus close on a click outside them, or on Escape.
  for (const menu of document.querySelectorAll(".hub-menu")) {
    addEventListener("click", (event) => menu.contains(event.target) || (menu.open = false));
    menu.addEventListener("keydown", (event) => event.key === "Escape" && ((menu.open = false), menu.querySelector("summary").focus()));
  }

  // Unread: new, or updated since you last opened it, counting from your first visit to the hub.
  const read = (key, fallback) => {
    try {
      return JSON.parse(localStorage.getItem(key)) ?? fallback;
    } catch {
      return fallback;
    }
  };
  const write = (key, value) => {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch {}
  };
  let since = read("hub:since", 0);
  if (!since) write("hub:since", (since = Date.now()));
  const seen = read("hub:seen", {});
  // A page prerendered on hover counts as read only once it is shown.
  const markRead = () => write("hub:seen", { ...read("hub:seen", {}), [bar.dataset.doc]: Number(bar.dataset.mtime) });
  if (bar.dataset.doc) document.prerendering ? document.addEventListener("prerenderingchange", markRead, { once: true }) : markRead();
  for (const link of document.querySelectorAll("[data-doc]:not(.hub-bar)")) {
    const mtime = Number(link.dataset.mtime);
    if (mtime <= since || (seen[link.dataset.doc] ?? 0) >= mtime) continue;
    link.insertAdjacentHTML("afterend", '<span class="hub-flag unread">' + (link.dataset.doc in seen ? "Updated" : "New") + "</span>");
  }

  for (const button of document.querySelectorAll("[data-copy]")) {
    const label = button.querySelector("span");
    button.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(location.href);
        label.textContent = "Copied";
      } catch {
        label.textContent = "Copy failed";
      }
      setTimeout(() => (label.textContent = "Copy link"), 1600);
    });
  }

  const box = document.querySelector(".hub-rail-box");
  if (box) {
    // The rail is always open beside the page, and a closed disclosure above it on narrow screens.
    const wide = matchMedia("(min-width: 1200px)");
    const sync = () => (box.open = wide.matches);
    sync();
    wide.addEventListener("change", sync);
    const links = [...box.querySelectorAll(".hub-toc a")];
    const targets = links.map((link) => document.getElementById(decodeURIComponent(link.hash.slice(1))));
    // With three or more sections, each subsection belongs to the section above it and folds away
    // until that section is in view. section[i] is the section of subsection i.
    const items = links.map((link) => link.parentElement);
    const fold = items.filter((item) => item.classList.contains("h2")).length >= 3;
    const section = {};
    items.forEach((item, i, all) => {
      if (item.classList.contains("h3")) section[i] = all.findLastIndex((other, j) => j < i && other.classList.contains("h2"));
    });
    let queued = 0;
    const spy = () => {
      queued = 0;
      let active = -1;
      targets.forEach((target, i) => {
        if (target && target.getBoundingClientRect().top < 120) active = i;
      });
      links.forEach((link, i) => (i === active ? link.setAttribute("aria-current", "location") : link.removeAttribute("aria-current")));
      const open = section[active] ?? active;
      if (fold) items.forEach((item, i) => (item.hidden = i in section && section[i] !== open));
    };
    addEventListener("scroll", () => (queued ||= requestAnimationFrame(spy)), { passive: true });
    spy();
    for (const link of links) link.addEventListener("click", () => wide.matches || (box.open = false));
    // Live reload: the server sends an event when the file changes on disk.
    new EventSource("/events?doc=" + encodeURIComponent(bar.dataset.doc)).onmessage = () => location.reload();
  }
}
`;

function send(response, code, type, body, headers = {}) {
  response.writeHead(code, { "content-type": type, "cache-control": "no-cache", "x-content-type-options": "nosniff", ...headers });
  response.end(body);
}

async function handle(request, response, fresh = false) {
  const url = new URL(request.url ?? "/", "http://localhost");
  const pathname = decodeURIComponent(url.pathname);
  if (request.method !== "GET" && request.method !== "HEAD") return send(response, 405, types[".txt"], "Method not allowed");
  if (pathname === "/assets/kit.css") return send(response, 200, types[".css"], await kit("style"));
  if (pathname === "/assets/kit.js") return send(response, 200, types[".js"], await kit("script"));
  if (pathname === "/assets/hub.css") return send(response, 200, types[".css"], await readFile(join(here, "hub.css")));

  const { repos, docs } = await library(fresh);
  // /raw serves a document on its own, without the hub's bar; /events tells a page its file changed.
  if (pathname.startsWith("/raw/") || pathname === "/events") {
    const target = pathname === "/events" ? decodeURIComponent(url.searchParams.get("doc") ?? "") : pathname.slice(4);
    const { worktree, path } = route(target, repos);
    const found = worktree && path && (await resolveFile(worktree, path.endsWith("/") ? `${path}index.html` : path));
    if (!found) return fresh ? send(response, 404, types[".txt"], "Not found") : handle(request, response, true);
    if (pathname === "/events") {
      response.writeHead(200, { "content-type": "text/event-stream", "cache-control": "no-store" });
      const mtime = () => stat(found.file).then((info) => info.mtimeMs, () => 0);
      let last = await mtime();
      const timer = setInterval(async () => {
        const now = await mtime();
        if (now !== last) response.write("data: change\n\n");
        last = now;
      }, 1000);
      return request.on("close", () => clearInterval(timer));
    }
    if (found.directory) return send(response, 308, types[".txt"], "", { location: `${url.pathname}/` });
    const extension = extname(found.file).toLowerCase();
    if (extension === ".md" || extension === ".html") return send(response, 200, types[".html"], (await documentHtml(found.file)).html);
    return send(response, 200, types[extension] ?? "application/octet-stream", await readFile(found.file));
  }

  const html = (code, page) => send(response, code, types[".html"], page);
  if (pathname === "/") {
    const query = url.searchParams.get("q")?.trim() ?? "";
    const kind = url.searchParams.get("kind") ?? "";
    const state = url.searchParams.get("status") ?? "";
    const all = url.searchParams.has("all");
    const pool = query ? search(docs, query) : unique(docs).toSorted((a, b) => b.mtime - a.mtime).map((doc) => ({ doc }));
    const byKind = (result) => !kind || result.doc.kind === kind;
    const byState = (result) => !state || statusOf(result.doc) === state;
    const shown = pool.filter(byKind).filter(byState);
    const href = (changes) => {
      const params = new URLSearchParams(Object.entries({ q: query, kind, status: state, ...changes }).filter(([, value]) => value));
      return params.size ? `/?${params}` : "/";
    };
    const tab = (text, count, link, on, className = "") => `<li${className ? ` class="${className}"` : ""}><a href="${link}"${on ? ' aria-current="true"' : ""}>${text}<span class="hub-n">${count}</span></a></li>`;
    const kindPool = pool.filter(byState).map((result) => result.doc);
    const statePool = pool.filter(byKind).map((result) => result.doc);
    const filters = `<nav class="hub-filters" aria-label="Filter documents"><ul>${tab("All", kindPool.length, href({ kind: "" }), !kind)}${kindsIn(kindPool).map((name) => tab(escapeHtml(kindName(name, true)), kindPool.filter((doc) => doc.kind === name).length, href({ kind: name }), kind === name)).join("")}</ul><ul>${tab("Drafts", statePool.filter((doc) => statusOf(doc) === "draft").length, href({ status: state === "draft" ? "" : "draft" }), state === "draft", "is-draft")}${tab("Local", statePool.filter((doc) => statusOf(doc) === "local").length, href({ status: state === "local" ? "" : "local" }), state === "local")}</ul></nav>`;
    const limit = all ? Infinity : 60;
    const terms = query.toLowerCase().split(/\s+/).filter(Boolean);
    const results = query
      ? `<div class="hub-results">${docList([{ rows: shown.slice(0, limit) }], { terms })}</div>`
      : timeline(shown.slice(0, limit).map(({ doc }) => doc));
    const more = shown.length > limit ? `<p class="hub-more"><a class="hub-button" href="${href({ all: "1" })}">Show all ${shown.length}</a></p>` : "";
    const empty = `<div class="hub-empty"><p class="hub-empty-title">Nothing matches</p><p>${query ? "Try fewer or shorter words, or " : ""}<a href="/">clear the search and filters</a>.</p></div>`;
    const everything = unique(docs);
    const repoCount = [...repos.values()].filter((repo) => !repo.notes).length;
    const sub = query
      ? `${plural(shown.length, "document")} ${shown.length === 1 ? "matches" : "match"}`
      : `${plural(everything.length, "document")} across ${plural(repoCount, "repository", "repositories")} and your notes, <span class="hub-warn">${plural(drafts(everything), "draft")}</span>`;
    const head = `<header class="hub-head"><h1${query ? ' class="is-query"' : ""}>${query ? `Results for “${escapeHtml(query)}”` : "Recent"}</h1><p class="hub-sub">${sub}</p>${searchField(query, true, { kind, status: state })}${filters}</header>`;
    return html(200, indexPage({ title: query ? `Search: ${query}` : "Recent", crumbs: [], head, body: shown.length ? results + more : empty, nav: libraryIndex(repos, docs, "home"), home: true, query }));
  }

  const { repo, worktree, path, extra } = route(pathname, repos);
  const notFound = () =>
    fresh ? html(404, indexPage({ title: "Not found", crumbs: [["Not found"]], head: '<header class="hub-head"><h1>Not found</h1><p class="hub-sub">No checkout on this box has this document. It may have lived on a branch whose worktree was removed.</p></header>', body: '<p><a class="hub-button" href="/">Back to recent documents</a></p>', nav: libraryIndex(repos, docs) })) : handle(request, response, true);
  if (!repo) return notFound();
  const main = repo.worktrees.find((candidate) => candidate.main) ?? repo.worktrees[0];
  const shown = worktree ?? main;
  if (!shown) return notFound();
  const doc = path && docs.find((candidate) => candidate.worktree === shown && candidate.path === path);
  // A document's images and other files resolve beside it, so its relative links work in the hub.
  if (path && worktree && !doc && !/\.(md|html)$/.test(path)) {
    const found = await resolveFile(worktree, path);
    if (found && !found.directory) return send(response, 200, types[extname(found.file).toLowerCase()] ?? "application/octet-stream", await readFile(found.file));
  }
  // A link into a removed worktree, or to a file the worktree no longer has, falls back to the main checkout.
  if (path && (!doc || !worktree)) {
    if (!fresh) return handle(request, response, true);
    const fallback = docs.find((candidate) => candidate.worktree === main && candidate.path === path);
    return fallback ? send(response, 302, types[".txt"], "", { location: docUrl(fallback) }) : notFound();
  }
  if (!path && extra) return notFound();
  const crumbs = repo.notes ? [["Notes", shown.url]] : [[repo.name, main.url], [shown.local ? "local" : shown.key, shown.url]];
  if (!doc) {
    const { head, body } = repoPage(repo, docs, shown);
    return html(200, indexPage({ title: repo.notes ? "Notes" : `${repo.name} · ${shown.label}`, crumbs, head, body, nav: libraryIndex(repos, docs, repo) }));
  }
  const found = await resolveFile(shown, path);
  if (!found) return notFound();
  const { html: page, headings } = await documentHtml(found.file);
  return html(200, docPage(page, { doc, headings, docs, crumbs: [...crumbs, [doc.title]], nav: libraryIndex(repos, docs, repo) }));
}

createServer((request, response) => {
  handle(request, response).catch((error) => {
    if (error instanceof URIError) return send(response, 400, types[".txt"], "Bad request");
    console.error(error);
    send(response, 500, types[".txt"], "Internal error");
  });
}).listen(Number(options.port), "127.0.0.1", () => console.log(`Docs hub on http://127.0.0.1:${options.port}/`));
