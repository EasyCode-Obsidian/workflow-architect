# State Management Reference

> This document defines the JSON schema for workflow state, state transition rules, and persistence strategy.
> All phase implementations depend on the state structure defined here.

<!-- 本文档定义工作流状态的 JSON schema、状态转换规则和持久化策略。 -->

---

## State File Location

```
<project-root>/.workflow/state.json
```

The state file is created when Phase 1 begins and persists throughout the entire workflow lifecycle.

## JSON Schema

```json
{
  "version": "1.0",
  "project_name": "string",
  "created_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "current_phase": "requirements | draft | planning | execution | completed",

  "phase_history": [
    {
      "phase": "string",
      "entered_at": "ISO-8601",
      "exited_at": "ISO-8601",
      "exit_reason": "approved | rejected_to_requirements | course_correction_planning | course_correction_draft"
    }
  ],

  "requirements": {
    "status": "in_progress | completed",
    "coverage_map": {
      "project_vision":       "clear | partial | missing",
      "functional_scope":     "clear | partial | missing",
      "user_personas":        "clear | partial | missing",
      "domain_data_model":    "clear | partial | missing",
      "tech_stack":           "clear | partial | missing",
      "integration":          "clear | partial | missing",
      "non_functional":       "clear | partial | missing",
      "ux_design":            "clear | partial | missing",
      "dev_constraints":      "clear | partial | missing",
      "edge_cases_risk":      "clear | partial | missing"
    },
    "questions_asked": 0,
    "answers": [
      {
        "category": "string",
        "question": "string",
        "answer": "string",
        "timestamp": "ISO-8601"
      }
    ]
  },

  "draft": {
    "status": "pending | in_progress | approved | rejected",
    "revision_count": 0,
    "approved_at": "ISO-8601 | null",
    "completed_sections": [],
    "cache_file": ".workflow/draft-cache.md | null"
  },

  "brainstorm": {
    "bs1": { "status": "pending | completed | skipped", "completed_at": "ISO-8601 | null", "artifact": ".workflow/brainstorm/bs-1.md | null" },
    "bs2": { "status": "pending | completed | skipped", "completed_at": "ISO-8601 | null", "audit_score": "null | number", "artifact": ".workflow/brainstorm/bs-2.md | null" },
    "bs3": { "status": "pending | completed | skipped", "completed_at": "ISO-8601 | null", "audit_score": "null | number", "artifact": ".workflow/brainstorm/bs-3.md | null" },
    "bs4": { "status": "pending | completed | skipped", "completed_at": "ISO-8601 | null", "audit_score": "null | number", "artifact": ".workflow/brainstorm/bs-4.md | null" },
    "bs5": { "status": "pending | completed | skipped", "completed_at": "ISO-8601 | null", "artifact": ".workflow/brainstorm/bs-5.md | null" },
    "bs6": { "status": "pending | completed | skipped", "completed_at": "ISO-8601 | null", "artifact": ".workflow/brainstorm/bs-6.md | null" },
    "bs7_count": 0
  },

  "planning": {
    "status": "pending | in_progress | completed | rejected",
    "total_phases": 0,
    "total_tasks": 0,
    "plans_written": {
      "level_1": false,
      "level_2_count": 0,
      "level_3_count": 0
    }
  },

  "execution": {
    "status": "pending | in_progress | completed | paused | aborted | error",
    "current_phase_index": 0,
    "current_task_index": 0,
    "total_phases": 0,
    "phases": {
      "1": {
        "name": "string",
        "total_tasks": 0,
        "completed_tasks": 0,
        "status": "pending | in_progress | completed",
        "tasks": {
          "1": {
            "name": "string",
            "status": "pending | in_progress | completed | error",
            "started_at": null,
            "completed_at": null
          }
        }
      }
    },
    "deepwiki_cache": {
      "phases_researched": [],
      "cache_dir": ".workflow/deepwiki-cache/"
    },
    "error_log": [
      {
        "phase": 1,
        "task": 2,
        "strike": 1,
        "error": "string",
        "resolution": "string",
        "timestamp": "ISO-8601"
      }
    ]
  },

  "bug_fixer": {
    "reviews": [
      {
        "id": 1,
        "trigger": "standalone | 3-strike | milestone | user-request",
        "target": "string — file path, directory, or description",
        "started_at": "ISO-8601",
        "completed_at": "ISO-8601 | null",
        "findings_count": 0,
        "fixed_count": 0,
        "skipped_count": 0,
        "report_file": ".workflow/bug-fixer/review-N.md | null"
      }
    ]
  },

  "change_requests": [
    {
      "id": 1,
      "mode": "mid-workflow | post-completion",
      "description": "string",
      "requested_at": "ISO-8601",
      "status": "analyzing | approved | in_progress | completed | rejected",
      "impact": {
        "severity": "light | moderate | major",
        "affected_phases": [],
        "affected_tasks": [],
        "affected_files": [],
        "new_tasks_count": 0
      },
      "resolution": {
        "approach": "modify-tasks | modify-plans | rethink-design",
        "plan_dir": ".workflow/changes/change-N/ | null",
        "completed_at": "ISO-8601 | null"
      }
    }
  ]
}
```

## State Transition Diagram

```
                 +---- reject ----+
                 v                 |
  INIT --> REQUIREMENTS -----> DRAFT
                 ^              |
                 |           approve
                 |              v
                 +-- reject -- PLANNING --> EXECUTION --> COMPLETED
```

### Transition Rules

| From           | To             | Condition                                        |
|----------------|----------------|--------------------------------------------------|
| (init)         | requirements   | Skill invoked; state.json created                |
| requirements   | draft          | Coverage sufficient + user confirms               |
| draft          | planning       | User approves draft                               |
| draft          | requirements   | User rejects draft                                |
| planning       | execution      | All L1/L2/L3 plans written + user approves        |
| planning       | requirements   | User rejects plans                                |
| execution      | completed      | All tasks completed + final verification passes   |
| execution      | execution      | Session resume — continue from last checkpoint    |
| execution      | planning       | User requests course correction (modify plans)    |
| execution      | draft          | User requests architecture rethink (modify design)|

## Persistence Rules

1. **When to write state.json:**
   - On Phase 1 start (initialize)
   - After each answered question (update coverage_map + answers)
   - On every phase transition
   - **After each brainstorm completion** (update brainstorm.bsN.status + completed_at + audit_score)
   - After each task completion in Phase 4
   - On error (log to error_log)

2. **Atomic writes:** Always write the complete state.json (never partial updates).

3. **Timestamp format:** ISO-8601 with timezone, e.g., `2026-03-31T14:30:00+08:00`.

## Session Resume Protocol

When the skill is invoked and `.workflow/state.json` already exists:

1. Read state.json
2. Display progress summary:
   - Current phase
   - If in execution: completed tasks / total tasks with percentage
   - Last activity timestamp
3. Ask user: **Resume** (continue from current state) or **Restart** (begin from Phase 1, archive old state)
4. On resume: enter the current phase and continue from where it left off
5. On restart: rename `.workflow/` to `.workflow.bak.<timestamp>/`, create fresh `.workflow/state.json`

## Rejection Back-Flow

When user rejects in Phase 2 (Draft) or Phase 3 (Planning):

1. Log rejection in phase_history with `exit_reason: "rejected_to_requirements"`
2. Set `current_phase` to `"requirements"`
3. **Preserve** all existing answers in `requirements.answers`
4. Reset coverage_map categories that need revision (based on user feedback)
5. Increment `draft.revision_count` or reset `planning.status`
6. Return to Phase 1 questioning loop, starting from the gaps

## Error Recovery

If state.json is corrupted or missing mid-workflow:

1. Check for `.workflow.bak.*` directories (archived by restart)
2. If backup exists: restore from latest backup's `state.json`
3. If no backup but plan files exist: reconstruct state from plan file structure
4. If nothing recoverable: inform user and offer to restart

## Brainstorm Artifact Persistence — 头脑风暴产物持久化

Brainstorm intermediate results are persisted to disk for traceability and context pressure relief.

<!-- 头脑风暴中间结果写入磁盘，用于可追溯性和减轻上下文压力。 -->

### Directory Structure

```
.workflow/
├── brainstorm/
│   ├── bs-1.md        # Requirements completeness check results
│   ├── bs-2.md        # Architecture brainstorm results
│   ├── bs-3.md        # Tech stack brainstorm results
│   ├── bs-4.md        # Algorithm/design brainstorm results
│   ├── bs-5.md        # Draft integrity check results
│   ├── bs-6.md        # Task decomposition review results
│   └── bs-7-N.md      # Error recovery brainstorm (N = occurrence count)
```

### File Format

Each brainstorm artifact file contains the complete output from all executed steps:

```markdown
# Brainstorm BS-N: <topic>
Date: <ISO-8601>
Mode: Full (7 steps) | Reduced (3 steps)

## Step 1: Research Findings
<research output>

## Step 2: Independent Proposals (Full mode only)
<proposals output>

## Step 3: Quality Gate (Full mode only)
<divergence check output>

## Step 4: Multi-Perspective Evaluation
<evaluation output>

## Step 5: Self-Interrogation
<self-interrogation output>

## Step 6: Independent Audit (Full mode only)
<audit scores and notes>

## Step 7: Synthesis / Decision
<final decision with confidence>
```

### Persistence Rules

1. Create `.workflow/brainstorm/` directory when the first brainstorm is triggered
2. Write the artifact file **after** all steps complete (not incrementally)
3. Update `brainstorm.bsN.status` and `brainstorm.bsN.artifact` in state.json
4. On session resume: read existing brainstorm artifacts to restore context
5. BS-7 files use incrementing suffix: `bs-7-1.md`, `bs-7-2.md`, etc.

## Draft Cache Persistence — 草案缓存持久化

Phase 2 draft content is cached to disk for session resilience, even though it is NOT a deliverable.

<!-- 草案内容缓存到磁盘以支持会话恢复，但它不是交付物。 -->

### Purpose

The draft lives primarily in the conversation, but sessions can be interrupted mid-Phase 2.
Without a cache, all draft content (up to 4 brainstorms worth of decisions) would be lost.
The cache file allows resuming Phase 2 from the last completed section.

### Cache File Location

```
.workflow/draft-cache.md
```

### Cache File Format

```markdown
# Draft Cache — Session Resume Artifact
# WARNING: This is a session-resume cache, NOT the final draft.
# It is auto-generated and should not be manually edited.
# Generated: <ISO-8601>

## Section 1: Project Overview
<section content>

## Section 2: Architecture Design
<section content>
BS-2 Decision: <summary>

## Section 3: Tech Stack Selection
<section content>
BS-3 Decision: <summary>

## Section 4: Algorithm & Design Strategy
<section content>
BS-4 Decision: <summary>

## Section 5: Project Structure
<section content>

## Section 6: Implementation Phases
<section content>

## Section 7: Risk Assessment
<section content>

## Section 8: Complexity Estimate
<section content>
```

### Persistence Rules

1. Create `.workflow/draft-cache.md` when Phase 2 begins
2. **Append each section** to the cache as it is completed (not all at once at the end)
3. Update `draft.completed_sections` array in state.json (e.g., `[1, 2, 3]`)
4. Update `draft.cache_file` in state.json
5. On session resume in Phase 2: read `draft-cache.md` to restore completed sections, skip to next incomplete section
6. On Phase 2 approval (transition to Phase 3): keep the cache file for Phase 3 reference
7. On Phase 2 rejection (return to Phase 1): delete the cache file and reset `draft.completed_sections`
8. The cache is a **resume artifact** — the conversation remains the primary presentation medium

## Bug Fixer State — Bug 修复状态

<!-- Bug Fixer 外挂技能在执行审查时更新此字段。 -->

### Field: `bug_fixer`

Added by the `workflow-architect-bug-fixer` add-on skill. Initialized on first Bug Fixer invocation (not at state.json creation).

**Persistence rules:**
1. Create `bug_fixer` field on first Bug Fixer invocation if it does not exist
2. Append a new review entry when a review session starts
3. Update `findings_count`, `fixed_count`, `skipped_count` as findings are processed
4. Set `completed_at` and `report_file` when the review session finishes
5. Review reports are persisted to `.workflow/bug-fixer/review-N.md` (N = review id)

**Directory structure:**
```
.workflow/
├── bug-fixer/
│   ├── review-1.md        # Review session report
│   ├── review-2.md
│   └── ...
```

### Backward Compatibility

A state.json from version `"1.0"` (without `bug_fixer` field) remains valid. The Bug Fixer skill initializes the field on first use.

## Change Request State — 变更请求状态

<!-- Issue Changer 外挂技能在处理变更请求时更新此字段。 -->

### Field: `change_requests`

Added by the `workflow-architect-issue-changer` add-on skill. Initialized on first Issue Changer invocation (not at state.json creation).

**Persistence rules:**
1. Create `change_requests` array on first Issue Changer invocation if it does not exist
2. Append a new entry when a change request is received
3. Update `status` through the lifecycle: `analyzing` → `approved` → `in_progress` → `completed`
4. Update `impact` fields after impact analysis completes
5. Update `resolution` fields when the approach is determined and executed
6. For Mode B (post-completion): set `resolution.plan_dir` to `.workflow/changes/change-N/`

**Directory structure:**
```
.workflow/
├── changes/
│   ├── change-1/
│   │   ├── change-plan.md           # Change-specific execution plan
│   │   └── tasks/
│   │       ├── task-01-<name>.md
│   │       └── ...
│   ├── change-2/
│   │   └── ...
│   └── ...
```

**Severity classification:**
| Severity | Criteria | Action |
|----------|----------|--------|
| light | Only affects current/future tasks, no new tasks needed | Modify Level 3 task plans in place |
| moderate | Requires new tasks or phase plan modifications | Return to Phase 3 for plan updates |
| major | Involves architecture changes or fundamental design shifts | Return to Phase 2 for redesign |

### Backward Compatibility

A state.json from version `"1.0"` (without `change_requests` field) remains valid. The Issue Changer skill initializes the field on first use.
