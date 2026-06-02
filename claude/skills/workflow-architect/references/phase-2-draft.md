# Phase 2: Draft Proposal — 草案产出

> This phase synthesizes Phase 1 requirements into a comprehensive draft proposal for the user.
> The draft is presented in conversation ONLY — never written to disk. Proceeds to Phase 3 on user approval.

<!-- 本阶段基于 Phase 1 收集的需求，向用户呈现整体方案草案。草案仅在对话中展示，不写入磁盘。 -->

---

## Entry Protocol

1. Read state.json, verify `current_phase` is `"draft"`
2. Load all requirements from `requirements.answers` in state.json
3. Update state: `draft.status: "in_progress"`
4. Create `.workflow/<name>/brainstorm/` directory if it does not exist
5. **Session resume check:** If `draft.completed_sections` is non-empty in state.json:
   - Read `.workflow/draft-cache.md` to restore completed sections
   - Read brainstorm artifacts for completed brainstorms (bs-2/3/4/5)
   - Display resume summary: "Resuming Phase 2. Sections [1,2,3] already completed. Continuing from Section 4."
   - Skip to the next incomplete section
6. If returning from a previous rejection: read `draft.revision_count`, load prior feedback
7. Initialize `.workflow/draft-cache.md` if it does not exist
8. **Read Context Bus files:**
   - Read `.workflow/<name>/context/domain-knowledge.md` for domain background and competitive landscape
   - Read `.workflow/<name>/context/interview-transcript.md` for full Q&A history from Phase 1
   - Read `.workflow/<name>/context/hypothesis-tracker.md` for confirmed/denied hypotheses

## Draft Content Structure

The draft MUST cover all 9 sections. Present them in this order.
Content depth should scale with project complexity.

### Section 1: Project Overview — 项目概述
- 2-3 sentences summarizing the project
- Core problem and solution approach
- Target users

### Section 2: Architecture Design — 架构设计

<STOP-GATE id="BS-2">

**STOP. Do NOT produce ANY Section 2 content yet.**

**Default: Layer 1 (automatic).** Execute inline self-reflection per [brainstorm-protocol.md](brainstorm-protocol.md) Tier 1:

1. **Research** — Read `.workflow/<name>/context/domain-knowledge.md` and `.workflow/<name>/context/hypothesis-tracker.md` to ground the research. Run 2-3 WebSearch queries about architecture patterns for this project type. If candidate frameworks/libraries are known (from Phase 0 pre-research in `.workflow/<name>/context/domain-knowledge.md` or Phase 1 answers), you MUST query DeepWiki to verify their architectural capabilities:
   `bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask "owner/repo" "What architecture patterns does <framework> best support? Any known limitations for <project type>?"`
   Output `🔍 Research Findings` block (include both WebSearch and DeepWiki results, label DeepWiki as `📚 DeepWiki`).
2. **Multi-Perspective Self-Evaluation** — Review from 6 roles (User/Dev/Architect/Security/Ops/Maintainer). Each role: 1-2 sentences. Output `🧠 Multi-Perspective` block.
3. **Self-Interrogation + Synthesis** — Select recommendation, raise 3 sharp challenges, respond. Output `💭 Self-Interrogation` and `✅ Decision` blocks.

**User-preference shortcut:** If user specified an architecture preference during Phase 1, use **validation focus** — research validates the choice, multi-perspective evaluates fit, self-interrogation challenges the choice. Flag concerns if found; do NOT generate alternatives.

**Upgrade to Layer 2:** If the user requests deeper analysis (e.g., `/brainstorm`, "run full brainstorm"), execute Layer 2 per [brainstorm-protocol.md](brainstorm-protocol.md) Tier 2 — all 7 steps including 3 independent Agents, Quality Gate, and Audit.

**SELF-CHECK before writing Section 2 content:**
- [ ] Research Findings block shown to user? If NO → STOP
- [ ] Multi-Perspective evaluation block shown to user? If NO → STOP
- [ ] Self-Interrogation + Decision block shown to user? If NO → STOP
- [ ] (Layer 2 only) Independent Proposals, Divergence Check, Audit blocks shown? If NO → STOP

**After ALL checks pass:** persist results to `.workflow/<name>/brainstorm/bs-2.md`, update `brainstorm.bs2` in state.json, THEN write Section 2 content.

</STOP-GATE>

Section 2 content (write ONLY after BS-2 completes):
- High-level architecture pattern (MVC, Clean Architecture, Event-Driven, etc.)
- Layer decomposition (presentation, business logic, data access, etc.)
- Component diagram (ASCII art)
- Key design patterns to be used (Repository, Factory, Observer, etc.)
- Data flow description
- **Include the brainstorm comparison matrix and decision rationale**

### Section 3: Tech Stack Selection — 技术栈选型

<STOP-GATE id="BS-3">

**STOP. Do NOT produce ANY Section 3 content yet.**

**Default: Layer 1 (automatic).** Execute inline self-reflection per [brainstorm-protocol.md](brainstorm-protocol.md) Tier 1, focused on tech stack decisions. Read Context Bus files first. Use Phase 0 tech ecosystem research (`.workflow/<name>/context/domain-knowledge.md`) as the starting point. For each candidate technology, include at least 1 DeepWiki `ask` query to verify actual API capabilities — WebSearch returns marketing pages, DeepWiki returns documentation:
   `bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask "owner/repo" "What are the main capabilities and limitations of <library> v<latest>?"`

**User-preference shortcut:** For user-specified tech choices (language, framework, database, etc.), use **validation focus** — validate with research, do NOT generate alternatives. For unspecified choices, evaluate options through multi-perspective self-reflection.

**Upgrade to Layer 2:** If the user requests deeper analysis, execute Layer 2 per [brainstorm-protocol.md](brainstorm-protocol.md) Tier 2. A single BS-3 brainstorm may mix modes — e.g., validation focus for "React" (user chose it) + Layer 2 for "state management library" (user didn't specify).

**SELF-CHECK:** Verify all required output blocks (Research, Multi-Perspective, Self-Interrogation, Decision) have been shown to the user before writing Section 3.

**After ALL checks pass:** persist results to `.workflow/<name>/brainstorm/bs-3.md`, update `brainstorm.bs3` in state.json, THEN write Section 3 content.

</STOP-GATE>

Section 3 content (write ONLY after BS-3 completes):
- Language and version with rationale
- Framework and version with rationale
- Database choice with rationale
- Build tools, package manager
- Testing framework
- Deployment toolchain
- For each choice: explain WHY this option over alternatives, **referencing brainstorm evidence**

### Section 4: Algorithm & Design Strategy — 算法与设计策略

<STOP-GATE id="BS-4">

**STOP. Do NOT produce ANY Section 4 content yet.**

**Default: Layer 1 (automatic).** Execute inline self-reflection per [brainstorm-protocol.md](brainstorm-protocol.md) Tier 1, focused on algorithm choices and design patterns. Read `.workflow/<name>/context/domain-knowledge.md` and `.workflow/<name>/context/hypothesis-tracker.md` to ground the research. If the algorithm or design strategy involves a specific library (e.g., search engine, ML framework, caching library), and the library is confirmed in domain-knowledge.md, you MUST query DeepWiki for implementation-level details:
   `bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask "owner/repo" "What algorithms/patterns does <library> provide for <use case>?"`

**User-preference shortcut:** If user specified algorithm or design preferences, use **validation focus**.

**Upgrade to Layer 2:** If the user requests deeper analysis, execute Layer 2 per [brainstorm-protocol.md](brainstorm-protocol.md) Tier 2.

**SELF-CHECK:** Verify all required output blocks (Research, Multi-Perspective, Self-Interrogation, Decision) have been shown to the user before writing Section 4.

**After ALL checks pass:** persist results to `.workflow/<name>/brainstorm/bs-4.md`, update `brainstorm.bs4` in state.json, THEN write Section 4 content.

</STOP-GATE>

Section 4 content (write ONLY after BS-4 completes):
- Key algorithms relevant to the domain
- Performance-critical paths and optimization strategy
- Caching strategy (if applicable)
- Concurrency/parallelism approach (if applicable)
- Security design (authentication, authorization, encryption)

### Section 5: Production Architecture — 生产级架构设计

<STOP-GATE id="BS-8">

**STOP. Do NOT produce ANY Section 5 content yet.**

**Default: Layer 1 (automatic).** Execute inline self-reflection per [brainstorm-protocol.md](brainstorm-protocol.md) Tier 1, focused on production readiness. Read Context Bus files first. If specific tools are referenced (monitoring, IaC, CI/CD), and they are known from Phase 0 pre-research, query DeepWiki:
   `bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask "owner/repo" "Production deployment best practices for <tool>?"`

**Focus areas for this brainstorm:**
1. **Research** — Read `.workflow/<name>/context/domain-knowledge.md` and `.workflow/<name>/context/hypothesis-tracker.md`. Run 2-3 WebSearch queries about production deployment patterns for the chosen tech stack. Query DeepWiki for production-specific capabilities of chosen frameworks.
2. **Multi-Perspective Self-Evaluation** — Review from 6 roles, with emphasis on Ops/SRE and Security perspectives:
   - "What fails at 3am? How do we detect and recover?"
   - "What's the blast radius of each failure?"
   - "Is observability designed in, or bolted on?"
3. **Self-Interrogation + Synthesis:**
   - "If traffic 10x's overnight, does this architecture handle it?"
   - "If a critical third-party API is down for 30 minutes, what happens to users?"
   - "Can a new team member deploy safely on day one?"

**SELF-CHECK before writing Section 5 content:**
- [ ] Research Findings block shown to user? If NO → STOP
- [ ] Multi-Perspective evaluation block shown to user? If NO → STOP
- [ ] Self-Interrogation + Decision block shown to user? If NO → STOP

**After ALL checks pass:** persist results to `.workflow/<name>/brainstorm/bs-8.md`, update `brainstorm.bs8` in state.json, THEN write Section 5 content.

</STOP-GATE>

Section 5 content (write ONLY after BS-8 completes):
- **Deployment Architecture** — containerization (Docker/OCI), orchestration (K8s/nomad/serverless), infrastructure diagram (ASCII art)
- **Observability Design** — metrics (what to measure), logging (structured, levels, aggregation), distributed tracing, health checks (liveness/readiness), alerting rules and thresholds
- **Security Hardening** — network segmentation, secrets management (vault/secrets-manager), TLS termination, CORS/CSP policies, dependency vulnerability scanning, container image scanning
- **Data Protection** — backup strategy (frequency, retention, RPO/RTO), encryption at rest and in transit, database migration strategy (zero-downtime where applicable), PII handling and data retention policies
- **Scaling & Resilience** — horizontal/vertical scaling strategy, auto-scaling triggers, rate limiting, circuit breakers, retry/backoff policies, graceful degradation paths, load shedding
- **CI/CD Pipeline** — build → test → scan → deploy stages, environment promotion (dev→staging→prod), rollback strategy, canary/blue-green deployment approach
- **Runbooks & Operations** — key operational procedures, incident response playbook, on-call expectations, SLI/SLO definitions
- **Infrastructure as Code** — Terraform/Pulumi/CDK/CloudFormation approach, configuration management

### Section 6: Project Structure — 项目结构
- Proposed directory layout (tree format) — include production configs and IaC paths
- Package/module organization rationale
- Configuration management approach (environment variables, config files, feature flags)
- Environment handling (dev/staging/prod) with clear separation

### Section 7: Implementation Phases — 实施阶段划分
- Divide the project into logical implementation phases
- **MUST include at least one Production Hardening phase** — observability instrumentation, security hardening, load testing, deployment automation
- Each phase: name, objective, estimated task count
- Phase dependencies (which phases must complete before others)
- This becomes the basis for Level 1 plan in Phase 3

### Section 8: Risk Assessment — 风险评估
- Top 5-10 technical AND operational risks
- Each risk: description, probability (High/Medium/Low), impact, mitigation strategy
- Include production-specific risks: data loss, service outage, security breach, dependency failure, traffic spike
- Known unknowns and how to resolve them

### Section 9: Complexity Estimate — 复杂度评估
- Overall complexity grade: Simple / Medium / Complex / Very Complex
- Estimated total implementation phases
- Estimated total tasks across all phases

## Presentation Protocol

### Incremental Presentation — 渐进式呈现

Do NOT dump the entire draft at once. Present section by section.

**Important:** Brainstorm artifacts are part of the presentation. The user MUST see brainstorm output BEFORE section content.

**Context management:** After each brainstorm completes and is persisted to disk, keep only a concise summary (decision + confidence + top 2 risks) in the conversation. See [brainstorm-protocol.md](brainstorm-protocol.md) "Context Management" section for full rules. Maintain the cumulative `📋 Brainstorm Progress` block after each brainstorm.

1. **Execute BS-2 (Layer 1, auto)** → show brainstorm artifacts → persist to disk → write Section 2 content
2. **Execute BS-3 (Layer 1, auto)** → show brainstorm artifacts → persist to disk → write Section 3 content
3. Present Sections 1-3 together (Section 1 has no brainstorm)
4. Ask: "Is this direction correct so far?" (到目前为止这个方向是否正确？)
5. If user confirms: **Execute BS-4 (Layer 1, auto)** → show brainstorm artifacts → persist to disk → write Section 4 content
6. **Execute BS-8 (Layer 1, auto)** → show brainstorm artifacts → persist to disk → write Section 5 content
7. Present Sections 4-5
8. Ask: "Any adjustments to design strategy or production architecture?" (设计策略和生产架构有需要调整的吗？)
9. If user confirms: present Sections 6-9
10. Final confirmation gate (BS-5 + approval)

### Section Revision — 局部修改

If user wants changes to specific sections:
- Revise ONLY the requested sections
- If a revised section has a brainstorm trigger (2/3/4/8), re-run the brainstorm for that section
- Re-present the revised sections
- Do NOT re-present unchanged sections
- Continue from where the revision was requested

## Approval Gate

### BS-5: Draft Integrity Check

<STOP-GATE id="BS-5">

**STOP. Do NOT present approval options yet.**

**Default: Layer 1 (automatic).** Execute BS-5 inline self-reflection on the **complete draft as a whole**:

1. **Research** — Read Context Bus files first for accumulated project context. Search for projects with similar architecture/tech stack combinations and their outcomes. If search returns 0 results, retry with broader keywords; if still 0, label as `⚠️ AI Inference`.
2. **Multi-Perspective Self-Evaluation** — Review the **complete draft** from 6 roles. Focus on:
   - Contradictions between sections
   - Unnecessary complexity (could a simpler approach achieve the same goal?)
   - Gaps between requirements (Phase 1) and proposed solutions (Phase 2)
3. **Self-Interrogation + Synthesis:**
   - "Are there contradictions or inconsistencies between these design decisions?"
   - "Is the overall solution more complex than it needs to be?"
   - "If requirements change significantly in a year, can this architecture adapt?"

**SELF-CHECK:**
- [ ] Research Findings block shown to user?
- [ ] Multi-Perspective Evaluation block shown to user?
- [ ] Self-Interrogation + Synthesis block shown to user?

**After ALL checks pass:** persist results to `.workflow/<name>/brainstorm/bs-5.md`, update `brainstorm.bs5` in state.json.

If issues found: present them to the user with suggested fixes BEFORE the approval gate.
If no issues: proceed to approval options.

</STOP-GATE>

After BS-5 completes, offer three explicit options using AskUserQuestion:

### Option A: Approve — 批准
- "Draft approved, proceed to detailed planning" (草案方向正确，进入详细计划阶段)
- Action: transition to Phase 3

### Option B: Revise — 修改
- "Need to revise specific sections" (需要修改部分内容)
- Action: ask which sections need revision, revise in place, re-present
- Increment `draft.revision_count`

### Option C: Restart — 重新开始
- "Direction is wrong, restart from requirements" (方向不对，需要重新收集需求)
- Action: return to Phase 1
- Preserve existing answers but flag categories needing re-evaluation

## Transition to Phase 3

On approval:

1. Verify brainstorm completion: check that `brainstorm.bs2`, `brainstorm.bs3`, `brainstorm.bs4`, `brainstorm.bs5`, `brainstorm.bs8` all have `status: "completed"` in state.json. If any are missing, **DO NOT proceed** — execute the missing brainstorm first.
2. Update state.json:
   - `current_phase: "planning"`
   - `draft.status: "approved"`
   - `draft.approved_at: <current timestamp>`
3. Log transition in `phase_history`
4. Carry the approved draft content forward into Phase 3 context
5. Read `references/phase-3-planning.md` and proceed

## Transition Back to Phase 1

On restart:

1. Update state.json:
   - `current_phase: "requirements"`
   - `draft.status: "rejected"`
   - Increment `draft.revision_count`
2. Log transition in `phase_history` with `exit_reason: "rejected_to_requirements"`
3. Ask user: "Which aspects need re-confirmation?" (哪些方面的需求需要重新确认？)
4. Based on answer: reset relevant coverage_map categories to "partial"
5. Read `references/phase-1-requirements.md` and resume questioning from gaps

## Constraints

- **Draft content is NOT a deliverable on disk.** The conversation is the primary presentation medium. However, a **session-resume cache** (`.workflow/draft-cache.md`) MUST be maintained incrementally.
- **Cache after each section.** After completing each section, append it to `.workflow/draft-cache.md` and update `draft.completed_sections` in state.json.
- **NEVER skip sections.** All 9 sections must be addressed (depth varies by complexity).
- **NEVER produce Section 2/3/4/5 content without completed brainstorm.** The STOP-GATE is NON-NEGOTIABLE.
- **NEVER proceed to Phase 3 without explicit user approval.**
- **NEVER proceed to Phase 3 without all brainstorms (BS-2/3/4/5/8) completed and persisted.**
- **Maintain consistency** between draft content and Phase 1 answers.
