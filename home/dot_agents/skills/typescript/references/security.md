# Security sharp edges

Read when the code handles untrusted input, secrets, auth, tokens or user-controlled keys. Each item: the hazard, then what to write. Hazards a lint rule catches (`==`, `eval` and `new Function`, string timers, sorts without a comparator, `parseInt` without a radix) are in the lint config ([stacks/typescript.md](../../readiness/stacks/typescript.md)).

## Coercion

- `+` concatenates as soon as one side is a string, and `<` on two strings compares character by character (`"10" < "9"`). Convert to numbers at the boundary, and compare numbers.

## Object keys from users

- Writing `target[key] = value` with a key from input lets `__proto__`, `constructor` or `prototype` change the prototype every object shares, which can turn on flags such as `isAdmin` everywhere. Recursive merges and `Object.assign` from parsed JSON carry the same risk.
- Store user-keyed data in a `Map`. When a plain object is unavoidable, create it with `Object.create(null)` and reject those three keys.
- `key in obj` also finds inherited properties (`"toString" in {}` is true). Test ownership with `Object.hasOwn(obj, key)`.

## Secrets and randomness

- Comparing a secret with `===` returns as soon as a byte differs, which leaks how much of a guess was right through timing. Use a constant-time comparison (`crypto.timingSafeEqual` in Node, on equal-length buffers). Compare fixed-length digests, such as HMACs of both values, so a length difference neither leaks nor throws.
- `Math.random` is predictable. Tokens, ids and nonces come from `crypto.randomUUID()` or `crypto.getRandomValues()`.
- Security settings with no value fail at startup. Define what `0`, an empty string and `-1` mean for each limit, and never let a missing value mean "unlimited" or "allow all".

## Parsing numbers

- `parseInt` stops at the first non-digit (`"12abc"` gives 12) and reads a `0x` prefix as hex. Use `Number(s)` and reject `NaN` and non-integers, or `parseInt(s, 10)` when a trailing suffix is expected.
- JSON numbers above 2^53 lose precision silently in `JSON.parse`. Carry large ids as strings, or parse them with `BigInt`.

## Regular expressions

- Nested quantifiers (`(a+)+`), overlapping alternatives (`(a|aa)+`) and adjacent greedy wildcards (`.*.*`) can backtrack exponentially and freeze the event loop on a crafted string. Keep patterns that run on input linear, cap the input length first, or use a linear-time engine.

## Async

- A missed `await` on a validation or authorization call lets the next line run before the check finishes, and its rejection goes unhandled. Await every check before acting on its result; the floating-promise lint rules catch the rest.

## Types that lie

- `as`, `!`, `any` and a guard that returns `true` without checking all compile cleanly and fail at runtime. Around security decisions, derive the type from a parse; never from an assertion.
