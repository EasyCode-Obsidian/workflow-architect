# Synthesis Protocol — 需求综合协议

> How to generate the final requirements summary from all collected information.

---

## Pre-Synthesis Checks

Before generating the requirements document:

```
□ CONTRADICTION SCAN: Review all answers for unresolved contradictions
  - If found: return to INTERVIEW phase to resolve them
  - If none: proceed

□ COVERAGE SCAN: Check domain model for empty critical slots
  - Problem Space: must be CLEAR
  - Solution Shape: must be CLEAR
  - Entity Map: at least core entities identified
  - Actor Map: at least primary actor journey mapped
  - If critical gaps: flag to user, ask if they want to add more or proceed

□ HYPOTHESIS AUDIT: Check for PENDING hypotheses with HIGH impact
  - If any remain: note them as "Assumptions" in the requirements document
  - These are areas where you're making an educated guess
```

---

## Requirements Document Structure

Generate the requirements in this order:

### Section 1: Project Overview

```
□ One-paragraph executive summary (problem → solution → value)
□ Success criteria (measurable, specific)
□ Scope boundaries (what's IN and what's explicitly OUT)
```

### Section 2: Domain Model

```
□ Core entities with descriptions
□ Entity relationships (with cardinality)
□ Key state transitions
□ Data characteristics (volume, growth, sensitivity)
```

### Section 3: User Requirements

```
□ Actor definitions (roles, permissions, primary actions)
□ Primary user journey (step-by-step)
□ Key interaction patterns
□ Authentication/authorization model (if applicable)
```

### Section 4: Functional Requirements

```
□ Core features (prioritized: MUST / SHOULD / COULD)
□ For each feature: input → processing → output
□ Integration points with external systems
□ API contracts (if applicable)
```

### Section 5: Technical Requirements

```
□ Architecture pattern and rationale
□ Tech stack with rationale for each choice
□ Deployment strategy
□ Non-functional requirements (performance, security, scalability)
```

### Section 6: Assumptions & Risks

```
□ ASSUMPTIONS: hypotheses that were not explicitly confirmed
  "We assume {X} because {evidence}. If wrong, {impact}."
□ RISKS: identified challenges and mitigation strategies
□ OPEN QUESTIONS: areas that need further exploration
```

---

## Synthesis Quality Checks

After generating the document:

```
□ COMPLETENESS: Does each section have content? (empty sections = coverage gaps)
□ CONSISTENCY: Do sections reference each other correctly?
  - Tech stack supports the described features?
  - Entity model covers all features?
  - User journeys use defined entities?
□ TRACEABILITY: Can each requirement be traced back to a user answer?
  - If a requirement has no source answer, it's an ASSUMPTION → label it
□ PRIORITY: Are features prioritized? (MUST / SHOULD / COULD)
□ TESTABILITY: Is each requirement specific enough to verify?
  - "Fast response time" → NOT testable
  - "API response < 200ms at p95" → Testable
```

---

## User Confirmation Protocol

Present the requirements summary to the user:

### Quick Mode

Show the full summary in conversation. Ask:
- **(A) Looks good** — requirements are complete
- **(B) Needs changes** — specify what to adjust
- **(C) Continue interview** — more questions needed

### Deep Mode

1. Show the executive summary + key highlights in conversation
2. Write full document to `.deep-interview/requirements.md` using the [template](../assets/templates/requirements-summary.md)
3. Ask the same A/B/C options

On "(B) Needs changes":
- Parse what the user wants to change
- Update the relevant section
- Re-present for confirmation

---

## State Updates (Deep Mode Only)

After synthesis:

```json
{
  "current_phase": "done",
  "questions_asked": <N>,
  "model_stability": "<STABLE/SETTLING>",
  "final_confidence": "<HIGH/MEDIUM>",
  "assumptions_count": <N>,
  "open_questions_count": <N>,
  "requirements_file": ".deep-interview/requirements.md",
  "updated_at": "<ISO>"
}
```

---

## Integration with Other Skills

The requirements output from Deep Interview can be consumed by:

- **workflow-architect**: Feed into Phase 1 coverage map or directly into Phase 2 draft
- **project-surgeon**: Feed into Phase 1 goal collection for richer context
- **Any planning skill**: Use the structured requirements as input

When invoked FROM another skill:
- Skip the confirmation step
- Return the requirements directly to the calling skill's context
