---
name: autopilot
description: Unattended runs that drive a spec's tickets to done under the harness's native goal, with a countable done-predicate. Use when asked to run, finish or autopilot a project, spec or ticket set while the user is away, or to resume or pause such a run.
---

# Autopilot

**You own the done-predicate, the ticket states and the rulings. `orchestrate` owns the units: briefs, worktrees, verification and integration.**

The native goal keeps the session working. This skill supplies the condition the goal judges, and decides what reaches the user.

**Run file:** `RUN.md` beside the tickets (in Linear, a project document). It holds the predicate, the standing orders, the contract inventory, the rulings and the progress log. Format: [run-file.md](run-file.md). Ticket conventions: [tickets.md](tickets.md).

## Steps

1. **Find the tickets.** The tickets live in repo markdown by default: the directory the spec or AGENTS.md names, or OpenSpec or Spec Kit when the repo uses one. They live in Linear only when the project tracks its work there. Read the spec, the tickets, AGENTS.md, `GATES.md` and the git state. Reuse every existing ticket as it is, and add a ticket only for a requirement no ticket covers. If there are no tickets yet, run `to-tickets` on the spec first. A ticket without a CHECK gets one drawn from `GATES.md` before the run starts. Done when every in-scope ticket is listed by id in the run file, and each has a CHECK.
2. **Contract inventory.** Re-read the spec. Give every requirement or constraint that could be silently dropped its own row: an id, the spec line, the ticket that owns it, and the CHECK that observes it (or a REVIEW line when no command can decide it, per [tickets.md](tickets.md)). Where a row has no owner or no observer, add an acceptance line and a CHECK to the owning ticket, or add a ticket. Done when every row names both.
3. **Done-predicate.** Write one countable predicate: "N/N tickets done, each with its CHECK passing on the integrated head; every inventory row observed; the full readiness check passing on the integrated head". It stays fixed for the whole run. N doesn't shrink, CHECK lines and tests stay as written, and blocked tickets count as not done. **Outcome over steps:** where the spec or the tickets declare a breakage window, the checks it names may stay red between the ticket that opens it and the one that closes it; the predicate needs everything green only at the end. Done when the predicate is in the run file with N and the exact commands.
4. **Set the goal** per [goal.md](goal.md). Done when the harness shows the goal active, or the user has the one line to paste, and the first `PREDICATE` line is printed.
5. **Drive.** Wake on worker events, with the fallback heartbeat, as `orchestrate`'s Long runs section describes; a worker stopped on a usage limit is left for T3 to resume. At every wake:
   - re-read these steps and the run file's standing orders;
   - hand the ready tickets (all blockers done) to `orchestrate`, passing the standing orders and the rulings so far;
   - move tickets on side effects only: `in-progress` when a worker spawns, `done` when the parent's verdict on the integrated head is `unit-verified` or better;
   - print the `PREDICATE` line with the check output behind every newly done ticket;
   - run the progress guard (step 7).

   Fix a mid-run discovery only when it blocks a ticket. File everything else as a backlog ticket outside the predicate.
6. **Rulings and escalation** per [escalation.md](escalation.md). The run stops to ask only for manual operations (credentials, billing, production, outreach), real product forks, and ambiguous spec lines. Each one becomes a visible `blocked` or `manual` ticket with the exact action or question, a recommended default, and the condition for resuming. Route around it and keep working the rest. Every other call is a ruling: decide, log it, continue.
7. **Progress guard.** Gate state is the set of ticket statuses plus which CHECKs pass. File edits that leave it unchanged aren't progress. Count heartbeats (under a native goal, the goal's turns), not worker events, which arrive many per wave; one while every unfinished worker waits on a usage limit or the owner doesn't count. When it hasn't changed across three heartbeats, pivot once: a different split, a sharper brief, or a new approach to the stuck ticket. If it is still unchanged three heartbeats later, stop the run as blocked and report why.
8. **Pause and pickup.** Pause when the user asks or the session must end. Finish or back out of the current step, and spawn nothing new. Commit the work as one `wip:` commit on the current branch (note a red tree in the body), and write the pickup note in the run file: where the run is, what is verified at which SHA, what was in flight, the next action, and any gotchas. Leave the branch unpushed. On pickup, read the run file and the tickets first, since they are the authoritative record. Rebuild live state from git (worktrees, branches, SHAs). Confirm each inherited `done` by re-running its CHECK on the current head, not by redoing the work. Continue from the next action.
   - **Phase handover:** when no native goal holds this session ([goal.md](goal.md)'s no-goal row), at each phase boundary let the wave drain, write the pickup note without the `wip:` commit, and continue in a fresh session per `orchestrate`'s Long runs. The new session picks up as above. Under a native goal, stay in the session.
   - **A usage limit isn't a pause:** T3 resumes this session at the reset, mid-step. Check which workers it resumed before acting.
9. **Close.** When the predicate holds, re-run every command it names on the integrated head and recount right before writing the report. When the spec asks for shipping, go on to `adversarial-review` and then `pr`.

## Report

- The predicate and the final count, with each command and its output.
- Tickets by status, the integrated head SHA, and any breakage window still open.
- **Attention**, written from the rulings log: the taste rulings and the default you took for each, rulings that cut against the spec's direction, and each blocked or manual ticket with the exact action it needs. "Nothing needs you" is a valid Attention section.
