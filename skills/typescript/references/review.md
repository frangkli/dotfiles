# Review and polish

Read when reviewing TypeScript, or when polishing code that already works (a style pass, a review lane). A review checks SKILL.md's rules first, since those decide correctness; this file adds the idioms a style pass can find and fix. In Effect code, also apply [effect-review.md](effect-review.md). Mechanical rules stay with the linter ([stacks/typescript.md](../../readiness/stacks/typescript.md) lists them).

Precedence is SKILL.md's: the repo's config and conventions win. Change idioms only in code the task touches; mention the rest in the handoff.

## Style preferences

Where the repo has its own convention, it wins. The recommended lint config also enforces array syntax and `import type`; check those where the repo's linter doesn't:

- **Named functions at module level are declarations** (`function parse(…) {}`); arrows for callbacks, local helpers and handlers typed by their context.
- **Array types:** `T[]` and `readonly T[]` for simple element types, `Array<…>` and `ReadonlyArray<…>` for complex ones (`Array<string | number>`). In Effect packages, `Array<T>` and `ReadonlyArray<T>` throughout.
- **Type-only imports are a separate `import type { … }` statement,** not an inline `type` specifier.
- **Extend an interface with `extends`,** not an intersection: `interface Admin extends User { readonly scopes: readonly Scope[] }`.
- **Generic names:** `T` for a single obvious parameter; descriptive names when there are two or more: `function get<TObject, TKey extends keyof TObject>(o: TObject, k: TKey)`.

## Modules

- **Import from the module that defines the symbol.** A package's public surface is its `package.json` `exports` entries, each a small entry file; import other packages through those entries, never through their internal paths.
- **Each new module, wrapper, layer or option hides more complexity than it adds.** A file that only forwards calls is a cost: inline it.

## Naming

- Booleans and predicates read as `isX` or `hasX`.
- A type for one value is singular (`Route` for a union of routes).
- Names come from the domain the code serves, matching the words the repo already uses for the same thing.

## Data transforms

- **Compose named steps.** A pipeline of small functions whose names say what each step does; chains (`filter`, `map`, `flatMap`) for straightforward transforms. `for…of` when you need early exit, several outputs, sequential `await`, or the code is measured-hot. A `pipe` helper only when the repo already has one.
- **`Map` and `Set` for keyed collections;** plain objects for fixed shapes.
- **`Object.keys` and `Object.entries` return `string` keys** by design. Iterate a typed `Map`, or keep a typed key list, rather than casting to `keyof T`.

## Current platform features

Confirm the repo's tsconfig `target` and `lib` and its runtime version (`engines`, `.nvmrc`, `.tool-versions`) include a feature before using it. Where they do, use the built-in instead of a helper or a dependency:

| Instead of | Use |
|---|---|
| `try`/`finally` that releases a handle | `using` / `await using` with a `[Symbol.dispose]` or `[Symbol.asyncDispose]` method (TS 5.2, plus runtime support) |
| `let resolve; new Promise((r) => { resolve = r; })` | `const { promise, resolve, reject } = Promise.withResolvers<T>()` (ES2024) |
| A `reduce` that builds groups | `Object.groupBy(items, keyOf)`, or `Map.groupBy` for non-string keys (ES2024) |
| Set math with `filter` and `has` | `a.union(b)`, `a.intersection(b)`, `a.difference(b)`, `a.isSubsetOf(b)` (ES2025) |
| `[...iter].filter().map()` over a large or lazy iterable | Iterator helpers: `iter.filter(f).map(g).take(n).toArray()` (ES2025) |
| Collecting an async iterable in a loop | `await Array.fromAsync(source)` (ES2024) |
| A hand-made timeout signal | `AbortSignal.timeout(ms)`, joined with a caller's signal by `AbortSignal.any([a, b])` |

## Logging

- Shipped code logs through the repo's structured logger, with the ids needed to trace the event.

## Tests

- **Test files are type-checked** like source (the tsconfig `include` covers them).
- **Type contracts of utilities and public APIs get type tests** (`expectTypeOf`, or `@ts-expect-error` to assert that something must not compile). How: [patterns.md](patterns.md), type tests.
- **Fixtures satisfy the full production type,** built by factory helpers. Where a test needs a deliberately partial object (a large framework request), use the repo's existing helper; an `as` in a test carries a comment. Production types never loosen for test setup: live call sites define the contract, and tests adapt to it.
