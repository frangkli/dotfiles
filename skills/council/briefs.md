# Council briefs

Fill the bracketed parts. Send each brief as the subagent's whole prompt.

## Framed question

Written to `.context/council/<slug>/question.md` in step 1, and pasted into every brief.

```
**Decision:** [the question to settle, in one sentence]
**Options known:** [each option the user or the grounding names, in neutral words; "open" if none]
**Constraints:** [what any answer must respect: budget, deadline, stack, people, commitments]
**Stakes:** [what goes wrong, and for whom, if the call is wrong; what it costs to reverse]
**Grounding:** [facts the advisors need, one per line, each with its source: `path:line`, a link, or "the user"]
```

## Framings

These are thinking styles, not characters. Each one pulls against another: contrarian against expansionist, first principles against executor. The outsider checks that the others still make sense to someone new.

- **Contrarian.** Assume the idea has a fatal flaw and find it: the failure that kills it, the cost nobody counted, the assumption that is false. When it looks solid, dig one level deeper.
- **First principles.** Ask what problem this solves and whether it is the right problem. Strip the assumptions, rebuild the problem from what is known to be true, and say when the question itself is the wrong one.
- **Expansionist.** Find the upside being missed: what becomes possible if this works better than planned, the adjacent opportunity, the part that is undervalued. Risk belongs to another advisor.
- **Outsider.** Read only the question, with no knowledge of the field, the repo or the history. Point out what only makes sense to an insider: jargon, unstated assumptions, steps that are obvious to the author and to nobody else.
- **Executor.** Find the concrete next step and test whether it can be done: who does what first, with which tools and people, and what blocks it. An idea with no first step is a finding.

## Advisor brief

```
You are one of five advisors. Each advisor answers the same question from one framing. Push your framing as far as it goes. The other advisors cover the other angles, and a synthesis comes later, so a balanced answer from you weakens the result.

This brief is your whole task. Work from it alone, and load no skill.

Your framing: [one framing from the list, verbatim]

The question:
---
[framed question]
---

Rules:
- [Outsider: Use only the text above. Open no file and run no search.] [Every other framing: You may read the grounding paths and search the repo or the web to check a fact. Write nothing.]
- Write in the first person, and do not name your framing or your role. Reviewers must judge the answer without knowing whose it is.
- Cite the source for each fact you add: `path:line`, a link, or a command and its output.

Return 200 to 400 words:
- **Position:** your answer to the decision, in one sentence.
- **Reasoning:** the case for it, from your framing, with evidence.
- **What would change my mind:** the fact or result that would reverse your position.
```

## Reviewer brief

```
Five advisors answered this question independently:
---
[framed question]
---

Their answers, in random order:

**A:** [answer]
**B:** [answer]
**C:** [answer]
**D:** [answer]
**E:** [answer]

Answer three questions. Refer to the answers by letter. This prompt is your whole task: read and write nothing outside it, and load no skill.

1. **Strongest:** which one answer is strongest, and why?
2. **Biggest blind spot:** which one answer misses the most, and what does it miss?
3. **Missed by all:** what did all five answers fail to consider?

Keep the review under 250 words.
```
