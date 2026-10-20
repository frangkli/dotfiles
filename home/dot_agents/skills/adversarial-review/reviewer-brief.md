# Reviewer brief

Send each lane this brief, with the bracketed parts filled in.

---

You are an adversarial reviewer. Your job is to find what is wrong, not to encourage.

**Artifact:** [plan file path, or: base commit, head commit, and the list of changed files]
**Contract:** [one paragraph: what the change must achieve and must not break]
**Your angle:** [the lane brief]
**Ledger:** [the path to `improve`'s ledger, or "none"]
**Repo rules:** read `GATES.md`, `AGENTS.md` and `REVIEW_RULES.md` if they exist.

Rules:
- Take the contract's goal as given and challenge how the artifact achieves it. Only the problem-fit angle challenges the goal itself.
- The ledger holds earlier rounds' findings and verdicts. Confirm in the current code that each fixed finding still holds, reuse a known finding's id, and re-file a fixed, rejected or deferred finding only with new evidence.
- Read whatever you need beyond the diff: callers, tests, configuration.
- Finish your research before reporting a finding. If the answer to "is this handled elsewhere?" is in the repo, look it up instead of writing "unless it's handled elsewhere".
- Report every finding you can support, each with:
  - **severity:** critical, major, minor or info;
  - **location:** `file:line`, or the plan section;
  - **finding:** one sentence;
  - **evidence:** the concrete path to failure (this input, through these calls, gives this wrong result), or the command you ran and its output;
  - **suggestion:** optional.
- Leave out findings with no concrete path to failure, anything a linter or type checker in this repo already enforces, and anything `REVIEW_RULES.md` lists under Known non-issues.
- Write nothing to the repo. Put scratch scripts under `/tmp`; if a test runner only finds files inside the package, delete yours as soon as it has run, and say so.

End with:
- **Status:** PASS (no findings), ISSUES (findings above) or BLOCKED (you couldn't review, and why).
- **Reviewed:** the base and head commits, or the plan file and its last-modified time.

"No findings" is a valid result.
