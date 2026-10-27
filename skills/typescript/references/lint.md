# Lint

Read when a lint rule or compiler flag gets in the way, when you want to disable one, or when the repo's config lacks or contradicts a rule this skill leaves to the tools. The rules themselves, and the recommended config to set up or change a repo's lint, tsconfig or Effect language service, are in the readiness skill's [stacks/typescript.md](../../readiness/stacks/typescript.md).

## Never loosen to get green

- A failing rule or flag is fixed in the code. Keep every rule, severity and compiler flag as it is, and keep disables to single lines.
- Changing lint or tsconfig settings is a task of its own. Inside an unrelated change, propose the setting and its reason in your handoff instead.
- Where the repo's config lacks a rule the recommended config has, write the code as if the rule were on, and propose it in your handoff.
- Where the repo's config contradicts this skill, the repo wins (SKILL.md, Precedence): write the code its way and name the conflict in your handoff.

## Disabling a rule on one line

Only where the code is right and the rule can't see why: an `as` right after a check the compiler can't follow, the one cast in a brand constructor or a fully typed transform, a rule that contradicts a compiler flag. Then:

- Disable the next line only, naming each rule and the reason: `// oxlint-disable-next-line typescript/no-unsafe-type-assertion -- checked by isFrame above`. A disable without a rule name, a file-wide disable or a block disable is rejected.
- Compiler errors: `// @ts-expect-error -- <why>`, never `@ts-ignore` or `@ts-nocheck`.
- Effect language service: `// @effect-diagnostics-next-line <rule>:off -- <why>`.
- An unused disable is an error, so remove it when the code changes.
- List every disable in your handoff.

## Wrong third-party types

When an SDK's types are wrong or `any`, write one wrapper at the boundary that calls the SDK, parses the result with a schema and returns the domain type. Code past the wrapper uses its types, so the `any` and the disables it would need stay in that one place.
