# Workflow Architect

**Senior Architect Workflow — A 4-phase governed runtime from idea to complete implementation**

[中文版](README.md)

---

> A skill designed for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [OpenAI Codex CLI](https://github.com/openai/codex) that transforms the AI coding assistant into a **senior software architect**. Through a rigorous 4-phase workflow (Requirements → Draft → Planning → Execution), it guides projects from vague ideas to complete, working code.

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
- **DeepWiki Cross-Phase Research** — GitHub repo doc queries available in ALL phases (light validation in Phase 1-3, mandatory 3-tier protocol in Phase 4), ensuring API best practices before every line of code
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
Invocation: /workflow-architect-bug-fixer [target file/directory/bug description]
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
Invocation: /workflow-architect-issue-changer [change description]
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

## Project Surgeon — Existing Project Takeover

```
Invocation: /project-surgeon [project path, or '.' for current directory]
```

Designed for **existing projects** — systematic analysis, review, and improvement. Complementary to Workflow Architect (which creates projects from scratch).

**Four-Phase Workflow:**

| Phase | Purpose | Key Deliverable |
|-------|---------|----------------|
| Phase 1: Analysis | Auto-scan project structure, tech stack, dependency health, architecture patterns | `.project-surgeon/analysis-report.md` |
| Phase 2: Review | Full code audit using Bug Fixer's 7-dimension protocol | `.project-surgeon/review-report.md` |
| Phase 3: Planning | Generate three-level improvement plans by risk/priority | `.project-surgeon/project-plan.md` + phases/ |
| Phase 4: Execution | Execute improvements task by task with Preservation Gate protection | Improved code |

**Preservation Gate (unique safety mechanism):**

Compares test suite results before and after each task — auto-reverts on new test failures. Ensures improvements don't break existing functionality.

**Using Add-on Skills:**

```
/project-surgeon-bug-fixer src/              # Review code in src directory
/project-surgeon-issue-changer add a caching layer   # Submit change request
```

---

## Lite Versions — Small Model Optimization

```
Invocation: /workflow-architect-lite [project idea]
Invocation: /project-surgeon-lite [project path]
```

Streamlined versions designed for **smaller models** (Haiku, GPT-4o-mini) or **fast workflows**, merging 4 phases into 2 and removing high-overhead features.

**Full vs Lite comparison:**

| Feature | Full | Lite |
|---------|------|------|
| Phases | 4 (separate gates) | 2 (Understand → Execute) |
| Brainstorm | 2-tier protocol, 7 triggers | 3-question inline self-check |
| DeepWiki | 3-tier research protocol | Removed (WebSearch fallback) |
| Plan hierarchy | 3 levels (project → phase → task) | Flat: plan.md + task-NN.md |
| Error recovery | 3-Strike + 5 options | 1-Strike: try once → ask user |
| Review dimensions (PS) | 7 dimensions, 3-tier scan | 4 dimensions, Grep + Read top 20 |
| Preservation Gate | Auto-revert + ID tracking | Compare pass counts, user decides |
| File size | ~3,700-5,100 lines | ~500-600 lines (~85% reduction) |
| Working directory | `.workflow/` `.project-surgeon/` | `.workflow-lite/` `.project-surgeon-lite/` |

**When to use Lite:**
- Using smaller models or fast mode
- Small project scope (< 10 features / < 15 tasks)
- Prioritizing speed over depth of analysis

---

## Code Reviewer — 10-Dimension × 4-Role Fused Code Review

```
Invocation: /code-reviewer [target file/directory]
Invocation: /code-reviewer --diff          # only review git-changed files
Invocation: /code-reviewer [target] --full  # Full Audit mode
```

A standalone **read-only** code review skill that fuses 10 audit dimensions with 4 expert role perspectives. Never modifies project code.

**10 Audit Dimensions:**

| ID | Dimension | Source |
|----|-----------|--------|
| D1-D7 | Security, Logic, Concurrency, Performance, Error Handling, Dependencies, Consistency | Inherited from Bug Fixer |
| D8 | Architecture Quality | New: module boundaries, coupling, layer violations |
| D9 | Test Quality | New: coverage gaps, flaky tests, mock overuse |
| D10 | Documentation & CI/CD | New: README, CI config, Dockerfile quality |

**4 Review Roles:**

| Role | PRIMARY Dimensions | Perspective |
|------|-------------------|-------------|
| Developer | D2, D3, D5, D7 | Does the code work correctly, handle errors, follow conventions? |
| Security Expert | D1, D6 (CVEs) | Can the code be exploited? Is user data safe? |
| Architect | D4, D7, D8 | Is the structure sound, maintainable, scalable? |
| Ops/SRE | D6 (freshness), D10 | Is it deployable, monitorable, operable? |

**Two Modes:**

| Mode | Roles | Dimension Depth | Scenario |
|------|-------|----------------|----------|
| Quick Scan (default) | 3 (no Ops/SRE) | PRIMARY only | Daily review |
| Full Audit (`--full`) | 4 (all) | PRIMARY + SECONDARY | Comprehensive audit, report written to `.review/report.md` |

**Cross-Role Deduplication:** When multiple roles flag the same location, findings are auto-merged — keeping the highest severity and all role tags.

---

## Deep Interview — PQCP-Driven Deep Requirements Interview

```
Invocation: /deep-interview [project idea / feature description]
Invocation: /deep-interview [topic] --deep    # Deep mode
```

A standalone deep requirements interview skill using the **Pre-Question Cognitive Protocol (PQCP)** to analyze deeply before each question.

**Core Innovation — PQCP Three-Step Loop:**

| Step | Action | Purpose |
|------|--------|---------|
| SYNTHESIZE | Integrate all known information | Update overall project understanding |
| HYPOTHESIZE | Generate 2-3 hypotheses | Predict likely answers with reasoning |
| RESEARCH | WebSearch + DeepWiki validation | Validate hypotheses with external data (auto-triggers for tech questions) |
| CHALLENGE | Self-interrogate | Identify blind spots and wrong assumptions |

**Compared to Traditional Interviews:**

| Aspect | Traditional | PQCP Interview |
|--------|------------|----------------|
| Question style | "What tech stack do you want?" | "Since you're building a kanban app, I infer real-time updates are needed. I'd suggest React + WebSocket. What do you think?" |
| Context usage | Independent template questions | Each question based on synthesis of all known info |
| Post-answer | Update coverage | Contradiction detection + new dimension discovery + hypothesis revision |

**Two Modes:**

| Mode | PQCP Frequency | Questions | Output |
|------|---------------|-----------|--------|
| Quick (default) | Every 3 questions | 5-15 | Conversation only |
| Deep (`--deep`) | Every question | 10-50+ | `.deep-interview/requirements.md` |

**Existing skills also enhanced:** workflow-architect and project-surgeon Phase 1 interview/goal-collection now integrate PQCP protocol.

---

## Directory Structure

```
workflow-architect/                         # Repository root
├── README.md                               # Chinese documentation
├── README.en.md                            # This file
├── LICENSE                                 # License
├── claude/                                 # Claude Code version
│   └── skills/
│       ├── workflow-architect/             # Claude Code Skill (with platform-specific frontmatter)
│       │   ├── SKILL.md
│       │   ├── assets/
│       │   └── references/
│       ├── workflow-architect-bug-fixer/   # Bug Fixer standalone skill
│       │   ├── SKILL.md
│       │   └── references/
│       ├── workflow-architect-issue-changer/ # Issue Changer standalone skill
│       │   ├── SKILL.md
│       │   └── references/
│       ├── project-surgeon/               # Existing project takeover Skill
│       │   ├── SKILL.md
│       │   ├── assets/
│       │   └── references/
│       ├── project-surgeon-bug-fixer/     # Project Surgeon Bug Fixer
│       │   ├── SKILL.md
│       │   └── references/
│       ├── project-surgeon-issue-changer/ # Project Surgeon Issue Changer
│       │   ├── SKILL.md
│       │   └── references/
│       ├── workflow-architect-lite/       # Lite version (small model optimized)
│       │   ├── SKILL.md
│       │   ├── assets/templates/
│       │   └── references/
│       ├── project-surgeon-lite/         # Lite version (small model optimized)
│       │   ├── SKILL.md
│       │   ├── assets/templates/
│       │   └── references/
│       └── code-reviewer/               # 10-dimension × 4-role code review
│           ├── SKILL.md
│           ├── assets/templates/
│           └── references/
│       └── deep-interview/              # PQCP deep requirements interview
│           ├── SKILL.md
│           ├── assets/templates/
│           └── references/
└── codex/                                  # OpenAI Codex CLI version
    └── skills/
        ├── workflow-architect/             # Codex Skill (generic frontmatter)
        │   ├── SKILL.md
        │   ├── assets/
        │   └── references/
        ├── workflow-architect-bug-fixer/
        │   ├── SKILL.md
        │   └── references/
        ├── workflow-architect-issue-changer/
        │   ├── SKILL.md
        │   └── references/
        ├── project-surgeon/               # Existing project takeover Skill
        │   ├── SKILL.md
        │   ├── assets/
        │   └── references/
        ├── project-surgeon-bug-fixer/
        │   ├── SKILL.md
        │   └── references/
        ├── project-surgeon-issue-changer/
        │   ├── SKILL.md
        │   └── references/
        ├── workflow-architect-lite/
        │   ├── SKILL.md
        │   ├── assets/templates/
        │   └── references/
        └── project-surgeon-lite/
            ├── SKILL.md
            ├── assets/templates/
            └── references/
        └── code-reviewer/
            ├── SKILL.md
            ├── assets/templates/
            └── references/
```

Both versions have identical skill content, differing only in:
- **Frontmatter fields**: Claude Code version includes `allowed-tools`, `when_to_use`, etc.; Codex version has only `name` + `description`
- **Tool references**: Claude Code version references `AskUserQuestion`, `TaskCreate`, etc.; Codex version uses generic descriptions

---

## Installation

### Claude Code Installation

#### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (CLI, Desktop App, VS Code Extension, or JetBrains Extension)

#### One-Command Install

Send the following prompt directly in Claude Code to install:

```
Please install a Claude Code Skill for me.
Repository: https://github.com/EasyCode-Obsidian/workflow-architect

Steps:
1. Clone the repository to a temp directory:
   git clone https://github.com/EasyCode-Obsidian/workflow-architect.git /tmp/workflow-architect-repo
2. Copy the Claude Code skills into the skills directory:
   cp -r /tmp/workflow-architect-repo/claude/skills/workflow-architect ~/.claude/skills/workflow-architect
   cp -r /tmp/workflow-architect-repo/claude/skills/project-surgeon ~/.claude/skills/project-surgeon
3. Clean up:
   rm -rf /tmp/workflow-architect-repo
4. Verify: confirm ~/.claude/skills/workflow-architect/SKILL.md and ~/.claude/skills/project-surgeon/SKILL.md exist
5. Windows path: %USERPROFILE%\.claude\skills\
```

#### Manual Installation

**macOS / Linux:**
```bash
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git /tmp/wa-repo
cp -r /tmp/wa-repo/claude/skills/workflow-architect ~/.claude/skills/workflow-architect
cp -r /tmp/wa-repo/claude/skills/project-surgeon ~/.claude/skills/project-surgeon
# Lite version (optional)
cp -r /tmp/wa-repo/claude/skills/workflow-architect-lite ~/.claude/skills/workflow-architect-lite
cp -r /tmp/wa-repo/claude/skills/project-surgeon-lite ~/.claude/skills/project-surgeon-lite
# Code Reviewer (optional)
cp -r /tmp/wa-repo/claude/skills/code-reviewer ~/.claude/skills/code-reviewer
# Deep Interview (optional)
cp -r /tmp/wa-repo/claude/skills/deep-interview ~/.claude/skills/deep-interview
rm -rf /tmp/wa-repo
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git "$env:TEMP\wa-repo"
Copy-Item -Recurse "$env:TEMP\wa-repo\claude\skills\workflow-architect" "$env:USERPROFILE\.claude\skills\workflow-architect"
Copy-Item -Recurse "$env:TEMP\wa-repo\claude\skills\project-surgeon" "$env:USERPROFILE\.claude\skills\project-surgeon"
# Lite version (optional)
Copy-Item -Recurse "$env:TEMP\wa-repo\claude\skills\workflow-architect-lite" "$env:USERPROFILE\.claude\skills\workflow-architect-lite"
Copy-Item -Recurse "$env:TEMP\wa-repo\claude\skills\project-surgeon-lite" "$env:USERPROFILE\.claude\skills\project-surgeon-lite"
# Code Reviewer (optional)
Copy-Item -Recurse "$env:TEMP\wa-repo\claude\skills\code-reviewer" "$env:USERPROFILE\.claude\skills\code-reviewer"
# Deep Interview (optional)
Copy-Item -Recurse "$env:TEMP\wa-repo\claude\skills\deep-interview" "$env:USERPROFILE\.claude\skills\deep-interview"
Remove-Item -Recurse -Force "$env:TEMP\wa-repo"
```

**ccw / npx install (recommended):**

```bash
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git ~/.claude/skills-repos/workflow-architect
ln -s ~/.claude/skills-repos/workflow-architect/claude/skills/workflow-architect ~/.claude/skills/workflow-architect
ln -s ~/.claude/skills-repos/workflow-architect/claude/skills/project-surgeon ~/.claude/skills/project-surgeon
# Lite version (optional)
ln -s ~/.claude/skills-repos/workflow-architect/claude/skills/workflow-architect-lite ~/.claude/skills/workflow-architect-lite
ln -s ~/.claude/skills-repos/workflow-architect/claude/skills/project-surgeon-lite ~/.claude/skills/project-surgeon-lite
# Code Reviewer (optional)
ln -s ~/.claude/skills-repos/workflow-architect/claude/skills/code-reviewer ~/.claude/skills/code-reviewer
# Deep Interview (optional)
ln -s ~/.claude/skills-repos/workflow-architect/claude/skills/deep-interview ~/.claude/skills/deep-interview
```

Restart Claude Code after installation.

### OpenAI Codex CLI Installation

#### Prerequisites

- [Codex CLI](https://github.com/openai/codex) installed

#### Manual Installation

**macOS / Linux:**
```bash
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git /tmp/wa-repo
cp -r /tmp/wa-repo/codex/skills/workflow-architect ~/.codex/skills/workflow-architect
cp -r /tmp/wa-repo/codex/skills/project-surgeon ~/.codex/skills/project-surgeon
# Lite version (optional)
cp -r /tmp/wa-repo/codex/skills/workflow-architect-lite ~/.codex/skills/workflow-architect-lite
cp -r /tmp/wa-repo/codex/skills/project-surgeon-lite ~/.codex/skills/project-surgeon-lite
# Code Reviewer (optional)
cp -r /tmp/wa-repo/codex/skills/code-reviewer ~/.codex/skills/code-reviewer
# Deep Interview (optional)
cp -r /tmp/wa-repo/codex/skills/deep-interview ~/.codex/skills/deep-interview
rm -rf /tmp/wa-repo
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git "$env:TEMP\wa-repo"
Copy-Item -Recurse "$env:TEMP\wa-repo\codex\skills\workflow-architect" "$env:USERPROFILE\.codex\skills\workflow-architect"
Copy-Item -Recurse "$env:TEMP\wa-repo\codex\skills\project-surgeon" "$env:USERPROFILE\.codex\skills\project-surgeon"
# Lite version (optional)
Copy-Item -Recurse "$env:TEMP\wa-repo\codex\skills\workflow-architect-lite" "$env:USERPROFILE\.codex\skills\workflow-architect-lite"
Copy-Item -Recurse "$env:TEMP\wa-repo\codex\skills\project-surgeon-lite" "$env:USERPROFILE\.codex\skills\project-surgeon-lite"
# Code Reviewer (optional)
Copy-Item -Recurse "$env:TEMP\wa-repo\codex\skills\code-reviewer" "$env:USERPROFILE\.codex\skills\code-reviewer"
# Deep Interview (optional)
Copy-Item -Recurse "$env:TEMP\wa-repo\codex\skills\deep-interview" "$env:USERPROFILE\.codex\skills\deep-interview"
Remove-Item -Recurse -Force "$env:TEMP\wa-repo"
```

Restart Codex CLI after installation.

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

### Take Over an Existing Project

```
/project-surgeon .
```

Project Surgeon will guide you through four phases:

1. **Analysis** — Auto-scan tech stack, architecture, dependency health
2. **Review** — 7-dimension systematic code audit, output review report
3. **Planning** — Generate three-level improvement plans by risk/priority
4. **Execution** — Execute improvements task by task, Preservation Gate protects existing functionality

### Lite Version Quick Start

```
/workflow-architect-lite Build a REST API for a todo app
/project-surgeon-lite .
```

### Use Add-on Skills

```
/workflow-architect-bug-fixer src/              # Review code in src directory
/workflow-architect-bug-fixer "login failure"    # Track a specific bug
/workflow-architect-issue-changer add a notification system   # Submit change request
/project-surgeon-bug-fixer src/                 # Review code in takeover project
/project-surgeon-issue-changer add a caching layer  # Submit change in takeover project
/code-reviewer src/                                # Quick Scan review src directory
/code-reviewer --diff                              # Review only git-changed files
/code-reviewer . --full                            # Full Audit comprehensive review
/deep-interview a task management app               # Quick mode requirements interview
/deep-interview distributed message queue --deep    # Deep mode interview
```

### Session Resume

After exiting mid-workflow, invoke again to resume:

```
/workflow-architect    # Resume a project created from scratch
/project-surgeon       # Resume a takeover project
```

The system auto-detects state files (`.workflow/state.json` or `.project-surgeon/state.json`), displays current progress, and asks whether to resume or restart.

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

Cross-phase GitHub repository documentation queries ensuring technical decisions and code are backed by authoritative docs:

| Phase | Intensity | Purpose |
|-------|----------|---------|
| Phase 1 | Light | Validate tech hypotheses during PQCP, fact-check user claims in PARP |
| Phase 2 | Moderate | Verify framework capabilities and API docs during BS-2/3/4 brainstorm research |
| Phase 3 | Light | Confirm dependency mappings, verify API scope |
| Phase 4 | Full 3-Tier | Tier 1 batch queries → Tier 2 precise queries → Tier 3 mandatory coding-time queries |

Phase 4 Tier 3 is **mandatory**: before writing code that calls ANY library/framework API, before configuring library options, before implementing library-specific error handling — DeepWiki must be queried first. Scripts call DeepWiki's HTTP MCP endpoint directly — no MCP configuration needed.

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
