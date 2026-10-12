# Worker brief

A worker can't ask you a question, so the brief is all it knows. Every spawn carries all nine fields. Fit the length to the unit: a one-command unit gets a paragraph that still names the goal, scope, verify command and report shape.

A field you can't fill means the unit isn't scoped yet. Rescope it before spawning.

```text
GOAL        One sentence: the outcome, written for someone with no access to this chat.
SCOPE       Worktree <path>, branch <branch>, base <sha>.
            May write: <paths>. Leave untouched: <paths, including CHECK scripts and tests other tickets own>.
CONTEXT     The ticket (file or link); the files to read first; upstream reports pasted in full.
ACCEPTANCE  One checkable line per criterion, from the ticket.
VERIFY      The ticket CHECK: `<command>` → `<expected>`.
            The cheapest check from GATES.md that covers the change. Known gotchas.
TIMEBOX     <minutes>. When it runs out: commit what works, report it as partial, and stop.
FORBIDDEN   Push, rebase, force-push, merge and PRs (commit on your branch only).
            Edits outside SCOPE (report them as follow-ups instead).
            Changes to the CHECK, or to tests the ticket doesn't own.
            The full readiness check (the parent runs it once on the integrated head).
            <unit-specific bans>
REPORT      The block below.
STANDING    <standing-orders.md, pasted verbatim>
```

Close every brief with these lines:

> Deliver the complete unit, with no placeholders, TODOs or deferred remainder. Commit on your branch once ACCEPTANCE holds and VERIFY passes. Where the ticket and the code disagree, keep to the GOAL and record the mismatch under DEVIATIONS.

## Report block

```text
STATUS      done | partial | blocked
BRANCH      <branch>   HEAD <sha>   TREE clean | dirty
RAN         every command you ran, each with its exit code and the last lines of output
DEVIATIONS  Expected / Found / Why, one block per mismatch with the ticket or plan
FOLLOW-UPS  problems you saw outside SCOPE and left alone
```

## Standing orders

`.context/delivery/<slug>/standing-orders.md`:

```text
STOP: <reason>          (only while new spawns are halted)
1. <one constraint per line>
2. ...
```

Paste the whole file into STANDING on every spawn, including fix rounds. Instructions that live only in earlier messages get lost between agents.

## Fix rounds

A fix round goes to a fresh agent with a consolidated brief:
- the original brief;
- the current standing orders;
- the failing command and its output;
- the prior report;
- SCOPE's base set to the failed candidate SHA on the same branch.
