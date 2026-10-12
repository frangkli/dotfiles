# The plan

The plan is the one thing the user approves. It carries the evidence an implementer needs and every decision the user owes, so that approving it is all that's left.

## Sections

In this order. Write `n/a: <reason>` for a section that doesn't apply.

1. **Recommendation and decisions.** At the top: one paragraph on what will ship and why this approach, then the decision batch (below).
2. **Goal and non-goals.** Non-goals name the adjacent work you'll leave alone.
3. **Done-predicate.** One statement the run ends on, which a command or an observation on the real surface can prove false. Under it, the acceptance criteria, one per line as `CHECK: <command or observation> → <expected result>`, where the command is one you could paste (naming the test file a new test will live in) and the observation names the surface and what is seen there. A check passes on exit 0 plus a result only success prints. An absence check gets a negative control: it must fail on a build that still has the thing.
4. **Current state.** The traced flow and callers, with `file:line`; what the change touches; the root cause when something is broken.
5. **Design.** System and data-model changes. The repo's conventions it follows; where the repo has none, the documented current practice for its language and libraries at the pinned versions; where an existing pattern is clearly worse than that practice, the better one and why. What it reuses (helpers, types, modules) and what it removes. Why this design has the fewest code paths and fixes the root cause.
6. **Failure paths.** For each that applies (concurrency, retries, idempotency, cancellation, recovery, partial failure): the behaviour, and the test that proves it.
7. **Observability.** In the repo's traces, logs and metrics: instrumentation for new entrypoints, with trace continuity across process and service boundaries; business outcomes recorded separately from transport success; metric labels with a bounded set of values; what is redacted (credentials, request bodies, raw errors). Name the query that will show it working in production.
8. **Phases.** The verification harness and a baseline first: which checks prove the change, and what they show before it. Then phases ordered riskiest unknown first, each one a testable end-to-end result with its automated check and its manual check. A phase is ticked only when its evidence exists. Mark which phases run in parallel, from the throughput checkpoint.
9. **Checks.** Which `GATES.md` commands run while iterating, when each unit is done, and at ship points.
10. **Rollout and recovery.** How the change reaches production (deploys on merge, or which steps), flags, configuration, migrations and their order, backfills. How to roll back, and which steps can't be undone.
11. **Delivery requirements.** Configuration, credentials, publication (every artifact the repo releases that the change affects) and spending. For each: done with tools you already have (say which MCP server, API or CLI you checked), or needs the user.
12. **Surfaces and production acceptance.** Every surface the change touches (end-user UI, agent or MCP, SDK, CLI, API, workers) and the acceptance test for each through the repo's `verify` skill: what it does and what result passes. Acceptance that stops short of the live surface (a fake backend, a staging copy, the artifact without real traffic) goes in the decision batch, with what it leaves unproven.
13. **Prototypes.** Each question, what ran, and the result.
14. **Review.** Lanes and their statuses, the findings and how the plan changed, the dismissed findings with reasons, and the reader-test questions.
15. **Rulings.** Every ruling made so far, in the [rulings.md](rulings.md) format, so the user can overturn any.
16. **Delivery record.** Empty at approval. Filled in place at ship points and at the end: decisions made after approval, evidence, remaining work.

## Decision batch

Each decision: the question, the options with what happens under each, and the recommended default with its reason. Number them so the user can answer "approve, with 3 as B". The batch always holds:

- **Merge:** *merge when green* (you merge once every gate passes and the pre-merge checks hold; deployment follows where the repo deploys on merge) or *wait* (you stop at a green PR). Recommend merge when green when every step can be undone and the `verify` skill can prove the change in production. Recommend wait when the change has a step that can't be undone: deleting data, a destructive migration, breaking a public contract, spending that can't be recovered.
- Every taste ruling worth the user's attention, and every challenge to the user's direction ([rulings.md](rulings.md)).
- Every manual operation, cost or credential that delivery needs from the user.

## Approval message

Sent in chat after the plan is published:

- The file path, and the plans hub link when the hub serves the repo.
- The recommendation in two or three sentences.
- The decisions, numbered, each with its default.
- What approval starts: build, review, PR, merge if decided, deployment and production acceptance, without further questions unless a reopen trigger fires.
