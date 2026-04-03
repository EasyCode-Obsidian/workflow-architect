# Phase 0: Pre-Research Protocol — 预研协议

> Mandatory parallel research phase that runs BEFORE requirements collection.
> Three agents build domain knowledge so the interview starts from an informed position.

<!-- 在需求收集之前强制运行的并行研究阶段。三个代理构建领域知识，使访谈从知情的起点开始。 -->

---

## Purpose — 为什么需要预研

Without pre-research, the model enters the interview with near-zero domain knowledge and asks shallow, obvious questions. Pre-research provides:
- **Domain context** — common patterns, terminology, and pitfalls
- **Competitive landscape** — what exists, what users expect, what gaps remain
- **Tech ecosystem** — candidate libraries verified via DeepWiki, not guessed from training data

<!-- 没有预研，模型以近零领域知识开始访谈，问出的都是浅层显而易见的问题。 -->

**Cost:** ~10,000-15,000 tokens total for 3 parallel agents.

---

## Entry Protocol

1. Parse the user's initial idea/description
2. Create directories: `.workflow/context/`, `.workflow/agent-outputs/`
3. Initialize state.json: `pre_research.status: "in_progress"`
4. Write `.workflow/context/project-brief.md` with the user's raw input and initial parsing
5. Launch 3 Agents in parallel (see below)

---

## Agent A: Domain Research — 领域研究

**Goal:** Understand the problem domain, common solutions, and typical pitfalls.

**Agent prompt template:**

```
You are a domain research specialist. Your ONLY task is to research the domain
for a project and write a structured report.

## Project Idea
{user's initial description}

## Your Task — MANDATORY

1. Run 3-5 WebSearch queries:
   - "{domain} common architecture patterns {current_year}"
   - "{domain} typical challenges and pitfalls"
   - "{domain} successful projects and case studies"
   - "{domain} user expectations and pain points"
   - "{domain} regulatory or compliance considerations" (if applicable)

2. For each result, extract ACTIONABLE insights — not summaries.

3. Identify 5-10 aspects that a requirements interview MUST cover
   but a non-domain-expert would likely miss.

## Output
Write to: .workflow/agent-outputs/agent-a-domain.md

Use this format:
# Domain Research — {domain}
Generated: {timestamp}

## Domain Overview
{2-3 paragraph domain summary}

## Key Concepts & Terminology
- {term}: {definition relevant to this project}

## Common Architecture Patterns
{patterns with pros/cons}

## Typical Challenges & Pitfalls
{numbered list with severity}

## Interview Must-Cover Topics
{numbered list of aspects a non-expert would miss}

## Sources
{list of URLs consulted}

Return a 200-word summary of your top findings.
```

**Output file:** `.workflow/agent-outputs/agent-a-domain.md`

---

## Agent B: Competitive Analysis — 竞品分析

**Goal:** Map the existing solution landscape to identify gaps and user expectations.

**Agent prompt template:**

```
You are a competitive analysis specialist. Your ONLY task is to research existing
solutions similar to a project idea and write a structured report.

## Project Idea
{user's initial description}

## Your Task — MANDATORY

1. Run 3-5 WebSearch queries:
   - "{project type} alternatives comparison {current_year}"
   - "{project type} open source projects"
   - "{project type} best tools/products"
   - "{top competitor} user reviews problems"
   - "{project type} market gaps"

2. For each competitor/alternative found:
   - Core features and differentiators
   - Common user complaints (search: "{name} issues/problems/complaints")
   - Architecture approach (if open source or documented)

3. Identify feature gaps — what do users want that no existing solution provides well?

## Output
Write to: .workflow/agent-outputs/agent-b-competitive.md

Use this format:
# Competitive Analysis — {project type}
Generated: {timestamp}

## Existing Solutions
| Name | Type | Key Features | Weaknesses | Users |
|------|------|-------------|-----------|-------|
| ... | ... | ... | ... | ... |

## Feature Comparison Matrix
| Feature | Solution A | Solution B | Solution C | Our Opportunity |
|---------|-----------|-----------|-----------|----------------|
| ... | ... | ... | ... | ... |

## Common User Pain Points
{from review/complaint research}

## Market Gaps & Opportunities
{what's missing that the new project could address}

## Lessons Learned
{what to replicate vs. what to avoid from competitors}

## Sources
{list of URLs consulted}

Return a 200-word summary of key competitive insights.
```

**Output file:** `.workflow/agent-outputs/agent-b-competitive.md`

---

## Agent C: Tech Ecosystem + DeepWiki — 技术生态 + DeepWiki

**Goal:** Identify candidate technologies and verify them via DeepWiki documentation.

**Agent prompt template:**

```
You are a technology ecosystem researcher. Your ONLY task is to identify candidate
libraries/frameworks and verify their capabilities using DeepWiki.

## Project Idea
{user's initial description}

## DeepWiki Script
Platform: {Windows → powershell -File / Unix → bash}
Script path: {CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.{ps1|sh}

## Your Task — MANDATORY, NO EXCEPTIONS

1. Based on the project idea, identify 3-5 candidate libraries/frameworks
   that would be central to the implementation. Run 1-2 WebSearch queries
   to discover options: "{project type} best libraries/frameworks {current_year}"

2. For EACH candidate library, you MUST run DeepWiki:

   Step A — Get documentation structure:
   {script_command} structure "{owner/repo}"

   Step B — Query capabilities:
   {script_command} ask "{owner/repo}" "What are the core APIs, capabilities, limitations, and best practices for {library}?"

   Do NOT skip DeepWiki. Do NOT claim you ran it without actually running it.
   If DeepWiki returns an error or empty response:
   - Retry once with a simpler question
   - If still fails: run WebSearch "{library} API documentation overview" as fallback
   - Mark the entry as "⚠️ WebSearch fallback — verify manually"

3. If multiple candidates serve the same purpose, run a comparison query:
   {script_command} ask '["owner/repo1","owner/repo2"]' "Compare {lib1} vs {lib2} for {use case}: API ergonomics, performance, ecosystem"

4. Run 1-2 WebSearch queries for ecosystem health: "{library} npm downloads" or "{library} github stars maintenance status"

## Output
Write to: .workflow/agent-outputs/agent-c-tech.md

Use this format:
# Tech Ecosystem Research — {project type}
Generated: {timestamp}
DeepWiki queries run: {count}
DeepWiki fallbacks: {count}

## Candidate Libraries
| Library | GitHub Repo | Category | DeepWiki Status |
|---------|-------------|----------|----------------|
| express | expressjs/express | Web framework | ✅ Queried |
| prisma  | prisma/prisma     | ORM            | ✅ Queried |
| ...     | ...               | ...            | ⚠️ Fallback |

## DeepWiki Findings
### {library_1} ({owner/repo_1})
**Documentation structure:** {summary of topics available}
**Core capabilities:** {from DeepWiki ask response}
**Limitations:** {from DeepWiki ask response}
**Best practices:** {from DeepWiki ask response}

### {library_2} ({owner/repo_2})
...

## Ecosystem Health
| Library | Stars | Last Release | Maintenance | Community |
|---------|-------|-------------|-------------|-----------|
| ...     | ...   | ...         | ...         | ...       |

## Recommended Stack
{preliminary recommendation with reasoning — to be validated in Phase 1/2}

## Sources
{list of URLs and DeepWiki queries}

Return a 200-word summary: libraries researched, DeepWiki results, preliminary recommendation.
```

**Output file:** `.workflow/agent-outputs/agent-c-tech.md`

---

## Consolidation Protocol — 合并协议

After all 3 agents complete, the main model MUST:

1. **Read all 3 output files:**
   - `.workflow/agent-outputs/agent-a-domain.md`
   - `.workflow/agent-outputs/agent-b-competitive.md`
   - `.workflow/agent-outputs/agent-c-tech.md`

2. **Synthesize into `.workflow/context/domain-knowledge.md`:**
   ```markdown
   # Domain Knowledge — Consolidated Pre-Research
   <!-- Auto-generated from Phase 0 agents. Updated: {timestamp} -->

   ## Domain Summary
   {synthesized from Agent A}

   ## Competitive Landscape
   {synthesized from Agent B — key table + gaps}

   ## Tech Ecosystem
   {synthesized from Agent C — candidates + DeepWiki status}

   ## Key Risks & Unknowns
   {cross-referenced from all 3 agents}

   ## Interview Priority Topics
   {topics identified by Agent A that the interview MUST cover}
   ```

3. **Update `.workflow/context/project-brief.md`** with domain context summary.

4. **Initialize `.workflow/context/hypothesis-tracker.md`:**
   ```markdown
   # Hypothesis Tracker
   <!-- Updated after each brainstorm and interview answer -->

   | ID | Hypothesis | Confidence | Source | Status |
   |----|-----------|-----------|--------|--------|
   | H1 | {hypothesis from pre-research} | MEDIUM | Phase 0 | OPEN |
   | H2 | {hypothesis from pre-research} | LOW | Phase 0 | OPEN |
   ```

5. **Update state.json:**
   - `pre_research.status: "completed"`
   - `pre_research.consolidation_status: "completed"`
   - `pre_research.completed_at: {timestamp}`
   - `context_bus.domain_knowledge: ".workflow/context/domain-knowledge.md"`
   - `context_bus.project_brief: ".workflow/context/project-brief.md"`
   - `context_bus.hypothesis_tracker: ".workflow/context/hypothesis-tracker.md"`

6. **Present summary to user:**
   ```
   📚 Pre-Research Complete
   ════════════════════════════
   Domain researched: {domain}
   Competitors found: {count}
   Libraries evaluated: {count} ({deepwiki_count} via DeepWiki)
   Key risks identified: {count}
   Interview priority topics: {count}

   Consolidated knowledge: .workflow/context/domain-knowledge.md
   Proceeding to requirements collection...
   ════════════════════════════
   ```

---

## Error Handling — 错误处理

| Scenario | Action |
|----------|--------|
| Agent A fails | Retry once. If still fails, proceed without domain research — log warning. |
| Agent B fails | Retry once. If still fails, proceed without competitive analysis — log warning. |
| Agent C fails | Retry once. If still fails, fall back to WebSearch-only tech research — log warning. |
| Agent C DeepWiki fails (429) | Built-in retry in script (3 attempts). If all fail, WebSearch fallback. |
| All 3 agents fail | Inform user. Offer: (A) Retry all, (B) Skip pre-research and go to Phase 1 directly. |

**Critical:** Agent C's DeepWiki failure does NOT block the workflow. The fallback chain (retry → WebSearch → proceed with warning) ensures progress. But the failure MUST be logged in state.json (`pre_research.agents.tech_ecosystem.deepwiki_called: false`).

---

## Session Resume — 会话恢复

On skill invocation, if `pre_research` exists in state.json:

- **status: "completed"** → Skip Phase 0, proceed to Phase 1
- **status: "in_progress"** → Check each agent's status:
  - Re-run only agents with `status: "pending"` or `"failed"`
  - Skip agents with `status: "completed"`
  - After all agents done → run consolidation if `consolidation_status: "pending"`

---

## Constraints — 约束

- Phase 0 MUST complete before Phase 1 begins. This is NON-NEGOTIABLE.
- All 3 agents launch in parallel to minimize wall-clock time.
- Agent C MUST attempt DeepWiki for every candidate library. Fallback to WebSearch is acceptable only after DeepWiki failure.
- The user's initial description is passed verbatim to all 3 agents — do NOT summarize or filter it.
- Total agent execution should target under 60 seconds. If an agent appears stuck, allow 2 minutes before timeout.
- Agent outputs are raw research. The consolidation step (done by the main model) is where quality filtering and synthesis happens.
