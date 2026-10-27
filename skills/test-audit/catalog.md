# Low-value tests and the retention bar

## Low-value catalogue

A test matching one of these fails the value bar, unless the retention bar below names the contract it guards.

- **No assertion:** runs code for coverage and checks nothing.
- **Self-comparison:** the expected value is computed by the subject itself, or copied from it (an identity copy, an object compared with its own clone).
- **Copied inventory:** a fixture, export list or table restated in the test, so adding an entry means editing both.
- **Source grep:** reads source files and checks for strings, imports or function names, when the text isn't a declared contract.
- **Call shape:** asserts private helpers, call order or call counts that a real boundary test already covers.
- **Duplicate contract:** the same behavior proven again at another layer with no new transport or lifecycle risk; per-caller replays of a shared helper's tests.
- **Seam keeper:** exists only to keep a test-only export, global or wrapper alive. Production code whose only callers are tests belongs here too.
- **Mock-supplied result:** the mock returns the value the test then asserts.
- **Undefined-proof:** would still pass if the subject returned `undefined` or a constant. Matcher smells: `toBeDefined`, `toBeTruthy`, `not.toThrow`, `toBeGreaterThan(0)`, `toEqual([])` alone, or a bare "was called" with no check of the arguments. Fixes: assert the exact payload the mock received; pair an absence check with a presence check on another input.
- **Fabricated fixture:** a fixture that invents ordering, receipts or persistence the real code never produces.

## Retention bar

Keep a test that independently enforces one of these, even when it looks like a catalogue match:

- a public API, SDK, protocol, wire format, storage format or migration;
- configuration and defaults that users or operators rely on;
- security, permissions or platform behavior;
- exact generated output or prompt bytes, when exact output is the contract;
- package exports, release artifacts or architecture rules (import boundaries, layering);
- call order, when the order is observable from outside;
- source inspection, when it is the cheapest independent guard of a user-facing contract and survives renaming identifiers.

Slow or static is not a reason to remove a test. A test failing on the base branch may be a bug to fix, not a test to delete. Never retire a test of anything reachable from the package's public entry points. A test marked with a keep comment and a reason (`test-value: keep reason="..."`) is never a candidate; list it as suppressed.
