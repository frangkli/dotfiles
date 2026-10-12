# Effect

Read before writing code in a package that imports `effect`. Where this file conflicts with SKILL.md, this file wins: the mapping table names each vanilla rule Effect replaces. Rules not in the table apply unchanged. This file holds the rules that shape design and correctness; the idioms a review or polish pass checks (`Effect.fn` style, logging and spans, tests) are in [effect-review.md](effect-review.md). Read this file whole; once the code works, do SKILL.md's style pass with [review.md](review.md) and effect-review.md.

Names in examples are Effect 4 (checked against a 4.0 release candidate), with the Effect 3 spelling where it differs. Effect's own docs and community guides mix versions and even release candidates of one version (an error-class constructor and the `Config` constructors were renamed during the 4.0 betas), so confirm every name against the installed source before writing it.

## First

1. **Name the installed version.** Read `effect` in `package.json`, the workspace catalog or the lockfile.
2. **Read the installed guide completely:** `node_modules/effect/AGENTS.md` (v4 ships one, with runnable examples under `node_modules/effect/ai-docs/`), or the Effect reference the repo's AGENTS.md names (a pinned source checkout, docs at the pinned version). For a v3 to v4 question, the source checkout's `MIGRATION.md` and `migration/` folder have the rename tables.
3. **Confirm each API name** you're about to use in the installed source or declarations: `grep -nE "^export (const|function|class) timeout\b" node_modules/effect/src/Effect.ts`. Some exports are aliased (`catch_ as catch`, `while_ as while`); search for the alias too.
4. **Read the repo's convention** for each choice where Effect offers more than one spelling: open two or three sibling modules in the same package and note how they model absence (`Option` or `T | null`), branch on unions (`Match`, `$match` or `switch`), define errors (`Schema.TaggedError` or `Data.TaggedError`, one class per failure or one class with a `reason` literal), write functions (`Effect.fn`, `Effect.fnUntraced` or `(…) => Effect.gen(…)`), and define services and layers.

Done when you can name the installed version, the guide you read, and the repo's convention for each choice in step 4.

## Vanilla rule → Effect equivalent

In Effect code the right column is the default. Keep the vanilla form only where the file you're editing already uses it consistently for the same job, and never introduce it into a file that doesn't, even when sibling modules use it.

| Vanilla rule (SKILL.md) | In Effect code |
|---|---|
| Parse at the boundary with the repo's schema library or a hand guard | Decode with Effect Schema at the edge (`Schema.decodeUnknownEffect`; v3 `Schema.decodeUnknown`) and take the type from the schema (`typeof User.Type`). JSON text decodes through `Schema.fromJsonString(S)`. Small runtime checks use the `Predicate` module, not hand-written `isString` / `isRecord` |
| One shared `Brand<T, Name>` helper and a hand constructor | `Schema.brand("UserId")` after the checks on the schema; decoding is the one constructor. The `Brand` module (`Brand.nominal`, `Brand.check`) only for brands with no schema |
| `as const` array plus derived union | `Schema.Literals(["a", "b"])` (v3 `Schema.Literal("a", "b")`) and `typeof S.Type` |
| Discriminated union with `kind` | `_tag` unions. Data that crosses a boundary: `Schema.TaggedStruct` / `Schema.TaggedClass` members in `Schema.Union([...])` (v3 variadic `Schema.Union(A, B)`). In-memory only: `Data.TaggedEnum` with `Data.taggedEnum` constructors and `$is` / `$match` |
| Typed result union for expected failures | A tagged error class in the error channel, raised with `return yield* new NotFound({ id })`; callers recover with `Effect.catchTag` / `catchTags`. Effect's `Result` (v3 `Either`) only for synchronous helpers and for inspecting an outcome (`Effect.result`), never a hand-written `{ ok }` union |
| Throw an `Error` subclass for bugs | A defect: `Effect.die`, or `Effect.orDie` on a failure no caller can handle. Effect code doesn't `throw` |
| `new XError("…", { cause })` | A tagged error with a `cause` field (`cause: Schema.Defect()` in a Schema error), built in the `catch` of `Effect.try` / `Effect.tryPromise` |
| `switch` with a `never` default arm | `Match.type<T>()` or `Match.value(x)` with `Match.tag(...)` and `Match.exhaustive`; `Match.valueTags` / `Match.typeTags` for a handler object per `_tag`; a `TaggedEnum`'s `$match`. A `switch` on `_tag` with a `never` arm where the module already uses `switch` |
| `x?: T`, `T \| null`, `undefined` from lookups | In schemas: `Schema.optionalKey(S)` for a key that may be missing, `Schema.optional(S)` for `T \| undefined`, `Schema.NullOr(S)` for present-but-empty. In Effect logic: `Option<T>` where the module uses it, converted once at the integration point (`Option.fromNullishOr` in, `Option.getOrNull` / `getOrUndefined` out) |
| Hand env parsing into a typed config object at startup | `Config` (`Config.string`, `Config.int`, `Config.port`, `Config.url`, `Config.redacted`, `Config.schema(S, "NAME")`, `Config.withDefault`), read in the layer or entry effect that needs it, never `process.env`. A missing or malformed value fails layer construction with the setting's name |
| `fetch` | `HttpClient` from `effect/unstable/http/HttpClient`: `const client = yield* HttpClient.HttpClient`, then `client.get(url)` or `client.execute(request)`, decoding with `HttpClientResponse.schemaBodyJson(S)`. `HttpClient.filterStatusOk` fails non-2xx responses and `HttpClient.retryTransient` retries network errors and 5xx. Provide `FetchHttpClient.layer` or the platform client (`NodeHttpClient.layerUndici`). The `effect/unstable/*` modules are fine to use |
| Timeout or `AbortSignal` on outbound I/O | `Effect.timeout` (or `timeoutOption` / `timeoutOrElse`); interruption replaces the signal, and `HttpClient` requests abort with the fiber. A promise API wrapped with `Effect.tryPromise` takes Effect's signal: `Effect.tryPromise({ try: (signal) => sdk.send(input, { signal }), catch: (cause) => new SendFailed({ cause }) })` |
| Bounded retry loop with back-off | `Effect.retry` with a `Schedule`: exponential, jittered, capped by `Schedule.recurs`, filtered to retryable errors |
| `using` / `finally` | `Effect.acquireRelease` inside a `Scope` (`Effect.scoped`, or acquired inside a layer); `Effect.ensuring` / `Effect.onExit` for finalizers |
| Construct dependencies, pass clients as parameters | Services (v4 `Context.Service`; v3 `Context.Tag` or `Effect.Service`) provided by layers; tests provide test layers |
| `async` function, `Promise.all` | `Effect.fn("name")` for functions that return effects, `Effect.gen` inline; `Effect.all` / `Effect.forEach` with an explicit `{ concurrency }` |
| Wrap promise and callback APIs | `Effect.tryPromise` / `Effect.callback` (v3 `Effect.async`) once, at the integration point, mapping the failure to a tagged error. HTTP goes through `HttpClient` instead |
| `void task()` fire-and-forget | Fork into a scope so the fiber ends with its owner (`Effect.forkScoped`, `Effect.forkIn`, or a child fork: v4 `forkChild`, v3 `fork`). A detached fork (v4 `forkDetach`, v3 `forkDaemon`) carries a comment saying who stops it |
| `Date.now()`, `new Date()`, `Math.random()` | `Clock`, `DateTime` and `Random`, so tests control them (`Random.withSeed` gives repeatable values). `Random` is for non-security randomness only |
| `crypto.randomUUID`, `crypto.getRandomValues` or `node:crypto`'s `randomBytes` for ids, tokens and nonces | The `Crypto` service: `const crypto = yield* Crypto.Crypto`, then `crypto.randomUUIDv4` or `crypto.randomBytes(n)`. Its implementations use the platform's secure APIs; `NodeServices.layer` and `BunServices.layer` provide it |
| Repo's structured logger | `Effect.log*` with `Effect.annotateLogs`; spans from `Effect.fn("name")` or `Effect.withSpan`, attributes with `Effect.annotateCurrentSpan`; the repo's telemetry helpers |
| Pure core, effects at the edges | Unchanged: pure rules stay plain functions over domain values. Return an `Effect` only from code that does I/O, fails with a tagged error, needs a service, or reads the clock |

## Rules that apply unchanged

From SKILL.md, inside Effect code too: Precedence and Done means; illegal states unrepresentable (with `_tag`); the simplest total type; one canonical value with types derived from it (the Effect Schema is that value); literal unions, never `enum`; `satisfies` for tables; relationship-preserving generics, `const` type parameters and `NoInfer`; escape hatches (no `any`, unchecked `as` or `!`; a type parameter appears twice); immutability, `readonly` inputs and small total functions; security musts. At review time, [review.md](review.md) applies too, with [effect-review.md](effect-review.md) taking precedence.

## Errors

- **One tagged error per failure the caller handles differently,** carrying the fields a caller needs to respond (`id`, `limit`, `retryAfter`), not a message to parse. Where the repo groups failures as one class with a `reason` literal, add a reason instead of a class. Every `_tag` in a union is unique: two classes with one tag are caught together with no warning.
- **Define them with the repo's constructor:** `Schema.TaggedError<Self>()("Tag", { … })` when the error crosses a wire or needs encoding, `Data.TaggedError("Tag")<{ … }>` otherwise. Confirm the constructor's exact name; some v4 docs spell it `Schema.TaggedErrorClass`.
- **Recover narrowly.** `catchTag` / `catchTags` where you can act; `Effect.catch` (v3 `catchAll`) only at a boundary that handles every failure. v4 adds `catchReason` / `catchReasons` / `unwrapReason` for an error whose `reason` is itself a tagged union. Mapping a failure to another tagged error at a layer boundary is fine; turning it into a default value is the same bug as `catch { return [] }`.
- **Bugs are defects.** `orDie` on failures no caller can handle (a startup invariant). `catchCause` and `catchDefect` (v3 `catchAllCause`, `catchAllDefect`) belong only at the outermost boundary, so interruption and defects reach it.
- **Data returned to an external caller** (an API response with variants such as `requires_action`) stays a Schema union in the success channel; the error channel holds failures internal callers branch on.

## Schema, boundaries and absence

- **Decode once, at the boundary that owns the data.** Map the decode failure to that boundary's tagged error. Encode on the way out with the same schema.
- **Records** are `Schema.Struct` or `Schema.Class`; closed string sets are `Schema.Literals`; contracts stay readonly. Unknown payloads are `Schema.Unknown` or `Schema.Json`, never `Schema.Any`.
- **Brand ids and primitives that carry an invariant** (`Port`, `Sha256Digest`): `Schema.String.check(…).pipe(Schema.brand("Sha256Digest"))`, exported with `export type X = typeof X.Type`. A plain label with no invariant and no confusable neighbour stays unbranded.
- **Absence in schemas** follows SKILL.md's Absence rules: `optionalKey` for a missing key, `optional` only where `undefined` is passed on purpose, `NullOr` for present-but-empty. Defaults applied on decode use `Schema.withDecodingDefault`.
- **`Option` in v4 is yieldable, not an Effect:** `yield* option` fails with `NoSuchElementError`, which no caller can tell from another missing value. Turn absence into the domain failure explicitly: `Option.match`, `Option.isNone` plus `return yield* new NotFound(…)`, or `Effect.fromNullishOr(x).pipe(Effect.mapError(() => new NotFound(…)))`.

## Domain unions and matching

- **Pick the union's home by where it travels:** a Schema union of `TaggedStruct` / `TaggedClass` when it is decoded or encoded; `Data.TaggedEnum` when it lives only in memory; a plain `_tag` union type when the module already uses one.
- **Match exhaustively.** End a `Match` pipeline with `Match.exhaustive`, not `Match.orElse`, so a new variant fails the build. Put `Match.withReturnType<T>()` first when every arm must return one type.
- **A lookup table keyed by `_tag` or a literal** uses `satisfies Record<Union["_tag"], …>` the same way as in vanilla code.

## Config

- **Read configuration through `Config`** in the layer that needs it, or in a config service whose layer yields the values; tests provide a `Layer.succeed` with fixed values.
- **Validate with the schema:** `Config.schema(S, "NAME")`, or a typed constructor (`Config.int`, `Config.port`, `Config.url`, `Config.boolean`). Constructor case changed during the 4.0 betas (`Config.string` vs `Config.String`); use what the installed version exports.
- **Defaults with `Config.withDefault`,** which applies only when the value is unset; `Config.orElse` also replaces a malformed value, hiding the error.
- **Secrets are `Config.redacted`;** call `Redacted.value` only at the line that sends the secret.
- **Settings with a sensible default that code reads anywhere** (feature flags, tunables) are a `Context.Reference` with a `defaultValue`. A layer chosen by configuration is built with `Layer.unwrap`.

## Services and layers

- **Code asks for a service; it doesn't construct one.** Define with the repo's pattern; in v4: `class Billing extends Context.Service<Billing, { readonly charge: (…) => Effect.Effect<…> }>()("pkg/path/Billing") {}` and a `static readonly layer = Layer.effect(Billing, Effect.gen(function* () { … return Billing.of({ … }) }))`.
- **Method signatures have no requirements** (`R = never`): the layer yields the service's own dependencies once, and each method is an `Effect.fn("Billing.charge")`.
- **Get a service with `yield* Billing`,** then call its methods on the bound value. v4 has no static accessors; community guides recommending `Effect.Service` with `accessors: true` describe v3.
- **Provide once, at the edge.** Compose with `Layer.provide` / `Layer.provideMerge`. Keep a parameterised layer in a constant: layers memoize by reference, and v4 shares the memo map across `Effect.provide` calls (use `Layer.fresh` to force a rebuild).
- **Layer names** follow the repo (`layer`, `layerTest`, `layerConfig` in the official examples).

## Concurrency, timeouts and retries

- **Collection operations state their concurrency:** `Effect.forEach(xs, f, { concurrency: 8 })`. The default is sequential; `"unbounded"` only for a small, known-size input.
- **Collect every outcome** with `Effect.all(effects, { mode: "result" })` (confirm the option name) instead of stopping at the first failure, when partial failure is acceptable.
- **Time out each attempt, retry the attempts, and time out the whole:** `call.pipe(Effect.timeout("2 seconds"), Effect.retry(schedule), Effect.timeout("10 seconds"))`.
- **A production retry schedule** backs off exponentially with jitter, caps attempts, and retries only retryable failures (v4 `Schedule.while` on the input, `Schedule.setInputType<E>()`; see `ai-docs/src/06_schedule`). Defects are never retried.

## Resources and running

- **Acquire with `Effect.acquireRelease`;** a resource a service holds is acquired inside its layer, so the layer's scope releases it. `Effect.callback` returns its cleanup as a finalizer.
- **Run effects at the edge only.** A process entry point uses the platform's `runMain` (it handles signals and exit codes); a long-running server uses `Layer.launch`; a framework (HTTP router, job queue) builds one `ManagedRuntime` from the app layer and runs each request through it. Code in the middle returns effects and never calls `runPromise` / `runSync`.
- **HTTP handlers stay thin:** decode, call services, map errors to responses.

## v3 and v4 names that differ

| v3 | v4 |
|---|---|
| `Context.Tag`, `Context.GenericTag`, `Effect.Tag`, `Effect.Service` | `Context.Service` |
| `FiberRef` | `Context.Reference` |
| `Either`, `Effect.either` | `Result`, `Effect.result` |
| `Effect.catchAll`, `catchAllCause`, `catchAllDefect`, `catchSome` | `Effect.catch`, `catchCause`, `catchDefect`, `catchFilter` |
| `Effect.async` | `Effect.callback` |
| `Effect.fork`, `forkDaemon` | `Effect.forkChild`, `forkDetach` |
| `Layer.scoped` | `Layer.effect` |
| `Schema.decodeUnknown`, `decodeUnknownEither` | `Schema.decodeUnknownEffect`, `decodeUnknownExit` |
| `Schema.Literal("a", "b")`, `Schema.Union(A, B)` | `Schema.Literals(["a", "b"])`, `Schema.Union([A, B])` |
| `Schema.filter`, `Schema.transform`, `Schema.parseJson` | `Schema.check` / `refine`, `Schema.decodeTo`, `Schema.fromJsonString` |
| `Option.fromNullable` | `Option.fromNullishOr` |
| `@effect/platform`, `@effect/rpc`, `@effect/cli` | modules inside `effect`; HTTP, CLI, SQL, RPC and AI under `effect/unstable/*` |

v4 also changed what is an Effect: `Option`, `Result` and `Config` are yieldable in generators but not assignable to `Effect`; pass them to combinators with `Effect.fromOption` or `.asEffect()`.

Third-party pattern collections written for v3 (`Effect.Service`, `Either` as the error model, `@effect/schema` imports) are a source of ideas, not of API names.

## Checks

If the repo configures the Effect language service or its compiler patch, its diagnostics are part of the type check; fix them like type errors. It checks `yield*`, `return yield*` when raising, v3 names, sync decoders and `JSON.parse` in effects, and, in Effect packages, `process.env`, `Date`, `Math.random`, `fetch` and `crypto.randomUUID` ([stacks/typescript.md](../../readiness/stacks/typescript.md)); where the repo doesn't run it, apply those by hand.
