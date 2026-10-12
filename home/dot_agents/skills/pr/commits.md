# Phased commits

Each commit is one step a reviewer can read alone and `git bisect` can land on. It builds, its tests pass, and those tests ride in the same commit. The PR merges by rebase, so these commits land on the base as written and their messages are the lasting record of the change.

## Plan the phases

- Order by dependency: a commit uses only what the base or earlier commits provide. Usually shared libraries and schemas first, then services and APIs, then apps and UI.
- Tests go in the commit of the code they test. Docs for one layer go in that layer's commit; docs spanning layers get their own `docs:` commit.
- A change under about 50 lines in fewer than four files is one commit.
- Fixes from review fold into the commit of the layer they fix.
- Generated files go in the commit with the source that generates them, produced by the repo's generate command.
- If the repo keeps release-note files (such as changesets) and the change touches something it publishes, add one in that change's commit.
- If the existing commits already follow these rules, keep them and skip to the per-commit check.

## Rebuild the history

1. **Snapshot.** Stage the change's files by name (`git add <paths>`) and commit them as one snapshot. Save it: `git branch backup/<branch>`.
2. **Rebase the snapshot** onto the fresh base: `git fetch origin && git rebase origin/<base>`, resolving conflicts once, here.
3. **Record the tree:** `TREE=$(git rev-parse HEAD^{tree})`.
4. **Unstage:** `git reset origin/<base>`. The working tree keeps every change.
5. **Commit each phase:** `git add <paths>`, then `git commit -F .context/pr/<branch>/msg-<n>.txt`. When one file belongs to two phases, stage part of it: `git diff <file> > part.patch`, cut the patch down to this phase's hunks, `git apply --cached part.patch`.
6. **Check the tree:** `test "$(git rev-parse HEAD^{tree})" = "$TREE"`. If it fails, `git diff "$TREE" HEAD` shows what was lost or added; fix it until the trees match. `git status --porcelain` lists only the files you left out on purpose.
7. **Check every commit:** `git rebase --exec "<cheap check>" origin/<base>`. The cheap check builds or type-checks and runs the tests of what the commit touches, per `GATES.md`. A failing commit stops the rebase there; move the missing piece into that commit, `git rebase --continue`, then check the tree again.

Keep `backup/<branch>` until the PR merges, then delete it.

## Fixes after the PR is open

Commit each fix as `git commit --fixup=<commit it belongs to>`. Before the batch push, record the tree, run `git rebase --autosquash origin/<base>`, then repeat steps 6 and 7.

## Messages

Follow the repo's own rules first (a commitlint config, recent `git log`). Otherwise:

- **Subject:** `type(scope): subject`, at most about 70 characters, imperative, no trailing period, naming the real symbol or area that carries the change. Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`. Add `!` and a `BREAKING CHANGE:` footer only when an external contract breaks.
- **Body:** why the commit exists and what a reader of `git log` needs: the constraint, the obvious alternative and why it lost, the evidence. Wrapped at 72 columns. Leave out a restatement of the subject or a file list.
- **Footers:** `Fixes #<n>` only when every acceptance criterion of that issue is verified; otherwise `Refs #<n>`. Only for issues you opened and read.
- The author is the user's git identity, and the message ends with the body or the footers above.
