# Workflow Architect

**Senior Architect Workflow — A 4-phase governed runtime from idea to complete implementation**

[中文版](README.md)

---

> A skill designed for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that transforms the AI coding assistant into a **senior software architect**. Through a rigorous 4-phase workflow (Requirements → Draft → Planning → Execution), it guides projects from vague ideas to complete, working code.

## Why Workflow Architect?

The problems with just telling AI "build me a XXX project":

- AI **skips requirement analysis** and jumps straight to code — the direction may be completely wrong
- **Architecture decisions aren't scrutinized** — the model uses its first intuition, not the optimal choice after comparative analysis
- **No plan** — build as you go, resulting in messy code structure
- During long tasks, **can't roll back or change requirements** — must start over

Workflow Architect solves these:

| Pain Point | Solution |
|-----------|---------|
| Coding before understanding | Phase 1 deep interview, 10 categories covering all dimensions |
| Gut-feel architecture | Phase 2 brainstorm protocol, multi-perspective evaluation + self-interrogation |
| No plan, just code | Phase 3 three-level plan hierarchy, task-level granularity down to each step |
| Long tasks out of control | Phase 4 milestones, 3-Strike fault tolerance, change management |
| Requirement changes = restart | Issue Changer with impact analysis + incremental modification |
| Code quality by luck | Bug Fixer 7-dimension systematic review |

---

## Core Features

- **4-Phase Governed Workflow** — Requirements → Draft → Planning → Execution, with entry/exit gates at each phase
- **Two-Tier Brainstorm Protocol** — Lightweight (automatic, ~2K tokens) + Full Mode (on-demand, 3 Agents + Audit, ~30K tokens)
- **3-Level Plan Hierarchy** — Project plan → Phase plans → Task details, all persisted to disk
- **DeepWiki 3-Tier Research** — Auto-queries GitHub repo docs before coding for API best practices
- **3-Strike Fault Tolerance** — Progressively escalating fix strategies with multiple recovery options
- **Add-on Skill Ecosystem** — Bug Fixer (7-dimension code review) + Issue Changer (change request management)
- **Session Resume** — All state persisted to `.workflow/state.json`, lossless recovery after interruption
- **Cross-Platform** — Bash and PowerShell scripts included, supporting macOS/Linux/Windows

---

## Workflow Architecture

### State Machine

```
                 +---- reject ----+
                 v                |
  INIT --> REQUIREMENTS -----> DRAFT
                 ^              |
                 |           approve
                 |              v
                 +-- reject -- PLANNING --> EXECUTION --> COMPLETED
```

Four phases, strictly ordered. No phase can be skipped. Rejection in Phase 2 or 3 returns to Phase 1 with existing answers preserved.

### Four Phases in Detail

#### Phase 1: Requirements Collection

Exhaustively gathers requirements through structured deep interviews. One question at a time, with recommended answers.

**10-Category Taxonomy:**

| Category | Level | Coverage |
|----------|-------|---------|
| Project Vision & Goals | Required | Problem, success criteria, timeline |
| Functional Scope | Required | Core features, MVP boundary, non-goals |
| User Personas & Journeys | Required | User types, permissions, primary flows |
| Domain & Data Model | Required | Entities, relationships, persistence |
| Tech Stack & Architecture | Required | Language, framework, deployment |
| Integration & Dependencies | Optional | External APIs, third-party services |
| Non-Functional Requirements | Optional | Performance, security, scalability |
| UX & Interaction Design | Optional | Interface type, key screens |
| Development Constraints | Optional | Team size, CI/CD, testing strategy |
| Edge Cases & Risk | Optional | Anomalies, compliance |

**Exit criteria:** All 5 required categories reach "clear", at least 3 optional categories reach "partial".

#### Phase 2: Draft Proposal

Synthesizes requirements into a comprehensive architectural proposal, presented in conversation (never written to disk).

**8 Draft Sections:**

1. **Project Overview** — Core problem and solution approach
2. **Architecture Design** — Layer structure, component diagram, design patterns `← triggers BS-2 brainstorm`
3. **Tech Stack Selection** — Rationale and comparisons for each choice `← triggers BS-3 brainstorm`
4. **Algorithm & Design Strategy** — Key algorithms, security design `← triggers BS-4 brainstorm`
5. **Project Structure** — Directory layout, module organization
6. **Implementation Phases** — Logical phases, dependencies
7. **Risk Assessment** — Top risks and mitigation strategies
8. **Complexity Estimate** — Overall difficulty, effort estimation

Incremental presentation: Sections 1-3 → confirm → Sections 4-5 → confirm → Sections 6-8 → final approval.

#### Phase 3: Execution Plan

Transforms the approved draft into a 3-level plan hierarchy, all written to disk.

```
.workflow/
├── state.json                          # State persistence
├── project-plan.md                     # Level 1: Project plan
└── phases/
    ├── phase-1/
    │   ├── phase-plan.md               # Level 2: Phase plan
    │   └── tasks/
    │       ├── task-01-<name>.md        # Level 3: Task details
    │       └── task-02-<name>.md
    ├── phase-2/
    │   ├── phase-plan.md
    │   └── tasks/
    │       └── ...
    └── ...
```

Each Level 3 task plan includes: prerequisites, concrete steps, expected output, verification commands, commit message.

#### Phase 4: Plan Execution

Executes all tasks per plan while allowing professional judgment for code quality.

**Execution Flow:**

```
Read project plan → Execute by phase
  ├── DeepWiki Tier 1: Phase-level research (batch API doc queries)
  └── Execute by task
      ├── DeepWiki Tier 2: Task-level research (precise API queries)
      ├── Execute by step
      │   └── DeepWiki Tier 3: Real-time queries during coding
      ├── Run verification
      ├── Git commit
      └── Update progress
  └── Milestone checkpoint → User review
```

**Professional Judgment:** May add type annotations, defensive checks, meaningful names, idiomatic patterns. Must NOT add features, endpoints, or behaviors not in the plan.

**3-Strike Fault Tolerance:**

| Attempt | Strategy |
|---------|---------|
| Strike 1 | Analyze root cause, targeted fix |
| Strike 2 | Alternative approach, same goal |
| Strike 3 | Question assumptions, research |
| After 3 | Stop, offer 5 recovery options |

Recovery options: (A) BS-7 deep brainstorm (B) User provides fix (C) Skip task (D) Abort (E) Bug Fixer 7-dimension review

---

## Brainstorm Protocol

Triggered at critical decision points to ensure every important decision undergoes multi-dimensional review.

### Tier 1: Lightweight Mode (Default, Automatic)

Runs automatically at every trigger point. No Agent calls. Cost: ~2,000-3,000 tokens.

```
1. Research — 1-2 WebSearch queries for external facts
2. Multi-Perspective Self-Evaluation — Review from 6 roles (User/Dev/Architect/Security/Ops/Maintainer)
3. Self-Interrogation + Synthesis — Raise 3 sharp challenges, respond, output decision
```

### Tier 2: Full Mode (On-Demand, User Request)

Upgraded execution when user requests it (e.g., `/brainstorm`). Cost: ~30,000-40,000 tokens.

```
1. Forced Research — 2+ WebSearch queries
2. Independent Alternative Generation — 3 Agents in parallel (mutual exclusion + mixed models haiku/opus/sonnet)
3. Quality Gate — 4 divergence checks (including core tech overlap, must pass)
4. Multi-Perspective Evaluation — 6 role perspectives
5. Self-Interrogation Chain — 3 challenges, may overturn recommendation
6. Independent Audit — Different model audit Agent scoring (>=10/15 to pass)
7. Synthesis — Final decision + confidence + risks
```

### Trigger Points

| ID | Phase | When | Default Mode |
|----|-------|------|-------------|
| BS-1 | Phase 1→2 | Requirements completeness check | Lightweight |
| BS-2 | Phase 2 | Before architecture design | Lightweight |
| BS-3 | Phase 2 | Before tech stack selection | Lightweight |
| BS-4 | Phase 2 | Before algorithm strategy | Lightweight |
| BS-5 | Phase 2→3 | Draft integrity check | Lightweight |
| BS-6 | Phase 3 | Task decomposition review | Lightweight |
| BS-7 | Phase 4 | 3-Strike error recovery | User opt-in only |

---

## Add-on Skills

### Bug Fixer — Code Review & Bug Fix

```
Invocation: /workflow-architect:bug-fixer [target file/directory/bug description]
```

**7-Dimension Review Protocol:**

| Dimension | Checks |
|-----------|--------|
| Security Vulnerabilities | Injection, XSS, auth flaws, data leaks |
| Logic Errors | Boundary conditions, off-by-one, type confusion, null handling |
| Concurrency Issues | Race conditions, deadlocks, resource leaks |
| Performance Issues | N+1 queries, memory leaks, unnecessary computation |
| Error Handling | Uncaught exceptions, silent failures, error exposure |
| Dependency Risks | Native package manager audits (npm audit / pip audit / govulncheck etc.) |
| Consistency | Naming conventions, pattern consistency, API contracts |

**Two Modes:**
- **Standalone Mode** — Review any codebase directly
- **Integrated Mode** — Within workflow-architect, uses plan context for precise review

**Smart Scanning:**
- Git diff incremental scan (review changed files only)
- Tiered scanning (Grep filter → read matched files → deep analysis), 30-file context budget

### Issue Changer — Change Request Management

```
Invocation: /workflow-architect:issue-changer [change description]
```

**Two Operating Modes:**

| Mode | Scenario | Process |
|------|---------|---------|
| Mode A | Change request during Phase 4 execution | Pause → Impact analysis → Modify plans → Resume |
| Mode B | New requirements after project completion | Abbreviated requirements → Impact analysis → Incremental plans → Incremental execution |

**Impact Analysis Severity:**

| Severity | Impact Scope | Resolution |
|---------|-------------|-----------|
| Light | Affects current/future tasks only | Modify Level 3 task plans in place |
| Moderate | Needs new tasks or phase plan changes | Return to Phase 3 for plan updates |
| Major | Architecture changes involved | Return to Phase 2 for redesign |

**Three-Tier Confidence Auto-Detection (during execution):**

| Confidence | Condition | Behavior |
|-----------|-----------|---------|
| HIGH (>=5) | Explicit invocation or clear change statement | Enter change flow directly |
| MEDIUM (3-4) | Change verb + specific object | Single confirmation before deciding |
| LOW (<=2) | Uncertain tone / question marks | Don't trigger, hint after task completion |

---

## Directory Structure

```
workflow-architect/
├── SKILL.md                            # Main skill definition (entry point)
├── README.md                           # Chinese documentation
├── README.en.md                        # This file
├── LICENSE                             # License
├── assets/
│   ├── scripts/
│   │   ├── deepwiki.sh                 # DeepWiki query script (Unix/macOS)
│   │   └── deepwiki.ps1               # DeepWiki query script (Windows)
│   └── templates/
│       ├── project-plan.md             # Level 1 plan template
│       ├── phase-plan.md              # Level 2 plan template
│       └── task-plan.md               # Level 3 plan template
├── bug-fixer/
│   ├── SKILL.md                        # Bug Fixer skill definition
│   └── references/
│       ├── review-protocol.md          # 7-dimension review protocol
│       ├── fix-protocol.md            # Fix execution protocol
│       └── index.md                   # Reference index
├── issue-changer/
│   ├── SKILL.md                        # Issue Changer skill definition
│   └── references/
│       ├── impact-analysis.md          # Impact analysis protocol
│       ├── mid-workflow-protocol.md    # Mid-workflow change protocol
│       ├── post-completion-protocol.md # Post-completion change protocol
│       └── index.md                   # Reference index
└── references/
    ├── brainstorm-protocol.md          # Full brainstorm protocol
    ├── phase-1-requirements.md         # Phase 1 detailed reference
    ├── phase-2-draft.md               # Phase 2 detailed reference
    ├── phase-3-planning.md            # Phase 3 detailed reference
    ├── phase-4-execution.md           # Phase 4 detailed reference
    ├── deepwiki-integration.md        # DeepWiki integration protocol
    ├── state-management.md            # State management specification
    └── index.md                       # Reference index
```

---

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (CLI, Desktop App, VS Code Extension, or JetBrains Extension)

### One-Command Install

Send the following prompt directly in Claude Code to install:

```
Please install a Claude Code Skill for me.
Repository: https://github.com/EasyCode-Obsidian/workflow-architect
Installation: Clone the repository to Claude Code's skills directory.

Steps:
1. Clone to skills directory:
   git clone https://github.com/EasyCode-Obsidian/workflow-architect.git ~/.claude/skills/workflow-architect
2. Verify: confirm ~/.claude/skills/workflow-architect/SKILL.md exists
3. Windows path: %USERPROFILE%\.claude\skills\workflow-architect
```

### Manual Installation

**macOS / Linux:**
```bash
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git ~/.claude/skills/workflow-architect
```

**Windows:**
```powershell
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git "$env:USERPROFILE\.claude\skills\workflow-architect"
```

Restart Claude Code after installation.

---

## Quick Start

### Start a New Project

```
/workflow-architect A task management web app with team collaboration and kanban view
```

Workflow Architect will guide you through four phases:

1. **Requirements** — Ask questions one by one to clarify your needs
2. **Draft** — Present architecture proposal for your approval (can revise or reject)
3. **Planning** — Generate detailed three-level execution plans
4. **Execution** — Code per plan, committing after each task

### Use Add-on Skills

```
/workflow-architect:bug-fixer src/              # Review code in src directory
/workflow-architect:bug-fixer "login failure"    # Track a specific bug
/workflow-architect:issue-changer add a notification system   # Submit change request
```

### Session Resume

After exiting mid-workflow, invoke again to resume:

```
/workflow-architect
```

The system auto-detects `.workflow/state.json`, displays current progress, and asks whether to resume or restart.

---

## Technical Details

### State Management

All workflow state is persisted to `.workflow/state.json`, including:

- Current phase and status
- Phase history (with rollback records)
- Requirements coverage map
- Brainstorm completion status
- Execution progress (phase/task level)
- Error log
- Change request records

### DeepWiki Integration

During Phase 4 coding, queries GitHub repository documentation via DeepWiki using a 3-tier research protocol:

| Tier | When | Purpose |
|------|------|---------|
| Tier 1 | Before each phase | Batch query all libraries/frameworks in the phase |
| Tier 2 | Before each task | Precise query for task-specific APIs |
| Tier 3 | During coding | Real-time queries for uncertain API usage |

Scripts call DeepWiki's HTTP MCP endpoint directly — no MCP configuration needed.

### Context Management

Optimization strategies for large projects (10+ phases / 50+ tasks):

- **Lazy Loading** — Don't read all plans at once; load current phase/task on demand
- **Completed Phase Summarization** — Compress finished phases to 5-10 line summaries
- **Session Segmentation** — Prompt for new session when nearing context limits
- **Batched TaskCreate** — Create task entries by phase for 50+ task projects

### HARD-GATE Rules

These rules are non-negotiable:

1. NO code before Phase 4
2. NO phase advancement without explicit user approval
3. Plans guide execution, but professional judgment is allowed (type annotations, defensive checks, etc.)
4. NO skipping phases
5. Draft (Phase 2) is NEVER written to disk
6. Plans (Phase 3) are ALWAYS written to disk

---

## License

This project is licensed under a [Custom Restrictive License](LICENSE).

**Allowed:** Personal use (install, run, invoke)

**Prohibited:** Copying, distribution, modification, derivative works, referencing the design for other projects

See the [LICENSE](LICENSE) file for details.
