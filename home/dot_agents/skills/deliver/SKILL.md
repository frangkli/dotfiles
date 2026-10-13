---
name: deliver
description: Deliver a feature end to end. One reviewed HTML plan with batched decisions for approval, then autonomous build, review, PR, merge and production verification.
disable-model-invocation: true
---

# Deliver

Take the work agreed in this thread, or the request passed with this skill, from idea to verified in production with one checkpoint: the user's approval of a reviewed plan. Before approval you ground, plan, prototype and review. After approval you build, review, ship, merge if the plan allows it, and verify on the real surfaces without asking again.

**You own the plan, the rulings and the final verdict.** Subagents research, write code and review it.

**Working log.** From step 1, keep `.context/deliver/<slug>/log.md`: dial settings, the todo list, every ruling (format in [rulings.md](rulings.md)), the evidence for each check (command and result), and remaining work. After compaction or an interruption, resume from the log and the live git state.

**Checks in proportion.** `GATES.md` lists the repo's check commands, what each covers and how long it takes. While iterating, run the cheapest command that covers the change; when a unit is done, check the packages it touched; run the full readiness check only at ship points: once on the integrated head, before opening or updating the PR, and before merge. Prototypes get a smoke check only.

**Questions.** Classify every question before asking it ([rulings.md](rulings.md)). If running something answers it, run it. Before approval, the user's questions go into the plan's decision batch. After approval, reopen approval only for the triggers in rulings.md; everything else is a logged ruling.

## Steps

### 1. First reply

After a first read of the request and the repo layout, reply with:

- **Dials.** One line each, with your setting. The default for this skill is the middle setting:
  - Direction: taken as given; `council` only when it's open (several viable approaches, or the request may be the wrong problem). Heavier work turns it on; lighter work never does.
  - Shaping: a reviewed HTML plan (goals, non-goals, acceptance, reuse or remove, rollout).
  - Checkpoints: one, plan approval with batched decisions.
  - Unknowns: prototypes before the plan review.
  - Tests: code and tests land together.
  - Review: `adversarial-review` on the plan and on the code.
  - Merge: decided in the plan's decision batch.
  - After merge: deployment and production acceptance on every affected surface.

  If the work is lighter (a bug fix, a one-file change) or heavier (a new product, several PRs of shaping), say so, adjust the dials, and continue. The user can override any setting.
- **Throughput checkpoint.** Four lines: blocking first steps, independent workstreams, shared mutable state, smallest safe decomposition. Write `n/a: <reason>` for one that doesn't apply.

Copy steps 1–12 into the todo list verbatim. A step you skip stays listed as `skip: <reason>`.

Done when the reply is sent and the todo list and log exist.

### 2. Ground

- Read AGENTS.md, `GATES.md`, the repo's `verify` skill, decisions or ADRs on the area, and existing plans on the topic.
- Inspect the current state: branch, uncommitted changes, other worktrees. Leave unrelated work as you found it.
- Fetch and rebase onto the fresh trunk. Resolve conflicts by intent: neither the old plan nor trunk's code is right by default; judge both against the intended outcome, compatibility and simplicity, and revisit the design if trunk moved under it.
- Trace the affected flow end to end, with its callers. List the existing primitives the change can reuse and the code it could remove.
- Find the delivery facts: how the repo deploys (on merge or by hand), what it publishes, its observability, its configured review tools and bots, its isolated local environments, its secret runner (`fnox exec -- <command>` where configured), and which surfaces the change touches. Where `GATES.md` or a `verify` skill is missing, use the closest equivalent (CI config, package scripts, the surface's docs) and log the gap.

Done when the log names the entry points and callers (`file:line`), the check that covers each, the deploy path, and every surface the change touches.

### 3. Plan

When the Direction dial is set to council, run `council` first: its recommendation becomes the plan's approach, and each of its clashes becomes a decision in the batch. Draft the plan as [plan.md](plan.md) describes. Classify each open question as you meet it.

Done when every plan section is filled or marked `n/a: <reason>`, the done-predicate can fail, and each open question is listed as observable (step 4), a decision, or a ruling.

### 4. Prototype the open questions

For each observable question, run the smallest throwaway experiment that answers it: a script, a scratch branch, a query against a local or development environment. Record the question, what ran and the result in the plan. Only the answer carries into the change.

Done when no open question remains that running something could answer.

### 5. Review the plan

Run `adversarial-review` on the plan file, with the goals, non-goals and done-predicate as its contract. Ask its lanes to cover problem fit, bugs, regressions, security, operational burden and overengineering. Revise the plan for every Act on finding; turn each Consider finding into a plan change, a decision or a logged ruling; record the dismissed ones with their reasons in the plan's review section. Then run a reader test: give the plan alone to a fresh subagent, collect the questions it would ask, and answer them in the plan.

Done when every finding has a disposition in the plan and every reader-test question is answered there.

### 6. Publish and stop

Render the plan with `visual-doc`; it decides where the file goes (the repo's `docs/plans/`) and checks the page on the docs hub. Send the approval message described in [plan.md](plan.md).

Done when the plan page is saved in `docs/plans/` and rendered cleanly, and the approval message is sent. **End the turn here.** Only explicit approval starts step 7. A question, comment or changed decision means revise the plan in place, re-review what changed materially, and send the approval message again.

### 7–9. Build, integrate and review, ship

After approval, follow [execution.md](execution.md): build through `orchestrate`, run `improve` through `adversarial-review` on the integrated head, then ship with `pr`.

Done when `pr` reports every required check green on the head SHA, the configured review bots' bar met on that head, and no open threads.

### 10–11. Merge, deploy, accept in production

Follow [landing.md](landing.md). Merge only if the plan's merge decision says merge when green; otherwise run the pre-merge checks and stop at the green PR.

Done when the change is merged at an independently verified head, its deployment, configuration and publication are proven, and the `verify` skill has passed on every affected surface; or, when the decision was to wait, when the pre-merge checks are reported.

### 12. Report

Write the final report as [finish.md](finish.md) describes, and fold the log's decisions, evidence and remaining work into the plan's delivery record, committed with the work.

Done when every status in the report has its evidence and the report ends with an Attention section and the decisions that need the user, or "nothing needs you".
