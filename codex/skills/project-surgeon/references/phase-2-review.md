# Phase 2: Review — 7 维度审查详细协议

> This phase performs a systematic code review using the Bug Fixer's 7-dimension review protocol,
> adapted for project-wide analysis. Findings are cataloged but NOT fixed — fixes happen in Phase 4.
> The review protocol itself is defined in `bug-fixer/references/review-protocol.md`.

<!-- 本阶段使用 Bug Fixer 的 7 维度审查协议对代码进行系统性审查。发现问题只记录不修复——修复在 Phase 4 进行。 -->

---

## Critical Note

<!-- 关键说明：本阶段直接读取 bug-fixer 的审查协议，不调用 Bug Fixer 子技能。 -->

This phase **reads and follows** the 7-dimension review protocol defined in:

```
bug-fixer/references/review-protocol.md
```

It does NOT invoke the Bug Fixer sub-skill — the Bug Fixer is reserved for Phase 4 (3-Strike Option E and milestone reviews). This phase applies the same analytical framework but in a **read-only, catalog-only** mode.

The 7 dimensions are:

| Dim | Name | Focus |
|-----|------|-------|
| D1 | Security | Injection, auth bypass, data exposure, secrets in code |
| D2 | Logic | Off-by-one, null handling, race conditions, edge cases |
| D3 | Resource | Memory leaks, unclosed handles, connection pooling |
| D4 | Performance | N+1 queries, unnecessary computation, missing caching |
| D5 | Error Handling | Swallowed exceptions, missing validation, error propagation |
| D6 | Dependencies | Known CVEs, deprecated APIs, version conflicts |
| D7 | Consistency | Naming conventions, code style, pattern adherence |

---

## Entry Protocol

1. Read state.json, verify `current_phase` is `"review"`
2. Load Phase 1 analysis results from state.json (`analysis.*` fields)
3. Load `bug-fixer/references/review-protocol.md` for the 7-dimension protocol
4. Update state: `review.status: "in_progress"`
5. Initialize `review.dimensions_completed: []`

## 5-Step Review Protocol

### Step 1 — Scope Determination + BS-2（范围确定 + 头脑风暴）

<!-- 根据用户目标确定审查范围和维度优先级。 -->

Objective: Determine which files to review and which dimensions to prioritize based on the user's objective.

#### 1.1 Scope Selection by Objective

Map the user's objective (from `analysis.user_objective.type`) to a review scope:

| User Objective | Review Scope |
|---|---|
| `comprehensive_refactoring` | All source code files (excluding tests, configs, generated code) |
| `fix_specific_problems` | Phase 1 flagged areas + hot spot files (highest dependency count) |
| `add_new_features` | Files that will be modified/extended + adjacent code (importers/importees) |
| `modernize` | Files containing outdated patterns + dependency-related code |
| `custom` | Determined by user description — ask for clarification if ambiguous |

#### 1.2 Incremental vs Full Scan (Git repos only)

If the project is a git repository, ask the user how to scope the review:

```
How should we scope the code review?
如何确定代码审查范围？

(A) Incremental scan (recommended) — 增量扫描（推荐）
    Only review files changed since the last stable point (e.g., git diff against main/master).
    Faster, focused on recent changes.

(B) Full scan — 全量扫描
    Review all files within the determined scope.
    More thorough, but takes longer for large projects.
```

For incremental scan: use `git diff --name-only main...HEAD` (or `master...HEAD`) to get the file list, then intersect with the scope from 1.1.

If NOT a git repo: default to full scan within scope.

#### 1.3 Dimension Priority by Objective

Set dimension review order based on the user's objective:

| User Objective | Priority Order (high → low) |
|---|---|
| `comprehensive_refactoring` | D1 = D2 = D3 = D4 = D5 = D6 = D7 (equal weight) |
| `fix_specific_problems` | D2 Logic → D5 Error Handling → D1 Security → D3 → D4 → D6 → D7 |
| `add_new_features` | D7 Consistency → D2 Logic → D4 Performance → D1 → D5 → D3 → D6 |
| `modernize` | D6 Dependencies → D7 Consistency → D4 Performance → D1 → D2 → D5 → D3 |
| `custom` | Infer from user description, default to equal weight |

#### 1.4 BS-2: Validate Review Scope

<STOP-GATE id="BS-2">

Execute BS-2 brainstorm (Reduced Mode — 3 steps):

1. **Step 1 — Forced Research:** Search for common review blind spots in this tech stack and objective type.
2. **Step 4 — Multi-Perspective Evaluation:** From 6 roles, evaluate: "Is the review scope sufficient for this objective?"
3. **Step 5 — Self-Interrogation:**
   - "Are we reviewing the right files, or are we missing critical integration points?"
   - "Could the dimension priorities cause us to miss important issues?"

**Gap handling:** If gaps found, adjust scope before proceeding.

</STOP-GATE>

Persist to `.project-surgeon/brainstorm/bs-2.md`, update `brainstorm.bs2` in state.json.

Update `review.dimensions_completed` — this step does not complete a dimension, but record `"scope_determined"` in `review.steps_completed`.

---

### Step 2 — Execute 7-Dimension Review（执行审查）

<!-- 按 Bug Fixer 的 7 维度协议执行代码审查。 -->

Objective: Systematically scan all in-scope files across all 7 dimensions, in priority order.

#### 2.1 Load Review Protocol

Read `bug-fixer/references/review-protocol.md` and follow its scanning methodology.

#### 2.2 Tiered Scanning Strategy

Apply a 3-tier scanning approach to manage file volume:

| Tier | Method | Files | Purpose |
|------|--------|-------|---------|
| Tier 1 | Grep patterns | All in-scope files | Broad pattern detection (regex-based) |
| Tier 2 | Read file | Top 40 files by Tier 1 hit density | Deep line-by-line analysis |
| Tier 3 | Cross-file analysis | Top 15 hot spots from Tier 2 | Dependency chain and data flow analysis |

**File cap**: Maximum 40 files for Tier 2 deep read. If scope exceeds 40 files:
- Prioritize files with most Tier 1 hits
- Prioritize entry points and core modules (from Phase 1 architecture analysis)
- Prioritize files with highest import frequency

#### 2.3 Execute Each Dimension

For each dimension (in priority order from Step 1):

1. Run Tier 1 Grep patterns specific to the dimension
2. Rank files by hit density
3. Read top files (Tier 2) and analyze for the dimension's concerns
4. For high-severity findings, perform Tier 3 cross-file analysis
5. Record all findings

#### 2.4 Finding Format

Each finding MUST be recorded in this format:

```json
{
  "id": "D2-003",
  "dimension": "D2-Logic",
  "file": "src/services/user-service.ts",
  "line": 142,
  "severity": "HIGH",
  "title": "Null reference on optional user field",
  "description": "user.profile.avatar is accessed without null check. profile is optional per the User type.",
  "suggested_fix": "Add optional chaining: user.profile?.avatar",
  "related_findings": ["D5-001"]
}
```

**Severity levels**:

| Level | Definition |
|---|---|
| CRITICAL | Security vulnerability, data loss risk, crash in production |
| HIGH | Significant bug, performance degradation, reliability risk |
| MEDIUM | Code smell, maintainability concern, minor bug potential |
| LOW | Style issue, minor inconsistency, improvement suggestion |
| INFO | Observation, documentation suggestion, no action required |

After completing each dimension, update `review.dimensions_completed` — append the dimension ID (e.g., `"D1"`, `"D2"`, etc.).

---

### Step 3 — Cross-Reference with Phase 1 Analysis（交叉引用）

<!-- 将审查发现与 Phase 1 架构分析关联，识别系统性问题。 -->

Objective: Connect review findings with Phase 1 architectural analysis to identify systemic patterns.

#### 3.1 Architecture Layer Mapping

Map each finding to an architecture layer (from Phase 1's detected patterns):

- **Presentation layer**: Controllers, views, routes, handlers, components
- **Business logic layer**: Services, domain models, use cases
- **Data access layer**: Repositories, DAOs, ORM models, queries
- **Infrastructure layer**: Config, logging, middleware, utilities
- **Cross-cutting**: Types, interfaces, shared utilities

Produce a layer distribution summary:

```
| Layer          | Findings | Critical | High | Medium | Low |
|----------------|----------|----------|------|--------|-----|
| Presentation   | 5        | 0        | 2    | 2      | 1   |
| Business Logic | 12       | 1        | 4    | 5      | 2   |
| Data Access    | 8        | 2        | 3    | 2      | 1   |
| Infrastructure | 3        | 0        | 1    | 1      | 1   |
| Cross-cutting  | 2        | 0        | 0    | 1      | 1   |
```

#### 3.2 Systemic Issue Detection

Identify systemic issues — the same root cause manifesting in multiple files:

- Group findings by similar `title` or `description` patterns
- If 3+ findings share the same root pattern: classify as a **Systemic Issue**
- Record systemic issues separately with references to all individual findings

Example systemic issues:
- "Missing null checks on optional fields" (D2-003, D2-007, D2-015)
- "Error swallowed in catch blocks" (D5-001, D5-004, D5-008, D5-012)
- "SQL query built with string concatenation" (D1-002, D1-005)

#### 3.3 Hot Spot Identification

Rank files by finding density (findings per file):

```
| Rank | File                          | Findings | Highest Severity |
|------|-------------------------------|----------|-----------------|
| 1    | src/services/user-service.ts   | 8        | CRITICAL        |
| 2    | src/routes/api.ts              | 6        | HIGH            |
| 3    | src/db/queries.ts              | 5        | CRITICAL        |
```

Hot spots (top 10 files by finding count) are primary targets for Phase 4 execution.

---

### Step 4 — Generate Review Report（生成审查报告）

<!-- 使用模板生成结构化的审查报告。 -->

Objective: Produce a comprehensive, structured review report.

#### 4.1 Write Report

Write `.project-surgeon/review-report.md` with the following structure:

```markdown
# Code Review Report — 代码审查报告

## Summary — 摘要
- Total findings: N
- By severity: CRITICAL(n) HIGH(n) MEDIUM(n) LOW(n) INFO(n)
- Dimensions covered: 7/7
- Files reviewed: N (Tier 2 deep) / N (Tier 1 scanned)

## Critical Findings — 关键发现
(CRITICAL severity — must be addressed)

## High Findings — 高级发现
(HIGH severity — should be addressed)

## Medium Findings — 中级发现
(MEDIUM severity — recommended to address)

## Low / Info Findings — 低级/信息发现
(LOW + INFO severity — optional improvements)

## Systemic Issues — 系统性问题
(Cross-cutting patterns affecting multiple files)

## Architecture Cross-Reference — 架构交叉引用
- Layer distribution table
- Hot spot file ranking
- Architecture-level observations

## Appendix: Full Finding List — 附录：完整发现列表
(All findings in tabular format)
```

#### 4.2 Report Ordering

Within each severity section, order findings by:
1. Dimension priority (as set in Step 1)
2. File hot spot ranking
3. Finding ID (ascending)

---

### Step 5 — Priority Confirmation（优先级确认）

<!-- 展示发现摘要，让用户确认处理范围。 -->

Objective: Present findings to user and confirm which findings to address in Phase 3/4.

#### 5.1 Present Summary

Display a condensed summary to the user:

```
## Review Summary — 审查摘要

- **Total findings**: 30
- **CRITICAL**: 3 (security: 1, logic: 2)
- **HIGH**: 8 (logic: 3, error handling: 2, performance: 2, resources: 1)
- **MEDIUM**: 12
- **LOW/INFO**: 7
- **Systemic issues**: 4 patterns
- **Hot spots**: src/services/user-service.ts (8 findings), src/routes/api.ts (6)
```

#### 5.2 Collect User Priorities

Ask the user how to proceed:

```
How would you like to handle these findings?
你希望如何处理这些发现？

(A) Fix all Critical + High — 处理所有关键和高级发现
    Address 11 findings (3 CRITICAL + 8 HIGH). Most impactful, reasonable scope.

(B) Fix all — 处理所有发现
    Address all 30 findings. Comprehensive but time-consuming.

(C) Select specific — 选择特定发现
    I'll present the full list and you choose which to address.

(D) Custom priorities — 自定义优先级
    Describe your own priority criteria.
```

For option (C): present the full finding list and let the user select by Finding ID.
For option (D): record the user's custom criteria and apply them.

Record the user's choice to state.json:

```json
{
  "review": {
    "user_priorities": {
      "scope": "critical_and_high",
      "selected_findings": ["D1-001", "D2-003", "..."],
      "custom_criteria": null,
      "confirmed_at": "ISO-8601"
    }
  }
}
```

---

## Approval Gate

<!-- 审批门控：用户确认后进入 Phase 3。 -->

After user confirms priorities, present the phase transition gate:

```
Review complete. How would you like to proceed?
审查完成。下一步如何？

(A) Approve — proceed to Phase 3 (Planning)
    Create an execution plan to address the selected findings.

(B) Modify scope — adjust review scope or priorities
    Re-run review with different parameters.

(C) Restart — return to Phase 1 (Analysis)
    Re-analyze the project with different focus.
```

| Choice | Action |
|---|---|
| (A) Approve | `current_phase: "planning"`, `review.status: "completed"`, proceed to Phase 3 |
| (B) Modify | Reset relevant `review.dimensions_completed`, re-enter Step 1 with new scope |
| (C) Restart | `current_phase: "analysis"`, `review.status: "rejected"`, log in `phase_history`, return to Phase 1 |

## State Updates

After each step and dimension, update state.json:

```json
{
  "review": {
    "status": "in_progress",
    "steps_completed": ["scope_determined"],
    "dimensions_completed": ["D1", "D2", "D3", "D4", "D5", "D6", "D7"],
    "findings_count": {
      "critical": 3,
      "high": 8,
      "medium": 12,
      "low": 5,
      "info": 2
    },
    "files_scanned": {
      "tier1_grep": 142,
      "tier2_read": 40,
      "tier3_deep": 15
    },
    "systemic_issues_count": 4,
    "hot_spots": ["src/services/user-service.ts", "src/routes/api.ts"],
    "user_priorities": null
  }
}
```

This allows resumption from any dimension if the session is interrupted.
