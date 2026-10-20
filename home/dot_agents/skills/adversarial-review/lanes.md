# Lanes

Each lane is one subagent with one angle. Paste the lane's brief into [reviewer-brief.md](reviewer-brief.md).

## Code changes

### Correctness and security

Find what breaks. Review only code the change adds or modifies, and read beyond the diff to see how it is called.

- **Logic:** wrong results, unhandled states, off-by-one and boundary cases, error paths that hide a failure.
- **Concurrency and retries:** races, missing idempotency, retried non-idempotent work, missing timeouts or cancellation, unbounded queues or memory.
- **Cross-module effects:** a change in one place that silently breaks behaviour somewhere else.
- **Developer experience:** renamed or new environment variables, moved secrets, remapped ports, new setup steps that nobody will know to run.
- **Feature gates:** gated work that leaks outside its gate.
- **Security:** trace every input from where it enters to where it is used: injection, authorisation gaps, secrets in logs or responses.
- **Data and contracts:** schema, API or event changes that break old data, old clients or in-flight messages.

When the change clearly intends something risky (removing a flag, deleting a safeguard) and keeps it well contained, that is the intent, not a finding, unless the author seems unaware of the consequences.

### Structure

Find what makes the code harder to change next time. Prefer a few high-conviction findings over a list of cosmetic notes.

- A file pushed past roughly a thousand lines.
- Special cases bolted into unrelated flows, and feature checks scattered through shared code.
- Logic in the wrong layer; a duplicated copy of a helper that already exists.
- Wrappers, adapters or casts that only paper over a mismatched contract.
- A simpler idea that would remove the problem rather than tidy it: deleting a layer of indirection, or reshaping the state so conditionals disappear.

Rank remedies by how much they delete.

### Test integrity

Check that the tests prove the change.

- **Refute the verification.** Did the claimed checks actually run, exercise the changed path, and touch the real artifact rather than a fixture or a cached output? A check that failed to start counts as no check.
- **Weakened tests.** Assertions loosened, expected values changed, tests skipped or deleted, or inputs special-cased in the same change as the code, without a stated reason.
- **Vacuous tests.** Tests that would still pass if the subject returned nothing or a constant.
- **Held-out input.** For each changed behaviour, name one input the tests don't cover and check it by hand.
- **Scope against the contract.** Changed files outside the contract's reach, and any requirement that was narrowed or quietly reinterpreted.

### Idioms

Check the changed lines against the language's house idioms. For each language the change touches, load its language skill's `references/review.md` (TypeScript: `typescript/references/review.md`, plus `references/effect-review.md` in a package that imports `effect`) and apply every item to code the change adds or modifies. Apply the repo's own style or conventions document too, when AGENTS.md names one or the root has one (for example `STYLE.md`). Review only idiom and style; design belongs to the structure lane. The evidence for a finding is the review.md or repo document item it breaks and the line that breaks it, in place of a path to failure; severity is minor or info. A language with no `references/review.md` and no repo document gets PASS with "no review.md for <language>".

### Blast radius (small changes whose safety rests on one fact)

Listing callers is quick; the job is the breakage a search won't show. Find the one fact the change is safe because of, then look where search stops: library source at the pinned version, timing (teardown, async ordering), wire formats, stored data, flags, code several hops away. Prove that fact by running real code. Report how far the proof got: stated, pointed at the line, walked the failure path, ran a script against the real code, reproduced in the app.

### `ocr`

Run open-code-review on the same base and head. ocr takes one background file, so write the plan or contract, followed by the repo's `REVIEW_RULES.md` when it exists and `improve`'s ledger when there is one, headed by the reviewer brief's rule on the ledger, to `.context/adversarial-review/<slug>/background.md` and pass that:

```bash
ocr review --from <base> --to <head> --background-file .context/adversarial-review/<slug>/background.md --format json --audience agent
```

Exit code 0 doesn't prove coverage. `ocr review --preview` with the same refs lists the files ocr's rules select; changed files it leaves out (typically tests and docs) are excluded by design, so note them, since the test-integrity lane covers tests. A previewed file missing from the output's `coverage.completed`, or listed under `failed`, wasn't reviewed, and the lane reports it as a partial gap by name. If `ocr` isn't installed, can't reach its model (`ocr llm test` fails) or lacks credentials, record the lane as BLOCKED, which makes it a gap.

### GitHub Actions (changes that touch `.github/workflows/**`)

Run the `gha-security-review` skill on the changed workflow files and report its findings with their exploitation scenarios.

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
