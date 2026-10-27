---
name: orchestrate
description: Fan-out delivery, where the root agent splits implementation into bounded units, runs each in its own worktree under a fixed brief, re-verifies every candidate and integrates. Use when asked to fan out, parallelize or delegate implementation across agents or worktrees, or when autopilot or deliver reaches its build step.
---

# Orchestrate

**You own scope, briefs, verdicts and integration. Each worker owns one unit in its own worktree and hands back a candidate commit; you decide what lands.**

One agent is a valid choice. When one agent could finish inside the budget, or the units would write the same files or contract, do the work yourself without fan-out.

**Run state** lives in `.context/delivery/<slug>/` (git-ignored): `standing-orders.md`, `units.md`, `decisions.md`, and each unit's `briefs/<unit>.md` and `reports/<unit>.md`, saved as they are written or returned, so a fresh session can resume the run. You are their only writer. Each unit also gets a state folder, `state/<unit>/`, passed by absolute path: its worker writes `next.md` there, and `improve` gets the `improve/` subfolder for its own ([../improve/ledger.md](../improve/ledger.md)). Formats: [brief.md](brief.md) and [verify.md](verify.md).

## Steps

1. **Frame.** Read the request, AGENTS.md, `GATES.md`, the tickets, the branch, its dirty state and the existing worktrees. Make one unit per ticket, or split along seams so that no two units write the same file or shared contract. Give each unit an id, its ticket, its CHECK, the paths it may write, and what it depends on. Write the predicate ("all N units integrated at `unit-verified` or better, and the full readiness check passing on the integrated head") and the budget (the goal's token budget, the run file's Budget line, a time the user gave, or the caller's). Done when `units.md` lists every unit with those fields, under the predicate and budget.
   - Many edits of the same shape (a sweep): do the first by hand, write the codemod or script, prove it reproduces that unit, then run it instead of fanning out hand edits.
2. **Standing orders.** In `standing-orders.md`, write numbered constraints that hold for every unit: from the user, from the caller's rulings, and the AGENTS.md rules a worker would miss. Whenever you catch yourself restating an instruction, append it as a line first. A `STOP:` line at the top halts new spawns until you clear it. Done when the file exists.
3. **Brief.** Fill every section of [brief.md](brief.md), written per the `writing-for-agents` skill, for each ready unit (its dependencies already integrated). If a section can't be filled, the unit isn't scoped yet: rescope it, merge it into another unit, or do it yourself. A unit with high-impact interfaces gets its types settled first, as [brief.md](brief.md) describes. Give dependent units each upstream unit's delivered interfaces and head SHA, not its whole report. Done when every ready unit's brief passes `scripts/brief_check.py`; spawn nothing that fails it.
4. **Worktrees.** Give each writing unit its own branch and worktree, cut from its base: the integration head with all of its dependencies integrated. Use the harness's managed worktrees when it has them; otherwise use `git worktree add -b <branch> <path> <base>` in the location AGENTS.md names, or in a sibling directory. Prepare the worktree as AGENTS.md says, but only as far as the unit's VERIFY needs. Done when each worktree is clean at its recorded base SHA.
5. **Pilot.** Spawn one unit, the riskiest or the most typical, as a fresh subagent whose whole prompt is its brief. Take it through steps 7 and 8. Fix the brief template, the VERIFY recipe or the unit size from what the pilot shows. Done when the pilot is integrated, or its failure has changed the plan.
6. **Launch the wave.** Spawn every other ready unit in one message, then wait for their events (Long runs). Copy each worker's reported decisions into `decisions.md`, or the caller's log. When a unit is integrated, brief and spawn the units it unblocked. Once about 70% of the budget is spent, spawn nothing new: finish the units in flight and integrate what verifies. Judge workers while they run by their side effects, per [failures.md](failures.md). Done when every unit is integrated, abandoned with a reason, or left unstarted because of the budget.
7. **Verify each candidate** per [verify.md](verify.md). Re-run the ticket CHECK yourself on the candidate SHA, and record a verdict on the ladder, keyed to that SHA. A failed candidate goes to a fix round with a fresh agent. Done when the candidate has a verdict with the evidence beside it.
8. **Integrate** verified candidates in dependency order onto the integration branch, by merge or cherry-pick as the repo does it. After each one, run the cheapest check that covers the packages it touched. If integration conflicts or that check fails, the unit goes back for a fix round. Done when the integration head contains the candidate and the check passes.
9. **Integration gates, once.** On the integrated head, run what no single unit owns: the checks that cross unit boundaries (interfaces, end-to-end, regression) and the full readiness check from `GATES.md`. Workers ran only their focused checks; this is the one full run. A failure becomes a fix unit with its own brief. Done when every gate passes on the final head, with its output shown.
10. **Close.** Account for every agent you spawned as integrated, respawned, abandoned or absorbed into another unit. Remove the worktrees whose commits are integrated or kept on a branch, and the heartbeat. Report.

## Report

- The predicate and the count against it.
- One row per unit: ticket, candidate SHA, verdict, and whether it was integrated (and why not, if it wasn't).
- The integrated head SHA, and each gate command with its result.
- Abandoned and unstarted units, with their reasons.
- Decisions that need the user, each with a recommended default, or "nothing needs you".

Delegation covers building and integrating on the working branch. Pushing, opening PRs, merging to the main branch and deploying need the caller's or the user's authorization. When the caller asks, go on to `adversarial-review` and then `pr`.

## Long runs

- **Waking:** wake when a worker's task finishes, fails, stops on a usage limit or asks for input; the harness notifies you of each. A heartbeat every 60 minutes is only the fallback for a worker that died with no event ([failures.md](failures.md)). Disable it while the run waits only on the owner, and enable it again when they answer.
- **Usage limits:** a worker stopped on a usage limit is left alone; T3 Code resumes it at the reset ([failures.md](failures.md)). When you are resumed after a limit yourself, first check which workers T3 resumed, from their task status and their worktrees, and act only on the rest.
- **A fresh session per phase:** at a wave or phase boundary with no worker task in flight (task status and wake-ups belong to the thread that spawned the tasks, so let the wave drain first; a worker stopped on a usage limit is still in flight until it finishes after the reset), record the phase's end with `date -Iseconds`, write the handover at the top of `units.md` (what is integrated at which SHA, the phase's cost, the next action, gotchas), start a fresh session from it, move the heartbeat there and end this one. Context grows with every wake otherwise, and each wake rereads all of it. A native goal keeps its session running until the predicate holds, so under one, stay in this session and rely on compaction.
- **Phase cost:** record each phase's start in `units.md`, and put its cost in the handover: `python3 ~/.agents/skills/orchestrate/scripts/phase_cost.py <project> <start> <end>` sums the tokens and list-price dollars of every session in the project over that window, subagents and T3 worker threads included. On an API-key instance the dollars are real spend; on a subscription they are a comparison figure.
- **Recovery:** at every wake, in a fresh session, after compaction and after a changed request, rebuild the state from the run state files, `git worktree list` and the branch heads, and trust that over memory or summaries. Before using anything from an agent that returns late after you replaced it, check it against the current `units.md`.
- **Mechanical work stays off the main model:** waits for CI or a PR are background commands or T3's `watch_pull_request`. Have the `ci-reader` agent, when it's defined, read CI logs and run status. Judgement stays with you.

## Harness mechanics

| Action | Claude Code | Codex |
|---|---|---|
| Spawn a worker | Agent tool with the brief as the prompt, in the background; several calls in one message launch a wave | `spawn_agent` per unit, then `wait_agent` |
| Watch progress | The worktree's commits, and task notifications | The worktree's commits, and `wait_agent` results |
| Stop a stuck worker | Stop the background task | `close_agent` |

Under T3 Code, with either agent:
- **Spawn:** `delegate_task` with the brief as the task and isolation `shared`; the brief's SCOPE sends the worker to its own worktree. Keep each returned task id in `units.md`. Its finish, failure, usage limit and need for input wake you.
- **Watch:** `task_status`; stop with `task_cancel`. Both reach only tasks this thread created.
- **Heartbeat:** `schedule_task` with a 60-minute interval, bound to this thread; `update_scheduled_task` disables and enables it.
- **Fresh session:** `t3_thread_launch` on the run's checkout (`existing_worktree` with its `worktreePath` and `branch`, or `root` for the main checkout), with a message naming the skill and the run state folder. The new thread finds the old heartbeat with `list_scheduled_tasks`, deletes it and schedules its own.

Outside T3, a fresh session is a new session started on the run state folder, by the user or the harness's scheduler.

Messaging a worker (`SendMessage`, `send_input`) restarts it. Do it only to deliver work that needs state held in that agent, as [failures.md](failures.md) describes. T3's resume after a usage limit is different: the worker continues where it stopped.
