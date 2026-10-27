# Writing the rubric

The rubric is how the base gets picked. Write it before any candidate exists, so it measures what the task needs rather than what the first candidate happened to do.

Three to six criteria. For each one write:

- **Name** and **weight** (1–3; most criteria are 1).
- **What to look at:** the file, the call site, the command output, the scenario.
- **Scores:** what earns 1, 3 and 5, written as things a reader can observe in the artifact.

Each criterion names something observable. "Clean API" can't be scored; "a caller does the main scenario with one import and one call, without touching internal types" can. When you reach for an adjective, ask what you'd look at to decide it, and write that instead.

Cover what this task needs, typically drawn from:

| Kind | Example criterion |
|---|---|
| Caller fit | The usage brief's call sites read as written, with no knowledge of internals |
| Interface depth | Capability hidden behind the public surface, relative to the surface's size (count of exported names and options) |
| Invariants | Which invariants the types enforce, versus runtime checks, versus comments |
| Change locality | A likely next change (name it) touches how many files and modules |
| Fit with the repo | Follows the conventions the repo already uses; reuses its existing helpers and types |
| Correctness | Passes the acceptance check; handles the failure cases the task names |
| Cost | New dependencies, new services, migration steps, lines of code |

Leave out anything every candidate will pass: it adds no signal.
