---
name: design-rules
description: House design rules to apply alongside impeccable whenever you design, build, restyle, critique or audit a web interface (landing pages, product UI, components, copy, dark mode), including a quick look at one component file. Load it in the same turn as impeccable or any other UI design skill; it adds rules, it doesn't replace them. Not for backend-only or non-UI work.
---

# Design rules

Apply these wherever the brief, the project's DESIGN.md and the design skill in use (usually impeccable) leave the choice open. Where any of those speaks, it wins. Read them before the first UI edit and before writing a critique or audit.

## Copy

- A control's label names its result, and the same word carries through the flow: a "Publish" button produces a "Published" confirmation.
- Error text states what failed and how to fix it, in the product's voice, with no apology.
- One label per intent across nav, hero and footer (pick "Contact sales" or "Talk to us", not both). A primary button label fits on one line in three words or fewer.
- Headings and buttons follow the case the project already uses; a new project uses sentence case.
- One register per page: hype and terse product copy don't share a screen.
- Curly quotes and apostrophes, a real ellipsis (…), no em dashes (use a period, comma or colon), at most one middle dot per line.
- Testimonials run three lines or fewer and carry the person's name and role.
- Before handing off, read every visible string on the rendered page once, including alt text, empty states and the footer, and cut happy talk: sentences that only say how good something is.

## Tells to leave out when the axis is free

- Palette: a warm cream ground near #F4F1EA with a terracotta accent near #D97757 (Claude's own interface colours); the premium-consumer set #F5F1EA, #EFEAE0, #B08947, #B6553A, #9A2436, #1A1714; tinted near-black (#0B0B0B, #111) standing in for black.
- Type: one word of a headline set apart by italic, weight or colour; tracked all-caps labels; "→" appended to link and button text; labels built as "WORD — fragment".
- Chrome: version tags in the hero (V0.6, BETA) or a version footer; scroll-down cues; locale, clock or weather strips; decorative status dots or pills over images; decorative photo credits; slogan strips like "BRAND. MOTION. SPATIAL."; "Quietly trusted by".
- Data: lists of more than five items drawn as rows ruled above and below; filled progress bars used to compare values.

## Persuade pages

- Hero: headline at two lines or fewer at desktop width, supporting text at 20 words or fewer, the primary action visible without scrolling, four text elements or fewer, top padding of 6rem or less, and nothing under the action buttons (no tagline, trust strip or pricing teaser).
- Set the headline in a wide container with a fluid size (roughly `clamp(3rem, 5vw, 5.5rem)`) so it holds two to three lines at every width.
- Navigation sits on one line, 64–72px tall, never over 80px.
- At most one marquee per page and at most two alternating image/text splits in a row.
- A bento grid of N items has exactly N cells and no empty ones; with dense packing, check that the spans interlock at every breakpoint.
- Name the one thing a visitor should remember after the first look, and make later choices serve it.

## Components and details

- Nested rounded corners: inner radius = outer radius − the gap between them.
- In a row of cards, pin each card's action to its bottom edge so the buttons line up; pricing feature lists start at the same height in every column.
- Italic display type with descenders gets line-height 1.1 or more plus a little bottom padding, so nothing clips.
- Body paragraphs use `text-wrap: pretty` so no paragraph ends on a lone word.
- Visited links look different where people return to content (docs, article lists). No `href="#"` placeholders ship.
- A collapsible sidebar rail is 56–72px wide, keeps its labels in the DOM, has 44×44px targets, sets `aria-expanded` on the toggle and `inert` on hidden content.
- Full-height sections use `dvh` or `svh`, never `100vh`.
- No horizontal scroll at any width. Clip overflow from animated or offset elements with `overflow-x: clip`; `hidden` breaks sticky positioning.
- Scroll-linked effects run on CSS scroll-driven animations or an IntersectionObserver, not on framework state written per scroll event or per frame.
- The viewport meta allows zoom (no `user-scalable=no`, no `maximum-scale=1`). Transitions name their properties instead of `transition: all`.
- A public site ships a skip-to-content link, a custom 404, a favicon, title, meta description and Open Graph tags, and legal links in the footer.
- Keep CSS specificity flat, and check that section-level rules (`.section`) and component rules (`.cta`) don't cancel each other's padding or margin.

## Dark mode

- `color-scheme: dark` on the root, so form controls and scrollbars follow the theme.
- Body text is off-white (around #E0E0E0, tinted from the palette), not pure white.
- Accents drop 10–20% saturation from their light-theme values.

## Critique and audit

Report these as findings inside the design skill's own critique or audit structure; they add no new report sections.

- **Trunk test**, per page: could a first-time visitor say what site this is, which page they're on, what the major sections are, what their options are here, where they are in the structure, and how to search? Three or fewer clear answers is a high-severity finding.
- **Goodwill**: start at 70. Subtract 15 for hidden pricing or contact details or a forced tour; 10 for punishing input formats (rejecting spaces in a card number) or asking for information the task doesn't need; 5 per ambiguous choice. Report the score with each deduction.
- **First look**: name the first three things the eye lands on, and whether they're the three that matter.
- **Happy talk**: report the page's word count and the share that is happy talk.

## Redesigns

Before replacing a live site's look, record an SEO baseline (titles, meta descriptions, headings, indexed URLs). Keep URL slugs, navigation labels, form field names and order, the logo, legal and consent copy, and analytics IDs unless the user approves a change.

## Variants, comps and fonts

- Two variants are too close if their headlines could swap without anyone noticing; push one of them further.
- To read detail in a generated comp, regenerate that section larger instead of cropping the board.
- The batched screenshot round covers 375, 768 and 1440px widths.
- Fix a built page with targeted edits to the parts that fail; regenerate whole files only for a rebuild.
- Confirm every font on its official listing (Google Fonts, Fontshare or the foundry) and take its URL from there; mark an unconfirmed face as pending rather than guessing a name or URL.
