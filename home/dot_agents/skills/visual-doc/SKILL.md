---
name: visual-doc
description: Self-contained HTML documents (plans, explainers, research reports, experiment results, tradeoffs and specs) that help a reader understand and decide. Use when writing or revising any of these as a page someone will read, when a delivery skill reaches its plan step, or when a diagram, metric or comparison would explain faster than prose.
---

# Visual doc

Write one HTML page that explains a design, result or tradeoff so the reader can decide. Announce use of the skill briefly.

## Write it

Load the `writing` skill and follow its technical mode, including its AI-tell pass. On top of it:

- The first screen holds the recommendation or result, why it matters, and what the evidence supports.
- One `h1` (the title). One `h2` per section, phrased as the claim or question it answers. `h3` only inside a long section. The docs hub builds its contents list from `h2` and `h3`.
- Paragraphs of at most three sentences, one idea each.
- Method, sources and implementation notes go in `<details>`. A limitation that changes the recommendation stays in the main text.
- Keep the current design apart from history. When revising, rewrite the conclusion instead of appending a status paragraph.
- An explanation is not approval to implement or deploy.

## Visuals

Add a visual only when it says something faster than prose: a comparison, a flow, a metric, a timeline. One idea per visual. No decorative images, icons or illustrations.

| Question                             | Visual                                                               |
| ------------------------------------ | -------------------------------------------------------------------- |
| Where does the time go?              | A waterfall (`.bars` with `--start`), overlaps drawn to scale        |
| What changed in the experiment?      | Metric tiles plus a results table                                    |
| How does this work or fail?          | A `.flow` through the real components and owners                     |
| Which option should we choose?       | An options table with the chosen row marked                          |
| What talks to what, in which states? | A Mermaid diagram: sequence, state, ER, dependency graph or timeline |

Pick the diagram tool by what it shows:

- Mermaid (`<pre class="mermaid">`) is the default for structural diagrams. Colour a node with `class <node> good`, `warn` or `bad`; add no other styling.
- The kit's `.flow` and `.bars` cover simple flows and magnitudes.
- Hand-drawn inline SVG only for a bespoke visual whose layout carries meaning.

Each diagram or chart shows one idea, stays readable at 390 px wide, and has a text or table equivalent in its caption or beside it.

Every number comes from a source you can point to; never invent values to fill a chart. State units and the full-width scale in the caption, and never carry meaning by colour alone.

## The kit

Copy [assets/template.html](assets/template.html) to the target path, then replace all of its sample content. Keep `<style id="kit">` and `<script id="kit-js">` unchanged; put page-specific CSS in a second `<style>`. Set `<meta name="doc-kind">` to `plan`, `explainer`, `tradeoff`, `research`, `experiment` or `spec`.

| Component                     | Use it for                                          | Rule                                    |
| ----------------------------- | --------------------------------------------------- | --------------------------------------- |
| `.callout.recommend`          | The recommendation                                  | Once, before the first `h2`             |
| `.callout.risk`               | A risk that changes the decision                    | Only when it does                       |
| `.callout`                    | A note the reader must not miss                     | Rarely                                  |
| `.metrics`                    | Measured headline numbers                           | 2 to 4 tiles, each with a `.source`     |
| `.bars`                       | Magnitudes side by side, or a waterfall             | Units on every bar                      |
| `.flow`                       | A request or process through its owners             | 3 to 6 steps                            |
| `pre.mermaid`                 | Sequence, state, ER, dependency and timeline views  | One idea; caption gives the text form   |
| `.diagram` with `d-*` classes | A bespoke visual whose layout carries meaning       | Readable at 390 px wide                 |
| Table with `tr.chosen`        | Options and their tradeoffs                         | Wrap in `.scroll`                       |
| `.tabs`                       | Alternative views of one thing (before and after)   | All panels must make sense on their own |
| `.decisions`                  | Decisions the reader owns                           | At the end, each with a `.default`      |
| `<details>`                   | Method, sources, the fact-check note                | Closed by default                       |

Formatting shows hierarchy and nothing else:

- Colour has three meanings, set in the kit: green for the recommendation, the chosen option and good results; ochre for decisions the reader owns and drafts; red for risks and regressions. Use no other colours, and pair each colour with a word.
- Bold marks at most one key number or term per paragraph.
- Use the kit's type scale; don't set font sizes in page CSS.
- No external fonts, scripts, CDNs or frameworks, with one exception: kit-js loads the pinned Mermaid build from jsDelivr, with an integrity hash, when the page has a diagram.
- Kit-js adds the light, dark and system theme control; don't add another.

Use semantic HTML, labelled and keyboard-operable controls, and visible focus. Keep the content readable without JavaScript and at phone width.

## Save

1. Save in the repo you're working in, named `YYYY-MM-DD-<slug>.html` by the day it was first written:
   - plans, explainers and tradeoffs in `docs/plans/`;
   - research reports and experiment results in `docs/research/`;
   - specs where `to-spec` puts them.

   If the repo documents its own layout for these folders (AGENTS.md, a README inside them), follow that. A Markdown document in these folders declares its kind in front matter (`kind: experiment`); the docs hub renders it with the kit, and ```` ```mermaid ```` fences become diagrams there and on GitHub.
2. Commit the page with the work it explains, or on its own when the page is the deliverable. When revising, overwrite the same file and let git keep the history: no `-v2` or dated duplicates. The only copy never lives in `.context/`, `/tmp` or an environment-provided visualization directory. Evidence captures that no page links to stay in `.context/`.
3. A page with images, evidence files or sibling pages becomes a directory with `index.html`. Use relative links, never `file://` or preview URLs.

## Check before you finish

1. **Fact-check the page.** List every claim a reader could check: paths, names, behaviour, data flow, commands, APIs, dependencies, tests, numbers, dates and git history. Check each against its source: the code, `git show`, a command you run now, or the cited document. Mark each verified, corrected, unsupported or unverifiable. Fix errors in place, figures included. Remove an unsupported claim or label it as inferred or proposed. Every source link must resolve for the reader: link code at a commit the remote already has, or cite `path:line` as text. Done when every claim has a mark; give the counts in a closing `<details>` note, with what you corrected.
2. **Look at it.** Open the page's docs hub link with the browser tool; the hub serves every worktree's `docs/` live, so the saved file is already there. AGENTS.md names the hub and its link form. Without a hub, open `file://<absolute path>`. Don't start a server. Check at 1280 px and 390 px wide, use every control, and look for clipping, unreadable labels, misleading scales and broken sources. Done when both widths render cleanly and every control works; if no browser tool is available, say that only source checks ran.
3. **Inspect the file** for leftover sample content, placeholders, external dependencies and private data.

## Deliver

Return the finding or recommendation, the repo path of the page, and its docs hub link. End with the decisions the reader needs to make, each with a recommended default, or say that nothing needs them.
