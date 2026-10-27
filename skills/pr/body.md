# PR body

The body lets the owner understand the PR without reading the code: what it does, why, how it works, and every change a user or caller can see. Write it to `.context/pr/<branch>/body.md` and pass it with `--body-file`. Have the `writer` agent draft it when one is defined: give it the facts for each section, this file and the output path, then check its draft against the diff.

If the repo has a PR template (`.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`, `docs/pull_request_template.md`), fill it in and put these sections inside it.

**Title:** the same rules as a commit subject ([commits.md](commits.md)). For a one-commit PR, use that commit's subject.

```markdown
## Why

<the problem, the approach, and what the PR builds on>

## What changed

<every change in the diff, grouped by area>

## Scope

<what it covers, and what it deliberately leaves out>

## Blast radius

**Door:** <one-way | two-way>. <who or what it touches, and the one fact that makes it safe>

## Evidence

- <what you ran>: <before> → <after>
```

## Sections

- **Names:** describe each thing in words the reader knows. A PR number, ticket ID or code never stands alone: write what it is beside it, as in "#32 (renames the `diff` tables' change column to `status`)". Give a module, type or term the reader may not know one clause on what it holds or does.
- **Why:** the reader's problem, in the repo's domain words (its glossary or CONTEXT.md), the approach, and the PRs or code this PR builds on. No commit hashes or history of the work.
- **What changed:** cover the whole diff, grouped by area, with one `###` subsection per area when there are more than three. For each change, give before → after and the reason. List every change that a user or caller can see, even a one-word change: CLI output, exit codes, error codes and messages, config and public signatures. When there are several, use a before → after table. Name the parts that are pure moves or re-indentation, and give the command that shows the real change (`git diff -w`, `git diff --color-moved`). Put what a reviewer should check beside the change it concerns; there is no separate review-focus section. Name both sides of a rename. Use a visual when it's clearer than prose: pseudocode for logic, a call tree for control flow, a file tree for layout, a `diff` block for a shape that changed. Usually one visual, rarely two.
- **Length** follows the diff: a few lines for a one-line fix, as long as the done test below needs for a large refactor. Cut restatement, never coverage.
- **Scope:** always present. Name the follow-ups and known gaps. Link each plan, report or spec the branch adds or changes under `docs/` as a GitHub file link at the branch head.
- **Tradeoffs** (optional, after Scope): only the alternatives a reviewer would otherwise ask about.
- **Blast radius:** a two-way door is cheap to reverse by reverting. A one-way door is not: a destructive migration, data written in a new format, a removed public API, messages or emails sent. Name what breaks if the change is wrong (an API's consumers, stored data, a deploy, a layout on small screens) and the one fact the change is safe because of, with how far you proved it: stated, pointed at the line, ran a script against the real code, reproduced in the app. Check this section hardest when it says "two-way, small".
- **Evidence:** real behaviour, before and after, strongest first:
  1. a screenshot or recording, for a visual change;
  2. the test that failed before and passes now, by name, with its assertion as pseudocode;
  3. command output or a request against the running app that changed.

  Lint, type checks, the unit suite and CI status are shown by the checks themselves; leave them out. For performance, one number with its unit, before → after.

Done when a reader who has read only the body can say what each commit does, and no hunk in the diff surprises them. A delivery brief may add facts or sections; it does not cap the length or replace these sections.

Long logs, review ledgers, full hashes and per-file checklists go in a linked file, not the body. Notes to yourself and open blockers go in your report; the body is for the reviewer.

## Before posting

- Read the title, body and commit messages for secrets, customer names, emails and personal data, and run the repo's secret scanner on the body file if `GATES.md` names one.
- Use `Closes #<n>` only when every acceptance criterion of that issue is verified; otherwise `Refs #<n>` and what remains.

## Updating

When the scope changes, rewrite the title and body to describe the net diff, without narrating the review. Keep images already in the body. Update with `gh pr edit <n> --title "<title>" --body-file <file>`; if that fails with a GraphQL error, use `gh api -X PATCH repos/{owner}/{repo}/pulls/<n> -f title="<title>" -F body=@<file>`.
