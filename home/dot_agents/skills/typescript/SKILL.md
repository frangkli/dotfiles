---
name: typescript
description: 'Coding rules for TypeScript repos. Load before your first edit to any .ts, .tsx, .mts or .cts file in a task (a feature, fix, refactor or test), even when the request never says "TypeScript", e.g. "add an env var to the CLI". Also load when reviewing or polishing TypeScript code (then read its review reference too), and before changing tsconfig or lint setup.'
---

# TypeScript

The rules that shape the design and correctness of TypeScript code: domain types, absence, trust boundaries, errors, generics, functional core, async and security. Load this file before implementing.

- **Once the code works, and when reviewing:** read [references/review.md](references/review.md) for idioms, naming, modules, platform features and test style, and fix what it flags in the code you changed before handing off. This style pass is part of every implementation task, however small.
- **Effect code:** if the package you're changing imports `effect`, read [references/effect.md](references/effect.md) before writing code. Where it conflicts with this file, it wins.
- **Mechanical rules** are the linter's and the compiler's: no `any` or `!`, handled index reads, floating promises, named exports, array and import style. [references/lint.md](references/lint.md) says when a rule may be disabled and what to do where the repo's config lacks one.

## Precedence

1. **The repo first.** Its tsconfig, lint config and AGENTS.md win over this skill. Match the conventions of the file and package you're in.
2. **Where the repo has no convention,** use the documented current practice for the TypeScript and library versions it pins (read `package.json` and the lockfile; read library docs at that version).
3. **Where an existing pattern is clearly worse** than a rule here (a return-only generic, a guard that checks less than it claims, an unchecked cast at a boundary), use the better pattern in the code you're changing and say why in your handoff. Leave untouched code as it is and mention it instead.

Load a reference only when its case applies:

| Case | Read |
|---|---|
| Writing a generic, brand, correlated union, assertion function, template-literal, conditional or mapped type, a type test, or chasing slow type checks | [references/patterns.md](references/patterns.md) |
| Creating or changing a tsconfig, module mode or import extensions | [references/tsconfig.md](references/tsconfig.md) |
| A lint rule or flag gets in the way, you want to disable one, or the repo's config lacks or contradicts a rule | [references/lint.md](references/lint.md) |
| The code is React (`.tsx` components, hooks, props) | [references/react.md](references/react.md) |
| The code handles untrusted input, secrets, auth, tokens or user-controlled keys | [references/security.md](references/security.md) |

## Done means

- **Checks pass.** Take the commands from the repo's `GATES.md`; without one, from AGENTS.md, the package scripts and the lint config. While iterating, run the cheapest command that type-checks and lints the files you touched. When a shared type or export changed, also check the packages that consume it. Run the full readiness command only at ship points. Show the output: zero errors, zero warnings.
- **No silent escape hatches.** Every new `any`, `as`, `!`, `@ts-expect-error` or lint-disable comment meets the rules under Escape hatches, and your handoff lists each one with its reason.
- **No new suppressions to get green.** If a check fails, fix the types; never loosen a compiler flag or lint rule to pass.
- **Style pass done.** After the code works, re-read the diff against [references/review.md](references/review.md) (and [references/effect-review.md](references/effect-review.md) in Effect code) and fix what it flags.
- **Every advanced type pays for itself.** Each brand, generic, conditional or mapped type you add removes a cast, a `!`, a duplicated declaration or a runtime check, or turns a future mistake into a compile error. Name that payoff in your handoff; where you can't, use the plain type.

## Model the domain

- **Make illegal states unrepresentable.** When a comment would be needed to explain which field combinations are valid, split the type into a discriminated union. Two booleans that must stay in sync become one union. Functions that need one variant take that variant, not the union:
  ```ts
  // Before: { loading: boolean; data?: User; error?: Error }
  type UserState =
    | { readonly kind: "loading" }
    | { readonly kind: "loaded"; readonly user: User }
    | { readonly kind: "failed"; readonly error: Error };
  function render(state: Extract<UserState, { kind: "loaded" }>) { /* state.user is there */ }
  ```
- **Discriminant name:** the codebase's. In new code, `kind` for domain variants, `status` for lifecycle states, `_tag` in Effect code.
- **Build the shape so the bad value can't exist:** `[T, ...T[]]` for a non-empty list, `start` plus `duration` instead of two dates that must be ordered.
- **Stop at the simplest total type.** Keep `T[]` while every operation on it works for all values. Strengthen a type only where the loose one forces a `!`, a cast or a "can't happen" throw.
- **One canonical value, types derived from it.** When a schema, generated client, OpenAPI or protobuf definition, or DB schema owns a shape, infer the type from it. When the set of values must exist at runtime, write it once `as const`, check it with `satisfies`, and derive the union, so adding an entry updates the type:
  ```ts
  const PLANS = {
    free: { seats: 1 },
    team: { seats: 10 },
  } as const satisfies Record<string, { seats: number }>;
  type Plan = keyof typeof PLANS; // "free" | "team"
  // For a list: const MODES = ["read", "write"] as const; type Mode = (typeof MODES)[number];
  ```
  When the union is the canonical value instead, a table keyed by it uses `satisfies Record<Plan, …>`, so a new member fails the build until the table has it.
- **Derive variants with utility types when they must change together:**
  ```ts
  type NewUser = Omit<User, "id" | "createdAt">;
  type UserPatch = Partial<Pick<User, "name" | "email">>;
  type LoadedUser = Awaited<ReturnType<typeof loadUser>>;
  ```
  Declare a separate type when it must stay stable while the source changes (a public response shape that must not gain every new DB column). Which utility fits which need, and their traps: [references/patterns.md](references/patterns.md).
- **Brands for primitives that mean different things** (`UserId` vs `OrderId`) and get passed side by side. Create a branded value in exactly one validating constructor; the `as` lives there and nowhere else. When the value comes from a schema, use the schema library's brand so parsing and branding are one step; otherwise use one shared `Brand<T, Name>` helper ([references/patterns.md](references/patterns.md)).

## Absence

Each empty state gets one spelling, so readers can tell "not provided" from "provided as empty":

- **Missing key (`x?: T`):** omission is a real state at live call sites. With `exactOptionalPropertyTypes`, `x?: T` rejects an explicit `undefined`; write `x?: T | undefined` only where callers pass `undefined` on purpose.
- **`T | null`:** the field is always present and known to be empty. If every caller passes the field but the value can be empty, make it required `T | null`. Never make a field optional so tests or stories are easier to write.
- **`undefined`:** what lookups return (`Map.get`, `find`, `.at`, an optional key). Keep it as a return value; store and send `null` or omit the key.
- When missing and empty mean different things, keep both and say so in the type:
  ```ts
  interface ProfilePatch {
    readonly name?: string;        // missing: keep current
    readonly bio?: string | null;  // missing: keep current; null: clear it
  }
  const patch: ProfilePatch = { ...(bio === undefined ? {} : { bio }) }; // omit, don't assign undefined
  ```

## Boundaries and narrowing

- **Data from outside is `unknown` until parsed.** Trust boundaries: HTTP bodies, `fetch` responses, `JSON.parse`, files, env vars, CLI args, DB rows from untyped drivers, `postMessage`, IPC, queue messages, third-party SDK payloads typed `any`.
- **Parse once, at the boundary, into a named domain type.** Inside, trust the type: no re-validation deeper in the call chain, no defensive checks for states the type rules out. Keep wire and transport types out of a module's public interface.
- **Strings count as untrusted input too.** Parse configuration (env vars, CLI arguments, config files) once, in the one place the program loads it at startup, into a typed config object: a URL becomes a `URL`, a number a checked number, a mode its literal union. That place is the entry point or the start of the function that receives the environment, never the callback or request that later uses the value. Required values fail startup with a clear message; an optional value falls back to its default there only when it is unset, and a set but malformed value is reported with the setting's name (a startup error, or a warning where the feature is advisory). Pass the typed values onward, so no call site reads or re-parses the raw string. Request-scoped strings such as headers and query parameters are parsed at the request boundary in the same way.
- **Schemas before hand-written guards.** Use the repo's schema library and infer the type from the schema, so there is one definition instead of a schema, an interface and a guard that drift apart. With no schema library, hand-write a guard for a small local shape; when the change needs several boundary parsers, propose a library that implements Standard Schema in your handoff instead of adding a dependency for one guard.
- **Throwing parse where bad data is a bug** (config, internal service responses); **non-throwing parse where failure is an expected branch** (user input), returning the failure to the caller.
- **A type guard checks every field it claims.** Name it `isX` or `hasX`. A guard that checks less than its signature claims is worse than `as`, because the name says the value is safe.
- **Assertion functions for invariants:** when failure is a bug and the caller continues on the narrowed value, `asserts` narrows in place instead of an `if` plus `!` at each use. Declare it with `function` (an arrow assigned to a `const` needs an explicit type annotation to narrow):
  ```ts
  function assertNonEmpty<T>(xs: readonly T[], what: string): asserts xs is readonly [T, ...T[]] {
    if (xs.length === 0) throw new Error(`${what} must not be empty`);
  }
  ```
- **Narrow in this order:** discriminant, `in`, `typeof` or `instanceof`, a verifying guard, then `as` only after validation the compiler can't follow.
- **Inline predicates narrow on their own** (TS 5.5+): `xs.filter((x) => x != null)` is already `T[]`. `.filter(Boolean)` still doesn't narrow.
- **Switches over domain unions list every case and end in a `never` arm** that throws, so a new variant fails the build and a bad runtime value fails loudly:
  ```ts
  default: {
    const unhandled: never = state;
    throw new Error(`Unhandled state: ${JSON.stringify(unhandled)}`);
  }
  ```

## Escape hatches

- **`as` and `!` only** right after a check the compiler can't follow, inside a brand constructor, or inside a small transform whose parameters and return type are fully typed; elsewhere, fix the type.
- **A type parameter used only in the return type is an unchecked cast.** Boundary functions take a schema and return its output type, or return `unknown`:
  ```ts
  // Before: async function getJson<T>(url: string): Promise<T>
  async function getJson<S extends StandardSchemaV1>(url: string, schema: S): Promise<StandardSchemaV1.InferOutput<S>>
  // or, with no schema: async function getJson(url: string): Promise<unknown>
  ```
  Use whatever schema type the repo's library exposes; the shape of the rule matters, not the library.
- **Suppressions are a last resort:** one line, naming the rule and the reason ([references/lint.md](references/lint.md)).

## Errors

Split by kind of failure, and keep one style per module:

1. **Bugs, broken invariants and infrastructure faults throw** an `Error` subclass, with the original as `cause`. Let it reach the one boundary handler (the request handler, job runner or CLI entry point) that logs and responds.
2. **Expected outcomes the caller must branch on** (not found, conflict, validation failed, quota reached) are part of the return type, as a discriminated union named for the domain. Use the repo's existing `Result` type if it has one; don't add a result library to a repo that lacks one.
   ```ts
   type ReserveResult =
     | { kind: "reserved"; reservation: Reservation }
     | { kind: "sold-out" }
     | { kind: "over-limit"; limit: number };
   ```
3. **In Effect code,** expected failures are tagged errors in the error channel and bugs are defects. See [references/effect.md](references/effect.md).

- **Catch only to recover, to translate at a boundary, or to clean up.** A catch that logs and rethrows adds noise; one that returns a default hides the failure. `catch { return [] }`, `?? []` and `|| {}` on data the caller requires are swallowed errors: let them throw or return a typed failure.
- **Clean up with `using` or `await using`** when the runtime and target support it; otherwise `finally`.
- **Missing required config fails at startup** with a message naming the setting. Security settings never fall back to a permissive default.

## Functions and generics

- **Infer by default.** Annotate return types on functions with several return paths or recursion, and on functions whose result is a contract others rely on, such as boundary parsers and a module's public functions. Annotate empty collections and state that starts as `null`.
- **Generics preserve the relationship between input and output.** Use one when the output type depends on the argument's type; the constraint names only what the body reads. `(obj: object, key: string): unknown` forgets what the caller knew; this keeps it and rejects a misspelt key:
  ```ts
  function get<TObject, TKey extends keyof TObject>(obj: TObject, key: TKey): TObject[TKey] {
    return obj[key];
  }
  get(user, "email"); // string
  ```
  When a handler, payload or result depends on a discriminant (`type`, `kind`, an event name), key them all from one map type so the compiler checks the pairing: [references/patterns.md](references/patterns.md), correlated unions.
- **Design generics for inference at call sites.** If callers always pass type arguments, change the design. A `const` type parameter keeps literal types without `as const` at the call site; `NoInfer<T>` checks an argument against `T` without letting it widen `T`:
  ```ts
  function machine<const S extends string>(states: readonly S[], initial: NoInfer<S>) { /* … */ }
  machine(["idle", "busy"], "idel"); // error; without NoInfer, S would widen to include "idel"
  ```
- **Type-level programming** (conditional, mapped, template-literal types, `infer`) only where it removes duplication or casts. Each pattern with its payoff and when to skip it: [references/patterns.md](references/patterns.md).
- **One options object** when a function takes several parameters of the same type, any boolean flag, or optional parameters. Positional parameters for one or two distinct values and on hot paths. A boolean that switches behaviour is usually two functions.

## Functional style

- **Pure core, effects at the edges.** Business rules are functions from values to values. I/O, the clock, randomness and logging happen in the caller that wires the rule up, which passes in what it read (`now: Date`, the loaded rows). A rule you can test with plain values and no mocks is in the right place.
- **Immutable by default.** `readonly` fields on domain types, `readonly T[]`, `ReadonlyMap` and `Readonly<T>` on parameters; return a new value instead of changing an argument. Mutating a local value you're still building (an array filled by a loop) is fine while nothing else holds it.
- **Small total functions.** A function returns a value for every input its parameter type allows. When some inputs have no answer, narrow the parameter type (a non-empty tuple, a variant) or return the typed failure; a throw is for the bug case only.

## Async

- **A deliberate fire-and-forget** is `void task()` with a comment saying why and where its errors go.
- **Independent work runs concurrently:** `Promise.all`, or `Promise.allSettled` when partial failure is acceptable and you handle each outcome.
- **Outbound I/O has a timeout or an `AbortSignal`,** passed through from the caller when one exists. Retries are bounded, back off, and only repeat idempotent operations.

## Security musts

Details and examples: [references/security.md](references/security.md).

- User-controlled keys go into a `Map`, or are checked with `Object.hasOwn`; never merge parsed input into plain objects with `obj[key] =`.
- Secrets, tokens and MACs are compared with a constant-time comparison.
- Security-relevant randomness comes from `crypto.randomUUID` or `crypto.getRandomValues`.
- Numbers from strings parse with `Number()` plus a `Number.isNaN`/`Number.isInteger` check; ids above 2^53 stay strings or `BigInt`.
