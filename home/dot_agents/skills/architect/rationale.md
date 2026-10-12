# Design doc template

About a page of prose plus the sketch. File lists, wiring steps and test plans belong to `to-tickets`, not here. Replace each note in italics.

```markdown
---
type: design
date: <YYYY-MM-DD>
repos:
  - identifier: <owner/repo>
    sha: <base commit>
spec: <path or link>
research: <path>
---

# Design: <topic>

## Problem

*One paragraph: what the code must do, and what about the existing system makes the shape non-obvious. Name the constraints from grounding: types to interoperate with, callers that can't break, invariants that cross the boundary, each with `path:line`.*

## Usage (caller's view)

*Written first. The quickstart a consumer reads, then each job from the usage brief as a real call site in the file it would sit in: what is imported, what is called, what comes back, which failures are handled. The Shape below is derived from this; when they disagree, the types change.*

## Shape

*The data first, then how it flows through the signatures, then the sketch itself as code. Name the load-bearing decisions: which invariants the types enforce, where validation happens, who owns each piece of state, what the design deliberately does not do. State what the public surface hides and why it is no larger than it is.*

## Synthesis decision

*From arena's synthesis note: the base and why; the score tables; each graft and its source; what was passed over and why; convergence, divergence or dropouts; candidate branches and SHAs.*

## Tradeoffs accepted

*One line each: "We accept X in exchange for Y." Include anything a later reader could mistake for an oversight.*

## Alternatives considered

*Required. Each losing whole shape, in one or two lines: what it exposed to callers, what it hid, and why it lost. If the constraints left only one viable shape, say "this was the only viable shape because…".*

## Review

*The adversarial review's outcome: findings acted on and how the design changed, and declined findings with the reason.*

## Open questions and risks

*Phrased as questions, each with a recommended answer, so the reply is the decision.*

## Next step

*The first thing to build against this sketch, in one sentence.*
```
