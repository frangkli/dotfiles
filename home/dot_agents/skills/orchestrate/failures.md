# Liveness and failures

**Progress is side effects:** save points and commits on the unit's branch, `next.md` in its state folder, and a report. Transcript activity isn't progress.

**Check without resuming.** Read the worktree (`git -C <worktree> log -1`, `git -C <worktree> status --short`), the unit's `next.md` and the harness's task status. Sending a message to an idle agent restarts it, so it is a new spawn in disguise.

## Stuck workers

Each way a worker can stall is caught where it happens, with no timer:
- **Finished, failed, stopped on a usage limit, or waiting for input:** the harness wakes you ([SKILL.md](SKILL.md), Long runs).
- **A hung command:** every long command in a brief runs under `timeout`, so none waits forever.
- **Going in circles:** a worker whose same check fails twice with the same error stops and reports blocked, which is a finish.
- **A process that died with no event:** the only case for the fallback heartbeat. A task that is gone, or `interrupted` or `failed` without a usage limit and no event reached you, counts as a harness drop. Quiet is not dead: a task that is `running` or `waiting` is never a drop, however long since its last activity.

## Usage limits

A worker that stopped on a usage limit isn't failed, though `task_status` shows it as `failed`: its summary, or its thread's last error (`t3_thread_read`), names the usage limit. T3 Code resumes it at the reset with its context intact (`autoResumeLimitedThreads`), unless its thread is archived or has a pending request, so never archive it and answer any pending request. Never replace, interrupt or discard it, and never start a second agent on its unit. Replacing one duplicates its work, and the two agents' edits collide in one worktree. In one past run, replacements started a minute after T3 resumed the originals, and a fix was lost.

A subagent that runs inside your own session is resumed only with you. If one is gone after you resume, replace it from its state folder and `next.md`.

## Retry by failure mode

| What happened | Retry |
|---|---|
| Usage limit (`failed`, with the limit in its summary) | None: T3 resumes it |
| Hit a context or memory cap | Split the unit and respawn with the smaller scope |
| Network or harness drop, `failed` or `interrupted` for any other reason | Respawn with the same brief; it continues from the state folder and `next.md` |
| Finished without its report | Respawn with the same brief; it continues from the state folder and `next.md` |
| Blocked on the same failure twice, or a tool error | Respawn on a different model, or with a brief that names the mistake |
| Verdict `failed` | A fix round ([verify.md](verify.md)) |
| Unknown | Retry once |

Fix rounds and replacements go to a fresh agent with the consolidated brief from [brief.md](brief.md). Message an earlier agent only when the work needs state that lives only in that agent, such as a running process.

After two retries, abandon the unit. Mark it `abandoned: <reason>` in `units.md`, and as blocked in the ticket store when a caller owns the tickets. Then replan the units that depend on it.

## Stopping everything

- **Garbage across units** (a wrong upstream contract, a broken CHECK, a dead environment): write a `STOP:` line at the top of the standing orders, let the agents in flight finish, fix the cause, then clear the line.
- **Your own tools keep failing:** after a few consecutive tool aborts, write the handover to `units.md` (Long runs) and end the run.
