# Sketcher brief

Send this as the **Task** and **Artifact** of [arena's candidate brief](../arena/candidate-brief.md), with the usage brief, the spec and the research doc as grounding, and one framing per sketcher.

## Framings

Give each sketcher one. Pick two or three that pull this problem in different directions.

- **Smallest surface.** One to three entry points. Pull every policy and sequencing decision into the callee, even when its implementation grows.
- **Common caller first.** Make the most frequent job in the usage brief a single obvious call. Rare jobs may cost more.
- **Data first.** Design the data and who owns each piece of state; let the operations fall out of it. Trace every job through the data before writing a signature.
- **Seams at the edges.** Put each external dependency (storage, network, clock, third-party API) behind a seam this module owns; only domain types cross the public surface.
- **Reuse first.** Extend the modules and types the repo already has; add the least new surface that meets the usage brief.
- **Named variation.** Only when the spec names concrete future variants: shape the design so each named variant is an addition, not an edit.

## Task text

> Sketch the whole shape of [the new code]: its modules, types and function signatures. This is a design, not an implementation.
>
> Work in this order, and keep each layer consistent with the one before:
>
> 1. **Usage.** For every job in the usage brief, write the call site as the caller would write it, in the file it would sit in. The usage is the spec; when the types later disagree with it, change the types.
> 2. **Data.** The core types and who owns each piece of state. Trace each job's access pattern through them. If a job needs "a map, index or cache we'll add later", the data is wrong; fix it now.
> 3. **Signatures.** Bodies throw `not implemented`. Tricky logic gets pseudocode in a comment. Doc comments state intent and invariants. A reader should be able to follow data from input to output through types and signatures alone.
>
> Hold the sketch to these:
>
> - Hide as much as possible behind as small a public surface as possible. Parse external data into domain types at the boundary; wire, storage and framework types stay private.
> - Each piece of state has one owner. Where two actors could write the same state, say what happens; prefer per-actor state merged where it's read.
> - Encode invariants in types first, runtime checks second, comments last.
> - Validate at boundaries and trust types inside. Keep business logic in plain functions and the I/O shell thin.
> - One source of truth per fact; derive the rest.
> - Say what happens when an operation runs twice or stops halfway.
> - A flow should be traceable in three files or fewer.
> - The next contributor is an agent that sees only the files it opened, copies the nearest example and takes the shortest path that compiles. Shape the code so that path is the right one.
> - Follow the repo's existing conventions, and reuse its helpers and types.
>
> Put the sketch where the code would live, and write the rationale next to it from [rationale.md](rationale.md), Usage section first. Its prose follows these rules:
>
> - Open with the conclusion; every later sentence adds a fact the reader lacks.
> - Mark how you know each claim: measured (number, unit, command), inferred (cite `path:line`, say what would confirm it) or proposed (what it costs and gives up).
> - Figures, not adjectives ("340 ms to 45 ms", "3 of 120 tests"); name the real symbol, file or command; a fact you lack is a visible `[confirm: …]`, never a guess.
> - End with the open decisions, each with a recommended default, or "Nothing needs you".
