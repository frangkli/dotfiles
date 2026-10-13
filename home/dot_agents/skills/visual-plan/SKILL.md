---
name: visual-plan
description: HTML plans and reports that explain a design, experiment or tradeoff so the reader can decide. Use when writing or revising a plan or a research or measurement report, when a delivery skill reaches its plan step, or when a visual mental model or evidence comparison would help someone choose.
---

# Visual Plan

Help the reader understand the system and make a decision. Deliver a portable HTML explanation, not a decorative dashboard. Announce use of the skill briefly.

## Shape the explanation

- Establish the reader's decision, recommendation, and the concrete system or experiment being explained. Reuse known preferences and context; ask only about material gaps.
- Lead with the recommendation, why it matters, and what the evidence supports. Give a clear mental model within the first screen or two.
- Keep the main story concise. Put source detail, implementation notes, and measurement methods in native `<details>` sections. Keep any limitation that changes the recommendation in the main story.
- Use consistent plain language. Define necessary technical terms at first use. Replace vague boxes such as “processing layer” with what happens and who owns it.
- Show a concrete request or example through component boundaries. Include important failures, retries, ownership, or transaction boundaries when they explain the design; leave out edge cases that don't change it.
- Offer a few meaningful options with benefits, costs, limitations, and a recommendation. State what would change that recommendation. End with the decision or next action, not a repeated summary.
- Separate the current design from historical worklogs. When updating, rewrite the main conclusion instead of appending another status paragraph. Preserve scope and approval state: an explanation is not permission to implement or deploy.

## Use visuals for reasoning

Choose the visual that answers the actual question, and remove sections that add no value:

| Question                        | Useful visual                                                  |
| ------------------------------- | -------------------------------------------------------------- |
| Where does the time go?         | A scaled waterfall with overlapping work shown accurately      |
| What changed in the experiment? | Paired baseline/comparison plot and readable results table     |
| How does this work or fail?     | Request flow with concrete operations and ownership boundaries |
| Which option should we choose?  | Compact table of meaningful tradeoffs                          |

Prefer a few purposeful controls: switch real scenarios, compare alternatives, reveal evidence. Leave out animation, simulators, filters, or tabs that merely decorate the page. Keep the conclusion visible while controls change the supporting view.

Keep evidence honest: distinguish measured, inferred, proposed, and illustrative claims. Include units, sample size, denominators, scope, and collection date for quantitative results. Give the page an as-of date, and say whether each piece of behaviour is planned, tested, or deployed. Cite supporting sources near claims. Every number comes from a source you can point to: no invented measurements, confidence intervals, or numerical effects for a slider. Paired comparisons need comparable conditions; label uncertainty and coverage gaps. Preserve a textual/table equivalent of a chart and never encode meaning only by color.

## Visual defaults

Start from [assets/explainer.html](assets/explainer.html), then adapt freely to the task. Its sample content explains this skill; it is not a required structure. Replace or remove it fully for other tasks.

- Quiet light background, white content surfaces, subtle borders, restrained green/ochre accents with consistent meanings.
- Compact, readable typography: Avenir Next with Avenir/Gill Sans/sans-serif fallbacks, 15px body text at 1.55 line height, and headings about 20–28px. Keep simple bordered request-flow steps. Use monospace only for code or identifiers. Use bold sparingly and one type family; titles stay modest, with no KPI tiles, gradients, or shadows.
- Use whitespace to group related ideas, not inflate page length. Prefer ordinary sections and tables over nested cards. Leave about 12px between a table and its explanatory note; do not rely on cell padding to create that outside gap. Let short chart/table notes use the graphic width. Reserve narrower reading measures for longer prose, and let text wrap on its own rather than with manual line breaks.
- Inline CSS and small vanilla JavaScript. Use HTML/CSS or SVG for diagrams. A standalone explanation needs no framework, build step, external fonts, or CDN.
- Use semantic headings, labels, keyboard-operable controls, visible focus, descriptive links, and responsive layouts. Keep essential content readable without JavaScript. Adapt diagrams to narrow screens; constrain wide table scrolling to its own region.

## Save

1. Save in the repo you're working in, outside the skill directory:
   - plans as `docs/plans/YYYY-MM-DD-<slug>.html`;
   - research and measurement reports as `docs/research/YYYY-MM-DD-<slug>.html`.

   The date is the day the page was first written. If the repo documents its own layout for these folders (AGENTS.md, a README inside them), follow that.
2. Commit the page with the work it explains, or on its own when the page is the deliverable. When revising, overwrite the same file and let git keep the history: one current copy, no `-v2` or dated duplicates. The only copy never lives in `.context/`, `/tmp`, or an environment-provided visualization directory. Evidence captures that no page links to (saved responses, probe output) stay in `.context/`.
3. Keep each page self-contained and useful when opened as a file. A page with images, evidence files or sibling pages becomes a directory with `index.html`; use relative links, never `file://` or preview URLs.

When a hub serves the repo, it indexes `docs/plans/`, `docs/research/` and `docs/specs/` live from disk, labelled by repo and branch, so a saved page shows there at once, unmerged branches included.

## Check before you finish

1. **Fact-check the page.** List every claim a reader could check: paths, names, behaviour, data flow, commands, APIs, dependencies, tests, numbers, dates, and git history. Check each against its source: the code, `git show`, a command you run now, or the cited document. Mark each verified, corrected, unsupported, or unverifiable. Fix errors in place, figures included (a wrong edge or label is a wrong claim). Remove an unsupported claim or label it as inferred or proposed. Every source link must resolve for the reader: link code at a commit the remote already has (such as the merge base with the default branch), or cite `path:line` as text. Done when every claim on the page has a mark; give the counts in a closing `<details>` note, with what you corrected.
2. **Render it.** For a quick look, run `python3 <skill-directory>/scripts/serve.py /absolute/path/page.html`: it binds loopback on a free port, prints the URL and serves only that file, for as long as the process runs. Open the URL (or the hub page, when a hub serves the repo) with the available browser tool. Check the page at desktop and narrow widths, exercise every control, and look for clipping, unreadable labels, misleading scales, and broken sources. Done when both widths render cleanly and every control works; if no browser tool is available, say that only source checks ran. Stop the preview process afterwards.
3. **Inspect the file** for placeholders, leftover sample content, external dependencies, and private data.

When changing the preview helper, run its standard-library regression test: `python3 -m unittest discover -s <skill-directory>/scripts`.

## Deliver

Return a brief finding or recommendation, the repo path of the page, and its hub link when AGENTS.md or the environment names the hub's address. End with the decisions the reader needs to make, each with a recommended default, or say that nothing needs them.
