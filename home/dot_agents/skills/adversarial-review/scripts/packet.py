"""Build the review packet every lane of one round starts from.

  packet.py --base <commit> --head <commit> --out <file>
            [--scope <pathspec>...] [--spec <file>[#<heading>]...] [--ledger <ledger.json>]

The packet holds facts only, never the author's conclusions: the diff hunks with their
enclosing functions, the changed public items and where they're used, the spec sections
the ticket names, the ledger's open and settled findings, and the rule files to read.
"""
import argparse
import json
import re
import subprocess
from pathlib import Path

PUBLIC = [
    r"^\+\s*pub(?:\([^)]*\))?\s+(?:async\s+|unsafe\s+|const\s+)*(?:fn|struct|enum|trait|type|const|static|mod)\s+(\w+)",
    r"^\+\s*export\s+(?:default\s+)?(?:declare\s+)?(?:async\s+)?(?:function\*?|class|const|let|var|interface|type|enum)\s+(\w+)",
    r"^\+(?:async\s+)?def\s+([A-Za-z]\w*)|^\+class\s+([A-Za-z]\w*)",
    r"^\+func\s+(?:\([^)]*\)\s+)?([A-Z]\w*)",
]
RULE_FILES = ["AGENTS.md", "STYLE.md", "REVIEW_RULES.md", "GATES.md", "CONTRIBUTING.md"]
LANGUAGES = {".ts": "typescript", ".tsx": "typescript", ".rs": "rust", ".py": "python", ".go": "go"}
CODE = {".rs", ".ts", ".tsx", ".js", ".jsx", ".mjs", ".py", ".go", ".java", ".kt", ".swift", ".c", ".h", ".cc", ".cpp", ".rb", ".sh"}
MAX_USES = 15


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout


def public_items(diff):
    names = set()
    for line in diff.splitlines():
        for pattern in PUBLIC:
            m = re.match(pattern, line)
            if m:
                names.add(next(g for g in m.groups() if g))
    return sorted(names)


def uses(name, head):
    out = subprocess.run(["git", "grep", "-n", "-w", name, head, "--"],
                         capture_output=True, text=True).stdout.splitlines()
    lines = [l.split(":", 1)[1] for l in out]
    more = f"\n... {len(lines) - MAX_USES} more" if len(lines) > MAX_USES else ""
    return "\n".join(lines[:MAX_USES]) + more


def spec_section(arg):
    path, _, heading = arg.partition("#")
    text = Path(path).read_text()
    if not heading:
        return text
    out, level = [], None
    for line in text.splitlines():
        m = re.match(r"^(#+)\s+(.*)", line)
        if m and level is not None and len(m.group(1)) <= level:
            break
        if m and level is None and m.group(2).strip().lower() == heading.strip().lower():
            level = len(m.group(1))
        if level is not None:
            out.append(line)
    return "\n".join(out) or f"(heading '{heading}' not found in {path})"


def ledger_items(path):
    findings = json.loads(Path(path).read_text()).get("findings", {})
    rows = [f"- {f.get('title', '')} ({i}): {f['status']}, {f.get('severity', '')}, "
            f"{f.get('path', '')}:{f.get('lines', '')}" for i, f in findings.items()]
    return "\n".join(rows) or "none"


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--base", required=True)
    p.add_argument("--head", required=True)
    p.add_argument("--out", required=True)
    p.add_argument("--scope", nargs="*", default=[])
    p.add_argument("--spec", action="append", default=[])
    p.add_argument("--ledger")
    a = p.parse_args()

    root = Path(git("rev-parse", "--show-toplevel").strip())
    files = git("diff", "--name-only", a.base, a.head, "--", *a.scope).split()
    code = [f for f in files if Path(f).suffix in CODE]
    other = [f for f in files if Path(f).suffix not in CODE]
    diff = (git("diff", "--function-context", a.base, a.head, "--", *code) if code else "") + \
           (git("diff", "-U5", a.base, a.head, "--", *other) if other else "")
    parts = [f"# Review packet\n\nBase {a.base}, head {a.head}. Changed files:\n"
             + "\n".join(f"- {f}" for f in files)]

    rules = [f"- {f}" for f in RULE_FILES if (root / f).exists()]
    for lang in sorted({LANGUAGES[Path(f).suffix] for f in files if Path(f).suffix in LANGUAGES}):
        ref = Path.home() / ".agents/skills" / lang / "references/review.md"
        if ref.exists():
            rules.append(f"- {ref} ({lang})")
    parts.append("## Rule files to read\n\n" + ("\n".join(rules) or "none"))

    for spec in a.spec:
        parts.append(f"## Spec: {spec}\n\n{spec_section(spec)}")
    if a.ledger and Path(a.ledger).exists():
        parts.append("## Ledger\n\n" + ledger_items(a.ledger))

    items = public_items(diff)
    parts.append("## Changed public items and their uses\n\n" + ("\n\n".join(
        f"### {n}\n```\n{uses(n, a.head)}\n```" for n in items) or "none"))
    parts.append(f"## Diff (code with enclosing functions)\n\n```diff\n{diff}```")

    Path(a.out).write_text("\n\n".join(parts) + "\n")
    print(f"{a.out}: {len(files)} files, {len(items)} public items")


if __name__ == "__main__":
    main()
