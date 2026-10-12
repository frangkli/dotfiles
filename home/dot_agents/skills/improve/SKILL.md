---
name: improve
description: Review-and-fix loop that runs until findings converge. Use to improve, clean up or harden a module, system or repo, to fix the findings of a review, or as the fix step of adversarial-review and pr.
---

# Improve

A loop of fresh reviewers and fixers over one scope. A findings ledger keeps every verdict, and the loop stops on convergence, not on a round count. It ends only after a review, so no unreviewed fix ever counts as done.

## Inputs

- **Target:** the branch's change by default, or the paths you were given.
- **Scope:** path globs the fixer may touch. Default: the target's directories, wide enough to put tests next to the code.
- **Reviewer:** `adversarial-review` in findings mode by default, or the findings you were handed (from a review, a PR's bots, or a maintenance pass with [lens.md](lens.md)). Handed findings count as the first review; every later review is still `adversarial-review` in findings mode, which never calls `improve` back.
- **Contract:** what the change must achieve and must not break, when the caller has one. Fixes keep every requirement in it.
- **Base:** the commit to diff against.

## Steps

1. **Baseline.** Record the base and head commits. Hash the untracked files outside the scope and store the hashes in the ledger's `guarded` map. Create the ledger at `.context/improve/<slug>/ledger.json`, or load it if one exists: that's how a run resumes. Format and merge rules: [ledger.md](ledger.md).
2. **Review.** Run the whole reviewer every round, even when the last fix touched one file: with `adversarial-review`, that's every code-change lane it lists, `ocr` included, each a fresh subagent. Each reviewer gets the target, the scope and the whole ledger. It reports every defect with a severity, confirms which earlier fixes still hold by reading the current code, reuses a known finding's id, re-files a rejected finding only with new evidence, and writes nothing.
3. **Merge** the findings into the ledger.
4. **Triage.** Verify each new critical or major finding: trace it, or run the cheap check. Reject the false ones with the reason, which the ledger keeps. Structural suggestions that don't fix a concrete defect go in as minor, so the loop doesn't widen its own scope. A finding whose only fix drops or narrows a contract requirement isn't sent to the fixer: escalate it.
5. **Stop check.** If no critical or major finding is open, go to step 9. Otherwise check the stop table below.
6. **Fix.** A fresh fixer gets only the open critical and major findings, under [fixer-brief.md](fixer-brief.md).
7. **Scope guard.** Compare `git diff --name-only <base>` and the untracked files against the scope globs, and re-hash the guarded untracked files. Any change outside the scope halts the run. Leave it in place and report it; the user decides whether to revert.
8. **Back to step 2.**
9. **Finish.** Spot-check one pinned fix: in a scratch worktree, put that file back to its base version and confirm its test fails. Remove any comment or name that narrates the loop. Commit once (`fix: …`, or the repo's convention): running `improve` is the request to commit, so don't wait to be asked. Report.

Run the repo's cheapest relevant checks while fixing, and its full readiness check once at the end, as `GATES.md` describes.

## When to stop

| Outcome | When | Report |
|---|---|---|
| **Converged** | The last review left no critical or major finding open | Rounds, remaining minor findings, ledger path |
| **Escalated: not converging** | The open critical and major count didn't fall across three reviews in a row | The finding ids, and the design decision that's needed |
| **Escalated: recurring** | One finding stayed open through three reviews in a row | Same |
| **Escalated: relocated** | One finding was marked fixed in two different rounds | Same |
| **Escalated: impossible** | The fixer says a finding is real but blocked by a documented guarantee | The guarantee and the finding |
| **Escalated: contract** | The only fix for a finding drops or narrows a contract requirement | The requirement, the finding, and the options |
| **Escalated: design** | The fixer rejects a finding as "needs a decision": its root cause is a design problem a local fix would only route around | The finding, the design problem, and the fixer's options with a recommended default |
| **Escalated: unstable reviewer** | Reviews exceed twice the first review's critical-and-major count plus three, or that count alternates up and down across four reviews | The pattern: the reviewer keeps producing fresh findings rather than the code getting worse |
| **Halted** | A change outside the scope, or a reviewer or fixer that died or couldn't run (including a usage limit) | What happened, from the ledger; nothing reverted |

An escalation is never reported as success. To continue after one, start a fresh run with the user's ruling recorded in the ledger as binding.

## Report

Follow [the review report format](../adversarial-review/report.md), including its writing rules: outcome first, then what was fixed (each with its pin), what's left and why, and decisions that need the user.
