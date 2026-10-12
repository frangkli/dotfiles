# React

Read when the code is React. This covers typing component contracts; rendering and bundle performance belong to the repo's React performance skill or docs when it has one.

## Props are the live call sites' contract

The app's real call sites (routes, wired components, providers, hooks, exported package APIs) define what a component accepts. Stories, tests, fixtures and demos adapt to that contract; they never widen it.

1. Before changing a prop type, find every live call site; use stories and tests only as supporting evidence.
2. Classify each prop. **Required:** every live call site passes it. **Optional:** some live call site omits it and that absence is a real state. **Removed:** no live call site uses it.
3. If every caller passes a value that can be empty, make it required and nullable (`selected: Item | null`), not optional.
4. A rendered control requires its handler. A menu item that calls `onRename?.(…)` can render and do nothing; make `onRename` required, or don't render the item.
5. Remove fallbacks that existed only for widened props (`items ?? []`, `count ?? 0`, `handler && …`) once the props are required.
6. Tighten the props of child components that received optional values only because the parent's were optional.
7. When a story or test breaks, give it realistic state and handlers through a fixture helper in support code.

## Variants over booleans

Several boolean props that combine into states (`isPrimary`, `isDanger`, `isGhost`) become one discriminated `variant` prop or separate components. A component whose props switch it between unrelated layouts is two components.

## Typing

- Props are a plain `interface` on a function component. No `React.FC`.
- React 19: `ref` is an ordinary prop; no `forwardRef`.
- Derive props from what you wrap: `ComponentProps<typeof Button>`, `ComponentPropsWithoutRef<"button">`, and `Parameters<typeof handler>[0]` for callback arguments.
- `useState<T>()` with an explicit type when the initial value is `null`, an empty collection, or a literal that inference would widen.
- Pass setters as `Dispatch<SetStateAction<T>>`, not a hand-written `(value: T) => void`.
- Reducer actions are a discriminated union, handled by an exhaustive `switch`.
- Event handlers use React's event types (`ChangeEvent<HTMLInputElement>`), or let the JSX attribute type the inline handler.

## Imports

Import icons and components from their own entry points, not from a library's root barrel, unless the build is configured to optimise that package's imports.
