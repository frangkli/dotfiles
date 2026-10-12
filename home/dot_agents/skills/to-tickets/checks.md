# CHECK lines

Each ticket carries exactly one:

```
CHECK: <command> → exit 0 + "<token>"
```

It passes only when the command exits 0 **and** its output contains the token. Either alone proves nothing: a test runner that matched no tests can exit 0, and an error message can contain the token.

## Writing one

- **Start from `GATES.md`** (or the task runner scripts and CI workflow when the repo has none). Use the repo's check commands, narrowed to what the ticket touches (one package, a test-name filter). Use the cheapest command that observes the ticket's outcome; the full readiness check belongs only to the ticket that closes a breakage window or ends the run.
- **A success-only token.** Pick output that appears only after every assertion passed: the runner's summary line with a count from this ticket's tests ("4 passed"), or an `echo` chained with `&&` after the assertions.
- **Observe the outcome, not an activity.** "A duplicate key returns 409", not "handler added".
- **Measure numbers yourself.** A number copied from the spec into the token proves nothing; the command must compute it.
- **Absence needs a control.** A check that something is gone also proves, in the same command, that the search finds something known to exist, so a wrong path or pattern can't pass as absence:

  ```
  CHECK: grep -rq 'newClient(' src && ! grep -rq 'legacyClient(' src && echo NO_LEGACY → exit 0 + "NO_LEGACY"
  ```

- **One command line.** Chain steps with `&&`. If it needs setup (a running service, seed data), call the repo's script or task for it; secrets come through the repo's secrets wrapper.
- **It must be able to fail.** Before the ticket's work, the CHECK fails. One that already passes needs a sharper token or a different command, unless the work has already landed: then mark the ticket done and quote the passing output.
- **Manual only when nothing can decide.** For a visual judgement or a manual operation, write `CHECK: manual → <who confirms what, on which surface>`. The ticket isn't done until that person confirms. Keep these rare.
