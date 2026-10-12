---
name: council
description: Council of five framings that answer an open direction independently, review each other anonymously, and return one verdict. Use when asked to council or pressure-test an idea, direction or decision before any plan exists, or when grill or deliver finds the direction itself open.
---

# Council

Five fresh subagents answer the same framed question, each from one thinking style. Five more review the answers with the authors hidden. You write one verdict that keeps the disagreements visible, makes one recommendation and names one next step.

## Where it sits

Council is one setting on the dial spectrum that scales with the problem and the design scope. It asks whether this is the right thing to build, before anyone plans how.

- **Heavy flow:** the default direction step, in research → council → grill. Grill takes the verdict's clashes and recommendation as its question list.
- **deliver:** only when its Direction dial calls for it: several viable approaches, or a request that may be the wrong problem.
- **Standalone:** "council this", "pressure-test this idea", "is this the right approach".
- **Elsewhere:** small changes go straight to work. A plan, spec or diff goes to `adversarial-review`; a settled direction that needs a shape goes to `architect` or `arena`; prose goes to `writing`.

## 1. Frame

Read what grounds the question: AGENTS.md, the research docs and specs on the topic, recorded decisions, and every file the request names. Record the commit SHA you read at. Write the framed question to `.context/council/<slug>/question.md` with the template in [briefs.md](briefs.md).

The framed question is neutral. It states the decision, the known options, the constraints, the stakes and the grounding facts, each with its source. It ranks nothing and carries no opinion, yours or the user's. When the request is too vague to frame (no decision to make, or no subject), ask the user one clarifying question, then frame.

Done when the file names the decision and its stakes, every fact cites a path, link or the user, and a reader could not tell which option you favour.

## 2. Convene the advisors

Spawn five advisors in one message, as fresh background subagents. Each gets the advisor brief from [briefs.md](briefs.md), filled with its framing and the framed question, and nothing else: no other framing, no conversation, no view of yours. This step is your instruction to spawn subagents, in any harness; answering a framing yourself leaves the council with your bias in it.

| Action | Claude Code | Codex |
|---|---|---|
| Spawn | Agent tool, one call per subagent, all in one message, in the background | `spawn_agent` per subagent |
| Collect | Task notifications | `wait_agent` |

Respawn an advisor once if it returns no position. A framing that fails twice is a **gap**, named in the verdict; continue when four answers remain.

Done when every framing has an answer or is recorded as a gap.

## 3. Cross-review, anonymised

1. Shuffle the framings with a real random source, for example `printf '%s\n' contrarian first-principles expansionist outsider executor | shuf`, and assign the letters A to E in the output order.
2. Strip anything that names a framing from each answer ("as the contrarian…").
3. Write the letter-to-framing map to `.context/council/<slug>/mapping.md`. Reviewers never see it.
4. Spawn five fresh reviewers in one message with the reviewer brief from [briefs.md](briefs.md): the framed question and the labelled answers, in letter order.

Done when five reviews have returned, each naming the strongest answer, the biggest blind spot and what all answers missed, by letter only.

## 4. Verdict

Unmask the letters and write the verdict yourself, from the answers and reviews:

- **Agreements:** points two or more advisors reached independently, each with the framings that reached it.
- **Clashes:** each real disagreement, both sides, which framings hold each, and why they differ. Record a clash as a clash. The user, grill or deliver resolves it later.
- **Blind spots:** what surfaced only in the cross-review.
- **Recommendation:** one option, with its reasons. It may overrule the majority when the minority's reasoning is stronger; say why.
- **Next step:** one concrete action, and the result that shows it is done.

Write it as Markdown to `docs/research/YYYY-MM-DD-<slug>-council.md`, or where AGENTS.md says research goes, per the `writing` skill's technical mode ([technical.md](../writing/technical.md)). Open with the recommendation, then the question and the commit SHA, then the five sections above, then any gaps. Append the framed question, the five answers and the five reviews with the letter map, so a later council on the same question can see what changed.

Done when every clash names both sides and their framings, the recommendation is one option, and the next step is one action.

## 5. Hand back

In chat, give the file path, the recommendation in two sentences, and the clashes in one line each. End with the decisions for the user, each with its options and a recommended default.

- **From grill:** the clashes and the recommendation become grill's next round of questions.
- **From deliver:** the recommendation becomes the plan's direction, and each clash goes into its decision batch.
