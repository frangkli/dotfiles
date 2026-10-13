# Logic prototype

A single, self-contained HTML file (a **shareable demo**) that lets anyone drive a state model by clicking buttons. Use it when the question is about **business logic, state transitions or data shape**: the kind of thing that looks reasonable on paper and only feels wrong once you push it through real cases.

Because it's one file with nothing to install, a non-developer (a designer, a PM, a domain expert) can feel the model for themselves. So it speaks their language, not the code's.

## 1. State the question

Before writing code, write down the state model and the question in one paragraph, shown at the top of the demo (visible text, not a comment). Done when the paragraph names the cases that would settle the question.

## 2. Isolate the logic in a portable module

Put the logic that answers the question in a single `<script>` block written as a small, pure module that could be lifted into the real codebase. The page around it is throwaway; this module isn't. Pick the shape that fits the question:

- **A pure reducer**, `(state, action) => state`: discrete events, one state value.
- **A state machine** with explicit states and transitions: when "which actions are legal right now" is part of the question.
- **A few pure functions** over a plain data type: no implicit current state, only transformations.
- **A class or module with a clear method surface**: when the logic genuinely owns ongoing internal state.

Keep the module pure: the page calls into it, and the module never touches the DOM, `document` or button handlers. Mirror the real code's names and types where they exist, so the module lifts across cleanly.

## 3. Build the HTML file

One file, plain HTML, CSS and JavaScript, everything inline, so it opens with no framework, bundler or server. Label everything in **domain language**, not code. Top to bottom:

1. **Title and one-line explanation**: the question from step 1.
2. **Current state**: the full relevant state as a readable panel (labelled fields, not raw JSON), re-rendered after every click, with what just changed called out.
3. **Free-play buttons**: one per action, always available, so anyone can poke the model in any order. An action the model rejects shows why.
4. **Guided walkthroughs**: one scenario per tab, each with a plain-language description of the setup and what to watch for, then its ordered steps as real buttons. Starting a walkthrough resets to a known initial state. Cover the happy path, the tricky edge cases, and an attempt at something that should be illegal.

Clean typography, generous spacing, one accent colour, no animation: nothing competes with the state and the buttons.

Save it under the repo's `docs/plans/` on the prototype branch (for example `docs/plans/YYYY-MM-DD-prototype-<slug>.html`), so the docs hub shows it from the worktree.

## 4. Drive it yourself

Run every walkthrough before handing over: load the page in a headless browser, or run the module's script in the repo's JavaScript runtime with the walkthrough steps. Done when each scenario ends where its description says, or the mismatch is written down as a finding about the model. A mismatch caused by the page is a prototype bug; fix it.

## 5. Hand it over

Give the user the file path and its docs hub link. The interesting moments are "wait, that shouldn't be possible" and "I assumed X would be different": those are bugs in the idea, which is the point. Add actions or scenarios when they ask.

If no one will drive it (an unattended run), the verdict is yours: report what each scenario showed and log the verdict as a ruling.

## 6. Capture

Capture the answer and the prototype as the [SKILL](SKILL.md) describes. The validated module is what the real change reuses; the HTML shell stays on the prototype branch, where it remains runnable.
