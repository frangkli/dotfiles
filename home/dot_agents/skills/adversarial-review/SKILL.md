---
name: adversarial-review
description: Adversarial review of a plan, spec or code change before it ships. Use when asked to review, challenge or stress-test a plan, design, diff, branch or PR, or when a delivery skill reaches its review step.
---

# Adversarial review

Several fresh reviewers each attack one angle of the artifact, and a fresh verifier confirms or refutes what they claim. You judge the verified findings and report a finished verdict. On a code change, you then fix the verified findings with `improve`.

**Findings mode.** When `improve` calls this skill for a round, it passes the base (the target's base for round 1, its last reviewed head after that), the round number and the state folder, and for later rounds the lanes. Run steps 1 and 2 only, and return the lanes run, the lanes skipped and why, and each lane's summary. `improve` runs the round's verifier and owns the fixing and the report.

**Resuming.** Outside findings mode, if the change's state folder ([../improve/ledger.md](../improve/ledger.md)) holds an unfinished run, a run was cut off: skip the review and hand the change to `improve`, which continues from its `next.md`.

## 1. Scope and contract

- **Artifact.** A plan or spec file, or a code change given as explicit base and head commits (`git merge-base origin/main HEAD` and `HEAD` unless told otherwise). Commit a code change's uncommitted edits first as a `wip:` save point, so the head holds them; `improve` and `pr` fold it into the history later.
- **Contract.** One paragraph of intent: what the change must achieve and what it must not break, drawn from the plan, the spec, the PR body or the commits. Ask only if none of these exist.
- **State folder.** The caller's, or `improve`'s default ([../improve/ledger.md](../improve/ledger.md)). Outside findings mode, start round 1 with `ledger.py init`. Lane results, the packet and the verifier's records go there.
- **Groups.** For a code change, sort the changed files into high risk and the rest, by the risk test in step 2. A file with any high-risk change is high risk. When every file lands on one side, there is one group.
- **Packet.** In round 1, build one per group, and give every lane of a group the same bytes. The high-risk packet shows each hunk's enclosing function; the other takes `--lines 10`, which is smaller when functions are long. A confirming round builds one packet of the fix diff (step 2):

  ```bash
  python3 ~/.agents/skills/adversarial-review/scripts/packet.py --base <base> --head <head> --scope <the group's files> [--lines 10] \
    --spec <spec file>#<section the ticket names> --ledger <state>/ledger.json --out <state>/round-<n>/packet[-risky|-rest].md
  ```

Done when you can name the base and head commits (or the plan file), state the contract in one paragraph, and each group's packet is written.

## 2. Launch the lanes

Start every lane in one message, so they run in parallel; start `ocr` and Codex, when picked, in the background in that same message. Each lane is a fresh subagent whose brief is its group's packet, then [reviewer-brief.md](reviewer-brief.md) with its lane brief from [lanes.md](lanes.md), and nothing else. Paste them verbatim and fill only the bracketed fields: an added pointer ("in particular…") or a trimmed list steers the lane as surely as your own conclusions would.

- **Code change:** two questions pick each group's lanes. A lane both groups pick runs once, on both packets. The combined reviewer is its own lane (`combined.json`), apart from the bug pass. `ocr` has no file filter, so it reviews the whole change.
  - **Risk:** how bug-prone the code is. Code that parses input, runs queries, acts on git, files, auth, money or data, handles concurrency or migrations, or has complex logic with many edge cases is high risk. Risk sets the bug pass: correctness and security, test integrity, `ocr`, Codex ([cross-model.md](cross-model.md)), and a confirming round in `improve`.
  - **Impact:** how costly the code is to change later: public interfaces, shared types, contracts, schemas, wire formats. Impact sets the design pass: the design-and-style reviewer at full depth. The design review that matters most happens before code, with the owner seeing the types; this lane checks the code kept to it.

  | | Low impact | High impact |
  |---|---|---|
  | **Low risk** | One combined reviewer (the correctness and security brief plus the test integrity brief), no confirming round | The combined reviewer, and design-and-style at full depth |
  | **High risk** | The bug pass, and design-and-style for the repo's conventions | Both passes in full |

  - **Confirming round** (`improve`'s round 2 or 3): one combined reviewer on the fix diff, plus the bug pass scoped to the same diff when it touches high-risk code, plus design-and-style in a lens run. It never reviews the whole change again. Its one packet takes `--lines 10` unless the fix diff touches high-risk files.
  - **Add-ons:** the blast radius brief, for a small change whose safety rests on one fact; GitHub Actions, when the change touches `.github/workflows/**`.
  - **Nothing to check against:** a lane with nothing to review against isn't launched, for example design-and-style with no style document, no language `references/review.md` and no high-impact code. The coverage line names it and why.
  - When the change adds a check (a lint rule, a CI gate), the verifier proves it bites, in a scratch worktree under the state folder's `scratch/`: break the rule it enforces and see the check fail. A check that doesn't fail is a confirmed finding.
- **Plan or spec:** problem fit, correctness of the design, operational burden, and overengineering.

Done when every lane has written its result file with status PASS, ISSUES or BLOCKED and the base and head commits it reviewed. Respawn a lane once if it returns without them. A lane that fails twice is a **gap**, and a gap is unknown, never clean.

## 3. Fold in other reviewers

After the lanes return (not before), read the review bots' and humans' comments on the PR, if there is one, and add each claim to the round as a candidate in `round-<n>/others.json`, credited to its source.

## 4. Verify

Merge the round's candidates (`python3 ~/.agents/skills/improve/scripts/ledger.py candidates <state> 1`), then send the round's packets, the lane results and `round-1/candidates.json` to one fresh verifier under [verifier-brief.md](verifier-brief.md). It drops known findings, confirms or refutes each candidate, and writes `verified-1.json`. Record it with `ledger.py apply <state> 1 <head>`. You read its summary, not the lanes' full output. For a plan or spec, the verifier checks each claim against the plan and the code that exists today.

Done when every candidate is confirmed (with a trigger and evidence), refuted (with the evidence) or unverifiable (with what blocked it).

## 5. Judge

Sort the verified findings into four buckets:

- **Act on:** confirmed and worth fixing now. A minor belongs here only when its fix changes one line of code (its pin test aside). If this holds more than five items, filter harder or say why.
- **Consider:** real, but a judgement call or out of the change's scope.
- **Noted:** true and minor, or minor and unverifiable.
- **Dismissed:** refuted, hypothetical, a matter of taste ("I would have done it differently"), listed under Known non-issues in `REVIEW_RULES.md`, or about code the change didn't touch. Each with its reason; this list is what lets the reader trust the rest.

Rank a finding higher when two lanes raised it independently. Scrutinise security and data findings harder before dismissing them, not less.

Record each confirmed finding, and each unverifiable minor or info, left out of Act on with `ledger.py verdict <state> <id> deferred <bucket>`, so `improve` doesn't pick it up.

Done when all four lists are written in your reply, an empty one as "none", before anything goes to `improve`.

## 6. Act

- **Plan or spec:** report only (step 7), then `ledger.py outcome <state> done`. The author revises the plan.
- **Code change:** fixing is part of this skill, so don't stop at the report or ask first. With the four lists already in your reply, write `next.md` (round 1 verified, step 4 next, the head reviewed, the lanes picked, the high-risk files and whether a confirming round runs) and hand the Act on findings to `improve`, scoped to the change's files, together with the contract and the state folder. This review is `improve`'s round 1; `improve` continues at its step 4, runs its confirming round as this skill in findings mode, and commits when it's done. Report after `improve` finishes, including its outcome. Fix nothing yourself, however small: a fix made outside `improve` never gets reviewed. If Act on is empty, say so, run `ledger.py outcome <state> done` and skip `improve`.
- A finding that can only be fixed by dropping or narrowing a contract requirement is a decision for the user, not an Act on item.

## 7. Report

Follow [report.md](report.md). The report is finished work: everything checkable has been checked, each finding stands alone, and it ends only with decisions that need the user.
