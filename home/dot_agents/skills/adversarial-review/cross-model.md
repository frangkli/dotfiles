# The other vendor's model

For the bug pass on high-risk code. A reviewer from another model family can catch what the author's model reliably misses, at the cost of minutes and that subscription's usage. Run it read-only with approvals off (a read-only sandbox alone still lets Codex escalate a command when approvals are on), give it the packet and the same reviewer brief, and ask for JSON.

**From Claude Code, ask Codex:** write the brief (packet, then reviewer brief) to a file in one tool call, then launch Codex in another, with stdin from that file. Claude Code's Bash tool leaves stdin open when a command holds a heredoc, and `codex exec` waits on open stdin forever. Run it in the background, as with `ocr`, with its files under `<state>/round-<n>/raw/`:

```bash
timeout 900 codex exec --sandbox read-only -c approval_policy=never --ephemeral -o <raw dir>/codex.json - < <raw dir>/codex-brief.md > <raw dir>/codex.log 2>&1
```

After 60 seconds, check that the log has more than one line; if it doesn't, the launch hung, so kill it and relaunch once. When it finishes, write its findings in the lane result format to `<state>/round-<n>/codex.json`.

**From Codex, ask Claude Code:**

```bash
claude -p --permission-mode plan --output-format json "<reviewer brief, naming the packet and the files to read>"
```

Pass the brief as written and the artifact by file path, never your own reasoning. If the command fails or returns nothing usable, the lane is BLOCKED, which makes it a gap.
