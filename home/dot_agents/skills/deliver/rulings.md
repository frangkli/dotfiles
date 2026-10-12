# Questions and rulings

## Classify before asking

| Kind | Example | What to do |
|---|---|---|
| **Observable** | How a library behaves at the pinned version, a query's latency, what an API returns, whether a path is reachable | Run something (a prototype, a test, a query) and record the answer |
| **Discoverable** | The repo's convention, a past decision, whether a tool or credential is already available | Look it up in the repo, its docs, decisions, and the tools you have |
| **The user's** | A product fork (which behaviour users get), a manual operation (credentials, billing, production access you lack, outreach), an ambiguous line in the request | Put it in the decision batch with a recommended default |

Anything else is yours to decide: a ruling.

## Ruling classes

| Class | What it is | Where it goes |
|---|---|---|
| **Mechanical** | One answer is clearly right, given the repo and the request | The log only |
| **Taste** | Reasonable people could choose differently: two close approaches, borderline scope, a reviewer's valid point you chose not to take, verifying below the live surface | Before approval: the decision batch with your default. After approval: decide, log, and list it in the report's Attention section |
| **Challenge** | Evidence or reviewers say the user's stated direction should change: add, drop, merge or split scope, or a premise of the request is wrong | The decision batch, with the original direction, the proposed change, the reasoning and the cost of being wrong. The user's direction stands until they approve the change. After approval: a material challenge reopens approval; any other is followed as directed and listed in Attention |

Log every ruling as one row, in the working log and later in the plan:

```text
| # | Step | Decision | Class | Rationale | Rejected alternative |
```

## Reopening approval

After approval, reopen only for:

- a material scope change, or a breaking change the plan didn't include;
- a cost, an irreversible action or a production operation the plan didn't approve;
- access you can't get through tools already authorized, after checking the available MCP servers, APIs and CLIs and the repo's secret runner.

To reopen, update the plan in place, send a message holding only the new decisions with their defaults, and keep working on everything the decision doesn't block.

Rebases, CI flakes, review-thread triage, format fixes and choices between equivalent implementations are rulings: act, then log.
