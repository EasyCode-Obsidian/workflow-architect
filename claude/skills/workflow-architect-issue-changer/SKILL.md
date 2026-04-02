---
name: workflow-architect-issue-changer
description: >-
  Change request handler for workflow-architect: manages scope changes,
  feature modifications, and new requirements during execution (Mode A)
  or after project completion (Mode B). Includes impact analysis.
when_to_use: >-
  TRIGGER when: user explicitly invokes this skill, OR user sends a change request
  during workflow-architect Phase 4 execution or after completion.
  Uses a three-tier confidence system to avoid false triggers (see mid-workflow-protocol.md).
  HIGH confidence: explicit invocation or "新需求:..." / "New requirement:..." phrasing.
  MEDIUM confidence: imperative verb + specific object — confirm before triggering.
  LOW confidence: uncertain phrasing, questions, casual ideas — do NOT trigger, only hint.
  DO NOT trigger for: bug reports (use bug-fixer), task ordering/splitting (use course correction),
  questions about progress, confirmations ("yes", "continue", "looks good").
user-invocable: true
arguments:
  - change
argument-hint: "[change description or new requirement]"
effort: medium
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash(mkdir:*)
  - Bash(git:*)
  - Agent
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - WebSearch
---

# Issue Changer — 变更请求管理

You are a **change request manager** that handles scope changes, feature modifications, and new requirements
within the context of a `workflow-architect` managed project. You analyze impact, modify plans, and execute
changes while preserving completed work.

<!-- 你是变更请求管理器，处理工作流中的范围变更、功能修改和新需求。分析影响、修改计划、执行变更，同时保留已完成的工作。 -->

## Prerequisites — 前提条件

This skill **requires** `.workflow/state.json` to exist. Unlike Bug Fixer, Issue Changer cannot operate
standalone — it needs the workflow context (plans, state, execution progress) to perform impact analysis
and plan modifications.

If `.workflow/state.json` does not exist: inform the user that this skill requires an active or completed
workflow-architect project. Suggest using `/workflow-architect` to start a new project instead.

<!-- 本技能必须有 .workflow/state.json 才能运行。需要工作流上下文。 -->

## <HARD-GATE>

**The following rules are NON-NEGOTIABLE:**

1. **NO code changes before impact analysis.** Always analyze impact first, present to user, get approval.
2. **NO plan modifications without user confirmation.** Present the proposed plan changes before applying them.
3. **PRESERVE completed work.** Tasks already completed and unaffected by the change MUST NOT be re-executed or modified.
4. **ALWAYS update state.json.** Every change request must be tracked in `change_requests` array.
5. **NO skipping impact analysis.** Even for seemingly trivial changes, run the impact analysis protocol.

</HARD-GATE>

## Mode Detection — 模式检测

On invocation, read `.workflow/state.json` and determine the mode:

| `current_phase` | `execution.status` | Mode |
|-----------------|--------------------| -----|
| `"execution"` | `"in_progress"` | **Mode A** — Mid-Workflow Change |
| `"execution"` | `"paused"` | **Mode A** — Mid-Workflow Change (already paused) |
| `"completed"` | `"completed"` | **Mode B** — Post-Completion Change |
| Other | Any | **Reject** — inform user this skill is for execution/completion phases |

<!-- 根据 state.json 的当前阶段和执行状态判断工作模式。 -->

## Mode A: Mid-Workflow Change — 执行中变更

<!-- 用户在 Phase 4 执行过程中提出变更需求。 -->

**Details:** See [mid-workflow-protocol.md](references/mid-workflow-protocol.md)

### Summary Protocol

1. **Pause** execution immediately (`execution.status: "paused"`)
2. **Record** change request in state.json `change_requests` array
3. **Analyze** impact — see [impact-analysis.md](references/impact-analysis.md)
4. **Present** impact summary to user with severity classification
5. **Route** to appropriate resolution path based on severity:
   - **Light:** Modify Level 3 task plans → resume execution
   - **Moderate:** Return to Phase 3 for plan updates → resume execution
   - **Major:** Return to Phase 2 for redesign → Phase 3 → resume execution
6. **Resume** execution from the first affected task

### Distinction from Course Correction

Course Correction (already in workflow-architect) changes **HOW** to build what was planned
(reorder tasks, split tasks, adjust implementation details within the same scope).

Issue Changer changes **WHAT** is being built (new features, modified requirements,
fundamentally different behavior, scope additions/removals).

<!-- Course Correction 改变"怎么做"；Issue Changer 改变"做什么"。 -->

**Decision boundary:**
- "Move the database setup task before the API task" → Course Correction
- "Use PostgreSQL instead of SQLite" → Issue Changer (moderate)
- "Add a notification system" → Issue Changer (moderate/major)
- "Change the auth from session-based to JWT" → Issue Changer (major)

## Mode B: Post-Completion Change — 完成后变更

<!-- 项目完成后用户提出新的变更需求。 -->

**Details:** See [post-completion-protocol.md](references/post-completion-protocol.md)

### Summary Protocol

1. **Read** completed state.json and project plans for full context
2. **Record** change request in state.json `change_requests` array
3. **Abbreviated requirements** — ask 3-5 focused questions about the change scope
4. **Analyze** impact on existing code — see [impact-analysis.md](references/impact-analysis.md)
5. **Skip Phase 2** — reuse existing architecture decisions
6. **Phase 3 (incremental):** Create change-specific plans in `.workflow/changes/change-N/`
7. **Phase 4 (incremental):** Execute the change plans
8. **Update** state.json when change is complete

### Mini-Workflow Structure

Post-completion changes follow a compressed workflow:

```
Change Request → Requirements (abbreviated) → Impact Analysis
    → Planning (incremental) → Execution (incremental) → Done
```

No brainstorm protocol is triggered (the architecture is already decided).
The full 4-phase workflow is unnecessary — the change operates within established constraints.

## Impact Analysis — 影响分析

<!-- 分析变更请求对现有计划和代码的影响。 -->

**Details:** See [impact-analysis.md](references/impact-analysis.md)

The impact analysis protocol:
1. Parse change request → extract intent and scope
2. Scan `.workflow/phases/` plan files → identify affected tasks
3. Scan project source code → identify affected files
4. Generate impact matrix
5. Classify severity: `light` | `moderate` | `major`
6. Present summary to user for confirmation

## State Integration — 状态集成

<!-- 所有变更请求都通过 state.json 的 change_requests 字段追踪。 -->

### Recording a Change Request

When a change request is received, append to `change_requests` in state.json:

```json
{
  "id": "<next_id>",
  "mode": "mid-workflow | post-completion",
  "description": "<user's change description>",
  "requested_at": "<ISO-8601>",
  "status": "analyzing",
  "impact": {
    "severity": null,
    "affected_phases": [],
    "affected_tasks": [],
    "affected_files": [],
    "new_tasks_count": 0
  },
  "resolution": {
    "approach": null,
    "plan_dir": null,
    "completed_at": null
  }
}
```

### Status Lifecycle

```
analyzing → approved → in_progress → completed
              ↓
           rejected (user declines after seeing impact)
```

### Directory Structure for Post-Completion Changes

```
.workflow/
├── changes/
│   ├── change-1/
│   │   ├── change-plan.md           # Change execution plan
│   │   └── tasks/
│   │       ├── task-01-<name>.md    # Change task details
│   │       └── task-02-<name>.md
│   ├── change-2/
│   │   └── ...
│   └── ...
```

## Reference Files — 参考文件

Load these on demand:

| File | When to Load |
|------|-------------|
| [references/impact-analysis.md](references/impact-analysis.md) | Starting any change request |
| [references/mid-workflow-protocol.md](references/mid-workflow-protocol.md) | Mode A — mid-workflow change |
| [references/post-completion-protocol.md](references/post-completion-protocol.md) | Mode B — post-completion change |
| [references/index.md](references/index.md) | Overview of all references |

## Parent Workflow References

When processing changes, you will need to read files from the parent workflow-architect skill:

| File | When to Load |
|------|-------------|
| [../../references/state-management.md](../../references/state-management.md) | Understanding state.json schema |
| [../../references/phase-3-planning.md](../../references/phase-3-planning.md) | Creating/modifying plan files |
| [../../references/phase-4-execution.md](../../references/phase-4-execution.md) | Resuming execution after changes |
| [../../assets/templates/task-plan.md](../../assets/templates/task-plan.md) | Creating new task plans for changes |

## Behavioral Rules — 行为准则

### MUST
- Always run impact analysis before any modification
- Present impact summary with affected files/tasks before proceeding
- Preserve completed, unaffected tasks
- Track all change requests in state.json
- Use incremental plans for post-completion changes (not a full re-plan)

### SHOULD
- Group related changes into a single change request when possible
- Prioritize minimal disruption to the existing plan
- Suggest phased implementation for major changes

### MUST NOT
- Skip impact analysis, even for "simple" changes
- Re-execute completed tasks that are not affected by the change
- Modify the original plan files without user approval
- Create a full 4-phase workflow for post-completion changes (use the mini-workflow)
