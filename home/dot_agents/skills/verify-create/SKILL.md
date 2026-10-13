---
name: verify-create
description: "Generate a project's `verify` skill that drives the app the way a user does, on any language, framework or platform. Use when a repo has no scripted way to prove UI, CLI or service behavior, when adding an app surface to an existing `verify` skill, or when readiness fixes its verification gap."
---

# Create a verification skill

Every serious project needs a scripted way to drive the real app and prove behavior: launch it, exercise a feature the way a user would, and capture evidence. This skill generates that as the project-local skill `.agents/skills/verify/`, tailored to the repo. You write the generator's output for the next agent, not for a human: it will be read cold, mid-task, by an agent that has never seen the app, so write it per the `writing-for-agents` skill.

## 1. Interview the repo, not the user

Answer these from the codebase and only ask the user what you cannot observe:

- **Surface:** what does a user actually touch? A web UI, a CLI/TUI, a desktop app, an API, a mobile app, a library? A repo can have several; cover the one you were asked for (else the primary one) and note the rest.
- **Run:** how does the app start locally? Prefer the repo's own documented dev command (package scripts, task runner, README quickstart, `GATES.md`). Note ports, env vars, seed data, auth. Secrets come through the repo's secrets command (for example `fnox exec -- <command>`).
- **Drive:** how can an agent interact with it programmatically? Existing harnesses first — browser specs, expect scripts, PTY helpers, curl-able endpoints, a debug port. Only then pick a generic recipe: a browser automation CLI or CDP for web and Electron, a tmux/PTY harness for CLI/TUI, plain HTTP for services.
- **Observe:** what evidence can be captured? Screenshots, terminal transcripts, response bodies, logs, traces, exit codes, DB state.
- **Isolate:** can two instances run side by side (ports, data dirs, profiles, one database per worktree)? If not, say so in the generated skill: refusing to double-drive a shared instance beats corrupting the user's session.
- **Deploy:** does this surface deploy somewhere? Where, how is the live revision exposed, and what telemetry shows it working?

If the checkout doesn't build or start as-is, fix that first (or report it precisely) before generating; a skill written against a broken base teaches wrong steps. When an irrelevant missing asset blocks startup (a static dir the API never serves, a sample config), the generated skill may create it, clearly marked as verification scaffolding, and remove it in cleanup.

## 2. Generate the skill

Write `.agents/skills/verify/SKILL.md` with YAML frontmatter (`name: verify` and a `description` that names the app, its surfaces, and when to reach for it — without frontmatter the skill never registers; keep it model-invoked, with no `disable-model-invocation`, so agents reach it whenever they must prove a change) and these sections, each grounded in what the interview actually found (no placeholders left). When the repo has more than one surface, `SKILL.md` keeps what all surfaces share and routes to one `<surface>.md` per surface holding these sections; adding a surface later adds a file and a router line, and leaves the others alone.

- **Launch:** the exact command that starts the app for verification, and how to tell it's ready (a log line, a port answering, a prompt). Include teardown. For a short-lived CLI or TUI there is no server to keep alive: launch means build the binary (or install deps) once, then start each drive in its own isolated PTY or tmux session.
- **Doctor:** one read-only check that answers "is this instance worth driving?" — process up, right version/build, port owned by us, auth valid. An agent runs this first whenever anything looks off.
- **Drive:** the harness recipe with real selectors/commands from this repo, not examples. Prefer stable handles (ARIA labels, data attributes, prompt strings, route paths) over coordinates and tab order.
- **Evidence:** what to capture for a proof and where it goes. State the proof standards: exercise the real user path, not internal setters or test-only endpoints; capture the action and the resulting state, not just the final screen; verify side effects (files written, rows inserted, messages sent) alongside what's visible; mocks only where a production boundary already isolates the external system. State inspection may confirm an observation; it never injects or forces the state being proven. When the safe path is a dry-run or test mode, verify what it actually skips by observing (files, network, git refs) rather than trusting its name: some dry-runs still touch the network or open a browser. Each proof ends in one verdict: VERIFIED, NOT VERIFIED, or INCONCLUSIVE (no valid baseline, noisy signal, or environment drift); inconclusive is never a pass.
- **Browser pass:** only for a web surface. After driving each mapped page, the skill runs `agent-browser a11y <url> --tags wcag2a,wcag2aa,wcag21aa,wcag22aa --json` (axe), `agent-browser console --json` and `agent-browser errors --json`. `a11y` exits 0 even when it finds violations, so the skill parses the JSON: the page fails on any `data.violations[]` entry with `impact` `critical` or `serious`, on a console message of type `error`, on a hydration warning, and on any page error. Moderate and minor violations are listed, not failed. Ship this as a helper script that prints each failure with its rule id and selector and exits non-zero on a failure.
- **Cleanup:** how to tear down instances the run created. Never kill by process name; kill what you started. Cleanup removes instances and scratch state, never the evidence: proof artifacts survive the teardown, in a location the skill names.
- **Post-deploy:** only for a surface that deploys. How to prove which revision is live and how to run a canary against a baseline, per [`references/post-deploy.md`](references/post-deploy.md).
- **Helpers:** any script the skill ships is executable and its invocation is shown in the skill body. A helper the reader has to reverse-engineer is not a helper.

Claude Code reads project skills from `.claude/skills/`. If the repo has no `.claude/skills` link to `.agents/skills`, say so in your hand-off with the command that adds it (`mkdir -p .claude && ln -s ../.agents/skills .claude/skills`, from the repo root); if `.claude/skills` is a real directory, give the command that links `verify` into it.

## 3. Seed the feature map

Create `.agents/skills/verify/features/README.md` plus one file per user-facing feature you can identify (aim for the top 3-5 to start, from routes, commands, menus, or docs). Follow the shape in [`references/feature-map-example/`](references/feature-map-example/), with a README index and one file per feature. Each file answers, from the user's point of view: what the feature is, how to reach it, how to drive it with the harness, and what observable end state proves it works. The four H2s are `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, and `Gotchas`. With several surfaces, each feature file names the surface it drives. The map is the repo's maintained verification source; a proof that drives one convenient entry point is incomplete when the map lists others.

## 4. Prove the generated skill before handing it over

Run its own instructions end to end once: launch, doctor, drive ONE mapped feature (one is enough; the map exists so later runs can cover the rest), capture evidence, clean up. After cleanup, confirm the evidence still exists at the named location — a cleanup that eats the proof fails this step. Fix what fails, and run the generated cleanup after every failed iteration too, so broken attempts don't strand processes and ports. A generated skill that was never executed is a draft, not a deliverable.

## 5. Offer the maintenance loop

Point the user at `verify-maintain` for keeping the map honest as the app changes. Suggest a cadence only if they ask.
