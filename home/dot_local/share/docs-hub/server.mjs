// The docs hub: serves every repo's docs/ and internal/docs/, read live from each checkout and
// worktree (unmerged branches included), plus docs that are never committed: each main
// checkout's flat docs/local folder and the flat notes folder for docs about no repo. Read-only,
// loopback only.
//
//   node server.mjs [--port 7777] [--root ~/workspace]... [--notes ~/workspace/notes] [--kit <template.html>]
//
// URLs: /<repo>/<branch>/<path> for committed docs, /<repo>/~local/<file> for local docs and
// /~notes/<file> for notes. Git forbids "~" in branch names, so neither collides with a branch.
import { execFile } from "node:child_process";
import { createHash } from "node:crypto";
import { access, lstat, readdir, readFile, realpath, stat } from "node:fs/promises";
import { createServer } from "node:http";
import { homedir } from "node:os";
import { basename, dirname, extname, join, posix, sep } from "node:path";
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
// Committed docs: everything under docs/, and under internal/docs/ for repos published by an export
// that drops internal/. docs/local is the main checkout's uncommitted folder, listed on its own.
const docRoots = ["docs", "internal/docs"];
const rootOf = (path) => (path.startsWith("internal/docs/") ? "internal/docs" : "docs");
const isDocPath = (path) => /^(internal\/)?docs\/./.test(path) && !path.startsWith("docs/local/");
// The kind a document gets when it doesn't declare one, from the folder under docs/ it sits in.
const folders = { plans: "plan", research: "research", specs: "spec" };
const folderKind = (path) => {
  const folder = path.replace(/^(internal\/)?docs\//, "").split("/")[0];
  return Object.hasOwn(folders, folder) ? folders[folder] : "note";
};
const kindLabels = {
  plan: "Plans", explainer: "Explainers", tradeoff: "Tradeoffs",
  research: "Research", experiment: "Experiments", spec: "Specs", note: "Notes",
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

// Title, kind and searchable text. Kind comes from <meta name="doc-kind"> or `kind:` front matter.
function parseDocument(source, path) {
  if (path.endsWith(".html")) {
    const title = /<title[^>]*>([\s\S]*?)<\/title>/i.exec(source)?.[1] ?? /<h1[^>]*>([\s\S]*?)<\/h1>/i.exec(source)?.[1];
    const kind = /<meta name="doc-kind" content="([^"]+)"/i.exec(source)?.[1];
    const body = source.replace(/<(script|style|head)\b[\s\S]*?<\/\1>/gi, " ");
    return { title: stripTags(title ?? ""), kind, text: stripTags(body) };
  }
  const { fields, body } = frontMatter(source);
  return { title: fields.title || /^# (.+)$/m.exec(body)?.[1] || "", kind: fields.kind, text: body };
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
    const local = { dir: join(main, "docs", "local"), within: main, local: true, key: "~local", label: "local", url: `/${encodePath(name)}/~local` };
    repos.set(name, { name, dir: main, worktrees, local });
  }
  if (await stat(options.notes).then((info) => info.isDirectory(), () => false)) {
    const folder = { dir: options.notes, main: true, local: true, key: "~notes", label: "notes", url: "/~notes" };
    repos.set("~notes", { name: "notes", dir: options.notes, notes: true, worktrees: [folder], local: folder });
  }
  return repos;
}

const docBlobs = async (dir, commit) => {
  const output = await git(dir, "ls-tree", "-r", "-z", commit, "--", "docs", "internal/docs");
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

// A flat folder of uncommitted docs counts only if its real path exists and, for docs/local, stays
// inside the main checkout.
async function flatRoot(folder) {
  const [dir, within] = await Promise.all([realpath(folder.dir), folder.within && realpath(folder.within)]).catch(() => []);
  return dir && (!folder.within || dir.startsWith(within + sep)) ? dir : undefined;
}

// Docs in a flat folder (docs/local or notes): no git status, and the kind comes from the document.
async function flatDocs(repo, folder) {
  const root = await flatRoot(folder);
  const entries = root ? await readdir(root, { withFileTypes: true }).catch(() => []) : [];
  const docs = [];
  for (const entry of entries) {
    if (!entry.isFile() || entry.name.startsWith(".") || !/\.(md|html)$/.test(entry.name)) continue;
    const file = join(root, entry.name);
    const [content, info] = await Promise.all([readFile(file, "utf8"), stat(file)]).catch(() => []);
    if (!content) continue;
    const { title, kind, text } = parseDocument(content, entry.name);
    const date = /\d{4}-\d{2}-\d{2}/.exec(entry.name)?.[0] ?? new Date(info.mtimeMs).toISOString().slice(0, 10);
    const place = repo.notes ? `notes/${entry.name}` : `${repo.name} · docs/local/${entry.name}`;
    docs.push({ repo: repo.name, worktree: folder, path: entry.name, place, title: title || entry.name, text, date, kind: kind?.toLowerCase() || "note", mtime: info.mtimeMs, merged: true, local: true });
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
        const { title, kind, text } = parseDocument(content.toString("utf8"), path);
        const date = /\d{4}-\d{2}-\d{2}/.exec(path)?.[0] ?? new Date(info.mtimeMs).toISOString().slice(0, 10);
        const doc = { repo: repo.name, worktree, path, place: `${repo.name} · ${worktree.key} · ${path}`, title: title || basename(path), text, date };
        const isMerged = merged.get(path) === blob || inherited.get(path) === blob;
        docs.push({ ...doc, kind: kind?.toLowerCase() || folderKind(path), mtime: info.mtimeMs, merged: isMerged });
      }
    }
  }
  return docs;
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
// and notes are a single file name under /<repo>/~local or /~notes.
function route(pathname, repos) {
  const [, name, ...rest] = pathname.split("/");
  const repo = repos.get(name);
  if (repo?.notes || rest[0] === "~local") {
    const file = (repo?.notes ? rest : rest.slice(1)).join("/");
    const valid = /^[^/\\]+\.(md|html)$/.test(file) && !file.startsWith(".") && !file.includes("\0");
    return { repo, worktree: repo?.local, path: valid ? file : undefined, extra: file !== "" };
  }
  const tail = rest.join("/");
  const worktree = repo?.worktrees
    .toSorted((a, b) => b.key.length - a.key.length)
    .find((candidate) => tail === candidate.key || tail.startsWith(`${candidate.key}/`));
  const path = worktree ? tail.slice(worktree.key.length + 1) : /(?:^|\/)((?:internal\/)?docs\/.*)$/.exec(tail)?.[1];
  const valid = isDocPath(path ?? "") && posix.normalize(path) === path && !path.includes("\0");
  return { repo, worktree, path: valid ? path : undefined, extra: tail !== (worktree?.key ?? "") };
}

// Serves only regular files whose real path stays inside the worktree's docs folder, or directly in
// a flat folder of local docs.
async function resolveFile(worktree, path) {
  if (worktree.local) {
    const root = await flatRoot(worktree);
    const file = root && (await realpath(join(root, path)).catch(() => undefined));
    if (!file || dirname(file) !== root) return undefined;
    return (await stat(file)).isFile() ? { file, directory: false } : undefined;
  }
  const root = await folderRoot(worktree.dir, rootOf(path));
  const file = root && (await realpath(join(worktree.dir, path)).catch(() => undefined));
  if (!file?.startsWith(root + sep)) return undefined;
  const info = await stat(file);
  return info.isFile() || info.isDirectory() ? { file, directory: info.isDirectory() } : undefined;
}

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
      out.push(match[2] === "mermaid" ? `<pre class="mermaid">${text}</pre>` : `<pre><code>${text}</code></pre>`);
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
  if (extname(file) !== ".md") return withHeadingIds(source);
  const { fields, body } = frontMatter(source);
  const title = escapeHtml(fields.title || /^# (.+)$/m.exec(body)?.[1] || basename(file));
  const head = `<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${title}</title>`;
  return withHeadingIds(`<!doctype html><html lang="en"><head>${head}<style>${await kit("style")}</style></head><body><main>${markdown(body)}</main><script>${await kit("script")}</script></body></html>`);
}

const encodePath = (path) => path.split("/").map(encodeURIComponent).join("/");
const docUrl = (doc) => `${doc.worktree.url}/${encodePath(doc.path)}`;
const drafts = (docs) => docs.filter((doc) => !doc.merged).length;
const plural = (count, word) => `${count} ${word}${count === 1 ? "" : "s"}`;
// The only status markers: a quiet tag on a draft or an uncommitted local doc. Merged documents show nothing.
const status = (doc) =>
  doc.local ? '<span class="tag local">local</span>' : doc.merged ? "" : '<span class="tag draft">draft</span>';
const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const dayStart = (ms) => new Date(ms).setHours(0, 0, 0, 0);
const dayLabel = (ms, now = Date.now()) => {
  const days = Math.round((dayStart(now) - dayStart(ms)) / 864e5);
  const date = new Date(ms);
  if (days <= 0) return "Today";
  if (days === 1) return "Yesterday";
  return `${months[date.getMonth()]} ${date.getDate()}${date.getFullYear() === new Date(now).getFullYear() ? "" : `, ${date.getFullYear()}`}`;
};
const ago = (ms, now = Date.now()) => {
  const minutes = Math.max(0, Math.round((now - ms) / 6e4));
  if (minutes < 1) return "now";
  if (minutes < 60) return `${minutes}m ago`;
  if (minutes < 24 * 60 && dayStart(ms) === dayStart(now)) return `${Math.round(minutes / 60)}h ago`;
  const label = dayLabel(ms, now);
  return label === "Yesterday" ? "yesterday" : label;
};
const time = (doc) => {
  const iso = new Date(doc.mtime).toISOString();
  return `<time datetime="${iso}" title="${iso.slice(0, 16).replace("T", " ")} UTC">${ago(doc.mtime)}</time>`;
};

// One document in a list: when it changed, its title, kind and draft tag, then where it lives.
// Sidebar items show only the title and the draft tag.
function row(doc, { where = true, current = false, snippet = "" } = {}) {
  const title = `<span class="title">${escapeHtml(doc.title)}</span>`;
  const aria = current ? ' aria-current="page"' : "";
  if (!where) return `<a class="item${current ? " current" : ""}" href="${docUrl(doc)}"${aria}>${title}${status(doc)}</a>`;
  const place = doc.place;
  const excerpt = snippet ? `<span class="excerpt">${escapeHtml(snippet)}</span>` : "";
  return `<a class="item" href="${docUrl(doc)}">${time(doc)}<span class="body"><span class="head">${title}<span class="kind">${escapeHtml(doc.kind)}</span>${status(doc)}</span><span class="path">${escapeHtml(place)}</span>${excerpt}</span></a>`;
}

// A heading with a count over one bordered list, newest first.
const list = (heading, items) =>
  `<section class="group"><h2>${heading} <span class="count">${items.length}</span></h2><div class="card">${items.map(({ doc, snippet }) => row(doc, { snippet })).join("")}</div></section>`;

// Every term must appear in the title, the location, the kind, the status or the text. Title and
// location matches rank first, then how often the terms occur.
function search(docs, query) {
  const terms = query.toLowerCase().split(/\s+/).filter(Boolean);
  const results = [];
  for (const doc of unique(docs)) {
    const title = doc.title.toLowerCase();
    const where = `${doc.place} ${doc.kind} ${doc.local ? "local" : doc.merged ? "merged" : "draft"}`.toLowerCase();
    const text = doc.text.toLowerCase();
    if (!terms.every((term) => title.includes(term) || where.includes(term) || text.includes(term))) continue;
    const score = terms.reduce(
      (sum, term) => sum + (title.includes(term) ? 20 : 0) + (where.includes(term) ? 10 : 0) + Math.min(text.split(term).length - 1, 25),
      0,
    );
    const at = Math.max(0, text.indexOf(terms[0]));
    const start = Math.max(0, at - 80);
    results.push({ doc, score, snippet: `${start > 0 ? "…" : ""}${doc.text.slice(start, at + 160).trim()}…` });
  }
  return results.toSorted((a, b) => b.score - a.score || b.doc.mtime - a.doc.mtime);
}

// The docs a worktree's view lists: its own, plus the repo's local docs in the main checkout's view.
const inView = (docs, repo, worktree) =>
  docs.filter((doc) => doc.worktree === worktree || (worktree?.main && doc.worktree === repo.local));

function sidebar(repos, docs, repo, worktree, current, query = "") {
  const select = (label, items) =>
    `<label>${label}<select>${items.map(([url, text, selected, count]) => `<option value="${url}"${selected ? " selected" : ""}${count ? ` title="${plural(count, "draft")}"` : ""}>${escapeHtml(text)}</option>`).join("")}</select></label>`;
  const repoItems = [...repos.values()].map((candidate) => {
    const count = drafts(docs.filter((doc) => doc.repo === candidate.name));
    return [candidate.worktrees[0].url, `${candidate.name}${count ? ` · ${count}` : ""}`, candidate === repo, count];
  });
  let html = `<form action="/"><input type="search" name="q" value="${escapeHtml(query)}" placeholder="Search every document" aria-label="Search every document"></form>`;
  html += select("Repository · drafts", repo ? repoItems : [["", "Choose a repository", true], ...repoItems]);
  if (!repo) return html;
  // A repo's local docs belong to its main checkout's view.
  const base = worktree === repo.local && !repo.notes ? repo.worktrees.find((candidate) => candidate.main) : worktree;
  const branchItems = repo.worktrees.map((candidate) => {
    const count = drafts(docs.filter((doc) => doc.worktree === candidate));
    return [candidate.url, `${candidate.key}${count ? ` · ${count}` : ""}`, candidate === base, count];
  });
  if (!repo.notes) html += select("Branch or worktree · drafts", branchItems);
  const shown = inView(docs, repo, base).toSorted((a, b) => b.date.localeCompare(a.date));
  const byKind = Object.groupBy(shown, (doc) => doc.kind);
  html += '<nav aria-label="Documents in this worktree">';
  for (const kind of [...new Set([...Object.keys(kindLabels), ...Object.keys(byKind)])].filter((kind) => byKind[kind])) {
    html += `<h2>${escapeHtml(kindLabels[kind] ?? kind)} <span class="count">${byKind[kind].length}</span></h2>${byKind[kind].map((doc) => row(doc, { where: false, current: doc === current })).join("")}`;
  }
  return `${html}</nav>`;
}

const icons = {
  menu: '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M2.5 4.5h11M2.5 8h11M2.5 11.5h11"/></svg>',
  open: '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M9 2.5h4.5V7M13.5 2.5 7.5 8.5M11.5 9.5v3a1 1 0 0 1-1 1h-7a1 1 0 0 1-1-1v-7a1 1 0 0 1 1-1h3"/></svg>',
  contents: '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M6 4h7.5M6 8h7.5M6 12h7.5"/><circle cx="3" cy="4" r=".6"/><circle cx="3" cy="8" r=".6"/><circle cx="3" cy="12" r=".6"/></svg>',
};

// crumbs: [text, url] pairs, the last one the current page.
function page({ title, crumbs = [], side, main, headings = [], doc, home = false }) {
  const toc = headings.length
    ? `<nav id="toc" aria-label="Contents"><h2>Contents</h2>${headings.map((h) => `<a class="h${h.level}" href="#${escapeHtml(h.id)}">${escapeHtml(h.text)}</a>`).join("")}</nav>`
    : "";
  const trail = crumbs
    .map(([text, url], i) => (i < crumbs.length - 1 && url ? `<a href="${url}">${escapeHtml(text)}</a>` : `<span aria-current="page">${escapeHtml(text)}</span>`))
    .join('<span class="sep" aria-hidden="true">/</span>');
  const open = doc ? `<a class="open" href="/raw${docUrl(doc)}" target="_blank" aria-label="Open alone" title="Open alone">${icons.open}</a>` : "";
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtml(title)}</title><link rel="stylesheet" href="/assets/kit.css"><link rel="stylesheet" href="/assets/hub.css"></head>
<body class="${[toc && "has-toc", doc && "is-doc", home && "is-home"].filter(Boolean).join(" ")}">
<header class="bar"><button id="menu" aria-label="Documents" aria-expanded="false">${icons.menu}</button><a class="brand" href="/">Docs</a><nav class="crumbs" aria-label="Location">${trail}</nav>${open}<div data-theme-control></div>${toc ? `<button id="contents" aria-label="Contents" aria-expanded="false">${icons.contents}<span>Contents</span></button>` : ""}</header>
<aside>${side}</aside><div class="main">${main}</div>${toc}
<script src="/assets/kit.js"></script>
<script>
const frame = document.querySelector("iframe");
const toggle = (button, name) => button?.addEventListener("click", () => button.setAttribute("aria-expanded", document.body.classList.toggle(name)));
toggle(document.getElementById("menu"), "drawer");
toggle(document.getElementById("contents"), "toc-open");
for (const select of document.querySelectorAll("aside select")) select.onchange = () => (location = select.value);
if (frame) {
  const show = (id) => frame.contentDocument.getElementById(decodeURIComponent(id))?.scrollIntoView();
  for (const link of document.querySelectorAll("#toc a")) {
    link.onclick = (event) => {
      event.preventDefault();
      show(link.hash.slice(1));
      history.replaceState(null, "", link.hash);
      document.body.classList.remove("toc-open");
    };
  }
  frame.onload = () => {
    if (sessionStorage.scroll) frame.contentWindow.scrollTo(0, Number(sessionStorage.scroll));
    else if (location.hash) show(location.hash.slice(1));
    sessionStorage.removeItem("scroll");
    // Links to other documents open in the hub; links off the box open in a new tab.
    frame.contentDocument.addEventListener("click", (event) => {
      const link = event.target.closest("a[href]");
      const url = link && new URL(link.href);
      if (!url || url.pathname === frame.contentWindow.location.pathname) return;
      event.preventDefault();
      if (url.origin === location.origin) location = url.pathname.replace(/^\\/raw/, "") + url.hash;
      else open(url, "_blank", "noopener");
    });
  };
  // Live reload: the server sends an event when the file changes on disk.
  new EventSource("/events?doc=${doc ? encodeURIComponent(docUrl(doc)) : ""}").onmessage = () => {
    sessionStorage.scroll = frame.contentWindow.scrollY;
    location.reload();
  };
}
</script></body></html>`;
}

function send(response, code, type, body, headers = {}) {
  response.writeHead(code, { "content-type": type, "cache-control": "no-store", "x-content-type-options": "nosniff", ...headers });
  response.end(body);
}

async function handle(request, response) {
  const url = new URL(request.url ?? "/", "http://localhost");
  const pathname = decodeURIComponent(url.pathname);
  if (request.method !== "GET" && request.method !== "HEAD") return send(response, 405, types[".txt"], "Method not allowed");
  if (pathname === "/assets/kit.css") return send(response, 200, types[".css"], await kit("style"));
  if (pathname === "/assets/kit.js") return send(response, 200, types[".js"], await kit("script"));
  if (pathname === "/assets/hub.css") return send(response, 200, types[".css"], await readFile(join(here, "hub.css")));

  const repos = await findRepos();
  if (pathname.startsWith("/raw/") || pathname === "/events") {
    const target = pathname === "/events" ? decodeURIComponent(url.searchParams.get("doc") ?? "") : pathname.slice(4);
    const { worktree, path } = route(target, repos);
    const found = worktree && path && (await resolveFile(worktree, path.endsWith("/") ? `${path}index.html` : path));
    if (!found) return send(response, 404, types[".txt"], "Not found");
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

  const docs = await scan(repos);
  const respond = (code, title, main, extra = {}) =>
    send(response, code, types[".html"], page({ title, main, side: sidebar(repos, docs, extra.repo, extra.worktree, extra.doc, extra.query), ...extra }));
  if (pathname === "/") {
    const query = url.searchParams.get("q")?.trim() ?? "";
    const results = query ? search(docs, query) : unique(docs).toSorted((a, b) => b.mtime - a.mtime).map((doc) => ({ doc }));
    const heading = query ? `Results${results.length > 50 ? ", first 50 shown" : ""}` : "Recently updated";
    const form = `<form class="search" action="/" role="search"><input type="search" name="q" value="${escapeHtml(query)}" placeholder="Search every document" aria-label="Search every document"><button type="submit">Search</button></form>`;
    const intro = '<p class="muted">Plans, research, specs and notes from every checkout and worktree on this box, drafts and local docs included.</p>';
    const body = results.length ? list(heading, results.slice(0, 50)) : '<p class="muted">Nothing found.</p>';
    const crumbs = [[query ? "Search" : "All repositories"]];
    return respond(200, "Docs", `<div class="list"><h1>Docs</h1>${intro}${form}${body}</div>`, { query, crumbs, home: true });
  }

  const { repo, worktree, path, extra } = route(pathname, repos);
  const notFound = () => respond(404, "Not found", '<div class="list"><h1>Not found</h1><p class="muted">No checkout on the box has this document.</p></div>', { crumbs: [["Not found"]] });
  if (!repo) return notFound();
  const main = repo.worktrees.find((candidate) => candidate.main) ?? repo.worktrees[0];
  const shown = worktree ?? main;
  if (!shown) return notFound();
  const doc = path && docs.find((candidate) => candidate.worktree === shown && candidate.path === path);
  // A link into a removed worktree, or to a file the worktree no longer has, falls back to the main checkout.
  if (path && (!doc || !worktree)) {
    const fallback = docs.find((candidate) => candidate.worktree === main && candidate.path === path);
    return fallback ? send(response, 302, types[".txt"], "", { location: docUrl(fallback) }) : notFound();
  }
  if (!path && extra) return notFound();
  const where = repo.notes ? "notes" : `${repo.name} · ${shown.label}`;
  const crumbs = repo.notes ? [["notes", shown.url]] : [[repo.name, main.url], [shown.label, shown.url]];
  const context = { repo, worktree: shown, doc, crumbs };
  if (!doc) {
    const shownDocs = (shown.local ? docs.filter((candidate) => candidate.worktree === shown) : inView(docs, repo, shown)).toSorted((a, b) => b.mtime - a.mtime);
    const rows = shownDocs.length ? list("Recently updated", shownDocs.map((candidate) => ({ doc: candidate }))) : '<p class="muted">No documents in this worktree.</p>';
    return respond(200, where, `<div class="list"><h1>${escapeHtml(where)}</h1>${rows}</div>`, context);
  }
  const found = await resolveFile(shown, path);
  if (!found) return notFound();
  const { headings } = await documentHtml(found.file);
  context.crumbs.push([doc.title]);
  return respond(200, doc.title, `<iframe src="/raw${docUrl(doc)}" title="${escapeHtml(doc.title)}"></iframe>`, { ...context, headings });
}

createServer((request, response) => {
  handle(request, response).catch((error) => {
    if (error instanceof URIError) return send(response, 400, types[".txt"], "Bad request");
    console.error(error);
    send(response, 500, types[".txt"], "Internal error");
  });
}).listen(Number(options.port), "127.0.0.1", () => console.log(`Docs hub on http://127.0.0.1:${options.port}/`));
