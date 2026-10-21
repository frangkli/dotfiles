# Rulings and escalation

**Before asking, classify the question.** If the answer is a fact you could observe by running something (a prototype, a measurement, reading the code), get it yourself. That makes it a ruling, not a question.

## Reaches the user

Only these, batched into as few blocked tickets as possible:
- **Manual operations:** credentials, accounts, billing or paid access, CAPTCHA or 2FA, production changes, external outreach.
- **Real product forks:** a choice the spec doesn't settle, and that no prototype or measurement can settle.
- **Ambiguous spec lines:** two readings that lead to different observable behaviour.
- **High-impact interfaces:** the exact types of a public API, shared contract or schema, before their unit is built ([../orchestrate/brief.md](../orchestrate/brief.md)).

Each becomes a ticket with status `manual` or `blocked`, linked as blocking the tickets it holds up. It contains:
- the exact action or question;
- why the agent can't do it;
- the options, with a recommended default;
- what the agent will run afterwards to confirm it;
- the resume condition.

Secrets and their values stay out of tickets; name the secure path the user should use instead.

A gate that can't pass works the same way. Mark the ticket `blocked` with the reason, and leave the CHECK as written. The ticket stays visible and never counts toward the predicate.

## Stays with the agent

Retries, flaky CI, merge conflicts, review-thread triage, formatting, naming and file layout, scope the brief already excludes, and whether to keep going. Decide, log the ruling, continue.

## Ruling log

One row per ruling in the run file:

| when | decision | class | why | rejected alternative | evidence |
|---|---|---|---|---|---|

- **mechanical:** log only.
- **taste:** log it, and list it under Attention with the default you took.
- **challenge** (cuts against the spec or the user's stated direction): follow the spec, and list it under Attention as a question.

A user amendment mid-run is a scope change. Log it, update the contract inventory, and reconcile both before counting any more tickets as done.
