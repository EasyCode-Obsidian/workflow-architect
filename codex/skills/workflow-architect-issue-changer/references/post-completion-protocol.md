# Post-Completion Protocol (Mode B) — 完成后变更协议

> Handles change requests after the workflow-architect project has completed.
> Uses an abbreviated mini-workflow: Requirements → Impact Analysis → Planning → Execution.

<!-- 处理项目完成后的变更请求。使用缩减版迷你工作流。 -->

---

## Trigger Conditions — 触发条件

Mode B is triggered when:

1. `.workflow/state.json` exists with `current_phase: "completed"`
2. User invokes `issue-changer` with a change description
3. OR user sends a change-intent message and auto-detection triggers (see mid-workflow-protocol.md for patterns)

---

## Mini-Workflow — 迷你工作流

Post-completion changes follow a compressed workflow that skips Phase 2 (Draft Proposal)
because the architecture is already decided and validated.

```
Change Request
    │
    ▼
Abbreviated Requirements (3-5 questions)
    │
    ▼
Impact Analysis (full protocol)
    │
    ▼
Incremental Planning (change-specific plans)
    │
    ▼
Incremental Execution (execute change plans)
    │
    ▼
Verification & Completion
```

<!-- 跳过 Phase 2（架构已确定），使用缩减版需求收集 + 影响分析 + 增量规划 + 增量执行。 -->

---

## Step 1: Context Recovery — 上下文恢复

<!-- 恢复已完成项目的上下文。 -->

1. Read `.workflow/state.json` for project overview
2. Read `.workflow/project-plan.md` for architecture and tech stack decisions
3. Read the completion report from the last execution session (if in phase_history)
4. Scan the project directory to understand current file structure
5. Check if previous change requests exist in `change_requests` — understand the evolution

**Output:**
```
Project: <name>
Status: Completed on <date>
Architecture: <brief summary from project plan>
Previous changes: <count> (if any)
```

## Step 2: Abbreviated Requirements — 缩减版需求收集

<!-- 针对变更范围的简短需求收集，3-5 个问题。 -->

Unlike the full Phase 1 (which covers 10 categories), post-completion changes need only:

1. **What exactly do you want to change?** — clarify scope boundaries
2. **What is the expected behavior after this change?** — define acceptance criteria
3. **Are there any constraints I should know about?** — time, compatibility, dependencies
4. Optionally (if scope seems large):
   - **Can this be broken into smaller changes?** — suggest phased approach
   - **What existing functionality must NOT be affected?** — define protected areas

Ask the user for each question. Max 5 questions — do NOT enter the full 10-category taxonomy.

## Step 3: Impact Analysis — 影响分析

Run the full Impact Analysis Protocol. See [impact-analysis.md](impact-analysis.md).

**Post-completion specific considerations:**
- ALL tasks are completed, so affected tasks = code modification needed
- No "pending" tasks exist — all impact is on existing code
- Severity classification still applies (light/moderate/major):
  - **Light**: ≤ 3 files to modify, no new files needed
  - **Moderate**: 4-10 files to modify, OR new files needed, but architecture unchanged
  - **Major**: Architecture change needed → warn user this may be better suited for a new `workflow-architect` project

**For major changes:** Present the option to start a fresh workflow-architect project instead:
> "This change is significant enough that starting a new project with `workflow-architect` might produce better results. Would you prefer to: (A) Proceed with incremental change, or (B) Start a new project that incorporates this change?"

## Step 4: Incremental Planning — 增量规划

<!-- 为变更创建独立的增量执行计划。 -->

Create change-specific plans in `.workflow/changes/change-N/`:

### Directory Structure

```
.workflow/changes/change-<N>/
├── change-plan.md           # Change overview and task list
└── tasks/
    ├── task-01-<name>.md    # Change task details
    ├── task-02-<name>.md
    └── ...
```

### Change Plan Format

```markdown
# Change Plan #<N>: <title>

- **Date:** <ISO-8601>
- **Description:** <change description>
- **Severity:** <light | moderate | major>
- **Impact:** <count> existing files affected, <count> new files

## Context

<Brief summary of what the change does and why>

## Affected Existing Code

| File | Modification Required |
|------|----------------------|
| <path> | <description of change> |

## Task List

| # | Task | Files | Dependencies |
|---|------|-------|-------------|
| 1 | <task name> | <files to create/modify> | <dependent tasks> |
| 2 | <task name> | <files to create/modify> | <dependent tasks> |

## Verification

- [ ] <verification criterion 1>
- [ ] <verification criterion 2>
```

### Task Plan Format

Use the same template as the parent workflow: [../../assets/templates/task-plan.md](../../assets/templates/task-plan.md)

But with these adjustments:
- Phase reference → Change reference: `Parent: [Change Plan #N](../change-plan.md)`
- Commit message format: `fix|feat: <description> (Change #N, Task NN)`

### Plan Approval

Present the change plan to user:
- **(A) Approve** — proceed to execution
- **(B) Revise** — edit specific tasks
- **(C) Cancel** — reject the change request

## Step 5: Incremental Execution — 增量执行

<!-- 执行变更计划，与主工作流的 Phase 4 执行类似但更轻量。 -->

Execute the change plan tasks following the same protocol as the parent workflow's Phase 4:

1. Create task tracking entries for all change tasks: `[Change #N] Task NN: <name>`
2. Execute tasks in order
3. For each task:
   - Read task plan
   - Execute steps exactly as documented
   - Run verification
   - Commit with change-specific message
   - Update progress
4. Use the same 3-Strike error recovery as the parent workflow
   - After 3 strikes: offer options A/B/C/D (same as parent Phase 4)
   - BS-7 and Bug Fixer are both available as escalation options

**Progress format:**
```
[Change #N] [Task A/B] ✅ Completed: <task name>
```

### No Milestone Checkpoints

Unlike the main workflow, change execution does NOT have milestone checkpoints
(changes are typically small enough that per-task progress is sufficient).

## Step 6: Verification & Completion — 验证与完成

<!-- 验证变更并更新状态。 -->

After all change tasks complete:

1. Run verification criteria from the change plan
2. Run the project's test suite (if applicable) to check for regressions
3. Generate change completion report:

```
═══════════════════════════════════════════════════════
CHANGE REQUEST #<N> — COMPLETED
═══════════════════════════════════════════════════════

Change: <description>
Tasks Completed: <count>/<count>
Files Modified: <count>
Files Created: <count>
Errors Encountered: <count>

Verification: ✅ All criteria pass | ⚠️ Partial pass
═══════════════════════════════════════════════════════
```

4. Update state.json:
   - `change_requests[N].status: "completed"`
   - `change_requests[N].resolution.completed_at: "<ISO-8601>"`
   - `change_requests[N].resolution.plan_dir: ".workflow/changes/change-N/"`

---

## Multiple Sequential Changes — 多次连续变更

<!-- 用户可能在完成后提出多次变更。 -->

Users may submit multiple change requests after completion. Each change:

1. Gets its own `change_requests` entry with incrementing `id`
2. Gets its own `.workflow/changes/change-N/` directory
3. Runs impact analysis considering BOTH the original code AND previous changes
4. Previous change request context is available via `change_requests` array in state.json

**Context management for sequential changes:**
- Read previous change plans to understand cumulative modifications
- Impact analysis must scan `.workflow/changes/` in addition to `.workflow/phases/`
- If a new change conflicts with a previous change: flag to user before proceeding
