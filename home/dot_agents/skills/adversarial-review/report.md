# Report

A review report is finished work. The reader should never need to ask "did you check?" or "what does this mean?". Write its prose per the `writing` skill's technical mode ([../writing/technical.md](../writing/technical.md)), with the order below in place of its report contract.

1. **Verdict first.** One or two sentences: is the artifact sound, and what must change before it ships.
2. **Coverage.** The review size (light or full), the fact that decided it, and the bite test's result when one ran; each lane with its status and finding count, any gaps and why, and the base and head commits (or plan file) reviewed.
3. **Act on**, then **Consider**, then **Noted**, each under its own heading even when empty. Each finding stands alone:
   - what is wrong and where (`file:line` or plan section);
   - why it matters: the concrete failing case or its impact;
   - the evidence: what you ran or traced, and what it showed;
   - the fix, and roughly what it costs;
   - which lanes or reviewers raised it.
4. **Dismissed**, each with its reason.
5. **What `improve` did** (code changes), under its own heading: its outcome and round count, the findings it fixed with their pins and commit, and anything it escalated.
6. **Decisions for the user**, if any: each with the options, a recommended default, and what happens under each. If nothing needs the user, say so.

Everything you could check yourself is checked before you report. Never end with "next, verify X" or "confirm Y": do it, or say what blocked you.

If the run stopped early (an escalation, a halt, a usage limit), still report what finished, and mark each step that didn't run.

For a long report, run a reader test before returning it: give the report alone to a fresh subagent, ask which questions it would still have, and answer them in the report.
