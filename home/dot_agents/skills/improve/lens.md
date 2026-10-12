# Maintenance lens

For a maintenance or system-improvement pass with no review findings to start from. The reviewer looks for structure and quality, in this order, and each fix keeps behaviour unchanged. Idiom and style findings come from `adversarial-review`'s idioms lane in the later reviews, so this lens stays on design.

1. **Delete** dead code, unused options and exports, and unused files. First check for uses a search won't show: public APIs, generated code, reflection, serialisation, plugins.
2. **Collapse** wrappers with one caller, adapters with only one implementation, and layers that repeat the methods beneath them. Test: can a new reader find where a value comes from and what can change it in under a minute?
3. **Consolidate** each decision or data shape into one source of truth, and derive the rest. Leave code that only looks similar but changes for different reasons.
4. **Model state explicitly.** Flags that must stay in sync become one state type; a growing chain of conditionals across files becomes a table or a tagged union.
5. **Remove internal shims.** Move the remaining callers of a deprecated internal path and delete it.
6. **Shrink state.** Return values instead of mutating; locals instead of fields; no module-level mutable state.
7. **Split by job, never by line count.** Add a new layer or pattern only when it deletes more than it adds.

Stop when the problem you diagnosed is gone. Each step lands as its own commit, separate from feature work.
