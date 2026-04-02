# Domain Modeling — 领域建模协议

> How to build and maintain a mental model of the project domain
> throughout the interview process.

---

## Initial Domain Model (CONTEXT Phase)

Build from the user's initial description. The model has 5 layers:

### Layer 1: Problem Space

```
□ Core problem: What pain point does this solve?
□ Current solution: How is it being solved now (if at all)?
□ Gap: What's wrong with the current solution?
□ Success criteria: How will we know this project succeeds?
```

### Layer 2: Solution Shape

```
□ Project archetype: CLI / Web / API / Mobile / Desktop / Library / Pipeline / Other
□ Deployment target: Local / Cloud / On-prem / Edge / Hybrid
□ Scale expectation: Personal / Team / Organization / Public
□ Interaction model: Sync / Async / Real-time / Batch / Event-driven
```

### Layer 3: Entity Map

```
□ Core entities (nouns in the user's description):
  - Entity A: {name} — {brief description}
  - Entity B: {name} — {brief description}
□ Relationships:
  - A → B: {relationship type} (1:1, 1:N, N:M)
□ Key state transitions:
  - Entity A: {state1} → {state2} when {trigger}
□ Data characteristics:
  - Volume: {estimate}
  - Growth: {rate}
  - Sensitivity: {level}
```

### Layer 4: Actor Map

```
□ User types:
  - Actor 1: {role} — {primary actions} — {permissions}
  - Actor 2: {role} — {primary actions} — {permissions}
□ External systems:
  - System A: {what it provides/consumes}
□ Primary journey:
  Actor → {step 1} → {step 2} → ... → {outcome}
```

### Layer 5: Constraint Space

```
□ Technical: language, framework, platform preferences or requirements
□ Resource: team size, timeline, budget
□ Regulatory: compliance, data residency, accessibility
□ Integration: must connect to {systems}
□ Non-functional: performance, availability, security requirements
```

---

## Model Update Protocol (INTERVIEW Phase)

After each answer, update the relevant layers:

### Update Rules

```
1. ADD: New information fills an empty slot
   Example: "I want React" → Layer 5 Technical gets "framework: React"

2. REFINE: Existing information becomes more specific
   Example: "Actually, React with Next.js for SSR" → Update framework to "Next.js (React SSR)"

3. REVISE: New information contradicts existing model
   Example: "No, it should be a CLI, not a web app" → Revise Layer 2 archetype
   → FLAG CONTRADICTION and ask user to confirm

4. CONNECT: New information creates links between layers
   Example: "Admin users can delete other users' data" → Link Actor Map to Entity Map
   → May require new questions about authorization model

5. EXPAND: Answer reveals the model needs new slots
   Example: "It needs to integrate with Stripe" → Add to Layer 4 External Systems
   → Opens new dimension: payment flow, webhook handling, error scenarios
```

### Model Stability Tracking

Track how much the model changes per question:

```
After each answer, score the change:
  0 = No change (answer confirmed existing model)
  1 = Minor addition (filled an empty slot)
  2 = Refinement (made existing info more specific)
  3 = Revision (changed existing model element)
  4 = Expansion (model needs new dimensions)

Rolling average of last 3 scores:
  < 1.0 → Model is STABLE (convergence signal)
  1.0-2.0 → Model is SETTLING
  > 2.0 → Model is still EVOLVING (keep asking)
```

---

## Hypothesis Tree Management

Maintain a tree of hypotheses about the project:

### Structure

```
Root Hypothesis: "This project is a {type} that {does what}"
├── H1 (Architecture): "{pattern} because {evidence}" [CONFIRMED/PENDING/REJECTED]
├── H2 (Tech Stack): "{choice} because {evidence}" [CONFIRMED/PENDING/REJECTED]
├── H3 (Scale): "{expectation} because {evidence}" [CONFIRMED/PENDING/REJECTED]
├── H4 (Users): "{who} because {evidence}" [CONFIRMED/PENDING/REJECTED]
└── H5 (Complexity): "{level} because {evidence}" [CONFIRMED/PENDING/REJECTED]
```

### Hypothesis Lifecycle

```
PENDING → Asked question targeting this hypothesis →
  → User confirms → CONFIRMED (increase confidence in dependent hypotheses)
  → User rejects → REJECTED (revise model, regenerate dependent hypotheses)
  → User partially confirms → REFINED (update hypothesis, may spawn sub-hypotheses)
```

### Hypothesis-Driven Question Selection

```
Priority for next question:
1. Hypotheses with MOST downstream impact if wrong
2. Hypotheses with LOWEST confidence (most uncertain)
3. Hypotheses that are PENDING the longest
```

---

## Domain Familiarity Assessment

At the start of CONTEXT phase, assess your familiarity with the domain:

```
FAMILIAR (no research needed):
  - Standard web applications (CRUD, auth, forms)
  - Common CLI tools
  - Standard API patterns
  - Well-known domains (e-commerce, blog, task management)

SOMEWHAT FAMILIAR (light research):
  - Domain-specific applications (healthcare, finance, education)
  - Specialized architectures (real-time, distributed, ML pipeline)
  - Niche frameworks or ecosystems

UNFAMILIAR (research required):
  - Highly specialized domains (bioinformatics, aerospace, legal compliance)
  - Novel technology combinations
  - Industry-specific regulations or standards
```

For SOMEWHAT FAMILIAR and UNFAMILIAR:
```
□ Run 1-2 WebSearch queries:
  - "{domain} software architecture best practices"
  - "{domain} common requirements and challenges"
□ Integrate findings into initial hypothesis tree
□ Note where your knowledge has gaps — these become high-priority questions
```

---

## Model Visualization (Internal)

Maintain a compact text representation of your current model.
Update after each PARP cycle. Use this for PQCP Step A (SYNTHESIZE).

```
=== DOMAIN MODEL (Q{N}) ===
Problem: {one sentence}
Solution: {project type} — {key tech}
Entities: {entity list with relationships}
Actors: {actor list}
Constraints: {key constraints}
Confidence: {HIGH/MEDIUM/LOW}
Stability: {STABLE/SETTLING/EVOLVING} (avg change score: {N})
Open Questions: {list of unresolved areas}
===
```

This model is NOT shown to the user unless they ask. It's your internal state for PQCP.
