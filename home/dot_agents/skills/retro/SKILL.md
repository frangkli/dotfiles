---
name: retro
description: Retrospective on a coding session that proposes changes to the agent's environment.
disable-model-invocation: true
---

The user wants a **retrospective**. You're proposing changes to the coding agent's **environment** (docs, checks, review rules, tools) so future runs go better.

## Steps

1. Load the `writing-for-agents` skill. Everything you propose for AGENTS.md, `REVIEW_RULES.md`, a skill or a doc follows it. The candidate list you present to the user follows the `writing` skill's technical mode ([technical.md](../writing/technical.md)) instead.
2. Read the primary sources for the session the user names, or the current session if they name none. To find and read the logs, follow [session-logs.md](session-logs.md). Done when you've read every user turn and every failed tool call in the session.
3. Look for candidates in the categories below.
4. Present the candidates in order of severity. Each gives its evidence (`<log>:<line>`, a commit or a review comment), its category, the change, where it lives per [rules-home.md](../prevent-repeats/rules-home.md), and what it costs.
5. Apply the ones the user approves. A new check counts only once it fails on the session's real mistake: replay the mistake in a scratch worktree, run the check, see it fail, then restore.

## Categories

- **Navigation**: how easily did the agent find the right files? Are there hidden dependencies between files? Would a **navigation pointer** help? _Use when_ finding a piece of information took long, or the agent read the same file three or more times.
- **Automated checks**: could a check have caught the agent's mistake: a lint rule, a type, a test, a filesystem check? Read the repo's own check commands first (`GATES.md`, its task scripts, its CI workflow), so a check that exists but sits unwired or silently broken is the finding, not a reinvention. A repo with no **guardrail** (no hook and no CI job running its checks) is itself a finding. _Use when_ the agent made a mistake a check could have caught, or the repo has no guardrail.
- **Review rules**: should reviewers get a new rule, or should one be removed or clarified? Classify the mistake first. A **mechanical** one (a fixed pattern, a banned API, an import shape, a file-location rule) gets a deterministic check: a lint rule, hook or CI job, whichever the repo's tooling makes cheapest. A **judgement call** (cross-file consistency, fit with the surrounding design) gets a numbered rule with a concrete failing case in `REVIEW_RULES.md`. A pattern reviewers keep flagging that is intended gets a Known non-issues entry there. _Use when_ review failed to catch a mistake, or flagged the same non-issue twice.
- **AGENTS.md size**: should steering instructions move into a check, or into `REVIEW_RULES.md` where reviewers apply them? _Use when_ the repo's or the user's global AGENTS.md is large.
- **No-ops**: instructions in steering files that don't change the agent's behaviour. _Use when_ the steering files are large.
- **Tool economy**: expensive tool calls that could be streamlined, or custom tooling (CLIs, MCP servers) that spends many tokens. _Use when_ the agent made an expensive tool call.
- **Workarounds**: the agent routed around a broken script, a flaky check or a missing permission. The finding is fixing it at the source. _Use when_ the agent improvised past a failure.
- **Information access**: give the agent more to see: dev server logs teed to a file, read-only access to third-party services, the repo's observability. _Use when_ a crucial piece of information wasn't available.

## Reference

### Implementation and review

Work goes through implementation and review. The implementing agent carries the most **context pressure**: exploring, writing code, debugging. The reviewer receives a diff and carries the least. So reviewers impose the judgement rules, and checks impose the mechanical ones; the implementer's always-loaded context holds only what it needs to navigate and run checks.

### Files

- `AGENTS.md` (and `CLAUDE.md` where a harness needs it): loaded into every agent's context in the repo. Use it sparingly: **navigation pointers**, including the link to `REVIEW_RULES.md`.
- `REVIEW_RULES.md` at the repo root: the review rules and Known non-issues that every reviewer reads, `adversarial-review` and the review bots alike (the bots are pointed at it from their dashboards).
- `GATES.md`: the check commands, what each covers and how long it takes.
- Docs: reference files reached by pointers. Look for an existing doc before writing a new one.
- Skills: for docs whose description should sit in the agent's context, or for commands the user types. Follow `writing-for-agents`.
