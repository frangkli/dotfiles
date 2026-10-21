---
name: test-audit
description: Judge whether tests earn their place. Use when sweeping a suite or path for low-value, duplicate or implementation-coupled tests and the test-only code they keep alive, when a change adds test infrastructure or a large batch of tests, when asked to audit tests, or when proving a regression test for a bug fix. Ordinary per-change review gets the same value bar from adversarial-review's test-integrity lane.
---

# Test audit

A test earns its place when it fails on a credible regression that nothing else catches, through a seam production code already uses. This skill applies that bar in two modes:

- **Gate:** the tests a change adds or edits, on the diff from the merge base. For a change that adds test infrastructure or a large batch of tests, or when asked; every other change gets this bar from `adversarial-review`'s test-integrity lane.
- **Sweep:** the tests that already exist, across a path or the whole repo. Follow [sweep.md](sweep.md).

Few well-evidenced verdicts beat a long speculative list, and "every test earns its place" is a valid result.

## The value bar

A test needs all four answers. Without them, extend an existing test, move the proof to the real boundary, or leave the test out.

1. **Protects:** which observable behavior, invariant or independent contract?
2. **Fails when:** which credible regression turns it red?
3. **Why new:** why doesn't existing coverage catch that regression? Adding a row to an existing table-driven test or shared fixture beats a near-duplicate.
4. **Seam:** does it need an export, flag, wrapper or injection hook that no production caller needs? Then test at the boundary production uses instead.

A test that breaks under a behavior-preserving refactor is asserting implementation. Rewrite it at the owning boundary, unless exact output is the declared contract (golden files, wire formats, prompt bytes).

## Names and notes

A test explains itself through its name: it states the behavior it protects, e.g. `it("rejects descriptions over 1,000 characters")`. Add a comment only when the name and assertions leave the value unclear, such as a regression that isn't obvious or a fake standing in for a real system.

For a non-obvious test, one line on why it exists goes in the PR body (through `pr`) or the caller's report: the regression it catches, and what a green run doesn't prove (which fakes stand in, which live check is still owed). Obvious tests get no note.

## Regression proof

A test that claims to catch a bug carries three observations, each from a real run:

1. **Fails at HEAD**, before the fix, on its own assertion. A pass means it isn't a regression test. An import, fixture or environment error is a broken test: fix it once, or drop the claim.
2. **Passes at base**, the last commit before the bug, as the control. An assertion failure there means the test checks something else. If base can't run, record why.
3. **Passes after the fix.**

Record: `Regression proof: fails at HEAD yes · passes at base yes | unavailable (<reason>) · passes after fix yes`.

## Gate

1. List every test the change adds or edits (`git diff --name-only <merge-base>` filtered to test files, then the changed cases inside them).
2. For each, answer the four questions. A test with a missing answer is extended into an existing test, moved to the real boundary, or removed, with the reason. Rename a test whose name doesn't state the behavior it protects.
3. Check each against [catalog.md](catalog.md). A match fails the gate unless the retention bar names the contract the test guards.
4. For a test you doubt, break the subject in a scratch `git worktree` under `.context/`, never `/tmp` (return a constant, delete the guarded branch). The test must go red; if it stays green, it protects nothing.
5. For every regression test, record the regression proof.
6. Edited tests: an assertion weakened, an expected value changed or a case deleted needs a stated behavior change. Otherwise restore it and fix the code.

Done when every added or edited test answers all four questions under a name that states its behavior (or has a recorded reason for its change), every non-obvious test has its note, and every regression test has all three observations.
