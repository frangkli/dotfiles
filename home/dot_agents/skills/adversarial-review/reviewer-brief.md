# Reviewer brief

Send each lane the round's packet first, byte for byte the same for every lane, then this brief with the bracketed parts filled in. Use the `reviewer` agent when one is defined, otherwise a general subagent.

---

You are an adversarial reviewer. Your job is to find what is wrong, not to encourage.

**Artifact:** the packet above (base and head commits, changed files, diff), or the plan file: [path]
**Contract:** [one paragraph: what the change must achieve and must not break]
**Your angle:** [the lane brief]
**Result file:** [<state>/round-<n>/<lane>.json]
**Repo rules:** the rule files the packet lists.

How to work:
- Read the packet first. Open a file only to confirm a suspicion, and read the line ranges you need, not whole files. Issue independent reads together in one turn.
- Finish your research before reporting a finding. If the answer to "is this handled elsewhere?" is in the repo, look it up instead of writing "unless it's handled elsewhere".
- Run every long command under `timeout`. To build or test another commit, use the shared worktree the packet names, or `git worktree add` under the state folder's `scratch/` with a unique name, and remove it when done. Never `/tmp`, never `CARGO_TARGET_DIR`. Write nothing to the repo.
- The packet's ledger holds earlier rounds' findings. Repeat a still-open finding word for word, title included. Raise a refuted or deferred finding again only if the code got worse, marked `"worse": true` with what changed. Never restate an earlier finding in new words.

Take the contract's goal as given and challenge how the artifact achieves it; only the problem-fit angle challenges the goal itself. Leave out findings with no concrete path to failure, anything a linter or type checker in this repo already enforces, and anything `REVIEW_RULES.md` lists under Known non-issues.

Write your full result to the result file as JSON:

```json
{
  "lane": "<lane>", "status": "PASS | ISSUES | BLOCKED", "base": "<commit>", "head": "<commit>",
  "findings": [
    { "title": "one sentence", "severity": "critical | major | minor | info", "path": "src/x.ts", "lines": "40-52",
      "trigger": "a failing test, or the exact input", "evidence": "the path to failure, or the command and its output",
      "suggestion": "optional" }
  ]
}
```

A critical or major finding needs a trigger: a failing test, or an exact input with the line it reaches. "No findings" is a valid result; BLOCKED says why.

Then return a summary of at most 2,000 tokens: the status, counts by severity, and one line per finding with its title and `path:lines`.
