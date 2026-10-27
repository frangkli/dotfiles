# tsconfig

Read when creating a tsconfig, changing compiler flags, or choosing a module mode. In an existing repo, its config wins; change a flag only as the task's own subject, and say why.

## Baseline

Start from the strictest set and loosen one flag at a time, each with a comment giving the reason (tsconfig files accept comments).

```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,

    "verbatimModuleSyntax": true,
    "isolatedModules": true,
    "erasableSyntaxOnly": true,
    "moduleDetection": "force",

    "skipLibCheck": true
  }
}
```

| Flag | What it buys |
|---|---|
| `noUncheckedIndexedAccess` | Index and record reads include `undefined`, so missing keys surface at compile time |
| `exactOptionalPropertyTypes` | `x?: T` means "may be absent", not "may be `undefined`"; the one most likely to clash with third-party types, and the only usual candidate for loosening |
| `noPropertyAccessFromIndexSignature` | Index-signature reads use brackets (`headers["authorization"]`), so a read that may miss looks different from a declared field |
| `noImplicitReturns` | Every path of a function that returns a value returns one |
| `noImplicitOverride` | Renaming a base method can't silently orphan an override |
| `verbatimModuleSyntax` | Type-only imports must say `import type`, so what is erased is visible |
| `erasableSyntaxOnly` (TS 5.8+) | Rejects enums, namespaces and parameter properties, so type-stripping runtimes run the file as written |
| `moduleDetection: "force"` | Every file is a module, so stray globals and accidental declaration merging don't happen |
| `skipLibCheck` | Skips checking dependencies' `.d.ts` files; their errors aren't yours to fix |

Leave unused locals and parameters to the linter (`no-unused-vars` with an `_` ignore pattern) rather than `noUnusedLocals` and `noUnusedParameters`, which block compiles halfway through an edit. A repo that already turns them on keeps them.

## Module mode

Pick by what runs the code:

| Runtime | Settings | Relative imports |
|---|---|---|
| A bundler (Vite, esbuild, a framework build) | `"module": "preserve"`, `"noEmit": true` | Extensionless |
| Node runs `tsc` output | `"module": "nodenext"` | `.js` extensions |
| Node or Bun runs `.ts` directly (type stripping) | `"module": "nodenext"`, `"allowImportingTsExtensions": true` with `noEmit`, or `"rewriteRelativeImportExtensions": true` when `tsc` also emits | `.ts` extensions |

Set `types` explicitly (for example `["node"]`): TS 6.0 made the default an empty list, so ambient types are no longer picked up from every installed `@types` package.

Keep `include` tight (sources and tests, never `dist` or generated output) so type-aware lint and the checker don't walk build artifacts.

## Libraries

- Emit declarations (`declaration: true`); consider `isolatedDeclarations`, which requires explicit types on exports and lets other tools generate `.d.ts` files without the checker.
- Use project references (`composite`) when packages in one repo build against each other.
- Before publishing, check the package's exports and types resolve for every consumer mode (publint, and Are The Types Wrong or its CLI).
- A library never ships global type patches (for example ts-reset); those are for applications.

## Version notes

Check the release notes for the TypeScript version the repo pins.

- **5.5:** inferred type predicates (`filter((x) => x != null)` narrows).
- **5.8:** `erasableSyntaxOnly`.
- **6.0:** `strict` is on by default; `module` defaults to `esnext`; `target` floats to the newest edition; `types` defaults to `[]`; `noUncheckedSideEffectImports` is on. Deprecated: `baseUrl`, `moduleResolution` `node10` and `classic`, `esModuleInterop: false`. Use `paths` without `baseUrl`, and `bundler` or `nodenext` resolution.
- **7.0:** the Go-native compiler, roughly ten times faster. It keeps the 6.0 defaults and turns the 6.0 deprecations into errors. Type-aware linters built on it (tsgolint) require it, so most "the checker is slow" workarounds can go.
