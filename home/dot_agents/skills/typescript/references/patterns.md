# Advanced patterns

Read when writing a generic, a brand, a correlated union, an assertion function, a template-literal, conditional or mapped type, a type test, or when type checking is slow. In Effect code, [effect.md](effect.md) replaces the brand, result, union and exhaustiveness patterns below with Effect's own.

Each pattern names its payoff and when to skip it. The bar from SKILL.md holds: a pattern goes in only where it removes a cast, a `!`, a duplicated declaration or a runtime check, or turns a likely mistake into a compile error. Check the TypeScript version the repo pins before using a feature: `satisfies` 4.9, `const` type parameters 5.0, `NoInfer` 5.4, inferred type predicates 5.5.

## Relationship-preserving generics

A type parameter relates two things: it appears in at least two positions (two parameters, or a parameter and the return). Indexed access (`T[K]`) and mapped types carry the relationship through.

```ts
// Before: the caller's knowledge is lost, and the result needs a cast
function pick(obj: object, keys: string[]): Record<string, unknown>

// After: keys are checked against obj, the result keeps their types
function pick<TObject, TKey extends keyof TObject>(obj: TObject, keys: readonly TKey[]): Pick<TObject, TKey> {
  // oxlint-disable-next-line typescript/consistent-type-assertions, typescript/no-unsafe-type-assertion -- the one cast, in a fully typed transform
  const out = {} as Pick<TObject, TKey>;
  for (const k of keys) out[k] = obj[k];
  return out;
}
pick(user, ["id", "email"]); // { id: UserId; email: string }

function groupBy<TItem, TKey>(items: readonly TItem[], keyOf: (item: TItem) => TKey): Map<TKey, TItem[]> { /* … */ }
```

- Constrain as little as the body needs: `T extends { id: string }`, not `T extends User`, when only `id` is read.
- A parameter that appears once is its constraint: `function len<T extends unknown[]>(xs: T): number` is `function len(xs: readonly unknown[]): number`.
- Callers shouldn't need type arguments. If they do, pass a value that carries the type (a schema, a key, a factory).
- **Skip when** the function treats the value opaquely and its result type doesn't depend on the input: take the constraint type.

## Correlated unions

When a payload, handler or result depends on a discriminant, write one map type from discriminant to payload and derive everything else from it. A generic `K` then ties the handler to its payload, so dispatch needs no cast and no `switch`.

```ts
interface EventMap {
  "user.created": { readonly userId: UserId };
  "order.paid": { readonly orderId: OrderId; readonly amountCents: number };
}
type EventName = keyof EventMap;
type AppEvent = { [K in EventName]: { readonly type: K; readonly payload: EventMap[K] } }[EventName];
type Handlers = { readonly [K in EventName]: (payload: EventMap[K]) => void };

function dispatch<K extends EventName>(handlers: Handlers, event: { type: K; payload: EventMap[K] }) {
  handlers[event.type](event.payload); // checked: Handlers[K] takes EventMap[K]
}

function on<K extends EventName>(name: K, listener: (payload: EventMap[K]) => void): () => void { /* … */ }
on("order.paid", (p) => p.amountCents); // p is the order.paid payload
```

- Before: `(handlers[event.type] as any)(event.payload)`, or a `switch` repeating every case. Adding an event to `EventMap` now updates `AppEvent`, `Handlers` and every `on` call site, and a missing handler fails to compile.
- The map is the canonical value. When a schema owns the event shapes, derive `EventMap` from it.
- **Skip when** there are two or three variants handled in one place: a discriminated union and an exhaustive `switch` read more plainly.

## `const` type parameters and `NoInfer`

```ts
// const keeps literals; callers don't write `as const`
function defineRoles<const R extends readonly string[]>(roles: R): R { return roles; }
const roles = defineRoles(["admin", "member"]); // readonly ["admin", "member"], not string[]

// NoInfer: the second argument is checked against S but doesn't widen it
function machine<const S extends string>(states: readonly S[], initial: NoInfer<S>) { /* … */ }
machine(["idle", "busy"], "idel"); // error
```

- `NoInfer` fits defaults, fallbacks and "one of the values above" arguments.
- **Skip `const`** when the parameter only feeds a wide type (`string[]`); a primitive-constrained parameter (`P extends string`) already infers a literal from a literal argument.

## Branded types

```ts
declare const brand: unique symbol;
export type Brand<T, Name extends string> = T & { readonly [brand]: Name };

export type UserId = Brand<string, "UserId">;
export function parseUserId(raw: string): UserId {
  if (!/^usr_[a-z0-9]{12}$/.test(raw)) throw new InvalidIdError("UserId", raw);
  return raw as UserId; // the only cast; every UserId passes through here
}

function cancel(orderId: OrderId, by: UserId) { /* … */ }
cancel(userId, orderId); // error: swapped arguments no longer compile
```

- One `Brand` helper per repo; one constructor per brand. With a schema library, brand in the schema, so decoding and branding are one step.
- Brand a unit when units mix in arithmetic (`Cents` vs `Dollars`, `Ms` vs `Seconds`).
- **Skip when** the primitive has one meaning in its module, or values of different meanings never meet in one signature.

## Canonical values with `satisfies` and `as const`

Write the runtime value once and derive the types from it.

```ts
// Before: a union and a table that drift apart
type Currency = "usd" | "jpy";
const minorUnits: Record<string, number> = { usd: 2, jpy: 0, eur: 2 };

// After
export const CURRENCIES = {
  usd: { symbol: "$", minorUnits: 2 },
  jpy: { symbol: "¥", minorUnits: 0 },
} as const satisfies Record<string, { readonly symbol: string; readonly minorUnits: number }>;
export type Currency = keyof typeof CURRENCIES;
export type CurrencyInfo = (typeof CURRENCIES)[Currency];
```

- `satisfies` checks the shape and keeps the literal keys; an annotation (`: Record<string, …>`) would widen `Currency` to `string`.
- When a union is canonical (from a schema or a protocol), make the table follow it: `satisfies Record<Currency, …>` fails the build when a member has no entry.
- **Skip** `as const` on values that are meant to change at runtime.

## Assertion functions

```ts
export function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

const row = rows.find((r) => r.id === id);
assert(row, `row ${id} was inserted above`);
row.total; // narrowed, no `!`
```

- For invariants: failure is a bug and the caller continues on the narrowed value.
- Declare with `function`, or give a `const` an explicit function type; otherwise the call doesn't narrow.
- **Skip when** failure is an expected branch (user input, not found): return a typed result instead.

## Precise absence

| Spelling | Means | Typical source |
|---|---|---|
| `x?: T` | the key may be missing | options objects, patches, sparse records |
| `x: T \| null` | present, known to be empty | DB columns, API fields, state that starts empty |
| `T \| undefined` (return) | the lookup found nothing | `Map.get`, `find`, `.at`, `arr[i]` with `noUncheckedIndexedAccess` |

- Under `exactOptionalPropertyTypes`, `{ x: maybe }` with `maybe: T | undefined` fails for `x?: T`. Build the object without the key: `{ ...(maybe === undefined ? {} : { x: maybe }) }`.
- `Partial<T>` produces `?:` keys, so it inherits the same rule.
- `"x" in obj` tests for the key; `obj.x !== undefined` tests for a value. Use the one that matches the meaning.
- Convert between spellings at the boundary (a DB `null` to a missing key in a public payload, or the reverse) once, in the mapper.

## Typed results

```ts
type ReserveResult =
  | { readonly kind: "reserved"; readonly reservation: Reservation }
  | { readonly kind: "sold-out" }
  | { readonly kind: "over-limit"; readonly limit: number };

function reserve(stock: Stock, qty: number): ReserveResult { /* … */ }

const r = reserve(stock, 2);
switch (r.kind) {
  case "reserved": return ok(r.reservation);
  case "sold-out": return conflict("sold out");
  case "over-limit": return badRequest(`max ${r.limit}`);
  default: { const unhandled: never = r; throw new Error(`Unhandled: ${JSON.stringify(unhandled)}`); }
}
```

- Each failure variant carries the data the caller needs to respond (`limit`), not a message string to parse.
- A generic `Result<T, E>` is for repos that already have one. A domain-named union is the default in repos without one.
- **Skip when** every caller would turn the failure straight into a throw: throw at the source.

## Readonly

- Parameters: `readonly T[]`, `ReadonlyMap<K, V>`, `ReadonlySet<T>`, `Readonly<T>`. A mutable value passes to a readonly parameter; the reverse needs a copy, which is the point.
- Domain types: `readonly` on fields that never change after construction. Canonical tables: `as const`.
- `readonly` is shallow. Mark nested fields where they are declared; reach for a recursive `DeepReadonly` only for config or fixture trees that are frozen whole.
- **Skip** on local values being built and on library types you can't change (that is why `prefer-readonly-parameter-types` is usually off).

## Utility-type derivation

| Need | Write |
|---|---|
| A subset or superset of fields | `Pick<T, K>`, `Omit<T, K>`, `interface B extends A` |
| Every field optional or required | `Partial<T>`, `Required<T>` |
| A total table keyed by a union | `Record<Union, V>` |
| Some members of a union | `Extract<U, { kind: "a" }>`, `Exclude<U, { kind: "a" }>` |
| A function's inputs or output | `Parameters<typeof f>[0]`, `ReturnType<typeof f>`, `Awaited<…>` |
| A nested field's type | `User["address"]`, `(typeof LIST)[number]` |
| Drop `null` and `undefined` | `NonNullable<T>` |

- Derive when the new type must change whenever the source does. Declare a separate type when it must stay stable (a public contract over an internal row).
- `Omit` doesn't check its keys: `Omit<User, "emial">` compiles and removes nothing. Prefer `Pick` for small subsets, or a checked helper: `type StrictOmit<TObject, TKey extends keyof TObject> = Omit<TObject, TKey>`.
- `Omit` and `Pick` collapse a union into one object. To drop a field from each variant: `type DistributiveOmit<TObject, TKey extends PropertyKey> = TObject extends unknown ? Omit<TObject, TKey> : never`.
- Past two nested utilities, give the result a name and a one-line comment.

## Template-literal types

```ts
type Entity = "user" | "order";
type Action = "created" | "deleted";
type EventName = `${Entity}.${Action}`; // 4 members

type Params<P extends string> =
  P extends `${string}:${infer Name}/${infer Rest}` ? Name | Params<`/${Rest}`>
  : P extends `${string}:${infer Name}` ? Name
  : never;
function route<P extends string>(path: P, handler: (params: Record<Params<P>, string>) => void) { /* … */ }
route("/users/:id/posts/:postId", (p) => p.postId); // p has id and postId

type Listeners<T> = { [K in keyof T & string as `on${Capitalize<K>}`]?: (value: T[K]) => void };
```

- For small closed string sets: event names, route patterns, prefixed keys.
- **Skip when** the set is open (any URL, any id) or a cross product grows past a few hundred members: use `string` plus a parser.

## Exhaustiveness

- `switch` with a `never` default arm (SKILL.md), enforced by the `switch-exhaustiveness-check` lint rule.
- `satisfies Record<Union, …>` for lookup tables: a new member fails the build.
- If the repo has an `assertNever(x: never): never` helper, call it in the default arm.
- An `if`/`else` chain over a union ends with a `never` assignment the same way.
- **Skip** on open sets (`string`, `number`): there is nothing to exhaust; handle the unknown case explicitly.

## Conditional and mapped types

- Reach for built-ins first (table above).
- A conditional type distributes over a bare union parameter. Wrap both sides (`[T] extends [U]`) to treat the union as a whole.
- Key remapping (`as` in a mapped type) filters or renames keys: `{ [K in keyof T as K extends `on${string}` ? K : never]: T[K] }`.
- Give every non-trivial helper type a name and a one-line comment saying what it computes; the hover text is all a reader gets.
- If a type takes more than a screen, generate the types from the source of truth (a schema, OpenAPI, the DB) instead.
- **Overloads** only when the return type depends on which argument shape was passed and a union return would force callers to narrow. Otherwise one signature with a union parameter.

## Type tests

- Test exported utility types and public generic APIs with the test runner's type assertions (`expectTypeOf(fn(x)).toEqualTypeOf<Expected>()` in Vitest), run in CI with type checking on.
- Assert what must not compile with `// @ts-expect-error -- <case>` on the offending line; the test fails if the line ever starts compiling.
- Test the inference callers rely on (the inferred return of a call), not only explicit type arguments.

## Checker performance

- Avoid deep recursive conditional types and unions of tens of thousands of members; both show up as slow checks and "type instantiation is excessively deep" errors.
- Annotate the return types of exported functions whose inferred types are large; it stops the checker re-deriving them at every use.
- Measure before changing anything: `tsc --extendedDiagnostics` for totals, `tsc --generateTrace <dir>` for the files and types that cost the most.
