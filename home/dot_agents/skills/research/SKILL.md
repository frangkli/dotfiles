---
name: research
description: Research how a codebase works today, or gather external facts from primary sources, into a cited research doc in docs/research/. Use before designing a big feature or new product, when asked to research, investigate or document how something currently works, or to collect docs, API or library facts into a written reference.
---

# Research

Answer questions about what exists today, from primary sources, and capture the answers as one cited document. Fresh subagents do the reading; you write the questions, check what they bring back, and write the doc.

The doc describes the system as it is. The wanted change stays out of it, so the findings can't bend toward a design someone already has in mind. Designing comes after, in `architect` or the plan.

When the conversation has other work to do, run this whole skill in one background agent and keep working.

## 1. Separate the request from the questions

Write down the wanted change, if there is one, in a short request note under `.context/research/<slug>/request.md`. Only you read it.

Then write two to seven **current-state questions**: what exists, where it lives, how it behaves, how it's tested, what constrains it. Give each one starting points: paths, packages, commands, URLs. "How does a request move from the HTTP handler to the database, and which steps retry?" is a current-state question. "How should we add retries?" is not; turn it into "Where do retries happen today, and what decides when they stop?".

In the heavy setting (research → `council` → `grill`), draft the questions from the request and any notes already in the conversation. Proceed without waiting for approval unless the user asked to see the questions first.

Done when the request note exists (or records "no change planned"), every question reads as a description of today's system, and someone holding only the questions couldn't tell what change is planned.

## 2. Pin what you're reading

Record the commit SHA of every repository you will read (`git rev-parse HEAD`, and each submodule you read) and the version of every external library or API the questions touch, as pinned by the repo. These go in the doc's frontmatter, so a reader can tell when the doc has gone stale.

## 3. Investigate with subagents

Split the questions into focused areas, usually two to six. For each area, spawn fresh subagents with the briefs in [briefs.md](briefs.md). This step is your instruction to spawn them, in any harness: the reading happens in their contexts, so yours stays free for checking and writing.

- **locator**: where the code, tests, config and docs for the area live. Send it first when you don't know where to look.
- **analyzer**: how the code works, traced through the call path with `file:line`.
- **pattern-finder**: existing examples of the thing in question, including how they're tested.
- **external sources**: facts about libraries, services and specs, from the source that owns them, at the version the repo pins.

Each subagent gets one bounded question, its starting points and the pinned SHAs. Never pass the request note. Launch independent subagents in one message so they run in parallel.

Done when every question has at least one finished investigation behind it. Wait for all of them before writing.

## 4. Check what came back

- Open the cited lines yourself for every claim the doc's headers will rest on. Where subagents disagree, the live code decides.
- Run a check only when a finding depends on runtime behaviour that reading leaves uncertain: the single test file or command that covers it, found through the repo's `GATES.md` or its test config. Record the command and the observed result. Research changes no code, so the repo's hand-off and readiness checks don't apply to it.
- Keep **tests read** and **checks run** apart. "A test asserts X" means you read it. "X holds" needs a command you ran and its output.
- For a gap, run one targeted follow-up investigation. What's still unknown after that becomes an open question, with what blocked it.

Done when every question has an answer whose citations you opened yourself, or is listed as open.

## 5. Write the doc

Write `docs/research/YYYY-MM-DD-<slug>.md` in the current worktree from [template.md](template.md). The doc is Markdown only, since later steps (`to-spec`, `architect`) read it. Add an HTML companion with `visual-plan` only when the user asks for one. Write the prose per the `writing` skill's technical mode ([technical.md](../writing/technical.md)), with the template and the rules below in place of its report contract and its HTML hand-off.

- **Headers state findings.** "Workers restore pending jobs before accepting new work", not "Worker startup" or "How do workers restart?". Lead each section with the finding, then the explanation, citations and any diagram.
- Organise by concept, and say what each part does before saying where it lives.
- Give each component its testing picture: where the tests are, what kind, which fixtures and helpers, or that you found none.
- Keep design out: no recommendations, no proposed changes. Constraints a design must respect are findings; state them as facts.

Done when the headers alone, read top to bottom, answer every question, and every claim cites a file and line or a source link.

## 6. Reader test and publish

If the doc runs past about 200 lines, give it alone to a fresh subagent and ask which questions it would still have. Answer them in the doc.

The plans hub shows every worktree's `docs/research/` live from disk, so writing the file publishes it. Commit it on the current branch when the task is producing commits.

## 7. Report

Reply with the doc's path, its finding headers as a list, the open questions, and the checks you ran. End with the decisions that need the user, or "nothing needs you".
