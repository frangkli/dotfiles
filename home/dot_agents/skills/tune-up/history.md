# History audit

Across recent sessions: where did agents waste turns or fail repeatedly, which setup change would have prevented it, and which rules changed nothing?

**Scope.** From a project checkout, audit that project's sessions. With `global`, audit every project and target the global instructions, skills and harness config in the dotfiles. The window defaults to the time since the last history report, else 14 days. Under ~20 interactive sessions in the window, report the count and stop.

**Privacy.** Reports quote sessions, so they go to the owner's private `devbox-infra` repo (`gh repo clone devbox-infra` when no checkout exists), as `docs/research/<YYYY-MM-DD>-history-audit.md` with a `.json` sidecar, for project runs too. A PR to a public repo carries the generic change and its reason, with no project names, paths, quotes or secrets.

## Steps

1. **Ground.** Load the newest `*-history-audit.json`: its metrics and each earlier proposal with its status (merged, rejected, pending). A rejected proposal returns only with new evidence; check each candidate class against `glen search` for earlier rulings.
2. **Collect numbers, no model calls.** AgentsView first: the CLI (`agentsview session list --json --since <window> --include-one-shot --include-automated`, `--project <name>` for a project run, `--sort failures|retries|edit-churn|compactions|context-pressure`; `agentsview session tool-calls <id> --json`; `agentsview session search`), its API on `127.0.0.1:8080/api/v1`, or its archive `~/.agentsview/sessions.db` read-only. Then command durations and exit codes from atuin (`atuin search --author '$all-agent' --after <date>`). State the filters in the report, then tabulate per project and per harness.
3. **Pick sessions to read.** The worst by signal, plus a few grade-A sessions as a control; at most 30. Give each to a fresh read-only subagent with a fixed brief: read every user turn and every failed tool call, from the raw transcript when it exists (`~/.claude/projects`, `~/.codex/sessions`), else `agentsview session messages`, and return observations cited as `<session id>:<message index>`.
4. **Cluster.** A class needs evidence from two or more sessions.
5. **Choose the fix at the highest level that works,** per `../prevent-repeats/rules-home.md`: a check or architecture change, then a skill change, then a harness setting, then one `AGENTS.md` line. Hand a class that lives in one repo's code to `prevent-repeats` in that repo with its session list. Hand Claude allowlist gaps to `fewer-permission-prompts`.
6. **Removals.** List rules no session shows changing behaviour, rules whose mistake no session shows any more, and checks that never fire.
7. **Write the report and stop.** Candidates in order of measured cost (wasted turns or tokens times sessions). Each gives its evidence (two or more session links), its class, the change, where the change lives, the metric it should move and by how much, and how the next run checks it. The removals list follows, then the numbered decision batch.
8. **Apply what the owner approves:** one branch per target repo, skill text per `writing-for-agents`, a trigger check for every changed skill description, every new check proven on a past mistake, shipped through `pr`.

## Signals

| Signal | Source | Candidate when |
|---|---|---|
| Repeated failures | `tool_failure_signal_count`, `consecutive_failure_max`, failed tool results grouped by error text | One error class in two or more sessions |
| Wasted turns | `tool_retry_count`, `edit_churn_count`, `runaway_tool_loop_count`, `mid_task_compaction_count`, one file read three or more times (re-reads after a compaction excluded) | A cause repeats: a missing pointer, a noisy command, a broken script routed around |
| User corrections | Later user turns that redirect the agent, `duplicate_prompt_count` | The owner repeats an instruction a check, skill or line could carry |
| Slow checks | atuin median duration per command; full-check runs per session | A `GATES.md` command runs far slower than listed, or sessions run the full check between steps |
| Missed skills | Claude `Skill` calls; Codex reads of a `SKILL.md` through the shell | A model-invoked skill missed matching tasks in two or more sessions |
| Cost outliers | `total_output_tokens`, `agentsview usage daily` | One task class costs several times the median with no better outcome |
| Secret leaks | `secret_leak_count` | Reported first, unquoted, with the rotation step |

On the next run, compare each merged change's metric in the sessions after its merge with the window before it. An effect needs at least two later sessions; a change that moved nothing over a full window becomes a removal candidate.
