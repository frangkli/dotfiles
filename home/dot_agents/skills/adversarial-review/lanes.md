# Lanes

Each lane is one subagent with one angle. Paste the lane's brief into [reviewer-brief.md](reviewer-brief.md), after the packet. The bug pass is correctness and security, test integrity, `ocr` and Codex; the combined reviewer gets the correctness and security brief and the test integrity brief together.

## Code changes

### Correctness and security

Find what breaks. Review only code the change adds or modifies, and use the packet's uses list to see how it is called.

- **Logic:** wrong results, unhandled states, off-by-one and boundary cases, error paths that hide a failure.
- **Concurrency and retries:** races, missing idempotency, retried non-idempotent work, missing timeouts or cancellation, unbounded queues or memory.
- **Cross-module effects:** a change in one place that silently breaks behaviour somewhere else.
- **Developer experience:** renamed or new environment variables, moved secrets, remapped ports, new setup steps that nobody will know to run.
- **Feature gates:** gated work that leaks outside its gate.
- **Security:** trace every input from where it enters to where it is used: injection, authorisation gaps, secrets in logs or responses.
- **Data and contracts:** schema, API or event changes that break old data, old clients or in-flight messages.

When the change clearly intends something risky (removing a flag, deleting a safeguard) and keeps it well contained, that is the intent, not a finding, unless the author seems unaware of the consequences.

### Test integrity

Check that the tests prove the change, and that each test earns its place.

- **Refute the verification.** Did the claimed checks actually run, exercise the changed path, and touch the real artifact rather than a fixture or a cached output? A check that failed to start counts as no check.
- **Weakened tests.** Assertions loosened, expected values changed, tests skipped or deleted, or inputs special-cased in the same change as the code, without a stated reason.
- **Vacuous tests.** Tests that would still pass if the subject returned nothing or a constant.
- **Held-out input.** For each changed behaviour, name one input the tests don't cover and check it by hand.
- **Scope against the contract.** Changed files outside the contract's reach, and any requirement that was narrowed or quietly reinterpreted.
- **Value**, minor findings only. Each added test answers four questions: which behaviour it protects, which credible regression turns it red, why existing coverage doesn't already catch that, and whether it needs a seam (an export, flag or hook) no production caller uses. A test missing an answer, a near-duplicate, or one that breaks under a behaviour-preserving refactor is a finding; [../test-audit/catalog.md](../test-audit/catalog.md) lists the usual patterns.

### Design and style

Find what will be costly to change later, and what breaks the repo's conventions. Check the code against the repo's style or conventions document and, for each language the change touches, its language skill's `references/review.md` (TypeScript also `references/effect-review.md` in a package that imports `effect`); the packet lists the paths.

- **Full depth on public interfaces, shared types, contracts and schemas:** names, which module owns the data, what a caller must know to use it, invalid states the types allow, and what a later change would have to break.
- **Elsewhere, only findings with a concrete cost:** logic in the wrong layer; a duplicate of a helper that already exists; special cases bolted into unrelated flows; wrappers or casts that paper over a mismatched contract; a simpler shape that deletes a layer or a set of conditionals. Rank remedies by how much they delete.
- **Style:** every item of the documents above that the added or modified lines break.

The evidence for a finding is the document item it breaks and the line that breaks it, or the concrete later change it makes costly, in place of a path to failure. A design problem in a public interface can be major; style items are minor or info.

### Blast radius (small changes whose safety rests on one fact)

Listing callers is quick; the job is the breakage a search won't show. Find the one fact the change is safe because of, then look where search stops: library source at the pinned version, timing (teardown, async ordering), wire formats, stored data, flags, code several hops away. Prove that fact by running real code. Report how far the proof got: stated, pointed at the line, walked the failure path, ran a script against the real code, reproduced in the app.

### `ocr`

Run open-code-review on the same base and head. ocr takes one background file, and it warns once that file passes about 2,000 characters, so keep it short. Write the contract, the three wording rules from [../improve/ledger.md](../improve/ledger.md), the repo's `REVIEW_RULES.md` Known non-issues when it has them, and the known list (`python3 ~/.agents/skills/improve/scripts/ledger.py known <state> <characters left>`) to `<state>/round-<n>/ocr-background.md`, and pass that:

```bash
timeout 900 ocr review --from <base> --to <head> --background-file <state>/round-<n>/ocr-background.md --format json --audience agent > <state>/round-<n>/raw/ocr.json
```

As soon as it finishes, read it and write its findings in the lane result format to `<state>/round-<n>/ocr.json`; an unread result is a gap. Exit code 0 doesn't prove coverage. `ocr review --preview` with the same refs lists the files ocr's rules select; changed files it leaves out (typically tests and docs) are excluded by design, so note them, since the test-integrity lane covers tests. A previewed file missing from the output's `coverage.completed`, or listed under `failed`, wasn't reviewed, and the lane reports it as a partial gap by name. If `ocr` isn't installed, can't reach its model (`ocr llm test` fails) or lacks credentials, record the lane as BLOCKED, which makes it a gap.

### Codex

The other vendor's model, on the bug pass: [cross-model.md](cross-model.md).

### GitHub Actions (changes that touch `.github/workflows/**`)

Run the `gha-security-review` skill on the changed workflow files, under the reviewer brief, and write its findings with their exploitation scenarios to the lane's result file.

## Plans and specs

### Problem fit

Rebuild the problem from first principles, then check the plan against it. This lane alone questions the goal itself.

- **Solves the stated problem:** walk from the problem statement to the done-predicate. Find phases that ship something other than what the problem asks for, and parts of the problem no phase reaches.
- **Traces to evidence:** the problem rests on an issue, data or a user report. Name each claim of need that the plan doesn't trace to one.
- **Cheaper route:** the goal met without building this, by configuring or reusing what exists, or by removing code, a step or a feature.
- **Hidden goal:** a stated non-goal that is the real goal, or that the plan's own success depends on.

The evidence for a finding is the plan section and the source that contradicts it or is missing (an issue, a file, a measurement), in place of a path to failure.

### Design correctness

Walk the plan's main flows end to end against the code that exists today. Find steps that can't work as written, missing failure handling, data-model changes with no migration path, and acceptance criteria nobody could check.

### Operational burden

Find what this costs to run: new services, jobs, credentials, configuration or manual steps; failure modes someone gets paged for; observability needed to tell whether it works in production; rollout and recovery steps.

### Overengineering

Find what could be smaller: abstractions with one user, options nobody asked for, new layers or patterns where an existing one fits, work the stated goal doesn't need. Name the smaller version.
