---
name: architect
description: Design the shape of new code before building it, as competing type-and-signature sketches judged against a hidden rubric and synthesised into one design. Use for a new module, service or product core, for an interface other code will depend on and that is costly to change later, when asked to architect or design something, or at the heavy setting's design step after the spec.
---

# Architect

Design it twice, at least. Fresh subagents each sketch the whole shape from a different framing: types, signatures and module boundaries, with `not implemented` bodies. A judge that sketched nothing scores them against a rubric you wrote first. You graft the best parts into one design, have it reviewed adversarially, and hand it on as the contract for implementation.

Use it for one-way doors: new modules, public interfaces, persisted data shapes, the core of a new product. For routine changes inside a settled shape, design inline instead.

## 1. Ground

Read the spec and the research doc. If no research doc covers every system the new code touches, run `research` on them first.

Done when you can name, each with `path:line`: the existing types the design must interoperate with, the callers it must not break, and the invariants that cross its boundary.

## 2. Write the caller's usage first

Write `.context/architect/<slug>/usage.md`, the usage brief every sketcher gets:

- **Callers:** who calls the new code, and the real file each call would sit in.
- **Jobs:** for each caller, what it has, what it needs back, and which failures it must handle. Three to six jobs, the most frequent first.
- **Quickstart:** the paragraph a consumer would read to get started, in the caller's words.

State the jobs in the caller's terms and leave the code to the sketchers: each writes its own call sites first, so the shapes can differ.

Done when every job traces to a real call site or a spec line, and the brief names no type that doesn't exist yet.

## 3. Write the rubric, hidden

Write the rubric with [arena's guide](../arena/rubric.md), before anyone sketches. Draw its 3–6 criteria from:

- **caller fit:** the usage brief's jobs read naturally at their call sites;
- **interface depth:** capability hidden behind the public surface, relative to its size;
- **invariants:** enforced by types rather than runtime checks or comments;
- **next-contributor safety:** assume the next contributor is an agent that sees only the files it opened, copies the nearest example and takes the shortest path that compiles. Score how often a change that looks right from one file is right for the whole repo;
- **fit:** uses the repo's conventions, helpers and types;
- **red flags:** hits from [red-flags.md](red-flags.md).

## 4. Decide the judges

Judge whether a wrong pick would be costly or hard to reverse: outside consumers or stored data would depend on the shape, or it grants access or moves money. Write the answer as one line at the top of the rubric file and in your next message to the user: `Cross-model judge: yes|no, because <reason>`.

Done when the line exists, before any sketcher starts.

## 5. Sketch through arena

Run `arena` with:

- **Candidates:** two or three sketchers, each with a different framing from [sketcher-brief.md](sketcher-brief.md). Pick framings that pull this problem in different directions.
- **Brief:** [sketcher-brief.md](sketcher-brief.md), with the usage brief and grounding attached. The artifact is a type sketch plus a rationale; the acceptance is that the sketch type-checks, with no implementation.
- **Judge screen:** [red-flags.md](red-flags.md).
- **Models:** the judge is a fresh subagent on your model, plus another vendor's model when step 4 said yes, run as arena describes.

Done when at least two sketches are whole-shape alternatives, not variants inside one shape. A sketcher that ignored its framing and returned a variant is respawned once. Two framings that independently reach the same shape is convergence: strong evidence, recorded as such.

## 6. Synthesise

Follow arena's pick and graft steps. Then:

- Reconcile the sketch to the usage, not the reverse: when a call site reads badly, change the types.
- Screen the synthesis against [red-flags.md](red-flags.md) again, since grafts can bring flags in.

The sketch's type check is the only check a design needs. It changes no application code, so the repo's hand-off and readiness checks wait for the implementation.

Done when the usage matches the sketch's signatures and the synthesis has no red-flag hit left unexplained.

## 7. Write the design doc

Load the `writing` skill by name and follow its technical mode, including its AI-tell pass. Write `docs/plans/YYYY-MM-DD-<slug>-design.md` from [rationale.md](rationale.md), with the synthesised sketch inline and the step 4 line under the synthesis decision. The docs hub shows it live from the worktree.

Done when every section of the rationale is filled and the technical mode's completion check passes.

## 8. Adversarial review

Run `adversarial-review` on the design doc. Revise the design for each Act on finding. A finding you decline goes under Open questions with your reason.

Done when no Act on finding is left unaddressed.

## 9. Hand off

Reply with the design doc's path, the base and grafts in two lines, the review outcome, and the decisions that need the user, each with options and a recommended default. The design doc is the contract for `to-tickets` and implementation. Land the sketch as a scaffold commit in source only when implementation follows on this branch.

No approval stop is needed before implementation unless the user asked for one.

## While implementing against the sketch

Deviations from the sketch are signals to surface. When code needs something the sketch didn't anticipate, decide whether the sketch was wrong, a requirement was missed, or the implementation is overreaching, and record the answer in the design doc.

**Scrap the design** when friction forms a pattern, not on a single instance:

- the same workaround shape in unrelated places;
- several unrelated edge cases that each need a special branch;
- types that only compile with escape hatches: casts, untyped values, optional fields that are always set in practice;
- a lock or coordination appearing where the sketch said state wasn't shared;
- callers that must know the abstraction's internal rules;
- two or more deviations of the same shape.

Complexity in the data is not complexity in the design; a few edge cases don't condemn a shape. To scrap: research what's been built, treat the new constraints as day-one facts, make the new sketch smaller than the old one before it grows, and run this skill again from step 2.
