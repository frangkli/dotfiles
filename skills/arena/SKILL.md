---
name: arena
description: Bake-off of competing candidates for one artifact, judged against a hidden rubric, then the best one grafted with the others' strengths. Use when asked to try several approaches, implementations or designs and pick the best, for a second opinion that needs real alternatives built, or as architect's sketch-and-judge step.
---

# Arena

Several fresh subagents attempt the same task in parallel, each in its own worktree. A judge that produced no candidate scores them against a rubric written before any candidate started. You pick a base, graft the best parts of the others into it by hand, and verify the result.

Use it where one attempt could lock in the wrong shape: a new module, an interface other code will depend on, a non-obvious algorithm. Over a settled design it only adds cost. Splitting work into independent parts is a different job (`orchestrate`, or a review's lanes).

## 1. Frame

Write the **candidate brief** from [candidate-brief.md](candidate-brief.md): the artifact, the task, the grounding to read, the base commit, the acceptance check, and what to return. Every candidate gets the same brief, so the brief is the contract.

Choose **N candidates** (two or more; three when the design space is wide) and how they differ:

- **Exploring shapes** (designs, interfaces, architectures): give each candidate a different framing, so each pushes one direction to its end. The caller supplies framings; `architect` has its own list.
- **Generation-bound work** (an implementation where the shape is settled): the same brief N times.

Candidates and judge run on the model you're on. Bring in another vendor's model, as the judge, only when the user asks or the artifact is a **high-risk interface**: one that outside consumers or stored data will depend on, where a wrong shape can't be fixed later without breaking them, and that grants access, moves money or changes how data is stored. Run it as [the review's cross-model lane](../adversarial-review/cross-model.md) describes.

Done when the brief has every field filled and each candidate has its framing or is marked as a repeat.

## 2. Write the rubric first

Write 3–6 criteria for this task to `.context/arena/<slug>/rubric.md`, following [rubric.md](rubric.md). Candidates never see it: they work to the task, not to the grader.

Done when the rubric file exists and no candidate has been launched yet.

## 3. Prepare the workspaces

Record the base commit. Create one git worktree per candidate yourself, on a new branch `arena/<slug>/<name>` from that commit, placed next to the repo's other worktrees. Name each candidate by its framing, or by number for repeats. A worktree lets a candidate check its artifact against the repo's real code and leaves a commit you can diff and graft from. When candidates will run code or a type check, prepare each worktree as the repo's AGENTS.md says for new worktrees. Only an artifact unrelated to any repo gets a plain directory instead.

Done when every candidate's worktree and branch exist and are prepared.

## 4. Fan out

Spawn every candidate in one message, as background subagents, each with the brief, its framing and its worktree path. This step is your instruction to spawn subagents, in any harness; writing the candidates yourself would make you a candidate and leave no independent author. Send nothing else: not the rubric, not the other framings, not your expectations.

A candidate that returns nothing, or returns without its commit SHA, is respawned once. After a second miss, record it as a dropout and continue if two or more candidates remain.

Done when every candidate has returned its commit SHA and report, or is recorded as a dropout.

## 5. Judge, and score it yourself

Label the candidates A, B, C… in random order. Launch one fresh, read-only judge with [judge-brief.md](judge-brief.md): the rubric, the labelled candidate branches or paths, and any screens the caller adds (architect adds its red flags). The judge sees neither the framings nor which model wrote what.

While it works, read every candidate end to end and score each criterion yourself, with evidence, before you open the judge's result. Score per criterion, not by overall impression.

Done when you have two complete score tables, yours and the judge's.

## 6. Pick a base

- **Same base from both:** the pick is confirmed.
- **Different bases:** one scorer is biased or a criterion is ambiguous. Read the judge's rationale against yours, decide, and record why. If a criterion was ambiguous, say how you read it.
- **Tied:** take the one with the smaller public surface and the cleaner boundary, the one the next contributor can extend without breaking an invariant.
- **Converged:** the candidates reached the same shape independently. That is strong evidence; take it, note the convergence, and skip grafting.
- **Wildly divergent:** the candidates solved different problems, not the same problem differently. The frame was under-specified. Sharpen the brief and run again rather than averaging them.

## 7. Graft by hand

Walk each losing candidate once more for what beats the base: usually one or two things each, not most of it. Rewrite each graft into the base in the base's own terms, so the result reads as one design. Paste nothing across.

Done when every graft is listed with its source candidate, and every strength you passed over is listed with the reason.

## 8. Verify

Check the synthesised artifact against the brief's acceptance check. For code, run the cheapest checks that cover it, as the repo's `GATES.md` describes; the full readiness check belongs to ship points. When verification finds a problem a candidate had handled, go back to step 7. When no candidate handled it, the frame was wrong: go back to step 1.

## 9. Record and clean up

Write the synthesis note to `.context/arena/<slug>/synthesis.md`, or into the section the caller names. Call each candidate by its name everywhere in the note, never by the judge's letter, so no reader has to translate labels. Write it per the `writing` skill's technical mode ([technical.md](../writing/technical.md)). The note covers:

- the base and why;
- both score tables, per criterion and candidate;
- each graft with its source, and what was passed over and why;
- convergence, divergence and dropouts;
- each candidate's branch and SHA;
- the verification result.

Remove the candidate worktrees. Delete their branches once the caller has accepted the result.
