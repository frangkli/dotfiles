---
name: visual-doc
description: Self-contained HTML documents (plans, explainers, research reports, experiment results, tradeoffs and specs) that help a reader understand and decide. Use when writing or revising any of these as a page someone will read, when a delivery skill reaches its plan step, or when a diagram, metric or comparison would explain faster than prose.
---

# Visual doc

Write one HTML page that explains a design, result or tradeoff so the reader can decide. Announce use of the skill briefly.

## Write it

Load the `writing` skill and follow its technical mode, including its AI-tell pass. On top of it:

- The first screen holds the recommendation or result, why it matters, and what the evidence supports. Open with the lead block (`.callout.recommend`): a few short paragraphs, each starting with a bold lead-in (**What we build.**, **Effort.**).
- One `h1` (the title). One `h2` per section, phrased as the claim or question it answers. Number the `h2`s when the text refers to sections by number. `h3` only inside a long section. The docs hub builds its contents list from `h2` and `h3`.
- Paragraphs of at most three sentences, one idea each. Define a term at first use. Name what each part does and who owns it, never a vague box such as "processing layer".
- Walk one concrete request through the parts, with real values (path, ID, payload), in a `<details>` under the structure figure. Show a failure or retry only when it explains the design.
- For options, state what would change the recommendation.
- Label each claim measured, inferred, proposed or illustrative, and put the label in the figure itself: the tile's source, the tab name or the caption. A measured number carries its unit, sample size, denominator and date. A paired comparison states that its conditions match. Note uncertainty and coverage gaps.
- Give the as-of date and whether each change is planned, tested or deployed. An explanation is not approval to implement or deploy.
- Method, sources and implementation notes go in closed `<details>`. A limitation that changes the recommendation stays in the main text. A risk that changes the decision goes in `.callout.risk`.
- Keep the current design apart from history. When revising, rewrite the conclusion instead of appending a status paragraph.
- Show a UI change as a small HTML mockup or a screenshot.

| Kind | Sections, in order |
|---|---|
| Plan | Recommendation, then data flow (backend), a mockup (UI) or before and after (refactor), options, order of work, risks, decisions |
| Explainer | Overview, key terms, how it works, where things live, gotchas |
| Tradeoff | Recommendation, each option drawn at one scale, what would change the call, decisions |
| Research | Finding, evidence with claim labels, what it doesn't cover, method in `<details>` |
| Experiment | Result, metrics and results table, conditions and sample size, what it doesn't cover |
| Spec | Testable behaviour, where the code lives, out of scope, done when |

## Visuals

Show structure, comparison and sequence as a visual by default: a table, a diagram, a card grid, phases or a tree in place of a bullet list. Charts are a separate choice, only for data that has a shape (see the chart rules). Prose carries the reasoning: why, what it means, and what would change the call. Before you write a sentence, find its place in a figure: a node or edge label, a cell, a bar, a tile or a caption. If a sentence describes a figure, make it a label in the figure. Use a numbered list for steps the reader follows. Use bullets only for short parallel items with no order, size or relation between them.

| Content shape | Visual | Rule |
|---|---|---|
| Parts and owners | `.arch` card grid of `.box`es | `.box.new` and `.tag.new` for new parts, `.owner` for who runs it |
| Calls, edges, states | Mermaid flowchart, sequence or state diagram | See diagram rules |
| One request | `.flow` or a sequence diagram | 3 to 6 steps |
| Order of work | `.phases` | Each phase ends on a check |
| Options | Table with `tr.chosen`, in `.scroll` | Followed by a "what would change this" line |
| 1 to 3 numbers | The sentence, with the key number bold, or a small table | The default for small numbers |
| 2 to 4 headline measurements | `.metrics` | Each tile has a `.source` |
| Change over time, when there's enough data | `.spark` sparkline in a tile, or Mermaid `xychart` | The tile's value is the last point |
| Magnitudes or where time goes, when there's enough data | `.bars`, with `--start` for a waterfall | Units on every bar |
| Part of a whole, when there's enough data | `.stack`; a pie only when one share is the point | Its key names every part with its value |
| Before and after | The same figure twice at one scale, in `.arch.two` | `<ins>` for additions, `<del>` for removals |
| Cases (failure modes, environments) | Small multiples in `.arch` with a shared scale | Never a table of sentences |
| Files and calls | File tree with `# role` comments, or a call tree, in `<pre>` | A diff of the tree when the point is the change |
| Many exact values | Table | |
| Dated work, when there's enough data | Mermaid gantt | Without dates, use `.phases` |
| Decisions the reader owns | `.decisions` | At the end, each with a `.default` |

Each figure makes one claim, and its caption opens with that claim. Each keeps a text or table equivalent beside it or in the caption, and stays readable at 390 px wide. Every number comes from a source you can point to. Never invent a value or a position, a quadrant point included. A chart without real data says "illustrative" in its caption.

Diagrams:

- Use a card grid when parts and owners matter more than the arrows, Mermaid when edges and states matter. Past about 12 nodes, draw a Mermaid overview of 5 to 8 nodes and put the detail in cards or a second figure. Hand-draw SVG (`.diagram` with `d-*` classes) only when the layout itself carries meaning.
- Keep node labels to a few words and put the detail and the verb on the edges. Use 5 to 12 nodes.
- Lean horizontal (`LR`) for flows and pipelines, so the diagram uses the page width and keeps the doc short. Use `TD` for hierarchies and long chains. Phones switch to top to bottom on their own.
- Colour a node only with `class <node> good`, `warn` or `bad`. Quote labels that contain punctuation, keep colons out of gantt task names, break lines with `<br/>`, and keep the classes `.node`, `.label`, `.cluster`, `.edgeLabel` and `.note` off page elements, since Mermaid styles them.

Charts:

- Chart only when the data has a shape: about 4 or more values, a trend over 3 or more ordered points, or a comparison across 3 or more items. With 1 to 3 numbers, put them in the sentence (bold the key one) or in a small table. Use metric tiles only for 2 to 4 headline measurements. Never chart small counts such as 3 of 5.
- Start bars at zero, share one scale across small multiples, and sort by value unless the order means something.
- A line needs 3 or more points on an ordered axis. For before and after, use paired bars.
- Use one y-axis, label values directly, add gridlines only when the reader must read values, and annotate only the point the caption names.
- When one series or option is the point, colour it and grey the rest.
- Pie, gantt, timeline, quadrant and sankey charts are fine when they are the clearest form. Prefer `.stack` to a pie, and `.phases` to a gantt that has no dates.

Draw the difference: options or changes become the same figure per option at one scale, with additions in green and removals in red. A code change shows as the file tree, call tree or a diff of either, as in `show-me`.

Tabs switch real scenarios or evidence, and the conclusion stays visible while they change. Add no decorative controls.

## The kit

Copy [assets/template.html](assets/template.html) to the target path, then replace all of its sample content. Keep `<style id="kit">` and `<script id="kit-js">` unchanged, and put page-specific CSS in a second `<style>`. Set `<meta name="doc-kind">` to `plan`, `explainer`, `tradeoff`, `research`, `experiment` or `spec`. See [assets/components.html](assets/components.html) for every component; copy only what the content needs.

Formatting serves clarity and consistency. Break a rule when the figure reads better without it:

- Green means recommended, chosen, new or good. Ochre means a decision for the reader or a draft. Red means a risk or regression. Everything else starts neutral. A chart that must tell categories apart uses the kit's categorical palette, which kit-js also gives Mermaid's pie, timeline, sankey and `xychart`. Pair each colour with a word.
- Bold marks a lead-in, or one key number or term in a paragraph.
- Use the kit's type scale, without font sizes in page CSS. Write − for minus, an en dash for ranges, × for multipliers, and a no-break space between a number and its unit.
- No external fonts, scripts, CDNs or frameworks, with one exception: kit-js loads the pinned Mermaid build from jsDelivr, with an integrity hash, when the page has a diagram. Kit-js also adds the light, dark and system theme control, so add no other.

Use semantic HTML, labelled and keyboard-operable controls, and visible focus. Keep the content readable without JavaScript and at phone width.

## Save

Write HTML with this skill for anything the owner reviews or decides on: plans, explainers, tradeoffs, experiment results and audits. Write Markdown for what later agent steps read: research inputs, specs and architect designs. The docs hub renders both the same way. A Markdown document declares its kind in front matter (`kind: experiment`), and its ```` ```mermaid ```` fences become diagrams in the hub and on GitHub.

1. Save in the worktree you're working in, named `YYYY-MM-DD-<slug>` by the day it was first written:
   - plans, explainers and tradeoffs in `docs/plans/`;
   - research reports and experiment results in `docs/research/`;
   - specs where `to-spec` puts them.

   If the repo documents its own layout for these folders (AGENTS.md, a README inside them), follow that. If its AGENTS.md says "Docs stay local: write them to `docs/local/` in the main checkout.", save them flat in `~/workspace/<repo>/docs/local/` and never commit them. A doc about no repo goes flat in `~/workspace/notes/`, never in a GitHub repo. In both flat folders the kind comes from `doc-kind` or `kind:`.
2. Commit the page with the work it explains, or on its own when the page is the deliverable. It merges to main with the work. When revising, overwrite the same file and let git keep the history: no `-v2` or dated duplicates. The only copy never lives in `.context/`, `/tmp` or an environment-provided visualization directory. Evidence captures that no page links to stay in `.context/`.
3. A page with images, evidence files or sibling pages becomes a directory with `index.html`. Use relative links, never `file://` or preview URLs.

## Check before you finish

1. **Fact-check the page.** List every claim a reader could check: paths, names, behaviour, data flow, commands, APIs, dependencies, tests, numbers, dates and git history. Check each against its source: the code, `git show`, a command you run now, or the cited document. Mark each verified, corrected, unsupported or unverifiable. Fix errors in place, figures included. Remove an unsupported claim or label it as inferred or proposed. Every source link must resolve for the reader: link code at a commit the remote already has, or cite `path:line` as text. Done when every claim has a mark; give the counts in a closing `<details>` note, with what you corrected.
2. **Look at it.** Open the page's docs hub link with the browser tool; the hub serves every worktree's `docs/` and `internal/docs/` live, so the saved file is already there. AGENTS.md names the hub and its link form. Without a hub, open `file://<absolute path>`. Don't start a server. Check at 1280 px and 390 px wide in light and dark, use every control, and look for clipping, unreadable labels, misleading scales and broken sources. Every Mermaid diagram must render: kit-js shows a failed one as its source under a red "This diagram didn't render" note, and the page must contain no "Syntax error" and no `aria-roledescription="error"`. Done when both widths and both themes render cleanly and every control works; if no browser tool is available, say that only source checks ran.
3. **Inspect the file** for leftover sample content, placeholders, external dependencies and private data.

## Deliver

Return the finding or recommendation, the repo path of the page, and its docs hub link. End with the decisions the reader needs to make, each with a recommended default, or say that nothing needs them.
