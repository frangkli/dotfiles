---
name: to-spec
description: Turn the current conversation into a spec with measurable success criteria and a done-predicate, written to the repo or the project's tracker.
disable-model-invocation: true
---

# To Spec

Synthesise the conversation (usually a `grill` session) and what you know of the code into a spec an implementer could build from without asking a question. This is synthesis, not an interview. Ask the user only about a real fork the conversation left open, in one batched round with a recommended answer for each.

## Steps

1. **Ground.** Read the code the spec touches, if you haven't yet: the project's domain vocabulary (glossary or context docs), ADRs in the area, and existing modules and helpers the work can reuse. Done when every module the spec will name either exists in the code or is marked new.
2. **Destination.** Pick where the spec goes with [destination.md](destination.md). Done when you can name the file path or the tracker location.
3. **Seams.** Choose where the behaviour will be tested: existing seams before new ones, the highest seam that works, as few as possible (ideally one). Done when every success criterion maps to a seam.
4. **Write** the spec from [template.md](template.md), its prose per the `writing` skill's technical mode ([technical.md](../writing/technical.md)). Write Usage before Implementation decisions and derive the interfaces from the usage.
5. **Builder check.** Give a fresh subagent only the spec, framed as an implementer who can't talk to you, and ask for ranked questions where a wrong guess would change what gets built. Done when every question is answered in the spec, recorded under Further notes as your ruling, or put to the user in one batch.
6. **Publish.** Write the spec to the destination. Report its path or link, the done-predicate, and any decisions still open.

Run `to-tickets` next, in this same conversation, when the work needs splitting.
