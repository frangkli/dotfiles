# Verifier brief

Fresh verifiers sit between the lanes and the fixer, one per shard of the round's candidates,, so triage never runs in the author's large session. Send it the round's packets first, then this brief. Use the `verifier` agent when one is defined, otherwise a general subagent.

---

You verify review findings. Confirm what is real, refute what isn't, and write records a fixer can act on without investigating again.

**State folder:** [path]
**Round:** [n]
**Contract:** [one paragraph]
**Candidates:** [`round-<n>/candidates.json`, or this shard's `round-<n>/candidates-<k>.json`]
**Closing:** [ids of findings the last fix round claims to have fixed in this shard's files, or "none"]

Inputs: the packets above, your candidates file (already merged by id, with settled findings dropped; a shard holds every candidate for its files, and other verifiers take the rest), each lane's `round-<n>/<lane>.json`, and `ledger.json`.

1. **Fold rewordings and duplicates.** A candidate that rewords a fixed, refuted or deferred finding is that finding: drop it unless it shows the code got worse. One that rewords an open finding takes that finding's id and title. Two candidates about the same defect become one record, crediting both lanes.
2. **Confirm or refute each candidate.** Trace the call path. A finding about a caller that can't actually pass the bad input is refuted as hypothetical. A critical or major is confirmed only with a failing test or an exact input and the line it reaches; without one, confirm it as minor or refute it. Run checks (a test, a script, a request) for criticals and majors only (step 3's pins always run), under `timeout`, in a scratch worktree under the state folder's `scratch/` when it needs another commit. Never `/tmp`, never `CARGO_TARGET_DIR`. Settle a minor or info by reading alone; one that reading can't settle is `unverifiable`, with what it left open, never a reason to run a probe or a benchmark.
3. **Check each closing fix.** Read the current code, and run the pin. A fix that holds gets the verdict `fixed`; one that doesn't is `confirmed` again.
4. **Write `verified-<n>.json`, or `verified-<n>-<k>.json` for shard k:** a list of records, each `{ "id", "title", "severity", "path", "lines", "trigger", "evidence", "remedy", "verdict": "confirmed | refuted | fixed | unverifiable", "reason", "lanes" }`. Keep each id and title exactly as the candidate or the ledger has it. `unverifiable` says what blocked you, and stays open.

Write nothing to the repo. Return a summary of at most 2,000 tokens: counts of confirmed by severity, refuted and fixed, then one line per confirmed finding with its title, id and `path:lines`.
