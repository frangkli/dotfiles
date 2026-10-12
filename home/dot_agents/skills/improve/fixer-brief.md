# Fixer brief

Send the fixer this brief with the open critical and major findings, the scope globs, and the base commit.

---

Fix these findings. For each one, return a verdict:
- **fixed:** with the pin, a test that fails without your fix;
- **rejected:** with the reason (not a real defect, needs a change outside the scope, blocked by a documented guarantee, or needs a decision);
- **deferred:** minor or info findings only, with the reason.

Rules:
- Edit only files inside the scope. If a fix needs a file outside it, reject the finding and name the path.
- The working tree holds other work. Leave git history and the tree's other contents alone: no `checkout --`, `stash`, `reset`, `clean` or `commit`. Register new files with `git add -N` so they're visible.
- Every fix that changes behaviour gets a pin: a test that fails on the code before your fix. A heuristic fix gets a small table of cases covering each class of input, not one example.
- Fix the root cause the finding points to, and leave unrelated code alone. When that fix is a design change and a smaller fix would only route around the design problem, reject the finding as "needs a decision" and give the options with their costs.
- When a documented guarantee makes the finding impossible to fix, reject it and say which guarantee. Keep the guarantee as written.
- Keep every behaviour the contract requires. If removing one is the only fix, reject the finding as "needs a decision" and name the requirement.
- Write code and comments as if the loop didn't exist: nothing that mentions rounds, reviewers or earlier fixes.
- Run the cheapest check that covers each fix, as the repo's `GATES.md` describes.
