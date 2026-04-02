# Phase 4: Plan Execution — 计划执行

> This phase executes the plans written to disk in Phase 3.
> Plans guide execution, but professional judgment is allowed for code quality standards.
> This is a long-running task that executes all phases and all steps in sequence.

<!-- 本阶段按照 Phase 3 落盘的执行计划进行实施。计划指导执行，但允许专业判断提升代码质量。 -->

---

## Entry Protocol

1. Read state.json, verify `current_phase` is `"execution"`
2. Update state: `execution.status: "in_progress"`
3. Read `.workflow/project-plan.md` to understand overall structure
4. Determine starting point:
   - Fresh start: begin from Phase 1, Task 1
   - Session resume: find last completed task in state.json, continue from next
5. **DeepWiki setup:** Determine the platform and locate the correct script:
   - **Unix/macOS:** `${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh` — verify it exists and is executable
   - **Windows:** `${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.ps1` — verify it exists
   - **Auto-detect:** Check if running on Windows (presence of `COMSPEC` env var or `OS` = `Windows_NT`). Use `.ps1` on Windows, `.sh` otherwise.
   - If neither script is found, log a warning — DeepWiki research will fall back to web search.
6. Create task tracking entries for ALL pending tasks across ALL phases
   - This provides real-time visibility to the user
   - Format: `[Phase N] Task NN: <name>`

## Execution Loop

```
FOR each phase P in project-plan (in order):
    Read .workflow/phases/phase-P/phase-plan.md
    Verify prerequisites are met
    Mark phase as in_progress in state.json

    === DEEPWIKI TIER 1: PHASE RESEARCH ===
    Run DeepWiki phase-level batch research (see DeepWiki Integration below)
    === END TIER 1 ===

    FOR each task T in phase P (in order):
        Read .workflow/phases/phase-P/tasks/task-TT-<name>.md
        Mark task as in_progress in state.json
        Mark the corresponding task entry as in_progress

        === DEEPWIKI TIER 2: TASK RESEARCH ===
        Run DeepWiki task-level focused research (see DeepWiki Integration below)
        === END TIER 2 ===

        FOR each step S in task T:
            Execute step EXACTLY as documented
            If step involves a command: run it and verify output
            If step involves file creation: create file with specified content
            If step involves file modification: edit as specified
            If step involves API usage with uncertainty:
                === DEEPWIKI TIER 3: CODING RESEARCH ===
                Query DeepWiki for precise API details (see DeepWiki Integration below)
                === END TIER 3 ===

        Run verification checks from task plan
        If verification passes:
            Mark task completed in state.json
            Mark the task entry as completed
            Git commit with pre-written message from task plan
            Output progress: [Phase X/Y] [Task A/B] Completed: <name> | Overall: C/D (E%)

        If verification fails:
            Enter error recovery (see below)

    Mark phase completed in state.json
    Output: "Phase P completed. Moving to Phase P+1."

    === MILESTONE CHECKPOINT ===
    Present milestone review to user:
    - Summary of what was built in this phase
    - Files created/modified count
    - Any errors encountered and how they were resolved
    - Options:
      (A) Continue to next phase
      (B) Review what was built (show key files)
      (C) Course correction — modify plans for remaining phases
      (D) Pause execution (can resume later)
      (E) Run code review — invoke Bug Fixer to audit this phase's deliverables before continuing (see [Bug Fixer](../bug-fixer/SKILL.md))

    If user chooses (C): enter Course Correction protocol (see below)
    If user chooses (D): mark execution as "paused" in state.json, stop
    === END CHECKPOINT ===

Output: "All phases completed. Running final verification."
Run final verification
Mark execution as completed
```

## Milestone Checkpoints — 里程碑检查点

<!-- 每完成一个执行阶段，暂停让用户审查产出，避免错误方向持续执行。 -->

After completing each execution phase (NOT each task — that would be too frequent), pause and present a milestone review.
This gives the user visibility into progress and the ability to course-correct before continuing.

**Checkpoint display format:**

```
═══════════════════════════════════════════════════════
MILESTONE CHECKPOINT — Phase X/Y COMPLETED: <phase name>
═══════════════════════════════════════════════════════

Completed tasks: A/A
Files created: <count>
Files modified: <count>
Errors encountered: <count> (all resolved)

Key deliverables:
- <file 1>: <one-line description>
- <file 2>: <one-line description>
- ...

Remaining: Y-X phases, B tasks
═══════════════════════════════════════════════════════
```

**When to skip checkpoints:**
- If the project has only 1 execution phase: skip the checkpoint (the final verification is sufficient)
- If the user previously selected "Continue" 3 times in a row: ask "Do you want to auto-continue remaining phases?" — if yes, skip future checkpoints

## DeepWiki Integration — API 研究集成

<!-- 通过 DeepWiki 三级研究协议，在编码前和编码中查询 API 最佳实践。 -->

Phase 4 integrates a 3-tier research protocol using DeepWiki to ensure API best practices during coding. The script at `${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh` calls DeepWiki's HTTP MCP endpoint directly — **no MCP configuration or session restart required**.

**Full protocol details:** See [deepwiki-integration.md](deepwiki-integration.md)

### Tier 1: Phase Entry (batch)

Triggered at the start of each execution phase, before any tasks.

1. Extract all libraries/frameworks from the phase plan's task table
2. Map each to `owner/repo` (use task plan's `Dependencies` section if available)
3. Run `bash <script> structure "owner/repo"` for each repo
4. Run `bash <script> ask "owner/repo" "Core APIs and best practices for <lib> relevant to <phase objective>"` for each repo
5. If multiple libs interact: run ONE cross-repo query with `repoName` as JSON array
6. Cache results to `.workflow/deepwiki-cache/phase-N-research.md`

### Tier 2: Task Entry (focused)

Triggered at the start of each task, before executing steps.

1. Identify specific APIs from the task plan's steps
2. Check Tier 1 cache — skip if already covered
3. Run `bash <script> ask "owner/repo" "<specific API question>"` for uncovered APIs
4. For integration tasks: use cross-repo queries
5. Max 5 queries per task

### Tier 3: During Coding (precise)

Triggered during step execution when encountering API uncertainty.

1. Ask precise questions: exact parameters, return types, error behavior
2. Frame questions around the code being written
3. No caching — results feed directly into code

### Script Invocation

**Unix/macOS (bash):**
```bash
# Single repo question
bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask "expressjs/express" "How does error-handling middleware work?"

# Cross-repo question (max 10 repos)
bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask '["expressjs/express","prisma/prisma"]' "How to handle Prisma errors in Express middleware?"

# Documentation structure
bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh structure "expressjs/express"
```

**Windows (PowerShell):**
```powershell
# Single repo question
powershell -File ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.ps1 ask "expressjs/express" "How does error-handling middleware work?"

# Cross-repo question (max 10 repos)
powershell -File ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.ps1 ask '["expressjs/express","prisma/prisma"]' "How to handle Prisma errors in Express middleware?"

# Documentation structure
powershell -File ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.ps1 structure "expressjs/express"
```

### Fallback

If DeepWiki is unavailable (sustained 429 after retries, network error):
1. Use `read_wiki_contents` (not rate-limited) + analyze directly
2. Fall back to web search
3. Fall back to model knowledge with `⚠️ Based on model knowledge` disclaimer

---

## Course Correction — 执行中回退

<!-- 允许用户在执行过程中发现问题时回退修改设计或计划，而非只能中止。 -->

When the user selects "Course correction" at a milestone checkpoint or explicitly requests it:

### Option 1: Modify Plans Only (back to Phase 3)

For issues like: task ordering wrong, missing tasks, task details need adjustment.

1. Mark `execution.status: "paused"` in state.json
2. Log transition to `phase_history`: `exit_reason: "course_correction_planning"`
3. Set `current_phase: "planning"`
4. Ask user which plans need modification
5. Edit the specific plan files in `.workflow/phases/`
6. Re-run Phase 3 consistency verification on modified plans
7. Return to Phase 4, resume from the first modified task
8. Previously completed tasks are NOT re-executed

### Option 2: Rethink Design (back to Phase 2)

For issues like: architecture decision was wrong, tech stack needs changing, fundamental design flaw.

1. Mark `execution.status: "paused"` in state.json
2. Log transition to `phase_history`: `exit_reason: "course_correction_draft"`
3. Set `current_phase: "draft"`
4. Read `.workflow/draft-cache.md` to restore draft context
5. Ask user which sections need revision
6. Re-run brainstorm for affected sections (BS-2/3/4)
7. After draft revision approved: regenerate affected plans (Phase 3)
8. Return to Phase 4, resume from the first affected task
9. Previously completed unaffected tasks are NOT re-executed

### Resuming After Course Correction

When returning to Phase 4 after course correction:

1. Read state.json to find the resume point
2. Identify which tasks are affected by the plan changes:
   - Tasks in modified phases: re-execute from the first modified task
   - Tasks in unmodified phases: keep as completed
3. Re-create task tracking entries for remaining tasks
4. Display resume summary and continue

## Plan Following — 计划遵循

### MUST Rules

- **MUST** execute steps in the order specified in task plans (reorder only if a dependency makes the original order impossible)
- **MUST** create files at the paths specified (adjust only for platform-specific path conventions)
- **MUST** use the code patterns/snippets provided in task plans as the baseline
- **MUST** run verification commands after each task
- **MUST** commit after each task with the pre-written message
- **MUST** update state.json after every task completion

### Professional Judgment Allowed

Plans guide execution, but professional standards apply. You **MAY**:
- Add type annotations and type safety measures
- Add defensive checks (null guards, input validation, error boundaries)
- Use meaningful variable/function names (even if the plan used generic names)
- Apply idiomatic patterns for the chosen language/framework
- Add standard comments and docstrings for public APIs
- Fix obvious bugs in plan-provided code snippets (e.g., missing semicolons, typos)

These are professional standards, not deviations.

### MUST NOT Rules

- **MUST NOT** add features, endpoints, or behaviors not in the plan
- **MUST NOT** skip steps
- **MUST NOT** modify the plan files during execution (use Course Correction instead)
- **MUST NOT** change the architecture or tech stack decisions from the plan

### Exception

If a step is genuinely impossible to execute as written (e.g., API changed, dependency unavailable), enter error recovery instead of improvising.

## 3-Strike Error Recovery — 三振出局机制

When a step fails or verification does not pass:

### Strike 1: Analyze and Fix — 分析修复
1. Analyze the error message
2. Identify root cause
3. Apply a targeted fix that stays within the plan's intent
4. Re-run the failed step
5. Log to `execution.error_log`: phase, task, strike=1, error, resolution

### Strike 2: Alternative Approach — 替代方案
1. The targeted fix didn't work
2. Research the issue (web search if needed)
3. Try an alternative approach that achieves the same goal
4. The alternative must still align with the plan's objective
5. Log to error_log: strike=2

### Strike 3: Investigate Assumptions — 质疑假设
1. Two attempts have failed
2. Question whether the plan's assumptions are correct
3. Check if dependencies, versions, or APIs have changed
4. Attempt one more fix based on updated understanding
5. Log to error_log: strike=3

### After 3 Strikes: Stop and Ask User — 停下来问用户

If all 3 strikes fail:

1. **STOP execution immediately**
2. Present failure summary to user:
   - Which phase/task/step failed
   - All 3 attempted resolutions (one sentence each)
   - Root cause hypothesis
3. Offer options to the user:
   - **(A) Run BS-7 deep analysis** — AI runs a full 7-step brainstorm to find a fix (takes longer but produces high-quality options)
   - **(B) Provide your own fix** — user provides guidance directly
   - **(C) Skip this task and continue** — mark task as error, move to next task
   - **(D) Abort execution entirely** — stop all execution
   - **(E) Run Bug Fixer deep review** — invoke `bug-fixer` for systematic 7-dimension code review that may discover root causes beyond the immediate error (see [Bug Fixer](../bug-fixer/SKILL.md))
4. Wait for user input before continuing
5. Reset strike counter for next issue

<!-- 先通知用户失败详情，再让用户决定是否需要 AI 深度排查。避免用户等待不必要的长时间 brainstorm。 -->

### Option A: BS-7 Deep Analysis — 深度排查

<STOP-GATE id="BS-7">

**User has requested deep analysis. Execute BS-7 (Full Mode — 7 steps) NOW.**

Read [brainstorm-protocol.md](brainstorm-protocol.md) and execute ALL steps below.

**Inline execution checklist:**

1. **Step 1 — Forced Research:** Run at least 2 web searches about the specific error type and technology involved. Output the `🔍 Research Findings` block. **If a search returns 0 results:** retry with broader keywords; if still 0, label output as `⚠️ AI Inference (search unavailable)` — do NOT present model knowledge as search findings.
2. **Step 2 — Independent Agents:** Launch 3 parallel Agents to propose genuinely different fix approaches (not variations of the same fix). Each agent gets the full error context (phase, task, step, all 3 strike attempts, error messages). Output the `🏗️ Independent Proposals Generated` block.
3. **Step 3 — Quality Gate:** Run the divergence check on the 3 proposals. Output the `🔬 Divergence Check` block. If FAIL, regenerate (max 5 rounds).
4. **Step 4 — Multi-Perspective:** Evaluate from Developer + Architect + Ops perspectives: "Why did this fail? Will this fix introduce new problems?" Output the `🧠 Multi-Perspective Evaluation` block.
5. **Step 5 — Self-Interrogation:** Select the safest fix with highest success likelihood. Raise 3 sharp challenges. Output the `💭 Self-Interrogation` block.
6. **Step 6 — Independent Audit:** Launch audit Agent, verify quality scores. Output the `🔍 Independent Audit` block. If FAIL, redo Steps 2-5 (max 5 rounds).
7. **Step 7 — Synthesis:** Output the `✅ Decision` block with recommended fix and confidence level.

**SELF-CHECK before applying fix:**
- [ ] Research Findings block shown to user? If NO → STOP, go back to Step 1
- [ ] Independent Proposals block shown to user? If NO → STOP, go back to Step 2
- [ ] Divergence Check block shown to user? If NO → STOP, go back to Step 3
- [ ] Multi-Perspective Evaluation block shown to user? If NO → STOP, go back to Step 4
- [ ] Self-Interrogation block shown to user? If NO → STOP, go back to Step 5
- [ ] Audit block shown to user? If NO → STOP, go back to Step 6
- [ ] Decision block shown to user? If NO → STOP, go back to Step 7

**After ALL checks pass:** persist results to `.workflow/brainstorm/bs-7-<N>.md` (N = occurrence count), update `brainstorm.bs7_count` in state.json, THEN apply the recommended fix and continue execution.

</STOP-GATE>

### Option B: User-Provided Fix — 用户自行修复

1. Receive user's guidance
2. Apply the fix as described
3. Re-run the failed step verification
4. If passes: continue execution, reset strike counter
5. If fails: report back to user, re-offer options (A)/(C)/(D)

### Option C: Skip Task — 跳过任务

1. Mark task as `"error"` in state.json with reason
2. Log to `execution.error_log`: phase, task, all 3 strikes, resolution="skipped"
3. Continue to next task
4. Output warning: `⚠️ Task skipped due to unresolved error. Downstream tasks may be affected.`

### Option D: Abort — 中止执行

1. Mark execution as `"aborted"` in state.json
2. Log abort reason in `phase_history`
3. Output final status: completed tasks, skipped tasks, abort point
4. Inform user they can resume later with `/workflow-architect`

### Option E: Bug Fixer Deep Review — Bug 审查

<!-- 调用 Bug Fixer 外挂技能进行系统化 7 维度代码审查。 -->

1. Invoke `bug-fixer` in Integrated Mode
2. Bug Fixer reads state.json, error_log, and current task context
3. Bug Fixer performs 7-dimension review on the failing task's files and related code
4. If Bug Fixer identifies and fixes the root cause: reset strike counter, resume execution
5. If Bug Fixer cannot resolve: return to this menu, re-offer options (A)/(B)/(C)/(D)

**Difference from BS-7:** BS-7 is a focused brainstorm on the specific error using the 7-step protocol (alternative approaches, multi-perspective evaluation). Bug Fixer is a broader systematic code audit that may discover issues beyond the immediate error (security vulnerabilities, logic errors, performance issues, etc.). They complement each other.

## Mid-Execution Change Request — 执行中变更请求

<!-- 当用户在执行期间发送变更请求时的处理协议。 -->

During Phase 4 execution, users may interrupt with change requests — new requirements, feature modifications, or scope changes. These are handled by the `issue-changer` add-on skill.

### Detection

Change requests can be detected in two ways:

1. **Explicit invocation:** User invokes `issue-changer` with a description
2. **Auto-detection:** User sends a message with change intent during execution (e.g., "I want to add...", "Can we change...", "我想改一下...")

### Routing

When a change request is detected during execution:

1. **Complete the current in-progress step** — never interrupt mid-step
2. **Pause execution:** `execution.status: "paused"`
3. **Hand off to Issue Changer:** The Issue Changer skill takes over with Mode A (mid-workflow protocol)
4. **After Issue Changer completes:** Resume execution per Issue Changer's resume protocol

### Distinction from Course Correction

| | Course Correction | Issue Changer |
|---|---|---|
| **Changes** | HOW to build (task order, splitting, implementation details) | WHAT to build (new features, requirements, scope) |
| **Trigger** | Milestone checkpoint option (C) | User message or explicit invocation |
| **Scope** | Within existing plan scope | Outside existing plan scope |
| **Example** | "Move DB setup before API task" | "Add a notification system" |

See [Issue Changer](../issue-changer/SKILL.md) for full protocol details.

## Progress Tracking — 进度追踪

### State File Updates

After each task completion, update state.json:

```json
{
  "execution": {
    "current_phase_index": <current>,
    "current_task_index": <current>,
    "phases": {
      "<N>": {
        "completed_tasks": <count>,
        "status": "in_progress",
        "tasks": {
          "<T>": {
            "status": "completed",
            "completed_at": "<timestamp>"
          }
        }
      }
    }
  }
}
```

### Progress Output Format — 进度输出格式

After each task:
```
[Phase X/Y] [Task A/B] ✅ Completed: <task name>
Overall Progress: C/D tasks (E%)
```

After each phase:
```
═══════════════════════════════════
Phase X/Y COMPLETED: <phase name>
Tasks: A/A completed
═══════════════════════════════════
```

### Task Entry Integration

- Create one task entry per Level 3 task at execution start
- Use format: `[P<N>-T<NN>] <task name>`
- Update to `in_progress` when starting each task
- Update to `completed` when task passes verification

## Session Resume — 会话恢复

If execution is interrupted and the skill is re-invoked:

1. Read state.json
2. Find the last completed task:
   - Scan `execution.phases` for the first task with `status != "completed"`
3. Display resume summary:
   ```
   Resuming execution...
   Last completed: Phase X, Task Y — <name>
   Next up: Phase X, Task Y+1 — <name>
   Overall: C/D tasks (E%)
   ```
4. Ask user: "Continue execution?" (继续执行？)
5. On yes: continue from next pending task
6. On no: present options (pause, abort, modify plan)

## Commit Protocol — 提交协议

After each task completes verification:

1. Stage all files created/modified by the task
2. Commit with the message from the task plan:
   ```
   <type>: <description> (Phase <N>, Task <NN>)
   ```
3. Common commit types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`

If the project directory is not a git repository:
1. Ask user if they want to initialize git
2. If yes: `git init`, create `.gitignore` as first commit
3. If no: skip all commits (but log a warning)

## Completion Protocol — 完成协议

When all phases and tasks are completed:

1. Run final verification:
   - Check all success criteria from Level 1 plan
   - Run full test suite if applicable
   - Verify project structure matches plan

2. Generate completion report (output in chat):
   ```
   ══════════════════════════════════════
   PROJECT EXECUTION COMPLETE
   ══════════════════════════════════════

   Project: <name>
   Phases Completed: X/X
   Tasks Completed: Y/Y
   Errors Encountered: Z (all resolved)

   Execution Timeline:
   - Started: <timestamp>
   - Completed: <timestamp>

   Deliverables:
   - <list of key files/features created>

   Next Steps:
   - <suggested follow-up actions>
   ══════════════════════════════════════
   ```

3. Update state.json:
   - `current_phase: "completed"`
   - `execution.status: "completed"`

4. Log final transition in `phase_history`

## Loop Detection — 循环检测

To prevent infinite loops during execution:

- **Same error 3 times:** trigger 3-Strike immediately (don't retry same fix)
- **Same file edited 5+ times in one task:** pause and ask user
- **No progress in 10 consecutive operations:** pause and ask user
- **Task taking more than 50 tool calls:** pause and assess

When loop detected:
1. STOP
2. Report the pattern detected
3. Ask user for guidance

## Large Project Context Management — 超大项目上下文管理

<!-- 当项目规模达到 10+ phases / 50+ tasks 时，单次会话无法容纳所有计划和执行上下文。
     本节定义分段执行策略，确保上下文窗口不会溢出。 -->

For projects with **10+ execution phases** or **50+ tasks**, a single session cannot hold all plan details and execution context simultaneously. Apply the following strategies:

### Strategy 1: Lazy Plan Loading — 延迟加载计划

Do NOT read all Level 2/Level 3 plans at execution start. Instead:

1. **At execution entry:** Only read `project-plan.md` (Level 1) for the overall structure
2. **At phase entry:** Read that phase's `phase-plan.md` (Level 2) — discard previous phase's plan from working memory
3. **At task entry:** Read that task's `task-NN-*.md` (Level 3) — discard previous task's plan after it's completed
4. **Never hold more than:** Level 1 + current Level 2 + current Level 3 in active context

### Strategy 2: Completed Phase Summarization — 已完成阶段摘要

After completing a phase, generate a compact summary (5-10 lines) instead of retaining the full plan:

```
Phase N Summary:
- Tasks completed: X/X
- Key files created: [list]
- Key decisions made: [list]
- Errors resolved: [count]
- Artifacts available: .workflow/phases/phase-N/
```

This summary replaces the full phase context for downstream reference.

### Strategy 3: Session Segmentation — 会话分段

When context pressure is detected (conversation getting very long):

1. **Complete the current task** — never break mid-task
2. **Commit all work** and update state.json
3. **Inform the user:** "Context window is reaching capacity. Recommend starting a new session to continue. All progress is saved in state.json."
4. The next session will resume cleanly via the Session Resume protocol

### Strategy 4: Task Entry Batching — 任务条目分批创建

For 50+ tasks, do NOT create all task entries upfront:

1. Create entries only for the **current phase's tasks** at phase entry
2. Mark completed tasks as done
3. At next phase entry: create that phase's task entries
4. Show overall progress as: `Overall: C/D tasks (E%) — current phase: Phase N`

### Thresholds — 阈值

| Metric | Threshold | Action |
|--------|-----------|--------|
| Total tasks | > 50 | Enable Strategy 4 (batched task entries) |
| Phases | > 8 | Enable Strategy 1 (lazy loading) |
| Tasks in single phase | > 15 | Consider splitting phase in Phase 3 |
| Consecutive sessions | > 5 | Verify state.json integrity at resume |
