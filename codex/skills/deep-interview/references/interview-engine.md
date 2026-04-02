# Interview Engine — PQCP 驱动的访谈引擎

> Defines the Pre-Question Cognitive Protocol (PQCP), question loop,
> Post-Answer Reflection, and convergence detection.

---

## CONTEXT Phase — 初始上下文建立

Before asking ANY question, analyze the user's initial input.

### Step 1: Parse Initial Input

```
□ Extract explicit requirements (what the user directly stated)
□ Extract implicit signals (tone, specificity level, domain vocabulary)
□ Identify the project archetype:
  - CLI tool / utility
  - Web application (SPA, SSR, static)
  - API service / backend
  - Mobile application
  - Desktop application
  - Library / SDK
  - Data pipeline / ETL
  - DevOps / infrastructure
  - Other / hybrid
□ Estimate complexity tier: Simple / Medium / Complex
```

### Step 2: Initial Domain Research

```
□ If domain is unfamiliar: run 1-2 web search tool queries to understand the domain
  - "{domain} common architecture patterns"
  - "{domain} typical requirements and challenges"
□ If domain is familiar: skip, but note your existing knowledge and its limits
□ Record research findings for reference in INTERVIEW phase
```

### Step 3: Build Initial Hypothesis Tree

```
□ Based on the initial input + research, generate 3-5 hypotheses about the project:
  H1: "The project is likely a {type} because {evidence}"
  H2: "The main challenge will be {X} because {reasoning}"
  H3: "The user probably needs {Y} but hasn't mentioned it because {reason}"
  ...
□ Rank hypotheses by confidence (HIGH/MEDIUM/LOW)
□ Identify the TOP 3 unknowns that need to be resolved
□ Plan initial question strategy: which unknowns to resolve first
```

### Step 4: Present Initial Understanding

Show the user your initial analysis before asking the first question:

```
"Based on your description, here's my initial understanding:

[1-3 sentence summary of what you think the project is]

Key assumptions I'm making:
- {assumption 1}
- {assumption 2}
- {assumption 3}

Areas I need to explore:
- {area 1}
- {area 2}

Let me start with the most important question..."
```

This gives the user an immediate opportunity to correct gross misunderstandings.

---

## INTERVIEW Phase — PQCP 驱动的问题循环

### Pre-Question Cognitive Protocol (PQCP)

Execute before EACH question (Deep Mode) or every 3rd question (Quick Mode).

#### Step A: SYNTHESIZE — 综合

```
□ Review all answers collected so far
□ Update your mental model: "The project is shaping up to be {description}"
□ Identify which areas are now CLEAR vs UNCERTAIN vs UNKNOWN:
  - CLEAR: enough detail to make decisions
  - UNCERTAIN: some info but gaps remain
  - UNKNOWN: not yet addressed
□ Note interconnections: "Answer about {X} implies {Y} for {Z}"
```

#### Step B: HYPOTHESIZE — 假设

```
□ For the next topic to explore, generate 2-3 hypotheses:
  H1: {hypothesis} — confidence: {HIGH/MEDIUM/LOW} — reasoning: {why}
  H2: {hypothesis} — confidence: {HIGH/MEDIUM/LOW} — reasoning: {why}
  [H3: optional contrarian hypothesis]
□ Identify the "leading hypothesis" (highest confidence)
□ Identify what would CHANGE if the leading hypothesis is wrong:
  "If H1 is wrong and H2 is right, then {consequence for architecture/design}"
□ This analysis determines how to frame the question
```

#### Step C: CHALLENGE — 质疑

```
□ Self-interrogate with 3 questions:
  1. "What assumption am I making that the user hasn't confirmed?"
  2. "The user hasn't mentioned {X} — possible reasons:
     (a) They don't need it
     (b) They haven't thought of it
     (c) They assume it's obvious
     → I should ask if reason is likely (b) or (c)"
  3. "If I were a {different stakeholder}, what would I care about?"
     Rotate through: end-user / developer / PM / security / ops
□ If challenge reveals a blind spot: adjust the question to probe it
```

### Question Formulation

After PQCP, formulate the question using this structure:

```
CONTEXT LINE: "Based on what you've shared about {prior answer}..."
  or: "Given that you want {X} and need {Y}..."
  or: "I notice you mentioned {Z} but haven't discussed {W}..."

HYPOTHESIS: "I'm thinking {leading hypothesis} because {reasoning}."
  or: "My best guess is {hypothesis}. Here's why: {chain}"

QUESTION: "Does that match your thinking? Specifically, {precise question}?"

OPTIONS (via asking the user):
  - Option A (Recommended): {hypothesis-aligned answer} — "because {reasoning}"
  - Option B: {alternative} — "if you need {different constraint}"
  - Option C: {contrarian option} — "if {assumption} is wrong"
  (Other is always available automatically)
```

**Key principle:** The question is framed as **hypothesis validation**, not open-ended exploration. The user corrects your thinking rather than generating answers from scratch.

### Post-Answer Reflection Protocol (PARP)

Execute after EACH answer:

```
□ INTEGRATE: How does this answer update my domain model?
  - Record the new information
  - Update affected hypotheses (confirm, revise, or reject)

□ CONTRADICTION CHECK: Does this answer conflict with any previous answer?
  - Compare against all prior answers
  - If contradiction found:
    → Flag immediately: "I notice this seems to contradict what you said about {X}. 
       Could you clarify?"
    → Do NOT proceed to next question until resolved

□ NEW DIMENSION CHECK: Does this answer open new areas?
  - "This answer about {X} implies we should also consider {Y}"
  - If yes: add follow-up questions with elevated priority
  - Track: "Opened by answer #{N}: {new area}"

□ HYPOTHESIS UPDATE: Were my pre-question hypotheses correct?
  - If confirmed: increase confidence in related hypotheses
  - If rejected: note what was wrong, adjust mental model
  - "I assumed {X} but learned {Y}. This changes my understanding of {Z}."

□ CONVERGENCE CHECK: Are we approaching sufficient coverage?
  (See Convergence Detection below)
```

### Question Selection Strategy

After PARP, select the next question topic:

```
Priority order:
1. CONTRADICTIONS — must be resolved before anything else
2. HIGH-IMPACT UNKNOWNS — topics that would most change the architecture
3. PQCP-IDENTIFIED BLIND SPOTS — areas surfaced by the CHALLENGE step
4. NEW DIMENSIONS — areas opened by recent answers
5. REMAINING GAPS — systematic coverage of unaddressed topics

Anti-patterns to avoid:
✗ Asking about a topic already CLEAR
✗ Asking a question whose answer can be inferred from existing info
✗ Asking low-impact questions when high-impact unknowns remain
✗ Repeating a question in different words
```

---

## Convergence Detection — 收敛判定

The interview ends when information **converges** — new answers stop changing the domain model.

### Convergence Signals

```
□ STRONG CONVERGENCE (ready to synthesize):
  - Last 3 answers confirmed existing hypotheses without introducing new unknowns
  - No open contradictions
  - All high-impact areas addressed
  - Domain model has been stable for 3+ questions

□ MODERATE CONVERGENCE (check with user):
  - Most high-impact areas addressed, 1-2 minor gaps remain
  - No contradictions
  - Present status and ask: "I think I have enough to work with. Shall I continue
    or synthesize what we have?"

□ NO CONVERGENCE (keep asking):
  - Recent answers are still changing the model significantly
  - Open contradictions exist
  - High-impact unknowns remain
```

### User Override

The user can signal readiness at any time:
- "够了" / "enough" / "proceed" / "let's go" / "that's all"
- When detected: present current understanding and confirm

### Forced Minimum

Even if user signals early:
- At least ONE question about the core problem/goal must have been asked and answered
- If not: inform user this is essential and ask it

### Progress Display

Every ~5 questions, briefly show convergence status:

```
📊 Interview Progress (Q{N}):
  ✅ Clear: {list of clear areas}
  🟡 Partial: {list of partial areas}
  ❓ Unknown: {list of unknown areas}
  Convergence: {STRONG/MODERATE/NONE}
```

---

## Quick Mode vs Deep Mode Differences

| Aspect | Quick Mode | Deep Mode |
|--------|-----------|-----------|
| PQCP frequency | Every 3rd question | Every question |
| PARP depth | INTEGRATE + CONTRADICTION only | Full (all 5 checks) |
| Convergence display | On completion only | Every ~5 questions |
| Domain research | Skip unless critical | Always in CONTEXT |
| State persistence | None | `.deep-interview/state.json` |
| Output | Conversation only | `.deep-interview/requirements.md` |
| Question target | 5-15 | 10-50+ |
