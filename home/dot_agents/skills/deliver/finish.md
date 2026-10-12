# Final report

Re-run or re-read every number and status just before writing it; the report states what is true now.

1. **Outcome.** One or two sentences: what the user now has, and where.
2. **Status.** One row each, with yes, no or n/a and the evidence:

   | Stage | Evidence |
   |---|---|
   | Implemented | Commits on the branch |
   | Merged | PR link and merge SHA |
   | Deployed | The deploy record or version showing that SHA live |
   | Published | Artifact names and versions containing the change |
   | Enabled | Flags, configuration and migrations applied |
   | Verified | The acceptance runs per surface, and the telemetry checked |

   A row without evidence says no, and why.
3. **What changed.** A few lines, with links to the PR, releases and the plan.
4. **Verified outcomes.** Per surface: what ran and what it showed.
5. **Rulings.** Taste rulings and challenges, each a row in the [rulings.md](rulings.md) format; mechanical rulings as a count plus any worth a look.
6. **Remaining work and limitations.** Out-of-scope discoveries, repo gaps (no `GATES.md`, no `verify` skill), genuine blockers.
7. **Attention.** What the user should check, drawn from the rulings log: taste rulings made after approval, challenges followed rather than raised, anything verified below the live surface, findings dismissed on a narrow argument. "Nothing needs attention" is a valid entry.
8. **Decisions for the user**, each with options and a recommended default, or "nothing needs you".

A run authorized to merge reports after production acceptance, not at "ready to merge". A run with a blocked gate reports it as blocked, with what blocks it.
