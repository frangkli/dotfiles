---
name: grill
description: Interview the user in batched rounds until a plan, design or idea is settled. Use when the user asks to be grilled or to stress-test their thinking, or when shaping a new product or large feature before writing its spec.
---

# Grill

Interview the user until you share one understanding of what to build. Map it as a **design tree**: every decision branches into the decisions that hang off it. The subject is what the user names; with nothing named (a bare `/grill`), it is the plan, design or idea in this conversation.

## 1. Restate

Open with a restate block of what you understand so far. Mark anything unknown with `?`.

```
**Outcome:** what exists or works differently when this is done
**User:** who it's for
**Why now:** what makes it worth doing now
**Success:** a measurable result: a number, a command that passes, a behaviour someone can watch
**Constraints:** what the solution must respect
**Out of scope:** at least one named exclusion
```

The out-of-scope line is required. If nothing is excluded yet, the first round asks what is.

## 2. Rounds

The **frontier** is every decision whose prerequisites are settled: the questions you can ask now without guessing answers you haven't heard. Ask the whole frontier in one round, numbered, each with your recommended answer, then wait for the reply.

```
**Q1. <title>**: <question, with the options spelled out>
Recommended: <your answer>

**Q2. <title>**: ...
Recommended: ...

**Rulings** (say which to overturn):
- <decision you made yourself> because <reason>
```

- When a `council` verdict exists for the subject, its clashes and recommendation are the first round's questions. When the direction itself is open (several viable approaches, or the subject may be the wrong problem) and no verdict exists, run `council` before the first round.
- Word each question so "yes" accepts the recommendation.
- A question earns a place in the round only when its options lead to different builds and the user's preference decides between them. Make the other calls yourself and list them under **Rulings**, one line each.
- Facts are your job. When a question needs one from the code, docs or tools, send a subagent for it and ask the rest of the frontier meanwhile; only the questions downstream of the lookup wait.
- When the user states how existing code behaves, check it against the code and show any contradiction.
- When an answer is observable by running something (does this state model hold, does this API feel right), use the `logic-prototype` skill instead of asking.
- On a large scope, make the first round one breadth-first pass over the top-level branches before going deep.
- Where it sharpens the choice, offer the minimal version and the ideal version as the two options.

Each answered round moves the frontier outward. Recompute it and ask the next round. A question that depends on another question still open in this round belongs to a later round.

## 3. Answers

An answer is "yes" (accepts the recommendation), a chosen option, a stated alternative, or an explicit "yes to all".

Vague assent ("sounds good", "whatever you think", "fine") is not an answer. Re-ask each open question as two concrete options with your recommendation. When an answer is a buzzword ("scalable", "clean"), ask: "If you didn't have to justify this to anyone, what would you want?"

## 4. Close

The session is done when the frontier is empty and an implementer could build it without asking a single question. Show the final restate block, with every `?` resolved and the Success line measurable, and get an explicit yes to it. Act on the plan only after that yes.

The usual next step is `to-spec` in this same conversation, so the spec keeps every answer.
