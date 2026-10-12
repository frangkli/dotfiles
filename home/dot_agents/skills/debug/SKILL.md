---
name: debug
description: 'Diagnosis loop for bugs and performance regressions: build a red feedback loop before forming theories. Load first, before reading code, for any bug report or debugging request, however small it looks: wrong output, an error, a failing test or a slowdown, e.g. "debug this", "diagnose", "X never shows", "when I paste it, it fails", "the build got slower".'
---

# Debug

A discipline for hard bugs. Skip phases only when explicitly justified.

When exploring the codebase, read the repo's glossary or domain doc (`GLOSSARY.md`, `CONTEXT.md`) if one exists to get a clear mental model of the relevant modules, and check ADRs in the area you're touching. Read `GATES.md` for the check commands, what each covers and how long it takes.

Keep scratch artifacts (harnesses, captured traces, fixtures, repro scripts, measurements) in `.context/debug/<slug>/`, which git ignores.

## Redact

This skill has you show commands, outputs and captured artifacts. **Redact every secret first**: write `<REDACTED>` in its place. Build loops that read credentials from the environment (injected by the repo's secret tool, e.g. `fnox exec -- <loop>`), so the credential stays out of what you show. Captured artifacts carry auth headers: quote only the lines that carry the signal.

If the redacted output is not enough to diagnose the bug, say so and ask the user.

## Phase 1: Build a feedback loop

**This is the skill.** Everything else is mechanical. If you have a **tight** pass/fail signal for the bug (one that goes red on _this_ bug), you will find the cause; bisection, hypothesis-testing, and instrumentation all just consume it. If you don't have one, no amount of staring at code will save you.

Spend disproportionate effort here. **Be aggressive. Be creative. Refuse to give up.**

### Ways to construct one, in roughly this order

1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e. `GATES.md` names the runner; run the single test or file, not the suite.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** that drives the UI and asserts on DOM/console/network.
5. **Replay a captured trace.** Save a real network request / payload / event log to `.context/`; replay it through the code path in isolation.
6. **Throwaway harness.** Spin up a minimal subset of the system (one service, mocked deps) that exercises the bug code path with a single function call.
7. **Property / fuzz loop.** If the bug is "sometimes wrong output", run 1000 random inputs and look for the failure mode.
8. **Bisection harness.** If the bug appeared between two known states (commit, dataset, version), automate "boot at state X, check, repeat" so you can `git bisect run` it.
9. **Differential loop.** Run the same input through old-version vs new-version (or two configs) and diff outputs.
10. **No loop in sight? Build one.** Drive a UI with a browser automation tool, script against the real service, or capture a fixture or recording and replay it. Ask a person only for what no tool can reach (a physical device, a login you lack), and report that as a blocker.

Build the right feedback loop, and the bug is 90% fixed.

### Tighten the loop

Treat the loop as a product. Once you have _a_ loop, **tighten** it:

- Can I make it faster? (Cache setup, skip unrelated init, narrow the test scope.)
- Can I make the signal sharper? (Assert on the specific symptom, not "didn't crash".)
- Can I make it more deterministic? (Pin time, seed RNG, isolate filesystem, freeze network.)

A 30-second flaky loop is barely better than no loop; a 2-second deterministic one is tight, a debugging superpower.

### Non-deterministic bugs

The goal is not a clean repro but a **higher reproduction rate**. Loop the trigger 100×, parallelise, add stress, narrow timing windows, inject sleeps. A 50%-flake bug is debuggable; 1% is not, so keep raising the rate until it's debuggable.

### When you genuinely cannot build a loop

Stop and say so explicitly. List what you tried. Ask the user for: (a) access to whatever environment reproduces it, (b) a redacted captured artifact (HAR file, log dump, core dump, screen recording with timestamps), or (c) permission to add temporary production instrumentation. Do **not** proceed to hypothesise without a loop.

### Completion criterion: a tight loop that goes red

Phase 1 is done when the loop is **tight** and **red-capable**: you can name **one command** (a script path, a test invocation, a curl) that you have **already run at least once** (show the invocation and its output, redacted), and that is:

- [ ] **Red-capable**: it drives the actual bug code path and asserts the **user's exact symptom**, so it can go red on this bug and green once fixed. Not "runs without erroring"; it must be able to _catch this specific bug_.
- [ ] **Deterministic**: same verdict every run (flaky bugs: a pinned, high reproduction rate, per above).
- [ ] **Fast**: seconds, not minutes.
- [ ] **Agent-runnable**: you run it unattended, with no person in the loop.

If you catch yourself reading code to build a theory before this command exists, **stop: jumping straight to a hypothesis is the exact failure this skill prevents.** No red-capable command, no Phase 2.

## Phase 2: Reproduce + minimise

Run the loop. Watch it go red as the bug appears.

Confirm:

- [ ] The loop produces the failure mode the **user** described, not a different failure that happens to be nearby. Wrong bug = wrong fix.
- [ ] The failure is reproducible across multiple runs (or, for non-deterministic bugs, reproducible at a high enough rate to debug against).
- [ ] You have captured the exact symptom (error message, wrong output, slow timing) so later phases can verify the fix actually addresses it.

### Minimise

Once it's red, shrink the repro to the **smallest scenario that still goes red**. Cut inputs, callers, config, data, and steps **one at a time**, re-running the loop after each cut, and keep only what's load-bearing for the failure.

Why bother: a minimal repro shrinks the hypothesis space in Phase 3 (fewer moving parts left to suspect) and becomes the clean regression test in Phase 5.

Done when **every remaining element is load-bearing**: removing any one of them makes the loop go green.

Do not proceed until you have reproduced **and** minimised.

## Phase 3: Hypothesise

Generate **3–5 ranked hypotheses** before testing any of them. Single-hypothesis generation anchors on the first plausible idea.

Each hypothesis must be **falsifiable**: state the prediction it makes.

> Format: "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

If you cannot state the prediction, the hypothesis is a vibe: discard or sharpen it.

**Show the ranked list to the user before testing.** They often have domain knowledge that re-ranks instantly ("we just deployed a change to #3"), or know hypotheses they've already ruled out. Cheap checkpoint, big time saver. Don't block on it; proceed with your ranking if the user is AFK.

## Phase 4: Instrument

Each probe must map to a specific prediction from Phase 3. **Change one variable at a time.**

Tool preference:

1. **Debugger / REPL inspection** if the env supports it. One breakpoint beats ten logs.
2. **Targeted logs** at the boundaries that distinguish hypotheses.
3. Never "log everything and grep".

**Tag every debug log** with a unique prefix, e.g. `[DEBUG-a4f2]`. Cleanup at the end becomes a single grep. Untagged logs survive; tagged logs die.

**Perf branch.** For performance regressions, logs are usually wrong. Instead: establish a baseline measurement (timing harness, `performance.now()`, profiler, query plan), then bisect. Measure first, fix second.

## Phase 5: Fix + regression test

Write the regression test **before the fix**, but only if there is a **correct seam** for it.

A correct seam is one where the test exercises the **real bug pattern** as it occurs at the call site. If the only available seam is too shallow (single-caller test when the bug needs multiple callers, unit test that can't replicate the chain that triggered the bug), a regression test there gives false confidence.

**If no correct seam exists, that itself is the finding.** Note it in your report: the codebase architecture is preventing the bug from being locked down.

If a correct seam exists:

1. If an existing test already drives this behaviour at this seam, extend it instead of adding one.
2. Turn the minimised repro into a failing test at that seam, named for the behaviour it protects: `it("rejects descriptions over 1,000 characters")`, not `it("fixes bug #123")`.
3. Watch it fail in its own assertion (an import, fixture or setup error is a broken test, not a red one). If you forced the red by mutating code or a fixture, `diff` against a pristine copy to prove the mutation landed before you trust it.
4. Apply the fix.
5. Watch it pass.
6. Re-run the Phase 1 feedback loop against the original (un-minimised) scenario, then the cheapest `GATES.md` checks that cover the packages you touched.

The name and assertion explain the test. Add a comment only when they leave its value unclear. If the regression isn't obvious from the name, put one line in the PR body on why the test exists and what a green run doesn't prove (mocks or fixtures standing in for reality). If production code gained an export, flag or hook that only this test uses, the test belongs at a real boundary instead.

### Fix the cause

The fix removes the root cause, at the layer that owns the broken invariant. A small, targeted fix is right when it is that fix. A fix that routes around a design problem or a fault in the surrounding code is not, even if it turns the loop green: fix the cause, or, if that is large, report the design question with options and a recommended default. When the code invited the bug (two lists kept in step by hand, a check copied across callers), that structure is part of the cause; restoring the one broken entry alone leaves it in place.

A fix that turns this loop green but exposes new failures elsewhere means its premise is wrong. Write that premise down and test it as a hypothesis (Phase 3 format) instead of patching the next failure.

## Phase 6: Cleanup

Required before declaring done:

- [ ] Original repro no longer reproduces (re-run the Phase 1 loop)
- [ ] Regression test passes, under a name that states the behaviour it protects (or absence of seam is documented)
- [ ] Failing-before and passing-after output shown
- [ ] All `[DEBUG-...]` instrumentation removed (`grep` the prefix)
- [ ] Throwaway harnesses and repro scripts left only in `.context/`, nothing scratch in the diff
- [ ] The hypothesis that turned out correct is stated in the commit / PR message, so the next debugger learns
