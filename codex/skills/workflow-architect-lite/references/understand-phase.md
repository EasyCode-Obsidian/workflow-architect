# Phase 1: Understand

## Entry Checklist

- □ State.json loaded (or created fresh)
- □ `current_phase` set to `"understand"`
- □ `.workflow-lite/` directory exists

## Step 1: Collect Requirements

Ask **3-5 focused questions** using asking the user. Cover these 5 areas:

| # | Area | Example Question |
|---|------|-----------------|
| 1 | **Vision** | What problem does this project solve? Who is it for? |
| 2 | **Scope** | What are the core features (list 3-5)? |
| 3 | **Tech** | Any preferred language, framework, or platform? |
| 4 | **Users** | How will users interact with it? (CLI / Web / API / Mobile) |
| 5 | **Constraints** | Any deadlines, dependencies, or restrictions? |

Rules:
- □ Ask ONE question at a time via asking the user
- □ Infer answers from context when obvious (e.g., user already stated the tech stack)
- □ Stop asking when all 5 areas are clear. Do NOT exceed 5 questions.
- □ If the user's initial message already covers most areas, ask only 1-2 clarifying questions.

## Step 2: Present Proposal

Present a **3-section proposal** directly in conversation (not on disk):

### Section A: Overview (3-5 sentences)
- Problem being solved
- Proposed solution
- Target users

### Section B: Architecture & Tech Stack
- Architecture pattern (e.g., REST API + React SPA, CLI tool, monolith)
- Language and framework
- Key libraries/dependencies (table: Name | Purpose)

### Section C: Implementation Phases
- Numbered list of 3-8 implementation phases
- Each phase: name + estimated task count
- Total task count

## Step 3: Self-Check

Before asking for approval, verify internally:

- □ Is the scope realistic for one workflow run?
- □ Are there obvious gaps the user didn't mention?
- □ Could a simpler architecture achieve the same goal?

If any concern: raise it to the user alongside the proposal.

## Step 4: Approval Gate

Ask the user via asking the user:

- **(A) Approve** — proceed to Execute phase
- **(B) Revise** — specify what to change, re-present proposal

On approval:
- □ Update state.json: `current_phase` → `"execute"`, `proposal_approved` → `true`
- □ Proceed to Phase 2
