# Finding session logs

Both harnesses write one JSONL file per session. Find the session by its working directory and time, not by guessing from the latest file.

## Claude Code

- Location: `${CLAUDE_CONFIG_DIR:-~/.claude}/projects/<encoded cwd>/<session-id>.jsonl`. The encoded cwd is the absolute path with every `/` and `.` turned into `-` (for example `/home/me/src/app` → `-home-me-src-app`).
- Subagent transcripts and large tool outputs sit in `<session-id>/subagents/` and `<session-id>/tool-results/` beside the file.
- Each line has a `type`. User turns are `user`, model turns `assistant`; tool calls and results are content blocks inside them (`tool_use`, `tool_result` with `is_error`).

## Codex

- Location: `${CODEX_HOME:-~/.codex}/sessions/YYYY/MM/DD/rollout-<timestamp>-<id>.jsonl`, with older ones under `archived_sessions/`.
- The first line is `session_meta`; its `payload.cwd` names the working directory, so `grep -l '"cwd":"<path>"'` across the session folders finds the right files.

## Other harnesses

Look for the harness's documented transcript folder, or ask the user for the path.

## Reading

- Measure line lengths before reading: one line can hold megabytes of tool output. Pull fields with `jq` instead of printing whole lines.
- Read every user turn first: corrections, repeated instructions and frustration mark the expensive moments.
- Then the failed tool calls and the repeated work: the same file read three or more times, or the same edit made twice. Re-reads right after a context compaction don't count.
- Cite findings as `<file>:<line>` in the log, and take every number from the log or a command you ran.
