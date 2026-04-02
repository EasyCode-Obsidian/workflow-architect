# Phase 3: Execution Plan — 执行计划落盘

> This phase transforms the approved Phase 2 draft into a 3-level execution plan, written to disk.
> Level 1: Project Plan | Level 2: Phase Plans | Level 3: Task Details

<!-- 本阶段将 Phase 2 批准的草案转化为三级执行计划，写入磁盘。 -->

---

## Entry Protocol

1. Read state.json, verify `current_phase` is `"planning"`
2. Update state: `planning.status: "in_progress"`
3. Confirm the approved draft content is available in context
4. Read plan templates from `assets/templates/`

## Directory Creation

Create the full `.workflow/` directory tree before writing any plans:

```
.workflow/
├── state.json                              (already exists)
├── project-plan.md                         (Level 1)
└── phases/
    ├── phase-1/
    │   ├── phase-plan.md                   (Level 2)
    │   └── tasks/
    │       ├── task-01-<name>.md            (Level 3)
    │       ├── task-02-<name>.md
    │       └── ...
    ├── phase-2/
    │   ├── phase-plan.md
    │   └── tasks/
    │       └── ...
    └── ...                                 (one folder per phase)
```

### Naming Conventions — 命名规范

- Phase folders: `phase-N` (1-indexed, e.g., `phase-1`, `phase-2`)
- Task files: `task-NN-<kebab-case-name>.md` (zero-padded 2 digits, e.g., `task-01-init-project.md`)
- All names in kebab-case (lowercase, hyphens)
- Names should be descriptive and action-oriented

## Writing Protocol

### Step 1: Write Level 1 — 项目总体计划

Use `assets/templates/project-plan.md` as the template. Fill in:

1. **Project name and date** from state.json and current timestamp
2. **Vision** from Phase 2 Section 1
3. **Architecture** from Phase 2 Section 2 (include ASCII diagram)
4. **Tech Stack table** from Phase 2 Section 3
5. **Phase Overview table** from Phase 2 Section 6:
   - Phase number, name, description
   - Task count per phase (estimate — will be precise after Level 3)
   - Dependencies between phases
   - Effort estimate (S/M/L/XL)
6. **Success Criteria** derived from Phase 1 answers
7. **Risk Register** from Phase 2 Section 7

Write to: `.workflow/project-plan.md`

After writing: present a summary of Level 1 to the user.

### Step 2: Write Level 2 — 阶段计划 (one per phase)

For EACH phase listed in the Level 1 plan:

Use `assets/templates/phase-plan.md` as the template. Fill in:

1. **Phase number and name**
2. **Objective** — one sentence describing this phase's goal
3. **Prerequisites** — what must be true before this phase starts
   - May reference completion of prior phases
   - May reference external dependencies
4. **Libraries & Dependencies** — list all external libraries/frameworks used in this phase:
   - Map each to its GitHub `owner/repo` identifier
   - Note what each library is used for in this phase
   - This inventory drives DeepWiki Tier 1 batch research in Phase 4
5. **Task list table** — enumerate every task in this phase:
   - Task number (within phase), name, description
   - Files to be created/modified (exact paths)
   - Estimated step count
6. **Deliverables** — concrete outputs of this phase
7. **Verification checklist** — how to confirm this phase is complete
8. **Phase-specific risks** — if any

Write to: `.workflow/phases/phase-N/phase-plan.md`

After writing ALL Level 2 plans: present a summary showing all phases and their task counts.

### Step 3: Write Level 3 — 任务详情 (one per task)

For EACH task in EACH phase:

Use `assets/templates/task-plan.md` as the template. Fill in:

1. **Task number, name, and parent phase reference**
2. **Objective** — one sentence
3. **Files section:**
   - **Create:** exact file paths to create (e.g., `src/models/user.py`)
   - **Modify:** exact file paths to modify with line ranges if known
   - **Test:** test file paths
4. **Dependencies section:**
   - Map each external library/framework used in this task to its GitHub `owner/repo`
   - Include a brief note on what the library is used for in this task
   - This mapping is consumed by DeepWiki research during Phase 4 execution
5. **Steps** — numbered, atomic, imperative instructions:
   - Each step starts with an action verb (Create, Add, Configure, Run, etc.)
   - Include code snippets where they clarify intent
   - Include shell commands where needed (e.g., "Run: `npm install express`")
   - Each step should be independently verifiable
   - Steps should be ordered by dependency
6. **Verification** — how to confirm the task is done:
   - Test commands to run
   - Expected output
   - Manual checks if needed
7. **Commit message** — pre-written commit message for this task

Write to: `.workflow/phases/phase-N/tasks/task-NN-<name>.md`

### Writing Order — 写入顺序

1. Level 1 first (establishes overall structure)
2. ALL Level 2 plans (establishes task inventory)
3. **BS-6 Brainstorm** (review task decomposition before writing Level 3)
4. ALL Level 3 plans (fills in implementation details)

This order ensures consistency: Level 2 plans reference Level 1 structure,
and Level 3 plans reference Level 2 task listings.

### BS-6: Task Decomposition Brainstorm

<STOP-GATE id="BS-6">

**STOP. Do NOT write Level 3 plans yet.**

After writing all Level 2 plans, you MUST execute brainstorm trigger BS-6 (Reduced Mode — 3 steps):

1. **Step 1 — Forced Research:** Search for task decomposition best practices for the project's tech stack. Output the `🔍 Research Findings` block. **If a search returns 0 results:** retry with broader keywords; if still 0, label output as `⚠️ AI Inference (search unavailable)` — do NOT present model knowledge as search findings.
2. **Step 4 — Multi-Perspective Evaluation:** Focus on Developer and Architect perspectives:
   - "Is the task granularity appropriate? Too large → split; too small → merge?"
   - "Are task dependencies correctly identified? Can some tasks run in parallel?"
   - "Are there missing tasks (config, testing, documentation, deployment)?"
   - "Does the ordering make sense, or would a different sequence be more efficient?"
   - Output the `🧠 Multi-Perspective Evaluation` block.
3. **Step 5 — Self-Interrogation + Synthesis:**
   - "Would swapping the order of Phase X and Phase Y be more logical?"
   - "Which task is most likely to become a bottleneck or blocker?"
   - "Are there implicit dependencies not reflected in the plan?"
   - Output the `💭 Self-Interrogation` and `✅ Decision` blocks.

**SELF-CHECK:**
- [ ] Research Findings block shown to user?
- [ ] Multi-Perspective Evaluation block shown to user?
- [ ] Self-Interrogation + Decision block shown to user?

**After ALL checks pass:** persist results to `.workflow/brainstorm/bs-6.md`, update `brainstorm.bs6` in state.json.

**Then:** Adjust the task breakdown based on brainstorm findings BEFORE writing Level 3 plans.

</STOP-GATE>

## Quality Rules — 质量要求

### Consistency
- Task counts in Level 1 MUST match actual task files in Level 3
- File paths mentioned in Level 2 task table MUST match Level 3 details
- Phase dependencies in Level 1 MUST be reflected in Level 2 prerequisites

### Completeness
- Every feature from the approved draft MUST appear in at least one task
- Every task MUST have at least one verification step
- Every task MUST have a commit message

### Atomicity
- Each Level 3 task should be completable independently (given prerequisites)
- A task should take 5-30 steps (if more, split into multiple tasks)
- A task should touch 1-5 files (if more, consider splitting)

### Traceability
- Level 3 tasks reference their parent phase
- Level 2 phases reference the project plan
- Changes can be traced from requirement → draft section → phase → task → step

## Automated Consistency Verification — 自动一致性验证

<!-- 所有计划写完后，自动运行一致性检查，在审批门前发现问题。 -->

After writing ALL Level 3 plans and before presenting the approval gate, run the following automated checks.
These checks are mandatory — do NOT present the approval gate if any check fails.

### Check 1: Task Count Match

```
FOR each phase P in project-plan.md:
    expected_count = task count listed in Level 1 phase table
    actual_count = number of task-*.md files in .workflow/phases/phase-P/tasks/
    IF expected_count != actual_count:
        FAIL: "Phase P: Level 1 says {expected} tasks, but {actual} task files exist"
```

### Check 2: File Path Consistency

```
FOR each task file in Level 3:
    FOR each file path in task's "Files" section (create/modify):
        Check: is this path referenced in the parent Level 2 phase-plan.md task table?
        IF NOT:
            WARN: "Task {T} references {path} not listed in phase plan"
```

### Check 3: Dependency Validation

```
FOR each phase P in Level 2:
    FOR each prerequisite listed in phase-plan.md:
        Check: does the prerequisite phase exist?
        Check: is the prerequisite phase ordered before P?
        IF NOT:
            FAIL: "Phase P depends on Phase Q, but Q comes after P or doesn't exist"
```

### Check 4: Feature Coverage

```
FOR each feature from the approved draft (Section 2 architecture + Section 6 phases):
    Check: is this feature covered by at least one Level 3 task?
    IF NOT:
        WARN: "Feature '{feature}' from draft is not covered by any task"
```

### Check 5: Task Completeness

```
FOR each Level 3 task file:
    Check: has at least one verification step?       IF NOT: FAIL
    Check: has a commit message?                     IF NOT: FAIL
    Check: has a "Files" section?                    IF NOT: WARN
    Check: step count is between 1-30?               IF NOT: WARN
```

### Verification Output Format

```
🔍 Plan Consistency Verification
═══════════════════════════════════════

Check 1 — Task Count Match:      ✅ PASS | ❌ FAIL (details)
Check 2 — File Path Consistency:  ✅ PASS | ⚠️ WARN (details)
Check 3 — Dependency Validation:  ✅ PASS | ❌ FAIL (details)
Check 4 — Feature Coverage:       ✅ PASS | ⚠️ WARN (details)
Check 5 — Task Completeness:      ✅ PASS | ❌ FAIL (details)

Overall: PASS ✅ / FAIL ❌
```

### Handling Failures

- **FAIL:** Fix the issue automatically (update the inconsistent plan file), then re-run the check.
- **WARN:** Present warnings to the user at the approval gate. User decides whether to fix or accept.
- If auto-fix is not possible: present the issue to the user and ask for guidance before the approval gate.

## Update State

After writing all plans, update state.json:

```json
{
  "planning": {
    "status": "completed",
    "total_phases": <count>,
    "total_tasks": <count>,
    "plans_written": {
      "level_1": true,
      "level_2_count": <count>,
      "level_3_count": <count>
    }
  }
}
```

Also populate `execution.phases` structure with all phase/task entries (status: "pending").

## Approval Gate

**Prerequisites:** Run Automated Consistency Verification (above) BEFORE presenting the approval gate. If any FAIL checks exist, fix them first. Include WARN items in the summary below.

After ALL plans are written and verification passes, present a comprehensive summary:

```
📋 Execution Plan Summary / 执行计划总结

Level 1: Project Plan
  - Phases: N
  - Total Tasks: M

Level 2: Phase Plans
  Phase 1: <name> — X tasks
  Phase 2: <name> — Y tasks
  ...

Level 3: Task Plans
  Total task files written: M

All plans written to: .workflow/
```

Then offer three options to the user:

### Option A: Approve — 批准执行
- "Plans ready, begin execution" (计划完备，开始执行)
- Action: transition to Phase 4

### Option B: Revise — 修改计划
- "Need to revise specific plans" (需要修改部分计划)
- Action: ask which plans need revision, update in place
- Re-verify consistency after revisions

### Option C: Restart — 重新开始
- "Unsatisfied with plans, restart from requirements" (计划不满意，重新收集需求)
- Action: return to Phase 1
- Archive existing `.workflow/` by renaming to `.workflow.bak.<timestamp>/`

## Transition to Phase 4

On approval:

1. Update state.json:
   - `current_phase: "execution"`
   - `execution.status: "pending"` → will become `"in_progress"` when Phase 4 starts
2. Log transition in `phase_history`
3. Read `references/phase-4-execution.md` and begin execution

## Transition Back to Phase 1

On restart:

1. Rename `.workflow/` to `.workflow.bak.<timestamp>/`
2. Update state.json (in new `.workflow/`):
   - `current_phase: "requirements"`
   - `planning.status: "rejected"`
3. Log transition in `phase_history`
4. Return to Phase 1 with existing answers preserved
