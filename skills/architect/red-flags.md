# Red flags

Screen every sketch, and the synthesis, for these. Each hit is a reason to revise the shape, or to explain in the rationale why it stays.

- **Shallow module.** The public surface is large compared with what it hides: callers call several methods in a fixed order to finish one job, options expose internal stages, or using it still requires knowing how it works. A deep module hides a lot behind a small surface; a long call chain is not depth.
- **Leaked decision.** One internal choice (a representation, a policy, a protocol detail, a wire or storage type) shows up in several modules, so changing it means coordinated edits. Wire and storage types belong behind the boundary, parsed into domain types.
- **Split by time.** Modules follow execution order (load, validate, transform, save) instead of the knowledge they own, so one representation and its rules repeat across stages.
- **Pass-through layer.** A method forwards its arguments to another with the same shape and adds nothing: no policy, no adaptation, no new abstraction.
- **Split ownership.** Two modules write the same state, or each keeps a copy. An agent editing one writer won't see the other, and their rules drift apart.
- **Two ways to do one thing.** The design offers more than one path to the same result. Agents copy whichever they find first, so every path keeps gaining callers.
- **Reachable internals.** Code outside the module can import its internals. The shortest path that compiles will use them, and they become interface. Make such imports fail the build.
- **Hand-synced lists.** The same set of items is listed in several places, so adding one means editing each. Derive the others from one list, or make the build fail when they disagree.
- **Escape hatches.** The sketch only type-checks with casts, untyped values, or optional fields that are always set in practice.
