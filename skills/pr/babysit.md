# Babysit

Own the PR until its stop condition: watch it, fix what it needs, push once per batch, and say exactly where it stands. Babysitting never authorizes merging.

## Modes

Declare one in your reply before the first look at the PR.

| Mode | For | Does | Stops when |
|---|---|---|---|
| **drive** | Shipping, "get it green" | Full passes, one each time the CI watch wakes you, reporting only at the stop | Green, escalated or stopped (stop table) |
| **background** | The user or the task carries on with other work | Full passes as in drive, reporting each one briefly | Same as drive |
| **threads-only** | "Answer the review comments" | Threads only: no CI work, no rebase | Every thread fixed, dismissed or asked |
| **check** | "Is it green?", small or docs-only PRs | One read-only status pass and a report | After the pass |

Default to drive for a PR you just opened, and to check for a small or docs-only one. Answer the user's questions mid-loop and carry on. In a stack, work only the lowest unmerged PR, and restack per [stacks.md](stacks.md).

## Reviewers

Before you treat silence as anything, know which checks and bots this PR should get:

- **Config:** `.github/workflows/`, `.coderabbit.yaml`, and any review tool AGENTS.md or `GATES.md` names. Greptile and Bugbot are configured in their dashboards, so find them by what actually ran.
- **What actually ran:** the check runs and bot comments on the last few merged PRs (`gh pr list --state merged --limit 5 --json number,headRefOid`, then `gh api repos/{owner}/{repo}/commits/<sha>/check-runs` and each PR's comments).

The **expected set** is those, plus every check that has appeared on any earlier head of this PR. A reviewer whose verdict you can read only in a browser counts as unknown; say so in the report.

## A pass

1. **State.** `git fetch origin`, then `gh pr view <n> --json headRefOid,isDraft,mergeable,mergeStateStatus,reviewDecision`. If your local branch doesn't contain the PR's head commit, someone else pushed: fetch their commits and build on them, never force-push over them. If it's a draft, `gh pr ready <n>`.
2. **Conflicts.** If `mergeable` is `CONFLICTING`, rebase onto a fresh `origin/<base>`, resolve, and re-run the checks the resolution touches. In threads-only mode, report the conflict instead.
3. **Threads.** Triage and fix per [threads.md](threads.md). Each fix is a fixup commit ([commits.md](commits.md)).
4. **CI.** Watch, classify and fix, as below.
5. **Push the batch, once.** Autosquash the fixups and check the tree and every commit (commits.md), run the full readiness check if code changed, then `git push --force-with-lease`. After the push, reply to the threads, citing the commits.
6. **Ledger and stop check** (below). If not stopped, start the next pass.

Each push restarts every check and bot, so a pass pushes at most once, with every fix you know of.

## CI

Wait without blocking the turn. Under T3 Code, call `watch_pull_request` and end the turn; it wakes you when checks finish, a reviewer comments or the branch conflicts, and `unwatch_pull_request` releases it when you hand back. Elsewhere, run `gh pr checks <n> --watch --fail-fast` as a background command where the harness wakes you when it exits, or in the foreground where it doesn't. Before ending the turn after a push, confirm the checks registered (the No checks rule below). Then read the full set: `gh pr checks <n> --json name,bucket,state,workflow,link`.

For each failure, read the failing step: `gh run view <run-id> --log-failed` for a GitHub Actions run (the run id is in the link); for any other check, its link and `gh api repos/{owner}/{repo}/check-runs/<id>`. When the `ci-reader` agent is defined, have it read the logs, and open a log yourself only when its report leaves the cause unclear. Run the stale-base and red-base checks yourself. Review and bot comments still go through the verifier ([threads.md](threads.md)).

Classify each failure before acting on it:

| Class | Sign | Action |
|---|---|---|
| **Caused by the change** | Fails in code or behaviour the change touches | Write "fails because X, affected by Y", fix it and every sibling site with the same defect, prove it locally, commit a fixup |
| **Stale base** | Fails in code the change didn't touch, and `git merge-base --is-ancestor origin/<base> HEAD` fails | Rebase onto the fresh base; no rerun |
| **Red base** | The same check fails on the base branch's head | Report it; fix it only if the task covers it |
| **Flake or infrastructure** | A lost runner, a network or registry timeout, a test unrelated to the change that passes on rerun | One rerun: `gh run rerun <run-id> --failed`. An identical second failure was never a flake: reclassify from the logs |

The same failure after two fix attempts escalates, with the logs and both attempts. Prove every fix locally before pushing it.

## The verdict is on the head commit

Green means every check in the expected set ran on the current head commit and passed, or was skipped by its own path rules. Confirm against the commit itself: `gh api repos/{owner}/{repo}/commits/<head>/check-runs --jq '.check_runs[] | {name, status, conclusion}'` and `gh api repos/{owner}/{repo}/commits/<head>/status`.

These are not green, and the report names them:

- **No checks:** nothing on the head after re-polling for a minute.
- **Unknown:** a check that crashed, was cancelled, errored before running, or ran zero tests.
- **Stale:** a result for an older commit.
- **Missing:** an expected check or bot still absent 30 minutes after the push. Stop and report what's missing.

## Greptile

When Greptile reviews this PR (a summary comment from `greptile-apps[bot]`, or a Greptile check on any head), it is a gate. Its latest summary must say `Confidence Score: 5/5`, and its "Last reviewed commit" link must point at the current head. A passing Greptile check is not a 5/5.

- Concerns in the summary count as findings, like threads.
- Greptile reviews when a PR opens, not on every push. After a push, request a review of the new head by commenting `@greptileai` on the PR (the body from a file, per threads.md). Do this once per head; if nothing arrives within 30 minutes, the reviewer is missing.
- A score below 5/5 with no concern you can act on: request one re-review. If the score stays the same on that head, escalate with Greptile's text.

When Greptile hasn't reviewed this PR, it isn't a gate; the report says it didn't run.

## Stop rule

Track the loop in [`improve`'s ledger format](../improve/ledger.md), in the PR's state folder: `improve`'s default, with `-pr` added to the slug. Each bot pass (the bots' reviews of one head) is a review round. Each thread or summary concern is a finding with its id from `ledger.py id`, keeping the thread id in its record; one with no path uses the PR number as its path. Severity comes from the bot or from the verifier; fix and ask items are blocking.

| Outcome | When |
|---|---|
| **Green** | Every expected check passed on the head, no fix item is open, and Greptile gives 5/5 on the head when it runs |
| **Waiting on the user** | Green except for open ask items |
| **Escalated: not converging** | The open blocking count didn't fall across three bot passes |
| **Escalated: recurring** | One finding stayed open, or one thread was reopened, through three passes |
| **Escalated: relocated** | One finding was marked fixed in two different passes |
| **Escalated: CI** | The same failure after two fix attempts |
| **Stopped** | An expected check or bot is missing, or a reviewer's verdict is unreadable |

On green, record the head commit and its patch id (`git diff origin/<base>...HEAD | git patch-id --stable`) in the ledger; [merge.md](merge.md) checks it.

From the third pass on, lean toward dismissing findings that match a Known non-issue in `REVIEW_RULES.md`, never for the high-risk areas in threads.md. An escalation or a stop is reported as what it is, never as green.
