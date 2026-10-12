---
name: prevent-repeats
description: Find the mistakes agents keep repeating in this repo and make each one impossible, fixing at the highest level that works and proving each new check fails on a real past mistake.
disable-model-invocation: true
---

# Prevent repeats

Agents in this repo keep getting corrected for the same mistakes. Change the repo so the next agent can't make them.

Assume every contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that compiles. Design the repo so a change that looks right from one file is right for the whole repo.

## 1. Find the mistake classes

Read recent commits and reverts, review comments from humans and bots, session logs where the user corrected an agent ([where to find them](../retro/session-logs.md)), AGENTS.md, `REVIEW_RULES.md`, and code comments that explain workarounds. Group the mistakes into classes. A class counts once it has happened twice.

Done when every class cites two occurrences: a commit, a review comment or a log line.

## 2. Fix each class at the highest level that works

1. **Eliminate it with architecture.** Give each piece of state one owner and each task one supported way. Hide internals so the wrong import fails. Replace hand-synced lists with one source of truth. Delete old ways and dead code an agent would copy.
2. **Enforce it with types** so the bad state can't be written. If bad code still compiles, add a lint or CI check whose error names the file, type or function to use instead. If the pattern is already common, fail only when a change adds more.
3. **Test the behaviour.** Fix or delete any test that would still pass if every function it calls returned nothing.
4. **Write a review rule last, only for judgement calls.** Nothing fails when an agent skips it.

## 3. Fix and prove

Fix the most frequent classes now, one commit each. Prove each new check fails on a real past mistake: in a scratch worktree, reapply the offending change (or revert its fix), run the check, and see it fail with an error that names the fix. Wire the check into the command `GATES.md` lists for it, so it runs the same way locally and in CI. Exceptions go on the offending line with a reason, an expiry date and a human's approval.

Done when every new check has failing output on a real past mistake and passing output on the fixed tree.

## 4. Record the rule

Record each rule in `REVIEW_RULES.md`, paired with what enforces it, as [rules-home.md](rules-home.md) describes, and write it per the `writing-for-agents` skill. When the user corrects you, fix the mistake and add the rule. If the rule was already there and nothing enforces it, that's a repeat: fix it at the highest level in the same change. Drop a rule once its mistake can't happen.

**Reply:** each class with its evidence, the level you picked and why a higher level didn't work, and each new check's failing and passing output.
