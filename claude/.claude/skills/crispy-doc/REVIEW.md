# Review mode

Assess the source against the shared writing standard in [SKILL.md](SKILL.md). Do not rewrite unless the user requests edits. Report only actionable findings.

## Output contract

Return these groups in this order:

- **Truth:** altered, unsupported, contradictory, or lost claims.
- **Flow:** fragments, missing transitions, broken reasoning, or misplaced sentences.
- **Finish:** human-centered narration, unnecessary passive wording, empty orientation, bare sequence, spatial metaphor, announcement sentence, interrupted or inverted clause, decorative emphasis, intensifier, rhetorical question, self-referential commentary, repetition, vague wording, grammar, terminology, or notation.

Under each group, list findings or write `No findings.` Every finding must quote or locate the defective phrase, name the defect, and state the editing action. Do not provide replacement prose unless the user requests edits.

End with exactly one verdict and one explanatory sentence:

- **Ready:** No actionable findings remain.
- **Revise:** One or more actionable findings remain.
- **Blocked:** Missing or contradictory source material prevents a reliable review.

## Finish check

Before returning the review, verify that:

- Truth, Flow, and Finish each contain findings or `No findings.`;
- every finding is actionable and grounded in the supplied source;
- the review contains no unsolicited rewrite;
- the verdict matches its definition.
