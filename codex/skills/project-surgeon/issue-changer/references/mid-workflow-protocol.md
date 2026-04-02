# Mid-Workflow Protocol (Mode A) — 执行中变更协议

> Handles change requests that arrive during Phase 4 execution.
> Pauses execution, analyzes impact, modifies plans, and resumes.

<!-- 处理 Phase 4 执行过程中到达的变更请求。暂停执行、分析影响、修改计划、恢复执行。 -->

---

## Trigger Conditions — 触发条件

Mode A is triggered when:

1. **User explicitly invokes** `/project-surgeon:issue-changer` during Phase 4 execution
2. **Three-Tier Confidence detection**: User sends a message during execution that may express change intent — classified by confidence level before any action is taken

### Three-Tier Confidence System — 三级置信度系统

<!-- 用三级置信度替代简单模式匹配，避免误触发打断工作节奏。 -->

Instead of simple pattern matching (which causes false triggers), user messages are scored
using a weighted signal system. The score determines the response level.

**Signal scoring table:**

| Signal | Weight | Examples |
|--------|--------|---------|
| Imperative verb (变更动词) | +2 | "改"/"换"/"加"/"删"/"移除" / "add"/"change"/"remove"/"replace"/"delete" |
| Specific technical object (具体对象) | +2 | file names, component names, technology names, API names |
| Certainty markers (确定性语气) | +1 | "必须"/"一定要"/"需要" / "must"/"need to"/"have to" |
| Uncertainty markers (不确定性语气) | -2 | "是不是"/"要不要"/"或许"/"可能" / "maybe"/"could we"/"what if"/"perhaps" |
| Question marks (疑问句标记) | -1 | "？" / "?" |
| Explicit requirement keywords (需求关键词) | +3 | "新需求"/"需求变更" / "new requirement"/"requirement change"/"scope change" |
| Explicit invocation (显式调用) | +10 | `/project-surgeon:issue-changer` |

**Confidence levels:**

```
Score ≥ 5  →  HIGH CONFIDENCE
                Action: Enter change request flow with a brief confirmation
                Prompt: "收到变更请求，正在暂停执行以处理。"
                        "Change request received. Pausing execution to process."

Score 3-4  →  MEDIUM CONFIDENCE
                Action: Single lightweight confirmation before any pause
                Prompt (ask the user):
                  "您的消息看起来可能是一个变更请求。要将其作为正式变更处理吗？这会暂停当前执行。"
                  Options: (A) Yes, process as change request
                           (B) No, just a thought — continue execution

Score ≤ 2  →  LOW CONFIDENCE
                Action: Do NOT pause, do NOT trigger, do NOT ask
                After the current task completes, append a non-intrusive hint:
                  "💡 您之前提到了关于 <topic> 的想法。如需正式变更，
                  可以使用 /project-surgeon:issue-changer。"
```

<!-- HIGH: 直接进入变更流程。MEDIUM: 轻量确认后再决定。LOW: 不打断，仅在任务完成后提示。 -->

**Scoring examples:**

| User message | Score | Level |
|-------------|-------|-------|
| `/project-surgeon:issue-changer add notifications` | +10 | HIGH |
| "新需求：加一个消息通知系统" | +3+2+2 = +7 | HIGH |
| "把认证从 session 换成 JWT" | +2+2+2 = +6 | HIGH |
| "Add a caching layer for the API" | +2+2 = +4 | MEDIUM |
| "是不是应该加个缓存？" | +2 -2 -1 = -1 | LOW |
| "I was thinking maybe we should use Redis" | +2 -2 = 0 | LOW |
| "要不要把数据库换成 PostgreSQL？" | +2+2 -2 -1 = +1 | LOW |
| "looks good, continue" | 0 | LOW (not even a change signal) |

**Design rationale:**
- The old pattern-matching approach ("我想改一下...") would score MEDIUM at best (+2 verb, no certainty marker, no specific object) — requiring confirmation instead of immediately triggering
- Only explicit invocations and unambiguous change statements reach HIGH
- Casual ideas and questions stay at LOW — zero disruption to workflow

---

## Protocol Steps — 协议步骤

### Step 1: Pause Execution — 暂停执行

1. Complete the current in-progress step (do NOT stop mid-step)
2. Update state.json:
   - `execution.status: "paused"`
   - `execution.pause_reason: "change_request"`
3. Record the change request in `change_requests` array (see SKILL.md for schema)
4. Output pause notification:

```
⏸️ Execution paused at Phase <X>, Task <Y> (step <Z>)
Processing change request...
```

### Step 2: Impact Analysis — 影响分析

Run the full Impact Analysis Protocol. See [impact-analysis.md](impact-analysis.md).

Key considerations for Mode A:
- **Completed tasks**: Their code may need modification. This is disruptive — flag it clearly.
- **Current task (in_progress)**: May need to restart from the beginning of the task.
- **Pending tasks**: Plans can be modified freely before execution.

### Step 3: Determine Resolution Path — 确定解决路径

Based on impact analysis severity:

#### Light Change (severity = light)

<!-- 轻量变更：直接修改 Level 3 任务计划。 -->

1. Identify the specific Level 3 task plans to modify
2. Present proposed changes to user
3. After approval:
   - Edit the task plan files in `.project-surgeon/phases/` using `Edit` tool
   - If the current in-progress task is affected: mark it as `pending` (restart it)
   - If only future tasks are affected: plans are updated, continue from current position
4. Update `change_requests[N]`:
   - `status: "in_progress"` → `"completed"`
   - `resolution.approach: "modify-tasks"`
5. Resume execution

#### Moderate Change (severity = moderate)

<!-- 中度变更：回到 Phase 3 修改阶段计划。 -->

1. Log transition in `phase_history`: `exit_reason: "change_request_moderate"`
2. Temporarily set `current_phase: "planning"`
3. Read the parent skill's Phase 3 planning protocol: [../../references/phase-3-planning.md](../../references/phase-3-planning.md)
4. Modify affected Level 2 phase plans:
   - Add new tasks if needed
   - Modify existing task plans
   - Re-verify consistency across the 3-level hierarchy
5. If new tasks are created, use the task plan template: [../../assets/templates/task-plan.md](../../assets/templates/task-plan.md)
6. Present updated plans to user for approval
7. After approval:
   - Set `current_phase: "execution"`
   - Update `change_requests[N]`:
     - `status: "completed"`
     - `resolution.approach: "modify-plans"`
8. Resume execution from the first affected task

#### Major Change (severity = major)

<!-- 重大变更：回到 Phase 2 重新设计。 -->

1. Log transition in `phase_history`: `exit_reason: "change_request_major"`
2. Set `current_phase: "draft"`
3. Read `.project-surgeon/draft-cache.md` to restore draft context
4. Identify which draft sections need revision (typically Section 2: Architecture or Section 3: Tech Stack)
5. Revise affected sections — present to user
6. After draft approval: regenerate affected plans (Phase 3)
7. After plan approval: resume execution (Phase 4) from the first affected task
8. Update `change_requests[N]`:
   - `status: "completed"`
   - `resolution.approach: "rethink-design"`

### Step 4: Resume Execution — 恢复执行

<!-- 恢复执行时的关键规则。 -->

**Critical rules for resuming:**

1. **Completed, unaffected tasks: KEEP as completed.** Do NOT re-execute.
2. **Completed, affected tasks: Mark as `pending`.** Their code needs modification.
   - Read the modified task plan
   - Execute only the steps that differ from the original plan
   - If the task was fundamentally changed: re-execute entirely
3. **The current (paused) task:**
   - If affected: restart from step 1 of the task
   - If NOT affected: resume from the paused step
4. **Pending, unaffected tasks: No change.** Execute as originally planned.
5. **New tasks: Insert in correct order** per the updated plan hierarchy.

**Resume display:**

```
▶️ Resuming execution after change request #<N>
  Change: <brief description>
  Resolution: <approach>
  Tasks affected: <count>
  Tasks added: <count>
  Resuming from: Phase <X>, Task <Y>
  Overall progress: <completed>/<new_total> (<percentage>%)
```

---

## Interaction with Existing Course Correction — 与现有回退机制的关系

<!-- 明确 Issue Changer 与现有 Course Correction 的边界。 -->

If the user's request is better handled by the existing Course Correction mechanism
(defined in [../../references/phase-4-execution.md](../../references/phase-4-execution.md)):

1. Inform the user: "This looks like a plan adjustment (task reordering/splitting) rather than a scope change. I'll handle it through the standard course correction flow."
2. Route to Course Correction instead of Issue Changer
3. Do NOT create a `change_requests` entry

**Decision rule:**
- Does the change alter WHAT is being built? → Issue Changer
- Does the change alter HOW the same thing is being built? → Course Correction
