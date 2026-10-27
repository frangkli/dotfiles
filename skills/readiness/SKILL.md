---
name: readiness
description: Audit how well a repo supports coding agents, report gaps and a readiness level, then fix the gaps you approve.
disable-model-invocation: true
---

# Readiness

Uneven agent results usually come from the repo, not the model: no fast check, setup that only works on one machine, no scripted way to see the app work. This skill scores a repo against capability criteria, reports the gaps that slow agents most, and fixes only what the user approves.

It judges capabilities, never tools: a criterion passes with whatever the repo already uses. A new repo runs the same steps; every criterion fails, and the recommendations become its setup plan.

## 1. Ground on the last report

Find the newest `docs/research/*-readiness.json`. If one exists, load it: each criterion starts from its last verdict, and a changed verdict needs evidence of what changed in the repo. This is what keeps two runs on the same repo from scoring differently.

Done when you have the previous verdicts loaded, or have confirmed there is no previous report.

## 2. Identify

Read before judging. Record:

- **Stacks:** languages, package managers, toolchain pins.
- **Apps:** each independently run or deployed unit (web app, API, worker, CLI, published package) with its surface (UI, HTTP, CLI, library), its start command and where it deploys. App-scoped criteria are scored once per app.
- **Existing tools:** checkers, test runners, hooks, CI system, review bots, secrets handling, observability backends, agent docs (`AGENTS.md`, `GATES.md`, `GLOSSARY.md`, `t3.json`, the `verify` skill under `.agents/skills/`).
- **Conditions that make criteria apply:** per app, whether it renders React or JSX, uses shadcn/ui (`components.json`), is a shared component library, calls a model (an LLM SDK in its dependencies), and has users or runs in production (ask the user when the repo doesn't show it).

Done when every app has a surface, a start command (or "none found"), its list of checkers and its conditions.

## 3. Audit

Run bite tests and setup checks in a scratch worktree of the audited commit, so they never touch the user's tree. Remove it when the audit ends.

Score every criterion in [criteria.md](criteria.md) as **PASS**, **FAIL** or **N/A**, per app where it is app-scoped:

- Evidence is a file and line, a command with its exit code and the deciding output line, or a measured time. A claim without evidence is a FAIL.
- A checker passes only after it bites: break one rule it should catch, see it fail, revert, see it pass. Recipes: [bite-tests.md](bite-tests.md).
- If the repo has CI workflows, run `gha-security-review` on them for the workflow-audit criterion.
- A criterion you couldn't check (missing credentials, a service you can't start) is a FAIL that names what blocked it. N/A needs a reason (a library has no deploy).

Done when every criterion has a verdict and evidence for every scope it applies to, and the scratch worktree is gone.

## 4. Score and report

**Level.** A level counts when at least 80% of its applicable criteria pass, and every level below it counts too. An app-scoped criterion adds one entry per app. Level 3 is the first target.

Write the report per [output.md](output.md): gaps first, ordered by how much they slow agents, then the level, the changes since the last report, and the evidence table. Save it in the checkout you were started in, as `docs/research/<YYYY-MM-DD>-readiness.html` with its `.json` sidecar.

Done when both files exist and every FAIL appears in the gap list.

## 5. Recommend

For each gap, give one to three options that fit the repo's stack and existing tools, each with its effort and what it changes. When an option in [defaults.md](defaults.md) fits, offer it as the recommended default; when it doesn't fit, say why and recommend what does. Fixes for the agent docs and checks areas follow [agent-docs.md](agent-docs.md); dev environment fixes follow [worktrees.md](worktrees.md) and [postgres.md](postgres.md).

Under DOC-6, also offer per-project installs of stack skills that match the detected stack: the vendor's own skill first (Sentry, Neon, Prisma, Stripe, Cloudflare, Supabase and Expo publish them; Next.js, Playwright, Storybook and TanStack ship them in the package), installed into `.agents/skills/` with `npx skills add <owner/repo> --skill <name> --agent codex`. List each pick with its source; read a pick's body before installing it.

End the report with the decision batch: one line per gap, the recommended option first, and what happens if the gap stays. Then stop. The audit changes nothing in the repo beyond the two report files.

## 6. Fix the approved gaps

Only after the user approves, and only the gaps they approved:

1. One branch for all approved fixes. Merge into existing configs, never overwrite them. For a missing `verify` skill, run `verify-create` once per app surface. `PRODUCT.md` and `DESIGN.md` stay the owner's: the hand-off names `/impeccable init`, which interviews the owner before it writes `PRODUCT.md`. After writing `t3.json`, the hand-off tells the owner to import its actions once in T3's project settings.
2. Prove each fix: the criterion it targets now passes with fresh evidence, including its bite test.
3. Re-run steps 3–4 on the branch and save the new report beside the old one.
4. Ship through `pr`, with the before and after levels in the body.

Done when the re-run audit passes every approved criterion and the PR's checks are green on its head commit.
