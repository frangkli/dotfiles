# Tickets

The root agent is the only writer of ticket state. Workers report to it.

## CHECK lines

`CHECK: <command> → <expected>`. A CHECK passes only when the command exits 0 **and** the expected text appears in its output. A CHECK that asserts absence must first be shown to catch a known case.

When no command can decide a requirement, write `REVIEW: <what to read> → <what must hold>` instead. The root agent records the verdict and its evidence in the run file's rulings. Keep REVIEW lines rare: most requirements can be observed by running something.

## Repo markdown (default)

Keep the format `to-tickets` wrote (one file per ticket, or one list). Each ticket carries:
- `Status:` one of `todo`, `in-progress`, `in-review`, `done`, `blocked`, `manual`;
- `Blocked by:` ticket ids;
- its acceptance lines, each with a CHECK.

Update the status in place, and commit status changes with the work they describe. When the repo uses OpenSpec or Spec Kit, use its task list and checkboxes instead, with the CHECK beside each task.

## Linear (when the project tracks work there)

| Here | Linear |
|---|---|
| Status | The team's closest existing status; leave the workflow as it is |
| `Blocked by:` | Blocking relations |
| `manual` | A `manual-operation` label, assigned to the user |
| Run file | A project document |
| Pickup note | A comment on the project's latest update |

Touch only this project, never other projects or workspace settings.
