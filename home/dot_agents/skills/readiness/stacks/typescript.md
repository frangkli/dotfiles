# TypeScript stack

The recommended lint and type-check setup for a TypeScript repo: the default to offer for VAL-1 and VAL-2 when the repo has no config, and the settings to merge into an existing config. [React UI](#react-ui) covers VAL-6, VAL-7, TST-5 and TST-7; [pnpm](#pnpm) covers SEC-12. It matches the `typescript` skill, which leaves every rule below to the tools. Rule ids are Oxlint's (checked against Oxlint 1.87 with oxlint-tsgolint 7.0, Vite+ 0.2.9, and `@effect/tsgo` 0.51 with Effect 4.0.0-rc.110); confirm them against the installed version, and keep a repo's own linter when it already does the job.

## Compiler flags

Each replaces lint rules; set them before the linter.

| Flag | Replaces |
|---|---|
| `strict` | `useUnknownInCatchVariables` covers `catch (e)`; the lint rule still covers `.catch((e) => …)` callbacks |
| `noUncheckedIndexedAccess` | index and record reads include `undefined`; with `no-non-null-assertion`, `!` isn't the escape |
| `exactOptionalPropertyTypes` | `x?: T` rejects an explicit `undefined` |
| `noPropertyAccessFromIndexSignature` | index-signature reads must use brackets, so a read that may miss is visible |
| `erasableSyntaxOnly` (TS 5.8+) | enums, runtime namespaces and parameter properties (Oxlint has no `no-restricted-syntax`; the flag is the only full ban) |
| `verbatimModuleSyntax` | `typescript/consistent-type-imports` (keep the rule for its autofix) |
| `noFallthroughCasesInSwitch`, `noImplicitReturns`, `noImplicitOverride` | `no-fallthrough`, most of `consistent-return`; overrides can't silently orphan |
| `isolatedDeclarations` (published packages) | `explicit-module-boundary-types` |

## Oxlint

Vite+ runs Oxlint as `vp lint` and reads the `lint` block of `vite.config.ts` (same keys as `.oxlintrc.json`). Its own preset is Oxlint's default (only the `correctness` category) plus `vite-plus/prefer-vite-plus-imports`; `vp create` and `vp migrate` add `typeAware` and `typeCheck`. That leaves most rules below off, so a repo needs the fragment.

Categories: turn on `correctness`, `suspicious` and `perf` (Effect's own set) and list every other rule by name. `pedantic`, `style` and `restriction` turned on wholesale bring rules that oppose each other (`import/no-default-export` and `import/prefer-default-export`) or the skill, and a named list means an Oxlint upgrade can't add rules silently:

```jsonc
{
  "plugins": ["eslint", "typescript", "unicorn", "oxc", "import", "promise"],
  "categories": { "correctness": "error", "suspicious": "error", "perf": "error" },
  "options": { "typeAware": true, "typeCheck": true, "denyWarnings": true, "reportUnusedDisableDirectives": "error" },
  "rules": {
    // Off: each contradicts the typescript skill
    "no-underscore-dangle": "off", // flags `x._tag` reads and `const _unused` bindings
    "oxc/no-map-spread": "off", // its fix mutates elements other code may hold
    "unicorn/consistent-function-scoping": "off", // flags every local helper that captures nothing

    // Pedantic: types, promises and errors
    "typescript/no-unsafe-argument": "error",
    "typescript/no-unsafe-assignment": "error",
    "typescript/no-unsafe-call": "error",
    "typescript/no-unsafe-member-access": "error",
    "typescript/no-unsafe-return": "error",
    "typescript/no-misused-promises": "error",
    "typescript/return-await": "error",
    "typescript/only-throw-error": "error",
    "typescript/prefer-promise-reject-errors": "error",
    "typescript/strict-boolean-expressions": "error",
    "typescript/switch-exhaustiveness-check": "error",
    "typescript/ban-ts-comment": "error",
    "typescript/prefer-ts-expect-error": "error",
    "eqeqeq": ["error", "always", { "null": "ignore" }], // `x != null` checks null and undefined together
    "radix": "error",
    "no-prototype-builtins": "error",
    "unicorn/prefer-top-level-await": "error",

    // Restriction and nursery
    "typescript/no-explicit-any": "error",
    "typescript/no-non-null-assertion": "error",
    "typescript/no-namespace": ["error", { "allowDeclarations": true }],
    "typescript/use-unknown-in-catch-callback-variable": "error",
    "typescript/no-dynamic-delete": "error",
    "typescript/no-unnecessary-condition": "error", // nursery: drop it if it misfires
    "import/no-default-export": "error",
    "oxc/no-barrel-file": ["error", { "threshold": 0 }], // the default (100) flags only huge barrels
    "no-console": "error",
    "no-param-reassign": ["error", { "props": true }],
    "no-empty": "error",
    "unicorn/no-array-for-each": "error",
    "unicorn/no-array-reduce": "error",
    "unicorn/prefer-number-properties": "error",
    "unicorn/no-abusive-eslint-disable": "error",

    // Style
    "typescript/consistent-type-definitions": "error", // `interface`
    "typescript/consistent-type-imports": "error", // separate `import type`
    "import/consistent-type-specifier-style": ["error", "prefer-top-level"],
    "import/no-duplicates": "error",
    "import/first": "error",
    "import/no-mutable-exports": "error",
    "typescript/array-type": ["error", { "default": "array-simple" }],
    "typescript/method-signature-style": ["error", "property"],
    "typescript/consistent-type-assertions": ["error", { "assertionStyle": "as", "objectLiteralTypeAssertions": "never" }],
    "typescript/no-inferrable-types": "error",
    "typescript/prefer-readonly": "error",
    "typescript/prefer-for-of": "error",
    "typescript/prefer-find": "error",
    "typescript/prefer-string-starts-ends-with": "error",
    "func-style": ["error", "declaration", { "allowArrowFunctions": true, "allowTypeAnnotation": true }], // bans only `const f = function () {}`
    "no-new-func": "error",
    "no-nested-ternary": "error",
    "no-implicit-coercion": "error",
    "no-template-curly-in-string": "error",
    "default-param-last": "error",
    "prefer-const": "error",
    "prefer-object-has-own": "error",
    "prefer-object-spread": "error",
    "prefer-template": "error",
    "logical-assignment-operators": "error",
    "unicorn/error-message": "error",
    "unicorn/throw-new-error": "error",
    "unicorn/prefer-structured-clone": "error",
    "unicorn/prefer-includes": "error",
    "unicorn/prefer-optional-catch-binding": "error",
    "unicorn/prefer-object-from-entries": "error",
    "unicorn/prefer-global-this": "error"
  },
  "overrides": [
    // Add the framework's route and page globs here
    { "files": ["**/*.config.ts", "**/*.stories.tsx"], "rules": { "import/no-default-export": "off" } },
    { "files": ["scripts/**"], "rules": { "no-console": "off" } },
    // Package entry files: the files each package.json `exports` names
    { "files": ["packages/*/src/index.ts"], "rules": { "oxc/no-barrel-file": "off" } }
  ]
}
```

Passing `no-unused-vars` any options object drops its default of ignoring `^_` names; restate `argsIgnorePattern`, `varsIgnorePattern` and `caughtErrorsIgnorePattern` as `"^_"` if you configure it.

Add a dead-export and dead-file finder (knip) for unused exports and files, which no lint rule sees.

## React UI

For an app that renders React or other JSX.

**Accessibility lint (VAL-6).** Load the `react` and `jsx-a11y` plugins in an override for the UI files; the base config's `correctness: "error"` turns their rules on at error. Map the design-system components to the elements they render under a top-level `settings` key: Oxlint rejects `settings` inside `overrides`. Set `polymorphicPropName` to the prop the component library uses (`render` for Base UI, `as` for many others).

```jsonc
{
  "settings": { "jsx-a11y": { "components": { "Button": "button", "Link": "a", "Image": "img" }, "polymorphicPropName": "render" } },
  "overrides": [{ "files": ["src/**/*.tsx"], "plugins": ["react", "jsx-a11y"] }]
}
```

Bite test: `<Image src="x.png" />` without `alt` in a covered file must fail `jsx-a11y(alt-text)`.

**Design-system lint (VAL-7), only when the repo uses shadcn/ui (`components.json` exists).** `@shadcn/lint` (Oxlint 1.80 or later) loads as a JS plugin. Its rules reject restyling a component through `className` (`no-restyle`, with per-component `contracts` for what each may change), raw palette colours such as `bg-pink-500` (`no-raw-colors`), arbitrary values such as `p-[13px]` (`no-arbitrary-values`), inline styles (`no-inline-styles`), classes Tailwind can't generate (`no-unknown-classes`) and class strings it can't read statically (`require-static-classes`):

```jsonc
{
  "jsPlugins": ["@shadcn/lint"],
  "rules": {
    "shadcn/no-restyle": ["error", { "allow": ["layout"] }],
    "shadcn/no-raw-colors": "error",
    "shadcn/no-arbitrary-values": "error",
    "shadcn/no-inline-styles": "error",
    "shadcn/no-unknown-classes": "error",
    "shadcn/require-static-classes": "error"
  }
}
```

**Component tests (TST-5).** Vitest with `environment: "happy-dom"` and Testing Library. Tests find elements with `getByRole` and `getByLabelText`, so a control with no accessible name fails; pure logic runs in the `node` environment. Render the real component; a test that mocks React's hooks checks call order, not what a user sees.

**Browser tests (TST-7), only for a shared component library.** A Vitest browser project (`@vitest/browser-playwright`, or `vite-plus/test/browser-playwright` under Vite+) with one Chromium instance and `headless: true` runs axe-core over every component, and CI runs it on Linux. App pages get their real-browser axe scan from the `verify` skill instead.

## SQL tests

Tests that need SQL run on PGlite (`@electric-sql/pglite`): a fresh in-memory instance per test file with the migrations applied, and the query layer on its PGlite driver (`drizzle-orm/pglite` for Drizzle). A test that needs an extension PGlite lacks or two connections at once runs on the project's Postgres test container: [postgres.md](../postgres.md#tests-on-pglite).

## pnpm

pnpm 11 and later turn on `strictDepBuilds`, `blockExoticSubdeps`, a one-day `minimumReleaseAge` and frozen-lockfile installs in CI. In `pnpm-workspace.yaml`, add only what the defaults leave out:

```yaml
trustPolicy: no-downgrade
allowBuilds:
  esbuild: true # one entry per package whose install script the app needs
```

`trustPolicyExclude` lists exceptions, each with a reason in a comment. SEC-12 fails when any file (`pnpm-workspace.yaml`, `.npmrc`, a CI step) turns a default guard off: `strictDepBuilds: false`, `blockExoticSubdeps: false`, `minimumReleaseAge: 0`, `dangerouslyAllowAllBuilds`, or `--no-frozen-lockfile` in CI. Name the file and line in the evidence.

## What the tools enforce

The skill omits these rules and relies on this config. **T** marks a type-aware rule.

| Behaviour | Enforced by |
|---|---|
| No `any`; `unknown`, then narrow | `typescript/no-explicit-any`; `no-unsafe-argument`, `-assignment`, `-call`, `-member-access`, `-return` (T) for `any` from libraries, `JSON.parse` and `res.json()` |
| No `!` | `typescript/no-non-null-assertion`, `no-extra-non-null-assertion`, `no-non-null-asserted-optional-chain` |
| No enums, runtime namespaces, parameter properties | `erasableSyntaxOnly`; `typescript/no-namespace` |
| Index reads handle `undefined` | `noUncheckedIndexedAccess` |
| Named exports, no barrel files | `import/no-default-export`; `oxc/no-barrel-file` with `threshold: 0`. It counts only `export *`, so review catches barrels built from `export { a } from` |
| `interface` for object shapes; property-style members | `typescript/consistent-type-definitions` (an intersection `type A = B & {…}` isn't flagged); `typescript/method-signature-style` |
| `T[]` for simple element types, `Array<…>` for complex ones | `typescript/array-type` with `array-simple` (`generic` in Effect packages) |
| No `const f = function () {}` | `func-style` with `"declaration"`, `allowArrowFunctions` and `allowTypeAnnotation`; declarations for module-level functions are review's |
| One condition per ternary | `no-nested-ternary` (`unicorn/no-nested-ternary` allows one parenthesised level) |
| `===`, `parseInt` radix, no `eval` | `eqeqeq` with `null: "ignore"` (allows only `== null` / `!= null`), `radix`, `no-eval`, `no-new-func`, `typescript/no-implied-eval` (T) |
| Sorts and in-place mutation | `typescript/require-array-sort-compare` (T), `unicorn/no-array-sort`, `unicorn/no-array-reverse` |
| No `for…in` over arrays; `for…of` over index loops | `typescript/no-for-in-array` (T); `typescript/prefer-for-of` |
| Promises handled; `void` marks fire-and-forget; top-level `await` over module-level `.then` | `typescript/no-floating-promises`, `no-misused-promises`, `await-thenable`, `return-await` (T); `unicorn/prefer-top-level-await` |
| Throw and reject `Error`s with a message; catch callbacks take `unknown` | `typescript/only-throw-error`, `prefer-promise-reject-errors`, `use-unknown-in-catch-callback-variable` (T); `preserve-caught-error`; `unicorn/throw-new-error`, `unicorn/error-message` |
| `@ts-expect-error` with a description | `typescript/ban-ts-comment`, `prefer-ts-expect-error` |
| Separate `import type`; one import per module; imports first; no `export let` | `typescript/consistent-type-imports`, `import/consistent-type-specifier-style`, `import/no-duplicates`; `import/first`; `import/no-mutable-exports` |
| `const`; no parameter mutation | `prefer-const`; `no-param-reassign` with `props: true`; `typescript/prefer-readonly` (T) for class fields |
| Logging, cloning, unused code | `no-console`; `unicorn/prefer-structured-clone`; `no-unused-vars` plus knip |
| Narrowing casts | `typescript/no-unsafe-type-assertion` (T), `no-unnecessary-type-assertion` (T); `typescript/consistent-type-assertions` bans `<T>x` and `{…} as T` |
| A type parameter appears twice | `typescript/no-unnecessary-type-parameters` (T) |
| Exhaustive switches | `typescript/switch-exhaustiveness-check` (T); its default still allows the `never` arm |
| No checks for states the type rules out | `typescript/no-unnecessary-condition`, `strict-boolean-expressions` (T; its default allows nullable objects) |
| Data transforms | `unicorn/no-array-reduce` (single-operation callbacks such as sums stay allowed), `unicorn/no-array-for-each`, `oxc/no-accumulating-spread`, `unicorn/prefer-array-flat-map`, `unicorn/prefer-set-has`, `unicorn/prefer-object-from-entries` |
| User keys, numbers from strings | `prefer-object-has-own`, `no-prototype-builtins`, `typescript/no-dynamic-delete`; `unicorn/prefer-number-properties` |
| Current idioms | `prefer-template`, `no-template-curly-in-string`, `prefer-object-spread`, `logical-assignment-operators`, `no-implicit-coercion`, `default-param-last`, `typescript/no-inferrable-types`, `typescript/prefer-find` and `prefer-string-starts-ends-with` (T), `unicorn/prefer-includes`, `prefer-optional-catch-binding`, `prefer-global-this` |
| Sequential awaits | `no-await-in-loop` |
| Disables name a rule | `unicorn/no-abusive-eslint-disable` (also flags a bare `oxlint-disable`); unused disables fail through `reportUnusedDisableDirectives`. Oxlint can't require the `-- reason`; review checks it |
| Effect code uses `HttpClient`, `Crypto`, `Clock`, `Random`, `Config` and `Effect.log` over platform APIs | the Effect override below |
| Boolean names `isX`/`hasX`; descriptive generic names | not in Oxlint (typescript-eslint `naming-convention`); review checks it |

## Conflicts with the skill

Each rule here would contradict a rule in the `typescript` skill under this baseline; the setting resolves it. Rules outside the three categories never turn on unless listed, so they need no setting.

| Rule | Skill rule it contradicts | Setting |
|---|---|---|
| `no-underscore-dangle` (suspicious) | `x._tag` reads; `_`-prefixed unused bindings | off |
| `oxc/no-map-spread` (perf) | return new values; don't change shared objects (its fix rewrites to a mutating `Object.assign`) | off |
| `unicorn/consistent-function-scoping` (suspicious) | a small helper beside its one use | off |
| `func-style` (Oxlint's default is `"expression"`) | function declarations for named functions | `"declaration"` with `allowArrowFunctions` and `allowTypeAnnotation` |
| `oxc/no-barrel-file` | no barrel files, except package entry files | `threshold: 0`; off for package entry files |
| `typescript/no-namespace` | type-only `declare namespace` | `allowDeclarations: true` |
| `unicorn/prefer-top-level-await` | Effect v4 `x.pipe(Effect.catch(…))` at module level (it matches `.catch` by name) | off in Effect packages |
| Effect `asyncFunction`, `extendsNativeError`, `processEnv`, `globalDate`, `globalRandom`, `globalTimers`, `globalConsole`, `globalFetch`, `newPromise`, `nodeBuiltinImport` | the vanilla rules (async functions, `Error` subclasses, env parsing at startup); they fire in files that never import Effect | only in the Effect-packages override |
| Effect `cryptoRandomUUID`, `cryptoRandomUUIDInEffect` | security randomness from `crypto.randomUUID` | only in the Effect-packages override. There `Crypto` (`randomUUIDv4`) meets the must: its implementations use the platform's secure APIs. `Random` is the insecure one (it defaults to `Math.random`) |

Compatible, despite the names: `unicorn/no-array-reduce` allows a single-operation callback such as a sum; `typescript/strict-boolean-expressions` allows `if (user)`; `switch-exhaustiveness-check` allows the `never` arm.

## Effect

For a package that imports `effect`. `@effect/tsgo` (Effect 4, TypeScript 7) or `@effect/language-service` (TypeScript 5) reads the plugin entry in `tsconfig.json`. Its diagnostics fail the build only where a gate runs them:

- **Oxlint:** `"prepare": "effect-tsgo patch --oxlint"` adds the rules as `effecttsgo/<kebab-name>` (the patch supports listed Oxlint and oxlint-tsgolint versions only). Extend the `recommended` preset; it contains no rule that contradicts the skill, and its 13 errors include `missing-return-yield-star`, `missing-star-in-yield-effect-gen` and `floating-effect`. `denyWarnings` makes its warnings fail the gate too. The `effect-native` rules go in an override for Effect packages only; an override can't extend a preset, so it lists them.
- **Patched `tsc`:** `effect-tsgo patch` (in `prepare`) makes `tsc` report them. Errors and warnings fail the exit code; suggestions don't (`ignoreEffectSuggestionsInTscExitCode` defaults to true), so the fragment promotes the rules the skill relies on to `error`.

Bite test: a generator that does `yield* new NotFound(…)` without `return` must fail the gate (`missingReturnYieldStar`). A repo whose only gate is `vp check` with no `effecttsgo/*` rules runs none of these.

Add to the Oxlint config:

```jsonc
{
  "extends": ["./node_modules/@effect/tsgo/oxlint-presets/recommended.json"],
  "overrides": [
    {
      // Effect packages: the effect-native preset plus two Oxlint settings
      "files": ["<effect-package>/src/**"],
      "rules": {
        "typescript/array-type": ["error", { "default": "generic" }],
        "unicorn/prefer-top-level-await": "off",
        "effecttsgo/async-function": "error",
        "effecttsgo/crypto-random-uuid": "error",
        "effecttsgo/crypto-random-uuid-in-effect": "error",
        "effecttsgo/extends-native-error": "error",
        "effecttsgo/global-console": "error",
        "effecttsgo/global-console-in-effect": "error",
        "effecttsgo/global-date": "error",
        "effecttsgo/global-date-in-effect": "error",
        "effecttsgo/global-fetch": "error",
        "effecttsgo/global-fetch-in-effect": "error",
        "effecttsgo/global-random": "error",
        "effecttsgo/global-random-in-effect": "error",
        "effecttsgo/global-timers": "error",
        "effecttsgo/global-timers-in-effect": "error",
        "effecttsgo/instance-of-schema": "error",
        "effecttsgo/new-promise": "error",
        "effecttsgo/node-builtin-import": "error",
        "effecttsgo/prefer-schema-over-json": "error",
        "effecttsgo/process-env": "error",
        "effecttsgo/process-env-in-effect": "error",
        "effecttsgo/schema-sync": "error"
      }
    }
  ]
}
```

For the patched `tsc`, in `tsconfig.json`:

```jsonc
{
  "compilerOptions": {
    "plugins": [
      {
        "name": "@effect/language-service",
        "diagnosticSeverity": {
          // Promoted: rules effect.md relies on
          "missingReturnYieldStar": "error",
          "missingStarInYieldEffectGen": "error",
          "floatingEffect": "error",
          "outdatedApi": "error",
          "anyUnknownInErrorContext": "error",
          "globalErrorInEffectFailure": "error",
          "globalErrorInEffectCatch": "error",
          "unknownInEffectCatch": "error",
          "tryCatchInEffectGen": "error",
          "unnecessaryFailYieldableError": "error",
          "schemaSyncInEffect": "error",
          "preferSchemaOverJson": "error",
          "schemaUnionOfLiterals": "error",
          "schemaStructWithTag": "error",
          "serviceNotAsClass": "error",
          "runEffectInsideEffect": "error",
          "effectFnOpportunity": "error",
          "abortControllerInEffect": "error"
        },
        "overrides": [
          {
            // Effect packages: these fire in any file, Effect or not
            "include": ["<effect-package>/src/**/*.ts"],
            "options": {
              "diagnosticSeverity": {
                "asyncFunction": "error",
                "extendsNativeError": "error",
                "newPromise": "error",
                "nodeBuiltinImport": "error",
                "processEnv": "error",
                "processEnvInEffect": "error",
                "globalDate": "error",
                "globalDateInEffect": "error",
                "globalRandom": "error",
                "globalRandomInEffect": "error",
                "globalTimers": "error",
                "globalTimersInEffect": "error",
                "globalConsole": "error",
                "globalConsoleInEffect": "error",
                "globalFetch": "error",
                "globalFetchInEffect": "error",
                "cryptoRandomUUID": "error",
                "cryptoRandomUUIDInEffect": "error"
              }
            }
          }
        ]
      }
    ]
  }
}
```

A line-level suppression names the rule and the reason: `// @effect-diagnostics-next-line missingReturnYieldStar:off -- <why>`. An unused directive is reported as a warning.
