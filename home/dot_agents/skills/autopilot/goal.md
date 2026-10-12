# Setting the goal

The goal's objective is one line under 4,000 characters, made of four parts joined with "and": the end state, the checks with their output shown, what stays untouched, and when to stop. Details live in the run file, which the objective names. Instructions for this session only (a dry start, a pause) stay out of the objective, which outlives the session.

```text
Every ticket listed in <run file> is done: its CHECK passes on the integrated head of <branch> and `<full readiness command>` exits 0 there. Each turn, print `PREDICATE <done>/<N> done, <blocked> blocked` with the output of the checks behind newly done tickets, and before stopping run every CHECK and the readiness command and print their output. Keep CHECK lines, checks and tests as written; blocked tickets count as not done. If only blocked tickets remain, or gate state is unchanged after one pivot, stop and report the blockers.
```

Claude Code's goal is judged by a separate model that reads only the transcript and runs nothing, so a check counts only when its output is printed. Codex judges with the same agent, but print the output anyway, so the run log and the report can cite it.

## Harness mechanics

| Harness | Set | End |
|---|---|---|
| Claude Code | The user types `/goal <objective>`. Without a user present, propose it with the goal tool (ProposeGoal) for one-key approval | `/goal clear`, or the judge finds the condition met |
| Codex | `create_goal` with the objective, plus `token_budget` when the user gave a budget (`orchestrate` stops spawning at about 70% of it) | `update_goal` with `complete` when the predicate holds, or `blocked` once the stop clause holds (not on the first sight of a blocker) |
| No goal feature | Use the predicate as the loop condition, and resume from the run file on each scheduled wake | When the predicate holds or the stop clause fires |

If the harness can't set the goal from this session, give the user the one line to paste, and start working toward the predicate meanwhile.
