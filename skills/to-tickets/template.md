# Ticket templates

## Repo file

One file for every ticket, numbered in dependency order. Only the agent coordinating the work updates the Status lines, so parallel workers never edit it at once.

<tickets-file>

# Tickets: <title>

**Source:** <link or path to the spec or plan>
**Done-predicate:** <copied from the spec, or written here when the source has none>
**Breakage windows:** <window: tickets inside it, checks that stay green, the closing ticket> | None: every ticket leaves the tree green

## Coverage

| Requirement | Ticket |
|---|---|
| <success criterion, user story or requirement, quoted briefly> | T<n> |

## T1: <title>

**Blocked by:** None (can start immediately)
**Status:** ready | in progress | done (with the passing CHECK output) | blocked (with the reason)

**Current:** what happens today.
**Desired:** the end-to-end behaviour this ticket makes work, from the user's or caller's view.
**Interfaces:** what it consumes and what it produces (types, contracts, endpoints, events).

- [ ] Acceptance criterion: one observable result in one sentence (at most three)

**Out of scope:** what a reader might assume is included but isn't.

CHECK: <command> → exit 0 + "<token>"

## T2: <title>

**Blocked by:** T1 (<title>)
**Window:** <window name>, only for tickets inside a breakage window
...

</tickets-file>

## Tracker issue

Same fields, one issue per ticket. Set blockers with the tracker's native relation and drop the "Blocked by" line; reference the parent issue when the source was one. In prose, refer to other tickets by title.
