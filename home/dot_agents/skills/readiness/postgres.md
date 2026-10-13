# Postgres per worktree

The recommended layout for a project that uses Postgres locally. `setup` and `teardown` ([worktrees.md](worktrees.md)) run these steps.

## Layout

- **One container per project** (`<project>-pg`) from the official image, data in a named volume. Every worktree of the project shares it.
- **One database per worktree,** `wt_<slug>`, cloned from the template: `CREATE DATABASE wt_<slug> TEMPLATE <project>_template STRATEGY FILE_COPY`. Record the worktree path on it: `COMMENT ON DATABASE wt_<slug> IS '<worktree path>'`; straggler cleanup reads it.
- **Unix socket, no TCP port:** bind-mount `~/.local/state/pg/<project>/` to `/var/run/postgresql` in the container. `.env.local` gets `DATABASE_URL=postgresql:///wt_<slug>?host=$HOME/.local/state/pg/<project>`, so worktrees and projects never compete for a port.

## Template safety

- **Locked template:** after building it, run `ALTER DATABASE <project>_template IS_TEMPLATE true ALLOW_CONNECTIONS false`. One open session on the template makes every clone fail.
- **Non-superuser role:** the app, its tests and agents connect as a role with `CREATEDB` and no superuser rights (for example `agent`), which owns the worktree databases. The superuser only builds the container and the template.
- **`flock` around project-wide steps:** container start, template rebuild and straggler cleanup hold `flock ~/.local/state/pg/<project>/lock`, so a cleanup never races a clone in another worktree.
- **Rebuild after migrations:** setup compares a hash of the migrations folder with the hash stored in the template's comment. When they differ, it rebuilds the template (unlock, drop, create, migrate, seed, lock). A worktree database made from the old template is recreated by `setup` with a reset flag.

## Test databases

`fsync=off`, `synchronous_commit=off` and `full_page_writes=off` trade crash safety for speed, so they apply to test databases only. `fsync` and `full_page_writes` are server-wide, so test databases live in a second container (`<project>-pg-test`) started with `-c fsync=off -c synchronous_commit=off -c full_page_writes=off`, with its own template built the same way. Dev databases keep the defaults.
