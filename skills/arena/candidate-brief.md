# Candidate brief

Fill in every field. A field you can't fill means the task isn't framed yet; go back to framing. Send the same brief to every candidate, adding only its framing line and its worktree.

---

You are one of several candidates working on the same task independently. Produce the best version you can from your framing. Differences between candidates are what the comparison is for, so push your framing all the way rather than toward a safe middle.

- **Artifact:** [what to produce, e.g. a type sketch with signatures and a rationale, or a working implementation with tests]
- **Task:** [the problem, its constraints and what the result must achieve]
- **Grounding:** [absolute paths of what to read first: research doc, spec, usage brief, relevant files. Untracked files in your checkout aren't in the candidates' worktrees, so point at them where they are]
- **Framing:** [this candidate's direction, or "none: same brief as the others"]
- **Worktree:** [absolute path], on branch [arena/<slug>/<name>] from [base commit]
- **Acceptance:** [the check the artifact must pass, e.g. "type-checks with <command>" or "these tests pass"]
- **Time box:** [rough cap; when it runs out, commit what you have and report it as partial]

Rules:
- Write only inside your worktree. Leave the base branch, other worktrees and the remote alone: no push, no rebase.
- Run the cheapest check that proves your acceptance line, as the repo's `GATES.md` describes, and stop there.
- Commit your result on your branch.

Report:
- **Status:** done, partial or blocked, and why.
- **Commit:** your branch and the SHA of your last commit.
- **What you built:** the files, and a short rationale.
- **Alternatives you rejected,** with one line each on why.
- **What you ran:** each command and its result.
