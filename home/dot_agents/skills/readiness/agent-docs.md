# Fixing agent docs and gates

For gaps in the agent docs and build-and-checks areas. Read `writing-for-agents` before writing any of these files.

## AGENTS.md

- One root file under ~60 lines, never over 100. Add an app-level `AGENTS.md` only where that app's commands differ, shorter than the root.
- Tables for commands, file-scoped first: test one file, lint one file, type-check one package. The full check appears once, as a pointer to `GATES.md`.
- Pointers, not copies: one line each to `GATES.md`, `REVIEW_RULES.md`, the `verify` skill, setup docs, architecture and security docs that exist. Repo-relative paths only.
- Cache only what an agent can't find by looking: unwritten conventions, the reason behind a surprising choice, gotchas. Leave out linter settings, installed skills, slogans and commit attribution.
- Claude reads `AGENTS.md` when `CLAUDE.md` links to it (`ln -s AGENTS.md CLAUDE.md`) or imports it (`@AGENTS.md`); add one only if the repo lacks both. Project skills live in `.agents/skills/`, with `.claude/skills` as a link to it.
- Before finishing, run every command in the file and resolve every path.

## GATES.md

```markdown
# Gates

| Command | Covers | Time |
|---|---|---|
| `<lint one file>` | <what it checks> | ~2 s |
| `<test one package>` | <which tests> | ~20 s |
| `<full check>` | lint, types, all tests, build | ~6 min |

While iterating, run the cheapest command that covers your change. When a unit of work is done, check the packages it touched. Run the full check only at ship points: before opening or updating a PR, once on the integrated head, and before merge.
```

Times come from runs you measured on this machine, rounded. Remove any `AGENTS.md` line that asks for the full check before every hand-off.

## REVIEW_RULES.md

Create `REVIEW_RULES.md` at the repo root in the shape [rules-home.md](../prevent-repeats/rules-home.md) gives, keeping only the rules below that fit the repo, and link it from the root `AGENTS.md`. Rules 9–12 apply to repos that run services. If AGENTS.md has a `## Code Review Rules` section, move its rules into the file and replace the section with the link.

```markdown
# Review rules

Flag only with a concrete case (this input or situation leads to this wrong result). Skip what lint enforces, comment density that matches the file, function length, and everything under Known non-issues.

1. Test integrity: a diff that changes code and tests together keeps assertions, expected values and test inputs as they were, unless it says why.
2. Tests that would still pass if the subject returned `undefined` or a constant (loose matchers, asserting only that a mock was called).
3. Broad `catch`, swallowed errors, success-shaped fallbacks, or silent defaults on required data.
4. A new entry point (HTTP handler, CLI, queue consumer, env or config read) without parsing and validation; or re-validation deep inside code a boundary already validated.
5. An abstraction with one caller or one implementation, a pass-through layer, or an option nobody sets.
6. Compatibility shims, deprecated aliases or dual paths kept only for internal callers.
7. Near-duplicate logic that must change together. Similar-looking code that changes for different reasons is fine.
8. Unrelated refactors or formatting mixed into a behaviour change.
9. An outbound call without a timeout or cancellation; retries without a bound and backoff, or retries of non-idempotent work.
10. A retried, queued or scheduled operation that isn't idempotent.
11. An unbounded queue, cache, pool, result set or in-memory list.
12. A schema, API or event change that breaks old data, old clients or in-flight messages.

## Enforced

| Rule | Enforced by |
|---|---|

## Known non-issues
```

The review bots read the file from their dashboard settings, so the repo holds no bot rules files. Move the rules of any `.cursor/BUGBOT.md` or `.greptile/` into `REVIEW_RULES.md` and delete those files. Pointing each bot at `REVIEW_RULES.md` is a dashboard setting: list it in the hand-off as a step for the user, one line per bot.
