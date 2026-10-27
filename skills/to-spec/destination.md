# Where specs and tickets go

Shared by `to-spec` and `to-tickets`. Take the first rule that matches.

1. **The user named a place.** Write there.
2. **The repo uses a spec framework.** Follow its layout and templates, and put the sections it has no slot for (success criteria, done-predicate, breakage windows, CHECK lines) in its closest file rather than dropping them.
   - OpenSpec (an `openspec/` folder): a change folder under `openspec/changes/`; the spec goes in its proposal, design and spec-delta files, tickets in its `tasks.md`.
   - Spec Kit (a `.specify/` folder): a feature folder under `specs/`; the spec goes in its `spec.md`, tickets in its `tasks.md`.
3. **The project tracks work in an issue tracker**, such as Linear, and its AGENTS.md or docs say so. The spec becomes the project or parent issue description; tickets become issues with the tracker's native blocking relations. A tracker merely being reachable from your tools doesn't count.
4. **Default: repo markdown.** Use the folder where the repo already keeps specs (look for `docs/specs/`, `specs/`, or spec-like documents in its docs). With none, use `docs/specs/<YYYY-MM-DD>-<slug>/`: the spec in `spec.md`, tickets in `tickets.md` beside it. Tickets cut from an existing repo document go beside that document, named after it with a `-tickets` suffix.

Write into the current checkout or worktree and give the path. Committing follows the repo's usual flow.
