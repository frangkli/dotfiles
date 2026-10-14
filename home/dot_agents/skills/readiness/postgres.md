# Postgres per worktree

The recommended layout for a project that uses Postgres locally. `setup` and `teardown` ([worktrees.md](worktrees.md)) run these steps.

## Layout

- **One container per project** (`<project>-pg`) from the official image, pinned by exact tag (`postgres:18.6`). Every worktree of the project shares it. For an extension, use the extension's own image at a pinned tag instead (`pgvector/pgvector:0.8.7-pg18`).
- **Data on the home disk:** bind-mount `~/.local/state/pg/<project>/data` to `/var/lib/postgresql` and run as `--user "$(id -u):$(id -g)"`, so the files belong to you. Create the folders before the first `docker run`; Docker creates a missing one as root.
- **One database per worktree,** `wt_<slug>`, cloned from the template: `CREATE DATABASE wt_<slug> TEMPLATE <project>_template STRATEGY FILE_COPY`. With `-c file_copy_method=clone` the clone shares blocks with the template on XFS, so it takes about 0.1 s at any size. Record the worktree path on it: `COMMENT ON DATABASE wt_<slug> IS '<worktree path>'`; straggler cleanup reads it.
- **Unix socket, no TCP port:** bind-mount `~/.local/state/pg/<project>/run` to `/var/run/postgresql`. `.env.local` gets `DATABASE_URL=postgresql://agent@/wt_<slug>?host=$HOME/.local/state/pg/<project>/run`, so worktrees and projects never compete for a port. `--network none` keeps the container off every network, so trust auth reaches only the socket.

```bash
pg=~/.local/state/pg/<project>
mkdir -p "$pg/data" "$pg/run"
docker run -d --name <project>-pg --restart unless-stopped --user "$(id -u):$(id -g)" --network none \
  -v "$pg/data:/var/lib/postgresql" -v "$pg/run:/var/run/postgresql" \
  -e POSTGRES_HOST_AUTH_METHOD=trust postgres:18.6 -c file_copy_method=clone
```

## Setup steps

`setup` runs these under `flock ~/.local/state/pg/<project>/lock`, for each container:

1. **Container:** create it when missing, `docker start` it when stopped, and recreate it when its image isn't the pinned tag. Recreating keeps the data folder; a new major version needs a manual `pg_upgrade` first.
2. **Ready:** wait for `docker exec <container> pg_isready -h localhost -U postgres`. The first-run init server already answers on the socket, but only the final server listens on TCP; `-U` is needed because the `--user` uid has no name in the container.
3. **Template:** rebuild it when the migrations hash differs from the one in its comment.
4. **Worktree database:** clone `wt_<slug>` when it's missing.

## Template safety

- **Locked template:** after building it, run `ALTER DATABASE <project>_template IS_TEMPLATE true ALLOW_CONNECTIONS false`. One open session on the template makes every clone fail.
- **Non-superuser role:** the app, its tests and agents connect as a role with `CREATEDB` and no superuser rights (for example `agent`), which owns the worktree databases. The superuser only creates the container, the role and the template database (`OWNER agent`), and locks it; migrations and seeds run as `agent`, so the tables belong to it.
- **`flock` around project-wide steps:** container start, template rebuild and straggler cleanup hold the project lock, so a cleanup never races a clone in another worktree.
- **Rebuild after migrations:** setup compares a hash of the migrations folder with the hash stored in the template's comment. When they differ, it rebuilds the template (unlock, drop, create, migrate, seed, lock, `CHECKPOINT`); the checkpoint writes the template out now, so the first clone doesn't wait for it. A worktree database made from the old template is recreated by `setup` with a reset flag.

## Tests on PGlite

TypeScript tests that need SQL run on [PGlite](https://pglite.dev) by default: Postgres compiled to WebAssembly, running in the test process, one in-memory database per test file with the migrations applied. They need no container. A test runs on the test container below instead when it needs:

- An extension outside the [PGlite catalog](https://pglite.dev/extensions/), such as pg_cron or TimescaleDB. PGlite loads only extensions built for it.
- More than one connection at once: concurrent transactions, row locks, `LISTEN`/`NOTIFY` between sessions, pool behaviour. PGlite is single-user and single-connection; `pglite-socket` multiplexes clients over that one connection, so it doesn't stand in.
- The production major version, when it differs from PGlite's (`SELECT version()`).

## Test databases

`fsync=off`, `synchronous_commit=off` and `full_page_writes=off` trade crash safety for speed, so they apply to test databases only. `fsync` and `full_page_writes` are server-wide, so test databases live in a second container (`<project>-pg-test`) with its own `data-test` and `run-test` folders, started with `-c fsync=off -c synchronous_commit=off -c full_page_writes=off -c file_copy_method=clone`, and its own template built the same way. With `fsync=off` the checkpoint leaves the template in memory, so after a rebuild also run `sync` on the host; otherwise the first clone waits while it's written. Dev databases keep the defaults.
