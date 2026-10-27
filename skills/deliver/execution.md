# Build, integrate and review, ship

Steps 7–9, after the user approves the plan. Work within the approved scope; the reopen triggers are in [rulings.md](rulings.md).

## 7. Build

- First, commit the approved plan on its own (`docs: add plan for <slug>` or the repo's convention), before any implementation commit, so the build starts from a recorded plan.
- If the plan has one phase and the harness has a native goal mechanism, set the goal from the done-predicate. Print each check's output in the transcript, since the goal's judge reads only the transcript. With more than one phase, set no goal, and hand over to a fresh session at each phase boundary per `orchestrate`'s Long runs.
- Hand bounded units (research, implementation, tests, independent review) to subagents through `orchestrate`: one brief and one worktree per unit, a pilot unit before fan-out, phases in the plan's order. Do a unit yourself when briefing it would take longer than doing it.
- Write code and its tests together, following the design section's conventions. Reuse the repo's helpers, types and modules before adding new ones.
- After the code works, re-read the diff against the language skill's `references/review.md` (for TypeScript, `typescript/references/review.md`, plus `references/effect-review.md` in Effect code) and fix what it flags.
- Prove each failure path the plan lists with a test that drives it: concurrent calls, a retried request, a cancelled operation, a crash mid-way and the recovery.
- Prove the observability through the repo's test seams: spans parented across the boundaries the plan names, outcomes recorded, label values bounded, secrets and bodies absent from what's exported.
- Run anything that touches shared state (databases, queues, ports) in the repo's isolated local environments.
- When a check fails, read the failure and reproduce it before retrying, then fix the cause. Checks keep their current strength: an expected value changes only when the plan changed that behaviour, and the commit says so.
- Fix mid-run discoveries only when they block the done-predicate. Log the rest as remaining work.

Done when every phase's CHECKs pass on the integrated head with their output shown, and each phase is ticked in the log with its evidence.

## 8. Integrate and review

1. Fetch trunk, rebase, and re-run the checks covering anything that moved.
2. Run `adversarial-review` on the change: base is the merge base with trunk, head is `HEAD`, and the contract is the approved plan. Its lanes include the review tools the repo has configured, with their coverage inspected. It hands verified findings to `improve`, which fixes them in its fixed rounds.
3. Record refuted findings with their evidence in the log. If `improve` escalates, treat it as a ruling or, when it meets a reopen trigger, as a decision for the user.
4. Run the full readiness check once on the head that `improve` left.

Done when `improve` reports done on the current head and the full readiness check passed on that same head.

## 9. Ship

- Fill the plan's delivery record (decisions after approval, evidence, remaining work) and commit it with the change.
- Ship with `pr`: phased commits, a cover-note body with real evidence, then the babysit (conflicts, then threads, then CI, batched into one push) until every required check is green on the head SHA, the review bots the repo has configured meet their bar on that head, and every thread is resolved. A change made for a reviewer fixes a verified problem; answer the rest with evidence. Missing, partial or stale review evidence counts as unknown.
- Other agents ship to the same trunk. Refresh trunk at each integration point; after a rebase, re-run the checks for what moved and push with `--force-with-lease`.

Done when `pr` reports green on the head SHA, the bots' bar met on that head, and no open threads. A PR with no checks reported is not green.
