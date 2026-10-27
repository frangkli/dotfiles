---
type: research
date: <YYYY-MM-DD>
topic: "<topic>"
repos:
  - identifier: <owner/repo>
    sha: <full commit SHA read>
versions:
  <library or API>: <version the repo pins>
status: complete | open-questions
---

# Research: <topic>

## Questions

1. <Current-state question, as asked.>
2. <…>

## Summary

<Two to four paragraphs: the main findings and how the parts connect. A reader who stops here knows the answers.>

## Findings

### 1. <A sentence that states what is true, e.g. "Workers restore pending jobs before accepting new work">

<The finding first, then how it works, with `path:line` citations. Add a table, a sequence or flow diagram, a call tree or signatures beside the prose they support.>

**Tests:** <where the tests for this are, what kind, the fixtures and helpers they use; or "none found" and where you looked.>

### 2. <Next finding as a statement>

<…>

## Checks run

| Command | What it shows | Result |
|---|---|---|
| `<command>` | <the claim it supports> | <observed output, short> |

<Or "None: every claim above comes from reading code, tests and docs.">

## Code references

<Files and directories grouped by area, one line each on their role. Say whether the list is exhaustive or covers the key files.>

## External sources

<Each link with what it supports, and the version and date it applies to.>

## Open questions

<What's still unknown about the current system, and what blocked finding it. Or "None.">
