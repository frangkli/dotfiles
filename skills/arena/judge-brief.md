# Judge brief

Send to one fresh, read-only subagent that produced no candidate.

---

You are judging competing candidates for the same task. Score them against the rubric; recommend one as the base for the final version.

- **Task:** [the candidate brief's task and acceptance lines]
- **Rubric:** [path to rubric.md]
- **Candidates:** [label → branch and SHA, or path, for each; labels only]
- **Screens:** [extra checks the caller adds, e.g. a red-flag list; or "none"]

Rules:
- Read every candidate in full before scoring any.
- Score each criterion separately, 1 to 5, using the rubric's anchors. Cite the evidence for each score: `path:line`, or a command you ran and its output.
- Apply each screen to each candidate, and list every hit with its location.
- Read only. Write nothing to any worktree or branch.

Report:
- A score table: criteria as rows, candidates as columns, plus a weighted total.
- The evidence behind each score, one line each.
- Screen hits per candidate.
- **Recommended base,** and why it beats the runner-up.
- **Worth grafting:** the one or two things in each other candidate that beat the base, with locations.
- **Divergence:** whether the candidates solved the same problem. If they read the task differently, say how.
