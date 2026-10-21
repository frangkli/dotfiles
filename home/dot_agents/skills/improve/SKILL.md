---
name: improve
description: Review, verify and fix loop with a fixed round budget. Use to improve, clean up or harden a module, system or repo, to fix the findings of a review, or as the fix step of adversarial-review and pr.
---

# Improve

Fresh reviewers find defects, a fresh verifier confirms them and a fresh fixer fixes them, over one scope. A run has one full review round and one confirming round, and a third round only when the confirming round confirms a new critical or major finding. A low-risk, low-impact change gets no confirming review: the verifier alone checks its fixes. Either way, no unchecked fix counts as done.

## Inputs

- **Target:** the branch's change by default, or the paths you were given.
- **Scope:** path globs the fixer may touch. Default: the target's directories, wide enough to put tests next to the code.
- **Reviewer:** `adversarial-review`. When it hands you its review, that review was round 1 of this run, already verified and recorded in the state folder: continue from its `next.md` at step 4. Findings handed over from anywhere else (a PR's bots, a person, a maintenance pass with [lens.md](lens.md)) are round 1's candidates: write them as `round-1/handed.json`, build round 1's packet with `adversarial-review`'s packet command, pick risk and impact with its table, and start at step 3.
- **Contract:** what the change must achieve and must not break, when the caller has one. Fixes keep every requirement in it.
- **Base:** the commit to diff against.
- **State folder:** the run's `state/<ticket>/` when an orchestrator passes one, otherwise `$(git rev-parse --path-format=absolute --git-common-dir)/improve/<slug>/`. It lives outside the worktree, so an agent resumed in any worktree of the repo finds it. Layout, formats and the `ledger.py` commands: [ledger.md](ledger.md).

## Steps

1. **Baseline.** If the state folder holds an unfinished run ([ledger.md](ledger.md) says when), continue from its `next.md`, never from round 1. Otherwise, if a finished ledger ended `done` and its `head` is an ancestor of `HEAD` (`git merge-base --is-ancestor`), the change only grew since that run: round 1's base is that head. After a rebase, or a run that ended any other way, round 1 uses the target's base. Move the finished ledger aside, keeping its `decisions` and its refuted and deferred findings, and run `ledger.py init`. Commit the target's uncommitted in-scope changes as a `wip:` save point, so every round reviews a commit; running `improve` is the request to commit. Add the contract and the hashes of the untracked files outside the scope to the ledger.
2. **Review.** Every round calls `adversarial-review` in findings mode, unless it already ran round 1 itself. For round 1, pass the target's base; it picks the lanes from its risk and impact table. Later rounds call it with its base set to the last reviewed head, so the packet, `ocr` and every lane see only the fix diff, plus the round number and the ids the fixes claim to close. The lanes: one combined reviewer, plus the bug-pass lanes scoped to the same diff when it touches high-risk code, plus design-and-style when the run uses the lens. When round 1 picked no confirming round (low risk, low impact), skip the lanes and go to step 3 with no candidates.
3. **Verify.** `ledger.py candidates <state> <n>`, then one fresh verifier under [the verifier brief](../adversarial-review/verifier-brief.md) gets the round's packet, the lane results, the candidates and the closing ids. It confirms or refutes each candidate, checks each closing fix, and writes `verified-<n>.json`. Then `ledger.py apply <state> <n> <head>`. Read only the verifier's summary. This is the round's only verifier.
4. **Decide.**
   - No critical or major open: go to step 7.
   - A confirmed finding whose only fix drops or narrows a contract requirement: escalate it, and send the rest on.
   - After round 1: fix.
   - After the confirming round: a new critical or major, or a fix that didn't hold, means fix, then the third and last round. Any other critical or major still open stops the run.
   - After the third round: anything critical or major still open stops the run.
5. **Fix.** One fresh fixer gets the verified records under [fixer-brief.md](fixer-brief.md). It never re-identifies a problem, may try more than one fix, and commits each fix as a local `fixup!` save point; nothing is pushed. Record each rejection and deferral with `ledger.py verdict`, and write the ids it claims fixed into `next.md` as the next round's closing list.
6. **Scope guard.** Compare `git diff --name-only <base>` and the untracked files against the scope globs, and re-hash the guarded files. A change outside the scope halts the run; leave it in place and report it. Otherwise back to step 2.
7. **Finish.** Spot-check one pinned fix: in a scratch worktree under the state folder's `scratch/`, put that file back to its base version and confirm its test fails. Remove any comment or name that narrates the loop. Fold the save points with `git -c sequence.editor=: rebase --interactive --autosquash <base>`, and give a remaining `wip:` commit a real message (`fix: …`, or the repo's convention), drafted by the `writer` agent when one is defined. Run `ledger.py outcome`, remove the scratch worktrees, and report.

After each step, rewrite `next.md`: the step just finished, the next one, the last reviewed head, the closing ids, and any lane still running. Run every long command under `timeout`. The same check failing twice with the same error halts the run as blocked, with both attempts.

Run the repo's cheapest relevant checks while fixing, and its full readiness check once at the end, as `GATES.md` describes.

## When to stop

| Outcome | When | Report |
|---|---|---|
| **Done** | A review round left no critical or major open | Rounds, open minor findings, state folder path |
| **Escalated: still open** | A critical or major is open when step 4 stops the run, including one the fixer rejected as outside the scope | Each finding by title and id, and the decision that's needed |
| **Escalated: impossible** | The fixer says a finding is real but blocked by a documented guarantee | The guarantee and the finding |
| **Escalated: contract** | The only fix for a finding drops or narrows a contract requirement | The requirement, the finding, and the options |
| **Escalated: design** | The fixer rejects a finding as "needs a decision": its root cause is a design problem a local fix would only route around | The finding, the design problem, and the fixer's options with a recommended default |
| **Halted** | A change outside the scope, a reviewer, verifier or fixer that died or couldn't run (including a usage limit), or a check that failed twice with the same error | What happened, from the ledger; nothing reverted. Running `improve` again continues from `next.md` once the cause is cleared |

An escalation is never reported as success. To continue after one, start a fresh run with the user's ruling added to the new ledger's `decisions` as binding.

## Report

Follow [the review report format](../adversarial-review/report.md), including its writing rules: outcome first, then what was fixed (each with its pin), what's left and why, and decisions that need the user. Name every finding by its title, with its id beside it.
