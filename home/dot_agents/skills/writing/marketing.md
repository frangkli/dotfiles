# Marketing: blogs, landing copy and announcements

The readers owe you nothing and leave at the first sentence that sounds like an ad. The bar: a developer would share the piece with their team.

## Rules

- **Open with the problem or the conclusion** in the first two sentences. Background, company history and hype come out.
- **Follow the reader's questions in order:** what problem this solves (short); how it works underneath (the bulk, and specific); the trade-offs and alternatives; how to try it. Engineering deep dives add what didn't work and the known limits.
- **Claim exactly what the product does.** Say beta when it's beta, and "suggests a likely cause" when it suggests one. A performance claim carries its number, unit and baseline.
- **Titles and headings make a specific claim** ("Why pre-aggregated metrics lose debugging context"), not a topic ("Architecture").
- **The voice runs through the whole piece:** first-person asides in the middle ("this is the part that tripped me up"), instead of a personal opening, a clinical middle and a sales close.
- **End with something to do:** docs, source, a way to try it, or a question for feedback.
- **Break paragraphs at turns in the argument.** A one-sentence paragraph is fine when it carries a new fact.
- **Words to cut on sight**, beyond humanizer's list: excited or thrilled to announce, best-in-class, industry-leading, cutting-edge, seamless, empower, leverage, unlock, streamline, game-changing, "At <company>, we believe", "In this post we'll explore".
- **Marketing tells:** smug simplicity (a code block followed by "That's it."), parallel ad-copy pairs ("Metrics tell you what's broken. Traces tell you why."), and three-beat reveals ("Not X. Not Y. It was Z."). Merge each into one sentence that states the claim.
- **Landing copy:** the headline says what the product does and for whom; one primary call to action per screen; every claim backed by a feature, number or quote the owner provided.
- **Announcements:** lead with what shipped and what the reader can now do. Dates, availability and prices come from the owner.
- **Proof:** code samples run; a system with more than two interacting parts gets a diagram.
- **Missing facts become questions.** When you lack how it works, how to try it, or the numbers, ask the owner or leave `[confirm: …]` placeholders. A paragraph of general benefits in their place is padding.

Done when a reader could answer "what is it, how does it work, how do I try it" from the piece, every claim traces to the owner or a source, and the AI-tell pass is done.

## Long pieces: fragments, then shape or beats

For anything longer than about 800 words, separate exploring from committing.

1. **Fragments (explore).** Interview the owner one question at a time about what they built, noticed, got wrong and believe. Append each usable piece to a fragments file, separated by `---`, in the order they come, with no headings. Push for a **leading word**: one term the whole piece can hang on. Done when the owner says the pile is enough. Working unattended, build the pile from the sources (PRs, notes, docs) and tell the owner it is yours.
2. **Prerequisites.** Agree what the reader knows walking in. Every other concept must be grounded in an earlier block before a later block leans on it.
3. **Shape (exploit), for an argument.** Draft two or three openings, each implying a different thesis, and let the owner pick or merge one. Then grow the article block by block: given what is grounded so far, ask what the reader needs next, pull it from the pile, choose its form (prose, list, table, code), and append it once agreed. When the pile lacks something, name the gap and ask for it, or cut the section.
4. **Beats (exploit), for a story.** Instead of shaping, offer two or three candidate next beats from where the piece stands, each reachable from the grounded concepts and saying what it grounds. Write only the chosen beat, then offer the next.

Once shaping starts, the fragments file is read-only. Re-read the article from disk before each write, since the owner may have edited it. Finish with the rules above.

## Return

The piece, in a file for anything long or in chat for short copy, plus a list of claims that need the owner's confirmation. End the chat reply with the AI-tell proof line from SKILL.md.
