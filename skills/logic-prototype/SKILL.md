---
name: logic-prototype
description: Build a throwaway prototype that answers a logic or state-model question with running code. Use when a state model, business rule or data shape needs checking against real cases, or when a question in a plan can be settled by running something instead of asking.
---

# Logic prototype

A prototype is **throwaway code that answers one question**. The question decides the shape.

## Pick a branch

- **"Does this logic, state model or data shape hold up?"** → [LOGIC.md](LOGIC.md): one self-contained HTML file with a pure logic module, free-play buttons and guided walkthroughs that push the model through the cases that are hard to reason about on paper.
- **"What should this look like?"** → load the `variate` skill and follow it instead. It builds the design variations and the switcher. Rule 6 below still applies once a variation wins.

If the question is ambiguous and the user isn't reachable, take the branch that matches the surrounding code (a backend module → logic; a page or component → UI) and state that assumption at the top of the prototype.

## Rules

1. **Throwaway from the start.** Create a `prototype/<slug>` branch before writing anything, in its own worktree if the current checkout holds other work. Put "prototype" in every file name.
2. **Trivial to run.** One file that opens in a browser with nothing installed.
3. **No persistence.** State lives in memory. When persistence is the question, use a scratch database or file named so anyone can see it's safe to wipe.
4. **Polish nothing.** No tests, no error handling beyond what keeps it running, no abstractions. Its only check is driving the walkthroughs ([LOGIC.md](LOGIC.md) step 4); the repo's test suites and readiness check stay out of it, because the product code doesn't change.
5. **Surface the state.** After every action, show the full relevant state so the change is visible.
6. **Capture the answer.** Commit the prototype on its branch. Write the answer where the work is tracked (the spec, ticket, plan or issue), or in your report when nothing tracks it yet: the question, the verdict, what it settled, and the branch and commit that hold the prototype. The validated decision reaches the main branch only through the normal change; the prototype branch never merges.
