# Technical: explanations, plans, reports and specs

The reader must understand a system or make a decision, often later and without your context. They judge the text by whether they can trust each claim and act on it.

## Evidence

Mark how you know each claim whenever the sentence doesn't already make it clear:

- **Measured:** you ran it. Give the number, its unit, and the command or conditions (commit, input size, number of runs): "p95 latency 45 ms over 200 requests at `abc1234`".
- **Inferred:** you reasoned from code, docs or another result. Cite where (`file:line`, a doc link) and say what would confirm it: "Likely the cause: `retry.ts:40` retries without backoff. A run with backoff would confirm it."
- **Proposed:** your recommendation or design. Say what it costs and what it gives up.

Write an inferred claim in an inferred voice, never in a measured one. Replace adjectives like fast, slow, large, significant and most with the figure, its unit and its baseline: "from 340 ms to 45 ms", "3 of 120 tests". Every number carries a unit, and each unit stays the same across the document. Before you write a claim down, run the cheap check that settles it: open the file, run the command.

## By kind

- **Explanation:** start from what the reader already knows and name the mechanism. Give one concrete case (a real call path, an input and its output) before the general rule. Define each term on first use. When more than two components interact, add a diagram through `show-me` (in chat) or `visual-doc` (in a document).
- **Plan:** goals, non-goals, acceptance criteria a command or observation can check, what gets reused or removed, rollout, and risks. Batch the decisions at the end, each with a recommended default. A calling skill's template takes precedence.
- **Spec:** every requirement can be tested, and the spec ends with a measurable done-predicate. It goes where the repo keeps specs: OpenSpec or Spec Kit if the repo uses one, repo markdown by default, Linear only if the project tracks work there.
- **Report:** follow the contract below.

## Report contract

Skills with their own report format (`adversarial-review`, `improve`) follow it; this is the default for every other report.

1. **Verified before returning.** Run, trace or reproduce every claim you can check. "Next, verify X" is never a closing line: do it, or say what blocked you.
2. **Verdict first.** One or two sentences that answer the question the report was for.
3. **Each finding stands alone:** what and where (`file:line`), why it matters (a concrete failing case or its impact), the evidence (command and output, or the trace), the recommended fix and its cost, and your confidence.
4. **End with only what needs the reader:** decisions, each with its options, a recommended default and the consequence of each choice. If nothing needs them, write "Nothing needs you."
5. **Reader test for long reports** (more than about two screens): give the report alone to a fresh subagent, ask which questions it would still have, and answer them in the report before you return it.

## STE pass

After drafting, and before the shared AI-tell pass, run the STE-flavoured mode of the [`asd-ste100`](../asd-ste100/SKILL.md) skill over the draft: its structural rules in full, its lexical rules as advice. Start with its linter as the mechanical first check, on the file or on the text through stdin:

```bash
python3 ~/.agents/skills/asd-ste100/scripts/ste-lint.py <file>
```

Fix each hard finding, or keep the sentence when the rewrite would drop a fact, a condition or a hedge. Read each advisory finding (passive voice, compound tense) and change the sentence only where the actor or the timing gets clearer.

## In a subagent brief

A subagent that writes one of these documents gets this block in its brief, verbatim:

> Write for a person who must understand or decide:
> - Open with the conclusion; every later sentence adds a fact the reader lacks.
> - Mark how you know each claim: measured (number, unit, command), inferred (cite `path:line`, say what would confirm it) or proposed (what it costs and gives up).
> - Figures, not adjectives ("340 ms to 45 ms", "3 of 120 tests"); name the real symbol, file or command; a fact you lack is a visible `[confirm: …]`, never a guess.
> - End with the open decisions, each with a recommended default, or "Nothing needs you".

## Where it goes

Anything the owner reviews or decides on (plans, explainers, tradeoffs, experiment results, audits) is HTML: write the content with this file, then hand it to `visual-doc`, which owns the HTML, the file location and the docs hub link. What later agent steps read (research inputs, specs, architect designs) is Markdown, and tickets go where the spec bullet above says. The docs hub renders HTML and Markdown the same way. An answer in chat stays in chat.

Done when every number has a unit and a source, every measured claim names its command or conditions, the text ends with decisions or "Nothing needs you", `ste-lint` reports no hard finding you haven't fixed or kept for a reason, and the AI-tell pass is done. End the chat reply with the AI-tell proof line from SKILL.md.
