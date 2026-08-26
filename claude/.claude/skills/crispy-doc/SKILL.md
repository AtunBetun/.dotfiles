---
name: crispy-doc
description: Retouches, synthesizes, or reviews supplied business and technical prose without changing facts, structure, or certainty. Use for concise, connected, system-centered, grammatical, leadership-ready writing.
---

# Crispy doc

Use the source as the factual boundary. Preserve every fact, number, link, decision, qualification, owner, contradiction, and level of certainty. Add no evidence or substantive claim. When two source claims conflict, keep both and make the mismatch clear; never reconcile them by choosing, merging, or silently rewriting one.

## Choose the mode

- **Retouch:** Improve grammar, wording, paragraph flow, and readability without changing meaning.
- **Synthesize:** Retouch and shorten by removing repetition and merging overlapping points. Preserve every unique example, mechanism, qualification, decision, tradeoff, and unresolved issue.
- **Review:** Read [REVIEW.md](REVIEW.md), then identify defects without rewriting unless the user requests edits.

Follow the requested mode. In retouch and synthesis modes, return only the revised prose; start with the content itself.

## Workflow

1. Inventory the source's claims, evidence, numbers, links, decisions, qualifications, owners, contradictions, uncertainties, headings, order, and format.
2. Apply the mode and the shared writing standard below.
3. Compare the result with the inventory. Restore anything lost or made more certain.
4. Run the mode's finish check. Fix every failure before returning the result.

## Shared writing standard

### Develop paragraphs

Treat the paragraph as the unit of composition. Give each explanatory paragraph one topic and develop only the logic the source supports. Use the shape that fits:

- Claim: point → fact or example → reasoning → significance.
- Walkthrough: concept → concrete case → ordered mechanism → result.
- Problem: failure → cause → example → impact or requirement.
- Decision: choice → evidence and criteria → strongest alternative → tradeoff.
- Control: risk → control → condition or metric → response → guarantee.

Combine fragments that leave one topic undeveloped; split when the topic changes. Every sentence must add a claim, fact, example, mechanism, reason, consequence, comparison, qualification, or decision. Never pad a paragraph or force a sentence count.

### Make sentences substantive

Name the relationship, trigger, role, or consequence instead of announcing content or position.

| Defect | Repair |
|---|---|
| Empty orientation: `Two paths sit outside this flow.` | Name both paths and how each differs, or merge their names into the next substantive sentence. |
| Bare sequence: `Then Amazon invoices the sale.` | Name the dependency: `After checkout confirms the order, Amazon invoices the sale.` |
| Vague role: `Amazon sits in the middle of all five steps.` | State the concrete functions Amazon performs, or delete the summary if the walkthrough already states them. |
| Answer announcement: `The first answer is yes.` | Match the question and answer by subject and predicate before fusing them, then restate that proposition directly. A statement about Amazon charging the customer does not answer whether Amazon overpays a tax authority. If they do not match, preserve both: state that the question remains unresolved and present the separate claim on its own. |
| Count or preview: `Three things follow.` or `Two questions follow: whether X and whether Y.` | Remove the count or preview frame. Delete it when empty; when content follows inline, restate each concrete subject in the sentence that answers or develops it. Preserve an unanswered or contradictory question explicitly. |
| Inverted clause | Put the subject before its verb and move figures into readable clauses: `The lipstick lists at 1,000.00 net. Adding 16 percent IVA, 160.00, brings the customer price to 1,160.00.` |

Use spatial terms such as `inside`, `outside`, `middle`, `upstream`, and `downstream` only for real boundaries, topology, or dependencies. Use sequence terms only when order matters. Prefer direct subject–verb order; a dependency clause may come first when it carries necessary logic. Allow at most one numeric appositive per sentence, and never place one between a subject and its verb.

### Connect the logic

Make relationships explicit when the reader would otherwise have to infer them:

- dependency: `After`, `Before`, `Once`, `When`, `Until`
- cause: `Because`, `Since`
- consequence: `Therefore`, `As a result`, `Consequently`, `This prevents`
- contrast: `However`, `In contrast`, `Instead`
- parallel work: `Meanwhile`, `Concurrently`
- example: `For example`

Name the concrete event or condition after a sequence transition. Use transitions only when they expose real logic; decorative repetition makes prose mechanical.

### Center the system

Use the most specific design, component, process, control, metric, state, or evidence as the subject: `The SchemaProvider checks the cache.` Prefer active subject–verb–object order.

Replace empty narration such as `we will`, `the team will`, or `the operator will` with system behavior or a process condition. Preserve a named owner when ownership is a source fact. Preserve whether work is manual or automatic: `Production promotion requires manual approval` must not become an automatic trigger. Use passive voice when no useful subject is known or the action matters more than its source. Keep instructions imperative.

### Be direct and restrained

Use supplied names, numbers, dates, conditions, and observable results. Preserve genuine estimates and uncertainty with their basis. Replace vague comparisons and unsupported adjectives with supplied evidence; if the source supplies none, keep the uncertainty rather than inventing precision.

Cut repetition before reasoning. Remove throat-clearing, duplicated conclusions, empty qualifiers, redundant pairs, and self-referential commentary. Delete intensifiers and editorial verdicts such as `fundamentally`, `genuinely`, `significant`, `biggest`, `precise`, and `not a formality`; retain the fact and measurable stake.

Carry emphasis in sentence structure. Use bold only for defined terms and labels required by the surrounding format. Remove decorative bold, italics, emoji, warning symbols, and vocal-stress punctuation. Convert rhetorical questions into declarative statements. Split em-dash chains and nested parentheticals; allow one short identifier or acronym expansion in parentheses. Replace colon-fragment openers with complete sentences.

### Keep notation consistent

Correct spelling, agreement, tense, articles, punctuation, parallelism, modifier placement, and ambiguous pronouns. Place `only` beside what it modifies. Use one stable name for each concept. Expand an acronym at first use unless the source already defines it. Apply inline code to symbols, APIs, commands, flags, paths, configuration keys, field names, and literal values. Preserve official names and quoted text.

When the source contains Mermaid, read `skill://crispy-mermaid` before editing or reviewing the diagram. Preserve the diagram's role in the prose.

## Retouch and synthesis rules

Preserve supplied headings, section order, and format unless the user requests a structural change. Add no sections, document format, audience announcement, or process commentary.

In synthesis mode, preserve each unique meaning once and place it where it best supports the paragraph. Keep mechanisms, evidence, qualifications, tradeoffs, consequences, decisions, and unresolved issues; remove only repetition and commentary that adds no information.

### Finish check

Before returning revised prose, verify that:

- every source fact, number, link, decision, qualification, owner, contradiction, and certainty remains;
- headings, order, and format remain unless the user requested a change;
- each paragraph develops one topic without padding;
- every sentence carries concrete content or a necessary logical relationship;
- manual and automatic behavior remain distinct;
- synthesis removes repeated meanings but retains their supporting reasoning;
- wording, grammar, terminology, notation, and formatting are consistent;
- the result contains no announcement sentence, empty orientation, bare sequence, inverted clause, decorative emphasis, rhetorical question, intensifier, or self-referential commentary.
