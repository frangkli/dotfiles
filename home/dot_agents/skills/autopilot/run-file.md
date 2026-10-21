# Run file

`RUN.md` beside the tickets, committed with them; in Linear, a project document. The root agent is its only writer. Ticket statuses live in the tickets themselves, not here. The user reads it to follow and resume the run, so write its prose (rulings, notes, the pickup) per the `writing` skill's technical mode ([technical.md](../writing/technical.md)).

```markdown
# Autopilot run: <slug>

Spec: <path or link> · Tickets: <directory or Linear project> · Branch: <integration branch> · Base: <sha>
Predicate: <text>, N = <n>
Goal: <objective line> (set <date> in <harness>)
Budget: <tokens or time, or none>

## Standing orders
1. <one constraint per line; pasted into every brief>

## Contract inventory
| id | requirement (spec line) | ticket | observing CHECK |
|---|---|---|---|
| R1 | "Exports are capped at 10k rows" (spec §3) | T-4 | `<command>` → `CAP OK` |

## Rulings
| when | decision | class | why | rejected alternative | evidence |
|---|---|---|---|---|---|

## Progress
| wake | done/N | blocked | gate state changed | note |
|---|---|---|---|---|

## Pickup
<while paused or at a phase handover: where the run is, what is verified at which SHA, what was in flight, the phase's cost, the next action, gotchas>
