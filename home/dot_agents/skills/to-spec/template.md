# Spec template

Use the project's domain vocabulary throughout. Name modules, interfaces, types and contracts; leave out file paths and line numbers, which go stale before the work lands. One exception: a snippet from a prototype that pins a decision more precisely than prose (a state machine, a reducer, a schema, a type shape) may go inline, trimmed to the decision and marked as coming from the prototype.

<spec-template>

# <Title>

## Problem

The problem from the user's point of view.

## Solution

The solution from the user's point of view.

## Success criteria

Numbered, each a measurable result with how it's measured: a number with its unit and threshold ("p95 under 300 ms on the search benchmark"), a command and its expected output, or a behaviour someone can watch on a named surface. Turn every vague goal from the conversation into one of these. End with at least one anti-goal: a result that would make this a failure even if it technically works.

## Done-predicate

One run-level condition that decides the whole spec is delivered, countable and decided by printed output, never by an activity ("code written", "reviewed"). Usually: every ticket's CHECK passes on the integrated head, the repo's full readiness check from `GATES.md` exits 0, and each success criterion is shown met. An unattended run uses this as its goal, so it must be checkable from the run's own output.

## Usage

The caller's view, written before the implementation decisions: how each caller (a user on a surface, a CLI invocation, an API client, another module) uses the new or changed behaviour, as short examples of calls, commands or interactions with their results. Prefer the smaller public interface that serves every example.

## User stories

A long, numbered list covering every behaviour, each as:

1. As a <actor>, I want <capability>, so that <benefit>.

## Implementation decisions

The decisions made, derived from Usage: modules built or changed, their interfaces, schema changes, API contracts, architectural choices, technical clarifications from the conversation. Name the existing modules and helpers the work reuses.

## Testing decisions

- The seams where behaviour is tested, and why each is the highest that works.
- What a good test checks here: external behaviour, not implementation details.
- Prior art: similar tests in the codebase to follow.

## Breakage windows

Whether intermediate steps may leave the tree red (outcome over steps). For a migration or rewrite where staying green at every step costs more than it saves, name each window: where it starts and ends, what may be red inside it, the checks that stay green throughout, and the step that restores full verification. Otherwise write "None: every step stays green."

## Out of scope

What this spec excludes, carried over from the `grill` session's out-of-scope line plus anything decided since.

## Further notes

Rulings you made while writing (one line each, with the reason), and anything else an implementer needs.

</spec-template>
