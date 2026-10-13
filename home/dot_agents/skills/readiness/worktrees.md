# Worktree lifecycle

The recommended fix for ENV-1 and ENV-4 to ENV-7: six recipes, two T3 Code actions that call them, and cleanup that stays inside this project. The repo holds no harness hooks and no per-tool trigger files beyond `t3.json`.

## Recipes

| Recipe | Does |
|---|---|
| `setup` | Brings this worktree to runnable; idempotent; ends with straggler cleanup |
| `teardown` | Stops this worktree's processes, then drops its per-worktree resources |
| `check` | Lint, types, tests and build, read-only; the command CI runs |
| `fix` | Writes formatter and lint autofixes |
| `test <path>` | Runs the tests for one file or package |
| `dev` | Runs the app through Portless and prints the worktree's URL |

Use the repo's native runner: `package.json` scripts or `vp run <task>` in JS and TS repos, a root `justfile` only in a repo that mixes languages. `pnpm up` is pnpm's update command and `pnpm setup` is pnpm's own installer, so never name a script `up`, and call the setup script as `pnpm run setup` (or `vp run setup`) everywhere it appears. `GATES.md` maps each recipe to its command.

## `setup`

1. Check prerequisites (Docker reachable, pinned toolchain installed). On a failure, exit non-zero with the command that fixes it.
2. Hold a per-worktree lock for the rest of the run: `flock "$(git rev-parse --git-dir)/setup.lock" <rest of setup>`. Steps that touch project-wide resources also hold the project lock ([postgres.md](postgres.md)).
3. Install dependencies from the frozen lockfile, start backing services, create the worktree's database, and write `.env.local` (slug, ports, `DATABASE_URL`, the Portless URL).
4. Run straggler cleanup.
5. Print one line naming what is ready and the URL. Under ~2 s when already up.

## `teardown`

1. Stop the processes whose working directory is inside this worktree: each `/proc/<pid>/cwd` that resolves under the worktree path, except teardown's own process and its ancestors (the T3 terminal that runs it sits in the worktree). Send `TERM`, wait up to 5 s, then `KILL` the survivors.
2. Drop the worktree's resources: its database (`DROP DATABASE … WITH (FORCE)`) and its containers (selected by the label that holds the worktree path).

Print each process stopped and each resource dropped.

## Straggler cleanup

The last step of `setup` removes what deleted worktrees of this project left behind. It acts only on these two classes, and prints each action with its reason (`dropped database wt_feat: worktree gone`, `stopped pid 4121: cwd deleted`):

- **Databases:** in this project's Postgres, a database named for a worktree (`wt_<slug>`) whose slug matches no entry in `git worktree list --porcelain` and whose recorded folder (the database comment) doesn't exist. Both conditions must hold.
- **Processes:** a process you own whose `/proc/<pid>/cwd` link ends in ` (deleted)` and whose path lies inside this project's worktree root: T3's `~/.t3/worktrees/<repo>/` and `<repo>/.claude/worktrees/`.

The main checkout, its database, and every other project's databases, containers and processes stay untouched.

## T3 Code actions

T3 runs scripts only from its own settings; `t3.json` at the repo root is the import source. Write it with the repo's commands:

```json
{
  "$schema": "https://t3.codes/schema/t3.json",
  "scripts": [
    { "name": "Setup", "command": "pnpm run setup", "icon": "configure", "runOnWorktreeCreate": true, "async": false },
    { "name": "Teardown", "command": "pnpm run teardown", "icon": "configure", "runOnSettle": true }
  ]
}
```

`async: false` holds the agent until setup exits, and a non-zero exit stops the thread from starting. `runOnSettle` runs in the thread's own worktree each time the thread settles; threads in the main checkout skip it. The actions run with `T3CODE_PROJECT_ROOT` and `T3CODE_WORKTREE_PATH` set.

Hand-off step for the owner, one line: import the `t3.json` actions once in T3's project settings ("From t3.json" in the actions menu).
