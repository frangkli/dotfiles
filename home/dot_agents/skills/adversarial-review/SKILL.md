---
name: adversarial-review
description: Adversarial review of a plan, spec or code change before it ships. Use when asked to review, challenge or stress-test a plan, design, diff, branch or PR, or when a delivery skill reaches its review step.
---

# Adversarial review

Several fresh reviewers each attack one angle of the artifact. You verify what they claim, judge it, and report a finished verdict. On a code change, you then fix the verified findings with `improve`.

**Findings mode.** When `improve` calls this skill as its reviewer, run steps 1–5 and return the verified findings with their severities and buckets. Skip steps 6 and 7: `improve` owns the fixing and the report.

## 1. Scope and contract

- **Artifact.** A plan or spec file, or a code change given as explicit base and head commits (`git merge-base origin/main HEAD` and `HEAD` unless told otherwise) plus the full text of every changed file.
- **Contract.** One paragraph of intent: what the change must achieve and what it must not break, drawn from the plan, the spec, the PR body or the commits. Ask only if none of these exist.
- **Gates.** Read the repo's `GATES.md`, AGENTS.md and `REVIEW_RULES.md` (review rules and Known non-issues, at the repo root) so reviewers know the repo's checks and rules.

Done when you can name the base and head commits (or the plan file) and state the contract in one paragraph.

## 2. Launch the lanes

Start every lane in one message, so they run in parallel; start the `ocr` command in the background in that same message. Each lane is a fresh subagent that receives the artifact, the contract and its lane brief from [lanes.md](lanes.md), wrapped in [reviewer-brief.md](reviewer-brief.md), and nothing else. Paste both verbatim and fill only the bracketed fields: an added pointer ("in particular…", "here: timers…") or a trimmed list steers the lane as surely as your own conclusions would.

- **Code change:** correctness and security, structure, test integrity, and idioms; blast radius for a small change whose safety rests on one fact; GitHub Actions when it touches `.github/workflows/**`; the `ocr` lane.
- **Plan or spec:** problem fit, correctness of the design, operational burden, and overengineering.
- **High-risk change** (auth, data, money, migrations, concurrency, public contracts): add the other vendor's model as one more lane, per [cross-model.md](cross-model.md).

Done when every lane has returned PASS, ISSUES or BLOCKED with the base and head commits it reviewed. Respawn a lane once if it returns without them. A lane that fails twice is a **gap**, and a gap is unknown, never clean.

## 3. Fold in other reviewers

After the lanes return (not before), read the review bots' and humans' comments on the PR, if there is one. Add the valid ones as findings, credited to their source.

## 4. Verify every finding

Before judging, confirm each finding against the code. Trace the call site, or run the cheap check: a test, a script, a request. A finding about a caller that can't actually pass the bad input is hypothetical; mark it so. Record what you ran and what it showed.

Done when every finding is marked **confirmed** (with the evidence), **refuted** (with the evidence) or **unverifiable** (with what blocked you).

## 5. Judge

Sort the findings into four buckets:

- **Act on:** confirmed and worth fixing now. If this holds more than five items, filter harder or say why.
- **Consider:** real, but a judgement call or out of the change's scope.
- **Noted:** true and minor.
- **Dismissed:** refuted, hypothetical, a matter of taste ("I would have done it differently"), listed under Known non-issues in `REVIEW_RULES.md`, or about code the change didn't touch. Each with its reason; this list is what lets the reader trust the rest.

Rank a finding higher when two lanes raised it independently. Scrutinise security and data findings harder before dismissing them, not less.

Done when all four lists are written in your reply, an empty one as "none", before anything goes to `improve`.

## 6. Act

- **Plan or spec:** report only (step 7). The author revises the plan.
- **Code change:** fixing is part of this skill, so don't stop at the report or ask first. With the four lists already in your reply, hand the Act on findings to `improve`, scoped to the change's files, together with the contract. This review counts as improve's first review; improve runs every later review as this skill in findings mode, with all the code-change lanes, and commits when it converges. Report after `improve` finishes, including its outcome. Fix nothing yourself, however small: a fix made outside `improve` never gets reviewed. If Act on is empty, say so and skip `improve`.
- A finding that can only be fixed by dropping or narrowing a contract requirement is a decision for the user, not an Act on item.

## 7. Report

Follow [report.md](report.md). The report is finished work: everything checkable has been checked, each finding stands alone, and it ends only with decisions that need the user.
