---
name: to-tickets
description: Break a spec, plan or the current conversation into tracer-bullet tickets, each with blocking edges and one CHECK line, written to the repo or the project's tracker.
disable-model-invocation: true
---

# To Tickets

Break the work into **tickets**: tracer-bullet vertical slices, riskiest first, each declaring the tickets that **block** it and one `CHECK` that decides when it's done. Any ticket on the frontier should be finishable by an agent that reads only that ticket and the code.

## Steps

1. **Gather.** Read the source in full: the spec or plan at the path or link you were given (with its comments), or the conversation. Read AGENTS.md and the repo's `GATES.md`; without one, find the check commands in its task runner scripts and CI workflow. Done when you can list every requirement, success criterion and breakage window in the source.
2. **Explore** the code the work touches: its domain vocabulary, ADRs in the area, modules and helpers to reuse, and prefactoring that would make the change easy. Done when each requirement has a module it lands in.
3. **Slice** by the rules below. Done when every ticket has a title, blockers and the behaviour it delivers.
4. **CHECK each ticket** per [checks.md](checks.md). Where a CHECK is cheap to run, run it now and confirm it doesn't pass yet. Done when every ticket has exactly one CHECK line.
5. **Cover the source.** Map every requirement and success criterion to the ticket whose CHECK observes it, and the done-predicate to the final ticket. Done when every row has a ticket, or a reason it has none.
6. **Breakage windows.** If the source allows a window, mark the tickets inside it, the checks that stay green throughout, and the ticket that closes it with the full readiness check as its CHECK. Otherwise every ticket's CHECK assumes a green tree.
7. **Review with the user**, if they're present: the numbered breakdown (title, blocked by, delivers, CHECK) and one batched round on granularity, blocking edges, and merges or splits, each with your recommended answer. If they aren't present, publish and list those choices as decisions in the report.
8. **Publish** to the destination in [../to-spec/destination.md](../to-spec/destination.md), in dependency order, blockers first, using [template.md](template.md), with the prose per the `writing` skill's technical mode ([technical.md](../writing/technical.md)).
   - Repo markdown or a spec framework: one file holding every ticket.
   - Tracker: create every issue first, then wire native blocking relations in a second pass, once real ids exist. Leave the parent issue open and unchanged.

Report the path or links, the ticket count, the frontier (tickets with no open blockers), coverage gaps, and decisions for the user.

## Slicing rules

- **Vertical.** Each ticket cuts a narrow but complete path through every layer it needs (schema, API, UI, tests) and is demoable or checkable on its own.
- **One context window.** Size each ticket for one fresh agent session.
- **Prefactoring first**, then the **riskiest unknown**, so a wrong assumption fails early.
- **Split on "and".** A title that needs "and", or acceptance that needs more than three criteria, is two tickets.
- **Interfaces, not paths.** Describe modules, types, signatures, contracts and behaviour, never file paths or line numbers: a ticket may wait for weeks. The agent that dispatches a ticket adds paths and the base commit to its spawn brief. A prototype snippet that pins a decision may go inline, trimmed and marked.
- **One name per thing.** An interface keeps the same name in every ticket that mentions it.
- **Wide refactors.** One mechanical change whose blast radius spans the codebase (rename a column, retype a shared symbol) can't land as a vertical slice. Prefer one ticket that migrates every caller and deletes the old form. When that can't stay green, either declare a breakage window or sequence expand → migrate in batches → contract, with the contract ticket deleting the old form.
