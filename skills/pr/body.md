# PR body

The body lets the owner understand the PR in a couple of minutes without reading the code: why it exists, what it changes and how much, what someone using it sees change, how it was tested, and what could break. Reviewer detail goes in a collapsed section at the end. Write it to `.context/pr/<branch>/body.md` and pass it with `--body-file`. Have the `writer` agent draft it when one is defined: give it the facts for each section, this file and the output path, then check its draft against the diff.

If the repo has a PR template (`.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`, `docs/pull_request_template.md`), fill it in and put these sections inside it.

**Title:** the same rules as a commit subject ([commits.md](commits.md)). For a one-commit PR, use that commit's subject.

```markdown
## Summary

<one or two short paragraphs: what exists today and what is wrong or missing, who hits it and why it matters now, then what the PR does about it and what it builds on or unblocks>

**Size:** <files, +added −removed>, mostly in <where>.

## Changes

- **<Area>** (<main change | supporting>)
  - <one line per change; a user-visible change starts with **Visible:** and gives before → after>
- **Other small changes**
  - <one line each, starting with the bold area it touches>

## Testing

<how it was tested, in plain words>

## Scope and risk

- **Scope:** <what this covers, and what it leaves out on purpose>
- **Risk:** <easy to undo or not; what breaks if it is wrong, and why that is unlikely>

<details><summary>Reviewer notes</summary>

<only what a line-by-line reviewer needs>

</details>
```

## Sections

- **Names:** describe each thing in words the reader knows. A PR number, ticket ID or code never stands alone: write what it is beside it, as in "#32 (renames the `diff` tables' change column to `status`)".
- **Summary:** the context a reader needs to care, in the repo's domain words: what exists, what is wrong or missing, who hits it, and why now. Then the approach, and what the PR builds on or unblocks. No history of the work, no commit hashes. The **Size** line comes from `git diff --shortstat <base>...HEAD`.
- **Changes:** one top-level bullet per area with its name in bold, ordered by size and tagged *main change* or *supporting*, so the reader sees the scale without reading further. One to four one-line nested bullets per area: say what changed, not every function or file. An area with only one change goes under a last **Other small changes** bullet instead, each line starting with the area in bold. A one-area PR uses plain bullets with no area. Use no headings below the `##` sections. Mark every change a user or caller can see (CLI output, exit codes, error codes and messages, config, public signatures) with **Visible:** and before → after in a few words. A fix found in review that changed behaviour gets its own small area.
- **Testing:** say how the change was tested, not which tests ran. Name the kinds of testing (unit tests, integration tests, new fixture files or rule fixtures, snapshot tests, a benchmark, a run against a real repository or the running app, a manual check) and, for each, the behaviours it covers in plain words. For new fixtures, say what they contain and what they prove, as in "two fixture repos, one with an excluded `vendor/` folder, check that its files reach no rule". Give a number only for performance (one number with its unit, before → after) or a bug's before → after. A screenshot or recording for a visual change. No test names, no lists of passing suites; lint, type checks and CI status show on the PR already.
- **Scope and risk:** two short bullets. Scope names what is in and what is deliberately left out, including follow-ups and known limits, and links each plan, report or spec the branch adds under `docs/` as a GitHub file link at the branch head. Risk says whether reverting undoes it (it doesn't for a destructive migration, data written in a new format, a removed public API or messages sent), what breaks if it is wrong, and the one fact that makes it safe.
- **Reviewer notes** (optional, collapsed): pure moves and the command that shows the real change (`git diff -w`, `git diff --color-moved`), renames with both names, a visual of a changed shape or flow, and anything a reviewer should check closely. Short bullets; leave it out when there is nothing.

**Length:** the part above Reviewer notes fits in about 40 lines for a large PR. A one-line fix needs only Summary and Testing. Cut detail, never a visible change or an area.

Done when a reader who reads only the part above Reviewer notes can say what the PR does, which areas changed and how much, what users see change, how it was tested and what could break.

Long logs, review ledgers, full hashes and per-file checklists go in a linked file, not the body. Notes to yourself and open blockers go in your report; the body is for the reviewer.

## Before posting

- Read the title, body and commit messages for secrets, customer names, emails and personal data, and run the repo's secret scanner on the body file if `GATES.md` names one.
- Use `Closes #<n>` only when every acceptance criterion of that issue is verified; otherwise `Refs #<n>` and what remains.

## Updating

When the scope changes, rewrite the title and body to describe the net diff, without narrating the review. Keep images already in the body. Update with `gh pr edit <n> --title "<title>" --body-file <file>`; if that fails with a GraphQL error, use `gh api -X PATCH repos/{owner}/{repo}/pulls/<n> -f title="<title>" -F body=@<file>`.
