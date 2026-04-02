# Impact Analysis Protocol — 影响分析协议

> Analyzes how a change request affects existing plans, code, and execution state.
> Used by both Mode A (mid-workflow) and Mode B (post-completion).

<!-- 分析变更请求如何影响现有的计划、代码和执行状态。Mode A 和 Mode B 共用。 -->

---

## Overview

Impact analysis is a mandatory step before any change is applied. It produces an **Impact Matrix** that
maps the change to affected plans, tasks, and source files, then classifies the overall severity.

## Protocol Steps

```
Step 1: PARSE — extract intent and scope from change request
Step 2: SCAN PLANS — identify affected plan files in .workflow/
Step 3: SCAN CODE — identify affected source files
Step 4: GENERATE MATRIX — build the impact matrix
Step 5: CLASSIFY — determine severity (light | moderate | major)
Step 6: PRESENT — show impact summary to user
```

---

## Step 1: Parse Change Request — 解析变更请求

<!-- 从用户的变更描述中提取意图和范围。 -->

1. Read the user's change description (from `$change` argument or conversation)
2. Extract:
   - **Intent**: What does the user want to achieve? (add feature, modify behavior, remove feature, change tech)
   - **Scope keywords**: Technical terms, feature names, file names mentioned
   - **Implicit scope**: What else might need to change based on the intent (e.g., "add auth" implies routes, middleware, database, UI)
3. If the description is ambiguous, ask clarifying questions (max 2 questions)

**Output:**
```
Change Intent: <add | modify | remove | replace>
Scope: <feature/component name>
Keywords: [<list of technical terms for scanning>]
Implicit Dependencies: [<list of potentially affected areas>]
```

## Step 2: Scan Plans — 扫描计划文件

<!-- 在 .workflow/phases/ 中搜索受影响的计划文件。 -->

1. Read `.workflow/project-plan.md` for the overall structure
2. Use `Grep` to search ALL plan files in `.workflow/phases/` for scope keywords
3. For each match, determine the relationship:
   - **Direct impact**: The plan/task directly implements the feature being changed
   - **Indirect impact**: The plan/task depends on or interacts with the changed feature
   - **No impact**: Keyword match is coincidental (e.g., appears in a comment)
4. Record affected plan files with their impact type

**For Mode A (mid-workflow):** Also check task execution status:
- Affected task is `completed`: May need modification of already-written code
- Affected task is `in_progress`: Current task needs plan update
- Affected task is `pending`: Plan can be updated before execution

**For Mode B (post-completion):** All tasks are completed, so all affected tasks require code modification.

## Step 3: Scan Code — 扫描源代码

<!-- 在项目源代码中搜索受影响的文件。 -->

1. Use `Grep` to search the project source code (excluding `.workflow/`, `node_modules/`, etc.) for scope keywords
2. Use `Glob` to find files with names matching the scope (e.g., `*auth*`, `*notification*`)
3. For each match, determine:
   - **Must modify**: This file directly implements the behavior being changed
   - **May need update**: This file imports/references the changed component
   - **Read-only reference**: This file mentions the concept but doesn't need changes
4. Record affected files with their modification type

## Step 4: Generate Impact Matrix — 生成影响矩阵

<!-- 构建变更请求的影响矩阵。 -->

Combine plan scan and code scan results into a structured matrix:

```markdown
## Impact Matrix

### Affected Plans
| Plan File | Impact Type | Task Status | Action Required |
|-----------|------------|-------------|-----------------|
| phases/phase-2/tasks/task-03-auth.md | Direct | completed | Modify existing code |
| phases/phase-3/tasks/task-01-api.md | Indirect | pending | Update plan before execution |

### Affected Source Files
| File | Impact Type | Action Required |
|------|------------|-----------------|
| src/middleware/auth.ts | Must modify | Core logic change |
| src/routes/users.ts | May need update | Import/reference update |
| tests/auth.test.ts | Must modify | Update tests for new behavior |

### New Files Required
| File | Purpose |
|------|---------|
| src/middleware/jwt.ts | New JWT implementation |
| tests/jwt.test.ts | JWT tests |
```

## Step 5: Classify Severity — 分类严重程度

<!-- 根据影响范围和深度分类变更严重程度。 -->

| Severity | Criteria | Resolution Path |
|----------|----------|-----------------|
| **Light** | ≤ 3 affected tasks, all in current/future phases, no architecture change, no new tasks needed | Modify Level 3 task plans in place |
| **Moderate** | 4-10 affected tasks, OR new tasks needed, OR phase plan needs update, but architecture unchanged | Return to Phase 3 for plan updates |
| **Major** | > 10 affected tasks, OR architecture change needed, OR fundamental design shift, OR affects completed phases significantly | Return to Phase 2 for redesign |

**Scoring heuristic (for borderline cases):**

| Factor | Points |
|--------|--------|
| Each directly affected task | +1 |
| Each indirectly affected task | +0.5 |
| Each new task required | +2 |
| Architecture change needed | +5 |
| Affects completed task code | +1 per task |
| New dependency/library needed | +1 |

- Score ≤ 3: Light
- Score 4-8: Moderate
- Score > 8: Major

## Step 6: Present to User — 向用户展示

<!-- 向用户展示影响分析摘要，等待确认。 -->

Present the impact summary in this format:

```
═══════════════════════════════════════════════════════
CHANGE REQUEST — IMPACT ANALYSIS
═══════════════════════════════════════════════════════

Request: <change description>
Severity: <LIGHT | MODERATE | MAJOR>

Affected Plans: <count> tasks (<direct> direct, <indirect> indirect)
Affected Files: <count> (<must_modify> must modify, <may_update> may update)
New Files: <count>
New Tasks: <count>

Resolution Path:
<description of what will happen — which plans change, what code gets modified>

Estimated Disruption:
- Completed work preserved: <count> tasks unaffected
- Work to redo: <count> tasks need code modification
- New work: <count> new tasks

═══════════════════════════════════════════════════════
```

Then ask the user:
- **(A) Approve and proceed** — apply the change with the proposed resolution path
- **(B) Modify scope** — narrow or broaden the change request
- **(C) Cancel** — reject the change request, resume original workflow

If user chooses (A): update `change_requests[N].status` to `"approved"`, proceed with resolution.
If user chooses (B): return to Step 1 with refined description.
If user chooses (C): update `change_requests[N].status` to `"rejected"`, resume execution (Mode A) or end (Mode B).
