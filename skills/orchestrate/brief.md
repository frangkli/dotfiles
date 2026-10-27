# Worker brief

A worker can't ask you a question, so the brief is all it knows. Every spawn, fix rounds included, carries every section below with something in it; write "none" with the reason where a section doesn't apply. Fit the length to the unit: a one-command unit gets a line per section.

A section you can't fill means the unit isn't scoped yet: rescope it, merge it into another unit, or do it yourself. Before every spawn, run `python3 ~/.agents/skills/orchestrate/scripts/brief_check.py <absolute path of the brief>`. It fails on a missing or empty section, a leftover `<placeholder>`, or missing closing lines; never spawn on a failure. It reads the labels below, upper case at the start of a line, and treats anything inside a code fence after the first label as quoted, so paste reports in a fence.

```text
GOAL          One sentence: the outcome, written for someone with no access to this chat.
CONTEXT       The ticket (file or link) and the files to read first. From upstream units, only the
              interfaces this unit depends on and the head SHA they landed at, not their whole reports.
SCOPE         Worktree <absolute path>: cd there first, and run git with `-C <worktree>`.
              Branch <branch>, base <sha>. State folder <absolute path>; `improve` gets its `improve/` subfolder.
              May write: <paths>.
OUT OF SCOPE  Paths and behaviour to leave alone, including CHECK scripts and tests other tickets own.
INTERFACES    The exact types, signatures, schemas or formats this unit delivers, or "none: <why>".
ACCEPTANCE    Numbered pass/fail criteria from the ticket. Each test names what it protects and the
              change that would make it fail.
VERIFY        The ticket CHECK: `<command>` → `<expected>`, plus the cheapest check from GATES.md
              that covers the change. Each new test fails before the change. Known gotchas.
EXIT          The checkable predicate that means done. Never relax it; report blocked instead.
FORBIDDEN     Push, merge, force-push and PRs; you integrate. Rebasing anything but your own save points.
              Edits outside SCOPE (report them as follow-ups). Changing a test, snapshot or threshold
              without reporting it first. The full readiness check (you run it once on the integrated head).
              <unit-specific bans>
DECISIONS     Reversible calls: decide, and list each under DECISIONS in the report. User-visible or
              hard to undo: park it there with the options and a default, and keep working around it.
PROGRESS      After each step, rewrite `next.md` in the state folder (step done, next step, head SHA),
              and commit `wip:` or `fixup!` save points on your branch, never pushed. A resumed or
              replacement agent continues from them.
REPORT        The block below.
STANDING      <standing-orders.md, pasted verbatim>
```

Close every brief with these lines:

> Deliver the complete unit, with no placeholders, TODOs or deferred remainder. Every long command runs under `timeout`; the same check failing twice with the same error means stop and report blocked with both attempts. Fold your save points into real commits once EXIT holds. Where the ticket and the code disagree, keep to the GOAL and record the mismatch under DEVIATIONS.

## Report block

```text
STATUS      done | blocked
BRANCH      <branch>   HEAD <sha>   TREE clean | dirty
RAN         every command you ran, each with its exit code and the observed result
DEVIATIONS  Expected / Found / Why, one block per mismatch with the ticket or plan
DECISIONS   each call you made, and each parked one with its options and default
UNCHECKED   any ACCEPTANCE or VERIFY item you couldn't check, and why
FOLLOW-UPS  problems you saw outside SCOPE and left alone
```

## Interfaces with high impact

A public API, a contract other units build on, or a schema is costly to change later. Before spawning its unit, write the exact types into INTERFACES, have them design-reviewed, and show them to the owner in the decision format. Under autopilot that is a parked decision with the types as the default: the unit and those that depend on it wait for the owner, and the rest carry on.

## Standing orders

`.context/delivery/<slug>/standing-orders.md`:

```text
STOP: <reason>          (only while new spawns are halted)
1. <one constraint per line>
2. ...
```

Paste the whole file into STANDING on every spawn, including fix rounds. Instructions that live only in earlier messages get lost between agents.

## Fix rounds

A fix round goes to a fresh agent with a consolidated brief, checked like any other:
- the original brief;
- the current standing orders;
- the failing command and its output;
- the prior report;
- SCOPE's base set to the failed candidate SHA on the same branch, with the same state folder, whose `next.md` you rewrite to name the fix as the next step.
