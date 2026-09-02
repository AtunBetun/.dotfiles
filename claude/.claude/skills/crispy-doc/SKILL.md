---
name: crispy-doc
description: Retouches, synthesizes, or reviews supplied business and technical prose without changing facts, structure, or certainty. Use for concise, connected, system-centered, grammatical, leadership-ready writing.
---

# Crispy doc

Use the source as the factual boundary. Preserve every established fact, number, link, decision, qualification, owner, contradiction, and bounded estimate. Add no evidence or substantive claim. When two source claims conflict, keep both and make the mismatch clear; never reconcile them by choosing, merging, or silently rewriting one. Omit knowledge-gap statements whose only content is what is unknown, unstated, unconfirmed, unresolved, pending, or not retrieved. Preserve observed absences and operating requirements: `The records contain no promotion block` is evidence; `Legal approval is required before launch` is a condition.

## Choose the mode

- **Retouch:** Improve grammar, wording, paragraph flow, and readability without changing meaning.
- **Synthesize:** Retouch and shorten by removing repetition and merging overlapping points. Preserve every unique example, mechanism, qualification, decision, tradeoff, and established constraint.
- **Review:** Read [REVIEW.md](REVIEW.md), then identify defects without rewriting unless the user requests edits.

Follow the requested mode. In retouch and synthesis modes, return only the revised prose; start with the content itself.

## Workflow

1. Inventory the source's established claims, evidence, numbers, links, decisions, qualifications, owners, contradictions, bounded estimates, headings, order, and format. Separate observed absences and operating requirements from knowledge gaps.
2. Apply the mode and the shared writing standard below.
3. Compare the result with the inventory. Restore established content that was lost or made more certain; remove knowledge gaps without inferring answers.
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

### Keep claims inside the evidence

Scope every claim to the records, cases, levels, or stages that support it. Before writing `every`, `all`, `only`, `same`, or a general rule, check the source for an exception. State the scope and exception together so the reader never has to discard an earlier model. If narrower evidence already names the dimensions that differ, delete a contradicted summary such as `only the discount changes` rather than trying to rescue it. For example, if most passes write paired records but one pass writes a single record per line, describe the pairing rule as pass-specific rather than universal.

Separate observation from inference. State what the fields, records, sequence, or comparison establish; do not turn repetition, ordering, or correspondence into a cause, decision point, or guarantee. `The order-level pass contains the promotion amounts that the final pass repeats` is an observation. It does not establish when the allocation became fixed unless the source identifies that event.

Attribute an action only when the evidence names the actor performing it. A source-system field can establish where a classification came from without proving that the same system executed every later calculation. When the actor is unsupported, make the calculation, field, record, or process the subject.

Resolve apparent conflicts where they first meet, but only with a relationship the source establishes. If the source explains why a process uses both order-level and shipment-level records, state each role. If it supplies only the two observations, state them separately without `although`, `but`, or an invented reconciliation. If two records, passes, or fields differ, name every supported dimension that matters instead of saying that only one value changes.

### Make sentences substantive

Name the relationship, trigger, role, or consequence instead of announcing content or position.

| Defect | Repair |
|---|---|
| Empty orientation: `Two paths sit outside this flow.` | Name both paths and how each differs, or merge their names into the next substantive sentence. |
| Bare sequence: `Then Amazon invoices the sale.` | Name the dependency: `After checkout confirms the order, Amazon invoices the sale.` |
| Vague role: `Amazon sits in the middle of all five steps.` | State the concrete functions Amazon performs, or delete the summary if the walkthrough already states them. |
| Answer announcement: `The first answer is yes.` | Match the question and answer by subject and predicate before fusing them. Restate a matching proposition directly. If they do not match, keep each established claim separately, omit the unanswered framing, and infer no answer. |
| Count or preview: `Three things follow.` or `Two questions follow: whether X and whether Y.` | Remove the count or preview frame. Retain only the concrete propositions that the source establishes and develop them directly. |
| Knowledge-gap inventory: `Three details are unstated and unconfirmed: ...` | Delete it. State only established evidence, observed absences, bounded estimates, decisions, and operating requirements. |
| Redundant count: `Records come in pairs, two per line.` | State the relationship once and scope it to the records that follow it: `Passes 1, 3, and 4 write one priced record and one zero record per line.` |
| Vague collective reference: `those last 8`, `the two combined`, `neither pair` | Repeat the shortest specific nouns or field names that bind the referents and operation. If the source does not identify them unambiguously, delete the clause rather than guess. |
| Anthropomorphic mechanism: `the discount moves`, `arrives after tax`, or `sits in a block` | Name the field behavior or calculation order: which pass contains the promotion block, which value is calculated first, and which amount is subtracted from it. |
| Document narration: `The diagram follows that combination.` | State the substantive calculation or relationship; let the diagram support it without announcing the diagram's role. |
| Slogan compression: `The columns are identical and the rows are not.` or `Two levers set the total.` | Replace the aphorism, table geometry, count, or metaphor with direct variable-to-measure relationships. Name the measure and values that remain equal, the input that changes them, and the calculation or consequence. Remove metaphorical labels such as `lever`, `driver`, and `dial`; do not reuse them in the repair. A specific reference such as `the status column contains F` remains valid because it names the field and value. |
| Inverted clause | Put the subject before its verb and move figures into readable clauses: `The lipstick lists at 1,000.00 net. Adding 16 percent IVA, 160.00, brings the customer price to 1,160.00.` |

Use spatial terms such as `inside`, `outside`, `middle`, `upstream`, and `downstream` only for real boundaries, topology, or dependencies. Use sequence terms only when order matters. Prefer direct subject–verb order; a dependency clause may come first when it carries necessary logic. Name records, passes, levels, fields, and operations instead of relying on `those`, `the two`, `both`, `combined`, or `it` when the referent could be read more than one way. Allow at most one numeric appositive per sentence, and never place one between a subject and its verb.

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

State established evidence, observed absences, bounded estimates, decisions, and operating requirements. Omit knowledge gaps rather than announcing missing information or inventing precision.

Cut repetition before reasoning. Remove throat-clearing, duplicated conclusions, empty qualifiers, redundant pairs, and self-referential commentary. Delete intensifiers and editorial verdicts such as `fundamentally`, `genuinely`, `significant`, `biggest`, `precise`, and `not a formality`; retain the fact and measurable stake.

Carry emphasis in sentence structure. Use bold only for defined terms and labels required by the surrounding format. Remove decorative bold, italics, emoji, warning symbols, and vocal-stress punctuation. Convert rhetorical questions into declarative statements. Split em-dash chains and nested parentheticals; allow one short identifier or acronym expansion in parentheses. Replace colon-fragment openers with complete sentences.

### Keep notation consistent

Correct spelling, agreement, tense, articles, punctuation, parallelism, modifier placement, and ambiguous pronouns. Place `only` beside what it modifies. Use one stable name for each concept. Expand an acronym at first use unless the source already defines it. Apply inline code to symbols, APIs, commands, flags, paths, configuration keys, field names, and literal values. Preserve official names and quoted text.

When the source contains Mermaid, read `skill://crispy-mermaid` before editing or reviewing the diagram. Preserve the diagram's role in the prose.

## Retouch and synthesis rules

Preserve supplied headings, section order, and format unless the user requests a structural change. Add no sections, document format, audience announcement, or process commentary.

In synthesis mode, preserve each established meaning once and place it where it best supports the paragraph. Keep mechanisms, evidence, qualifications, tradeoffs, consequences, decisions, and operating requirements; remove repetition, knowledge-gap inventories, and commentary that adds no information.

### Finish check

Before returning revised prose, verify that:

- every established source fact, number, link, decision, qualification, owner, contradiction, and bounded estimate remains;
- every universal claim is scoped to supporting evidence and names its exceptions;
- every causal statement, decision point, guarantee, and actor attribution is established by the source;
- apparent conflicts between levels, stages, records, or rules are resolved with a source-supported relationship or stated as separate observations;
- no transition implies a relationship that the source does not establish;
- every collective reference binds to specific source entities and operations, or the unsupported clause is removed;
- headings, order, and format remain unless the user requested a change;
- each paragraph develops one topic without padding;
- every sentence carries concrete content or a necessary logical relationship;
- manual and automatic behavior remain distinct;
- synthesis removes repeated meanings but retains their supporting reasoning;
- wording, grammar, terminology, notation, and formatting are consistent;
- the result contains no announcement sentence, empty orientation, bare sequence, knowledge-gap inventory, redundant count, vague collective reference, slogan compression, metaphorical `lever`, `driver`, or `dial`, anthropomorphic mechanism, inverted clause, decorative emphasis, rhetorical question, intensifier, or self-referential commentary.
