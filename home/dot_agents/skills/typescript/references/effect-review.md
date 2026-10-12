# Effect: review and polish

Read with [review.md](review.md) when reviewing or polishing code in a package that imports `effect`. [effect.md](effect.md) holds the design rules and takes precedence; confirm every API name against the installed version as it describes. Where the module you're in has its own consistent spelling, match it. The Effect language service flags a bare `yield` and a function that should be `Effect.fn` ([stacks/typescript.md](../../readiness/stacks/typescript.md)).

## Functions and style

- **`Effect.fn("name")` takes the binding's name** (it names the span and the stack frame). `Effect.fnUntraced` on hot paths and in library internals. Annotate a contract with `Effect.fn.Return<A, E, R>`. Where the module writes `(…) => Effect.gen(…)`, match it.
- **v4: extra combinators go as further arguments to `Effect.fn`,** not as a `.pipe` on its result.
- **Inline effects are `Effect.gen`,** with behaviour added by `.pipe(...)`. Write lambdas in pipelines (`Effect.map((x) => f(x))`) rather than point-free references, which lose overloads and generics.
- **v4 `Ref`, `Deferred` and `Fiber` aren't yieldable:** `Ref.get`, `Deferred.await`, `Fiber.join`.

## Observability

- `Effect.fn("name")` and `Effect.withSpan` create spans; `Effect.annotateCurrentSpan` adds attributes; `Effect.annotateLogs` adds log fields; `Effect.log*` writes logs inside the current trace.
- Use the repo's telemetry layer and helpers. Its rules on what may be exported (no secrets, bounded metric labels) apply to span attributes and log fields.

## Testing

- Use the repo's runner. With `@effect/vitest`, `it.effect` runs on a test clock that starts at 0 (move it with `TestClock.adjust`); `it.live` for real time and I/O.
- Provide test layers built on in-memory state (`Ref`, `Layer.succeed`) in place of mocks; `Layer.provideMerge` exposes a leaf service to the test.
- Assert failures by tag: run the effect with `Effect.result` (v3 `Effect.either`) or `Effect.exit`, and compare against the tagged error.
