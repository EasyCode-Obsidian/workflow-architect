# Phase 3: Planning — 重构计划落盘

> This phase transforms the prioritized findings from Phase 2 Review into a 3-level execution plan, written to disk.
> Plans are organized by risk/priority tiers, not by feature modules.
> Level 1: Project Plan | Level 2: Phase Plans | Level 3: Task Details

<!-- 本阶段将 Phase 2 审查产出的优先级发现转化为三级执行计划，按风险/优先级分层，写入磁盘。 -->

---

## Entry Protocol

1. Read state.json, verify `current_phase` is `"planning"`
2. Update state: `planning.status: "in_progress"`
3. Confirm the approved review findings and user priorities are available in context
4. Read plan templates from `assets/templates/`

## Directory Creation

Create the full `.project-surgeon/` directory tree before writing any plans:

```
.project-surgeon/
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
- Task files: `task-NN-<kebab-case-name>.md` (zero-padded 2 digits, e.g., `task-01-update-express.md`)
- All names in kebab-case (lowercase, hyphens)
- Names should be descriptive and action-oriented

## Risk/Priority Phase Ordering — 风险优先级排序

Unlike workflow-architect (which organizes by feature modules), project-surgeon organizes execution phases by **risk level and strategic priority**. This ensures low-risk, high-reward changes land first, building confidence and stabilizing the project before tackling riskier work.

### Mandatory Phase Ordering

```
Phase 1: Dependency Updates + Configuration Fixes   (低风险高回报 — Low risk, high reward)
Phase 2: Critical Bug Fixes + Security Patches       (关键修复 — Critical fixes)
Phase 3: Refactoring + Pattern Improvements           (结构改进 — Structural improvements)
Phase 4: New Features (if user objectives include)    (新功能 — New features, conditional)
Phase N: Documentation + Cleanup + Final Validation   (收尾 — Always last)
```

**Rationale:**
- Phase 1 first: dependency updates and config fixes are mechanical, low-risk, and often resolve multiple downstream issues at once
- Phase 2 second: critical bugs and security vulnerabilities must be addressed before any refactoring to avoid working on a broken baseline
- Phase 3 third: refactoring is medium-risk and benefits from a stabilized codebase
- Phase 4 conditional: new features only if the user's objective (`user_objective.type`) includes them (e.g., `"features"` or `"comprehensive"`)
- Phase N always last: documentation, cleanup, and final validation wrap up after all code changes are complete

### Finding Traceability — 发现追溯

Every task in Level 3 **MUST** reference at least one Finding ID from the Phase 2 review report. Finding IDs use the format `D<dim>-<seq>` (e.g., `D1-03` = Dimension 1, finding #3).

```markdown
## Traceability
- Finding(s): D1-03, D1-07, D3-12
- Severity: high
- Dimension: D1 (Code Quality), D3 (Security)
```

Tasks that address systemic issues may reference multiple findings. Every finding from Phase 2 that was included in the user's selected priorities (`review.user_priorities`) MUST appear in at least one task.

## Writing Protocol

### Step 1: Write Level 1 — 项目总体计划

Use `assets/templates/project-plan.md` as the template. Fill in:

1. **Project name and date** from state.json and current timestamp
2. **Project fingerprint summary** from Phase 1 analysis (tech stack, size, architecture)
3. **User objective** from Phase 1 analysis (`user_objective.type` and description)
4. **Review summary** from Phase 2 (total findings, severity breakdown, hot spots)
5. **Phase Overview table** organized by risk/priority tier:
   - Phase number, name, risk tier, description
   - Task count per phase (estimate — will be precise after Level 3)
   - Dependencies between phases
   - Effort estimate (S/M/L/XL)
6. **Success Criteria** derived from user objectives and review findings
7. **Risk Register** identified during review (systemic issues, hot spots)

Write to: `.project-surgeon/project-plan.md`

After writing: present a summary of Level 1 to the user.

### Step 2: Write Level 2 — 阶段计划 (one per phase)

For EACH phase listed in the Level 1 plan:

Use `assets/templates/phase-plan.md` as the template. Fill in:

1. **Phase number, name, and risk tier**
2. **Objective** — one sentence describing this phase's goal
3. **Prerequisites** — what must be true before this phase starts
   - May reference completion of prior phases
   - May reference external dependencies (e.g., "test suite must be passing after Phase 2")
4. **Libraries & Dependencies** — list all external libraries/frameworks relevant to this phase:
   - Map each to its GitHub `owner/repo` identifier
   - Note what each library is used for in this phase
   - This inventory drives DeepWiki Tier 1 batch research in Phase 4
5. **Finding coverage** — which Finding IDs (D<dim>-<seq>) are addressed in this phase
6. **Task list table** — enumerate every task in this phase:
   - Task number (within phase), name, description
   - Finding ID(s) addressed
   - Files to be created/modified (exact paths)
   - Estimated step count
7. **Deliverables** — concrete outputs of this phase
8. **Verification checklist** — how to confirm this phase is complete
9. **Phase-specific risks** — if any

Write to: `.project-surgeon/phases/phase-N/phase-plan.md`

After writing ALL Level 2 plans: present a summary showing all phases and their task counts.

### BS-3: Task Decomposition Brainstorm

<STOP-GATE id="BS-3">

**STOP. Do NOT write Level 3 plans yet.**

After writing all Level 2 plans, you MUST execute brainstorm trigger BS-3 (Reduced Mode — 3 steps):

1. **Step 1 — Forced Research:** Search for refactoring best practices and task decomposition strategies for the project's tech stack. Output the `🔍 Research Findings` block. **If a search returns 0 results:** retry with broader keywords; if still 0, label output as `⚠️ AI Inference (search unavailable)` — do NOT present model knowledge as search findings.
2. **Step 4 — Multi-Perspective Evaluation:** Focus on Developer and Architect perspectives:
   - "Is the task granularity appropriate? Too large → split; too small → merge?"
   - "Are task dependencies correctly identified? Can some tasks run in parallel?"
   - "Are there missing tasks (dependency updates, migration scripts, test updates, config changes)?"
   - "Does the risk-priority ordering make sense? Should any task move to a different phase?"
   - "Are the finding-to-task mappings complete? Any orphaned findings?"
   - Output the `🧠 Multi-Perspective Evaluation` block.
3. **Step 5 — Self-Interrogation + Synthesis:**
   - "Would swapping the order of Phase X and Phase Y be more logical given the dependency graph?"
   - "Which task is most likely to cause regressions in existing functionality?"
   - "Are there implicit dependencies not reflected in the plan?"
   - "Could any Phase 1 tasks be batched into a single PR for efficiency?"
   - Output the `💭 Self-Interrogation` and `✅ Decision` blocks.

**SELF-CHECK:**
- [ ] Research Findings block shown to user?
- [ ] Multi-Perspective Evaluation block shown to user?
- [ ] Self-Interrogation + Decision block shown to user?

**After ALL checks pass:** persist results to `.project-surgeon/brainstorm/bs-3.md`, update `brainstorm.bs3` in state.json.

**Then:** Adjust the task breakdown based on brainstorm findings BEFORE writing Level 3 plans.

</STOP-GATE>

### Step 3: Write Level 3 — 任务详情 (one per task)

For EACH task in EACH phase:

Use `assets/templates/task-plan.md` as the template. Fill in:

1. **Task number, name, and parent phase reference**
2. **Traceability** — Finding ID(s) addressed by this task (e.g., `D1-03, D3-12`), severity, dimension
3. **Objective** — one sentence
4. **Files section:**
   - **Create:** exact file paths to create (if any — less common in refactoring)
   - **Modify:** exact file paths to modify with line ranges if known
   - **Delete:** exact file paths to delete (if cleaning up dead code, deprecated configs)
   - **Test:** test file paths to create or modify
5. **Dependencies section:**
   - Map each external library/framework used in this task to its GitHub `owner/repo`
   - Include a brief note on what the library is used for in this task
   - This mapping is consumed by DeepWiki research during Phase 4 execution
6. **Steps** — numbered, atomic, imperative instructions:
   - Each step starts with an action verb (Update, Fix, Refactor, Remove, Configure, Run, etc.)
   - Include code snippets where they clarify intent (especially for refactoring patterns)
   - Include shell commands where needed (e.g., "Run: `npm audit fix`")
   - Each step should be independently verifiable
   - Steps should be ordered by dependency
   - For refactoring tasks: include BEFORE/AFTER code patterns where applicable
7. **Verification** — how to confirm the task is done:
   - Test commands to run
   - Expected output
   - Regression checks (existing tests must still pass)
   - Manual checks if needed
8. **Rollback plan** — how to undo this task if it causes regressions (important for refactoring)
9. **Commit message** — pre-written commit message for this task

Write to: `.project-surgeon/phases/phase-N/tasks/task-NN-<name>.md`

### Writing Order — 写入顺序

1. Level 1 first (establishes overall structure and risk-priority ordering)
2. ALL Level 2 plans (establishes task inventory per risk tier)
3. **BS-3 Brainstorm** (review task decomposition before writing Level 3)
4. ALL Level 3 plans (fills in implementation details with finding traceability)

This order ensures consistency: Level 2 plans reference Level 1 structure,
and Level 3 plans reference Level 2 task listings and Phase 2 Finding IDs.

## Quality Rules — 质量要求

### Consistency
- Task counts in Level 1 MUST match actual task files in Level 3
- File paths mentioned in Level 2 task table MUST match Level 3 details
- Phase dependencies in Level 1 MUST be reflected in Level 2 prerequisites
- Finding IDs in Level 2 MUST match Finding IDs in Level 3 tasks

### Completeness
- Every prioritized finding from Phase 2 MUST appear in at least one task
- Every task MUST have at least one verification step
- Every task MUST have a commit message
- Every task MUST reference at least one Finding ID

### Atomicity
- Each Level 3 task should be completable independently (given prerequisites)
- A task should take 5-30 steps (if more, split into multiple tasks)
- A task should touch 1-5 files (if more, consider splitting)
- Refactoring tasks should be small enough to be safely rolled back

### Traceability
- Level 3 tasks reference their parent phase AND Finding ID(s) from Phase 2
- Level 2 phases reference the project plan and aggregate Finding IDs
- Changes can be traced from finding → dimension → phase → task → step

## Automated Consistency Verification — 自动一致性验证

<!-- 所有计划写完后，自动运行一致性检查，在审批门前发现问题。 -->

After writing ALL Level 3 plans and before presenting the approval gate, run the following automated checks.
These checks are mandatory — do NOT present the approval gate if any check fails.

### Check 1: Task Count Match

```
FOR each phase P in project-plan.md:
    expected_count = task count listed in Level 1 phase table
    actual_count = number of task-*.md files in .project-surgeon/phases/phase-P/tasks/
    IF expected_count != actual_count:
        FAIL: "Phase P: Level 1 says {expected} tasks, but {actual} task files exist"
```

### Check 2: File Path Consistency

```
FOR each task file in Level 3:
    FOR each file path in task's "Files" section (create/modify/delete):
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

### Check 4: Finding Coverage

```
FOR each prioritized finding from Phase 2 (review.user_priorities.selected_findings):
    Check: is this Finding ID referenced by at least one Level 3 task?
    IF NOT:
        FAIL: "Finding '{finding_id}' is prioritized but not covered by any task"
```

### Check 5: Task Completeness

```
FOR each Level 3 task file:
    Check: has at least one verification step?       IF NOT: FAIL
    Check: has a commit message?                     IF NOT: FAIL
    Check: has a "Traceability" section with Finding IDs?  IF NOT: FAIL
    Check: has a "Files" section?                    IF NOT: WARN
    Check: step count is between 1-30?               IF NOT: WARN
```

### Check 6: Risk Tier Ordering

```
FOR each phase P in Level 1:
    Check: Phase 1 tasks are dependency/config type (low risk)?
    Check: Phase 2 tasks are bug fix/security type (critical)?
    Check: Phase N (last) tasks are documentation/cleanup type?
    IF ordering violated:
        WARN: "Phase P contains tasks that belong in a different risk tier"
```

### Verification Output Format

```
🔍 Plan Consistency Verification
═══════════════════════════════════════

Check 1 — Task Count Match:      ✅ PASS | ❌ FAIL (details)
Check 2 — File Path Consistency:  ✅ PASS | ⚠️ WARN (details)
Check 3 — Dependency Validation:  ✅ PASS | ❌ FAIL (details)
Check 4 — Finding Coverage:       ✅ PASS | ❌ FAIL (details)
Check 5 — Task Completeness:      ✅ PASS | ❌ FAIL (details)
Check 6 — Risk Tier Ordering:     ✅ PASS | ⚠️ WARN (details)

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
    "total_phases": "<count>",
    "total_tasks": "<count>",
    "plans_written": {
      "level_1": true,
      "level_2_count": "<count>",
      "level_3_count": "<count>"
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
  - Risk Tiers: N phases
  - Total Tasks: M
  - Findings Covered: F/F (100%)

Level 2: Phase Plans
  Phase 1 (Low Risk):     <name> — X tasks — findings: D1-01, D1-03, ...
  Phase 2 (Critical Fix): <name> — Y tasks — findings: D3-01, D5-02, ...
  Phase 3 (Refactoring):  <name> — Z tasks — findings: D2-04, D4-01, ...
  ...
  Phase N (Cleanup):      <name> — W tasks

Level 3: Task Plans
  Total task files written: M

All plans written to: .project-surgeon/
```

Then offer three options via AskUserQuestion:

### Option A: Approve — 批准执行
- "Plans ready, begin execution" (计划完备，开始执行)
- Action: transition to Phase 4

### Option B: Revise — 修改计划
- "Need to revise specific plans" (需要修改部分计划)
- Action: ask which plans need revision, update in place
- Re-verify consistency after revisions

### Option C: Restart — 重新开始
- "Unsatisfied with plans, restart from analysis" (计划不满意，重新开始分析)
- Action: return to Phase 1
- Archive existing `.project-surgeon/` by renaming to `.project-surgeon.bak.<timestamp>/`

## Transition to Phase 4

On approval:

1. Update state.json:
   - `current_phase: "execution"`
   - `execution.status: "pending"` → will become `"in_progress"` when Phase 4 starts
2. Log transition in `phase_history`
3. Read `references/phase-4-execution.md` and begin execution

## Transition Back to Phase 1

On restart:

1. Rename `.project-surgeon/` to `.project-surgeon.bak.<timestamp>/`
2. Update state.json (in new `.project-surgeon/`):
   - `current_phase: "analysis"`
   - `planning.status: "rejected"`
3. Log transition in `phase_history`
4. Return to Phase 1 with existing analysis preserved
