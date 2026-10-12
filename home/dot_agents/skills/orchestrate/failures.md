# Liveness and failures

**Progress is side effects:** new commits on the unit's branch, and a report. Transcript activity isn't progress.

**Check without resuming.** Read the worktree (`git -C <worktree> log -1`, `git -C <worktree> status --short`) and the harness's task status. A resume restarts an idle agent, so it is a new spawn in disguise.

**Stuck** means past the TIMEBOX with no new commit. Stop the agent, then respawn it fresh with the consolidated brief from [brief.md](brief.md).

**Fresh agents, not resumes.** Fix rounds and follow-ups go to a new agent with the consolidated brief. Resume an earlier agent only when the work needs state that lives only in that agent, such as an uncommitted change or a running process.

## Retry by failure mode

| What happened | Retry |
|---|---|
| Hit a context, time or memory cap | Split the unit and respawn with the smaller scope |
| Network or harness drop | Respawn as is |
| Tool error, or the same mistake twice | Respawn on a different model, or with a brief that names the mistake |
| Verdict `failed` | A fix round ([verify.md](verify.md)) |
| Unknown | Retry once |

After two retries, abandon the unit. Mark it `abandoned: <reason>` in `units.md`, and as blocked in the ticket store when a caller owns the tickets. Then replan the units that depend on it.

## Stopping everything

- **Garbage across units** (a wrong upstream contract, a broken CHECK, a dead environment): write a `STOP:` line at the top of the standing orders, let the agents in flight finish, fix the cause, then clear the line.
- **Your own tools keep failing:** after a few consecutive tool aborts, write a handoff at the top of `units.md` (what is done, where it lives, the command to resume) and end the run.
