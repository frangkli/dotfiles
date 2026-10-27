"""Check that a worker brief is complete before spawning.

brief_check.py <brief.md>    exit 0 when complete, 1 with what's missing

Each section label is upper case at the start of a line. A fence opened after the first
label is quoted material (a pasted report), never a label. A section is empty when it has
no content, or still holds a template placeholder such as <path>.
"""

import re
import sys

SECTIONS = [
    "GOAL", "CONTEXT", "SCOPE", "OUT OF SCOPE", "INTERFACES", "ACCEPTANCE", "VERIFY",
    "EXIT", "FORBIDDEN", "DECISIONS", "PROGRESS", "REPORT", "STANDING",
]
# Longest first, so "OUT OF SCOPE" isn't read as "SCOPE".
LABEL = re.compile(
    r"^(%s)(?::|\s|$)" % "|".join(re.escape(s) for s in sorted(SECTIONS, key=len, reverse=True))
)
PLACEHOLDER = re.compile(r"<[a-z][a-z .,'-]*>")
CLOSING = "Deliver the complete unit"


def sections(text):
    found, current, quoted = {}, None, False
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            if current:
                quoted = not quoted
            continue
        m = None if quoted else LABEL.match(line)
        if m and m.group(1) not in found:
            current = m.group(1)
            found[current] = [line[m.end():].strip(" :")]
        elif current and line.strip():
            found[current].append(line.strip())
    return found


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip())
    text = open(sys.argv[1], encoding="utf-8").read()
    found = sections(text)
    problems = []
    for name in SECTIONS:
        body = [l for l in found.get(name, []) if l]
        if name not in found:
            problems.append(f"{name}: missing")
        elif not body:
            problems.append(f"{name}: empty")
        elif any(PLACEHOLDER.search(l) for l in body):
            problems.append(f"{name}: template placeholder left")
    if CLOSING not in text:
        problems.append("closing lines: missing")
    if problems:
        print("Brief incomplete, don't spawn:\n" + "\n".join(f"- {p}" for p in problems))
        sys.exit(1)
    print("Brief complete.")


if __name__ == "__main__":
    main()
