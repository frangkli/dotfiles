# The other vendor's model

For high-risk changes only. A reviewer from another model family can catch what the author's model reliably misses, at the cost of minutes and that subscription's usage. Run it read-only with approvals off (a read-only sandbox alone still lets Codex escalate a command when approvals are on), give it the same reviewer brief, and ask for JSON.

**From Claude Code, ask Codex:**

```bash
codex exec --sandbox read-only -c approval_policy=never --ephemeral -o review.json "<reviewer brief, naming the files to read>"
```

**From Codex, ask Claude Code:**

```bash
claude -p --permission-mode plan --output-format json "<reviewer brief, naming the files to read>"
```

Pass the brief and the artifact by file path, never your own reasoning. If the command fails or returns nothing usable, the lane is BLOCKED, which makes it a gap.
