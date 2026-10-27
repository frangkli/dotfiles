# Where learned rules live

The one answer for `prevent-repeats`, `retro` and `pr`. There is no separate coding-standards file.

| What was learned | Where it goes |
|---|---|
| A mistake a check can decide | The check itself (architecture, a type, a lint rule, a test, a hook or a CI job), run by a command `GATES.md` lists, plus a row in the Enforced table |
| A judgement call no check can decide | A numbered rule in `REVIEW_RULES.md`, with the concrete failing case it prevents |
| A pattern reviewers keep flagging that is intended | An entry under Known non-issues in `REVIEW_RULES.md` |
| Where something lives, or which command to run | One pointer line in AGENTS.md, or in the nearest nested AGENTS.md for one package; check commands go in `GATES.md` |
| Anything config, scripts or `--help` already state | Nowhere: the environment is its own source |

## The file

`REVIEW_RULES.md` at the repo root, linked from AGENTS.md by one line (`Review rules and known non-issues: [REVIEW_RULES.md](REVIEW_RULES.md)`).

```markdown
# Review rules

Flag only with a concrete case (this input or situation leads to this wrong result). Leave what the Enforced table covers to its checks, and skip everything under Known non-issues.

1. <judgement rule>: <the failing case it prevents>.

## Enforced

| Rule | Enforced by |
|---|---|
| <rule> | <the type, lint rule, test or CI job, and the GATES.md command that runs it> |

## Known non-issues

### <short pattern name>

- Skip when: <conditions that must all hold>
- Do not skip when: <risk boundaries>
- Example signal: <phrases or code shapes that identify it>
- Why it is correct: <the line, guarantee or decision that makes it intended>
- Source: <PR or comment URL>
```

Create the file with this shape and add the AGENTS.md link when either is missing; when the file exists, keep its entries and add to them. If AGENTS.md still has a `## Code Review Rules` section, move its rules into the file and replace the section with the link line.

## Why here

Every reviewer reads this one file: `adversarial-review` loads it, and the review bots (Greptile, Bugbot) are pointed at it from their dashboards, so the repo carries no `.cursor/BUGBOT.md` or `.greptile/` rules. A bot rules file found in the repo moves into `REVIEW_RULES.md` and is deleted.

Implementers reach the file through AGENTS.md, so it stays short. A rule moves from the numbered list to Enforced when a check takes it over, and leaves Enforced when architecture makes the mistake impossible. A non-issue leaves the list when the code it describes is gone. When the file is long, prune before adding.
