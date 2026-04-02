# State Management Reference

> This document defines the JSON schema for project-surgeon state, state transition rules, and persistence strategy.
> All phase implementations depend on the state structure defined here.

<!-- 本文档定义 project-surgeon 状态的 JSON schema、状态转换规则和持久化策略。 -->

---

## State File Location

```
<project-root>/.project-surgeon/state.json
```

The state file is created when Phase 1 (Analysis) begins and persists throughout the entire workflow lifecycle.

## JSON Schema

```json
{
  "version": "1.0",
  "skill": "project-surgeon",
  "project_name": "string",
  "project_path": "/absolute/path/to/target/project",
  "created_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "current_phase": "analysis | review | planning | execution | completed",

  "phase_history": [
    {
      "phase": "string",
      "entered_at": "ISO-8601",
      "exited_at": "ISO-8601",
      "exit_reason": "approved | rejected_to_analysis | course_correction_planning | course_correction_review"
    }
  ],

  "analysis": {
    "status": "pending | in_progress | completed",
    "started_at": null,
    "completed_at": null,
    "steps_completed": [],
    "project_fingerprint": {
      "root_path": "",
      "tech_stack": [],
      "total_files": 0,
      "total_loc": 0,
      "file_breakdown": {},
      "has_tests": false,
      "test_framework": null,
      "has_ci": false,
      "has_docker": false
    },
    "architecture_analysis": {
      "pattern": null,
      "entry_points": [],
      "key_abstractions": [],
      "module_count": 0
    },
    "dependency_health": {
      "total_dependencies": 0,
      "audit_results": {
        "critical": 0,
        "high": 0,
        "moderate": 0,
        "low": 0
      },
      "outdated_major": 0,
      "potentially_unused": 0
    },
    "documentation_inventory": {
      "files": [],
      "config_approach": null,
      "has_docker": false,
      "has_iac": false,
      "ci_platform": null
    },
    "report_file": ".project-surgeon/analysis-report.md",
    "user_objective": {
      "type": null,
      "description": "",
      "confirmed_at": null
    }
  },

  "review": {
    "status": "pending | in_progress | completed",
    "started_at": null,
    "completed_at": null,
    "scope": null,
    "dimensions_completed": [],
    "findings": {
      "total": 0,
      "by_severity": {
        "critical": 0,
        "high": 0,
        "medium": 0,
        "low": 0,
        "info": 0
      },
      "by_dimension": {
        "D1": 0,
        "D2": 0,
        "D3": 0,
        "D4": 0,
        "D5": 0,
        "D6": 0,
        "D7": 0
      }
    },
    "hot_spots": [],
    "systemic_issues": [],
    "report_file": ".project-surgeon/review-report.md",
    "user_priorities": {
      "mode": null,
      "selected_findings": [],
      "confirmed_at": null
    }
  },

  "brainstorm": {
    "bs1": { "status": "pending | completed | skipped", "completed_at": null, "artifact": null },
    "bs2": { "status": "pending | completed | skipped", "completed_at": null, "audit_score": null, "artifact": null },
    "bs3": { "status": "pending | completed | skipped", "completed_at": null, "artifact": null },
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
    "test_baseline": {
      "has_tests": false,
      "total_tests": 0,
      "passing": 0,
      "failing": 0,
      "failing_test_ids": [],
      "captured_at": null
    },
    "deepwiki_cache": {
      "phases_researched": [],
      "cache_dir": ".project-surgeon/deepwiki-cache/"
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
        "completed_at": null,
        "findings_count": 0,
        "fixed_count": 0,
        "skipped_count": 0,
        "report_file": null
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
        "approach": "modify-tasks | modify-plans | rethink-review",
        "plan_dir": null,
        "completed_at": null
      }
    }
  ]
}
```

## Field Reference — 字段详解

### Top-Level Fields — 顶层字段

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Schema version. Currently `"1.0"`. Used for backward compatibility checks. |
| `skill` | string | Fixed value `"project-surgeon"`. Identifies which skill created this state file, distinguishing it from workflow-architect's `.project-surgeon/state.json`. |
| `project_name` | string | Name of the target project being analyzed/refactored. |
| `project_path` | string | **Absolute path** to the target project's root directory. This is critical because `.project-surgeon/` may be created inside the target project or in a separate workspace. |
| `created_at` | ISO-8601 | Timestamp when the state file was first created (Phase 1 start). |
| `updated_at` | ISO-8601 | Timestamp of the most recent state update. Updated on every write. |
| `current_phase` | enum | Current workflow phase. One of: `"analysis"`, `"review"`, `"planning"`, `"execution"`, `"completed"`. |

### phase_history — 阶段历史

An ordered array of phase transitions. Each entry records when a phase was entered, exited, and why.

| Field | Type | Description |
|-------|------|-------------|
| `phase` | string | Phase name that was entered. |
| `entered_at` | ISO-8601 | When the phase was entered. |
| `exited_at` | ISO-8601 | When the phase was exited. `null` if phase is current. |
| `exit_reason` | enum | Why the phase was exited: `"approved"` (normal progression), `"rejected_to_analysis"` (user rejected, restart from analysis), `"course_correction_planning"` (execution → planning), `"course_correction_review"` (execution → review). |

### analysis — 分析阶段 (replaces workflow-architect's `requirements`)

This block captures the results of Phase 1: project discovery and analysis. Unlike workflow-architect (which collects requirements via Q&A), project-surgeon analyzes an existing codebase.

| Field | Type | Description |
|-------|------|-------------|
| `status` | enum | `"pending"` (not started), `"in_progress"`, `"completed"`. |
| `started_at` | ISO-8601 | When analysis began. |
| `completed_at` | ISO-8601 | When analysis finished. |
| `steps_completed` | string[] | Which analysis steps have been completed. Possible values: `"discovery"`, `"architecture"`, `"dependencies"`, `"documentation"`, `"report"`. |

#### analysis.project_fingerprint — 项目指纹

A snapshot of the project's structure and technology at the time of analysis.

| Field | Type | Description |
|-------|------|-------------|
| `root_path` | string | Absolute path to the project root (same as top-level `project_path`). |
| `tech_stack` | string[] | Detected technologies, e.g., `["Node.js", "TypeScript", "React", "Express"]`. |
| `total_files` | number | Total number of source files (excluding `node_modules`, `.git`, etc.). |
| `total_loc` | number | Total lines of code (approximate). |
| `file_breakdown` | object | File count by extension, e.g., `{".ts": 150, ".tsx": 80, ".json": 20}`. |
| `has_tests` | boolean | Whether a test suite was detected. |
| `test_framework` | string\|null | Detected test framework, e.g., `"jest"`, `"pytest"`, `"go test"`. |
| `has_ci` | boolean | Whether CI/CD configuration was detected. |
| `has_docker` | boolean | Whether Docker configuration was detected. |

#### analysis.architecture_analysis — 架构分析

| Field | Type | Description |
|-------|------|-------------|
| `pattern` | enum\|null | Detected architecture pattern. One of: `"MVC"`, `"Clean"`, `"Monorepo"`, `"Microservices"`, `"Flat"`, `"Unknown"`, or `null` (not yet analyzed). |
| `entry_points` | string[] | Main entry point files, e.g., `["src/index.ts", "src/server.ts"]`. |
| `key_abstractions` | string[] | Core abstractions/modules identified, e.g., `["UserService", "AuthMiddleware", "DatabaseClient"]`. |
| `module_count` | number | Number of logical modules/packages detected. |

#### analysis.dependency_health — 依赖健康

| Field | Type | Description |
|-------|------|-------------|
| `total_dependencies` | number | Total number of direct dependencies. |
| `audit_results` | object | Vulnerability counts by severity: `{critical, high, moderate, low}`. |
| `outdated_major` | number | Number of dependencies with major version updates available. |
| `potentially_unused` | number | Number of dependencies that appear unused in the codebase. |

#### analysis.documentation_inventory — 文档清单

| Field | Type | Description |
|-------|------|-------------|
| `files` | object[] | Array of `{path, last_modified, type}` for each documentation file found. `type` can be `"readme"`, `"api"`, `"guide"`, `"changelog"`, `"license"`, `"other"`. |
| `config_approach` | string\|null | How configuration is managed, e.g., `"env-files"`, `"config-module"`, `"hardcoded"`. |
| `has_docker` | boolean | Whether Docker/Compose files exist. |
| `has_iac` | boolean | Whether Infrastructure-as-Code files exist (Terraform, CloudFormation, etc.). |
| `ci_platform` | string\|null | Detected CI platform, e.g., `"github-actions"`, `"gitlab-ci"`, `"jenkins"`. |

#### analysis.user_objective — 用户目标

| Field | Type | Description |
|-------|------|-------------|
| `type` | enum\|null | User's stated goal. One of: `"comprehensive"` (full audit + fix), `"fix"` (fix known issues), `"features"` (add features to existing project), `"modernize"` (update deps + patterns), `"custom"` (user-defined scope). |
| `description` | string | Free-text description of what the user wants to achieve. |
| `confirmed_at` | ISO-8601\|null | When the user confirmed the objective. |

### review — 审查阶段 (replaces workflow-architect's `draft`)

This block captures the results of Phase 2: systematic code review across multiple dimensions.

| Field | Type | Description |
|-------|------|-------------|
| `status` | enum | `"pending"`, `"in_progress"`, `"completed"`. |
| `started_at` | ISO-8601 | When review began. |
| `completed_at` | ISO-8601 | When review finished. |
| `scope` | enum\|null | Review scope. `"full"` (all dimensions), `"incremental"` (only changed areas), `"targeted"` (user-specified focus). |
| `dimensions_completed` | string[] | Which review dimensions are done, e.g., `["D1", "D2", "D3"]`. |

#### review.findings — 审查发现

| Field | Type | Description |
|-------|------|-------------|
| `total` | number | Total number of findings across all dimensions. |
| `by_severity` | object | Counts by severity: `{critical, high, medium, low, info}`. |
| `by_dimension` | object | Counts by dimension: `{D1, D2, D3, D4, D5, D6, D7}`. Dimensions correspond to the 7 review dimensions (e.g., D1=Code Quality, D2=Architecture, D3=Security, etc.). |

#### review.hot_spots — 热点文件

Array of `{file, finding_count}` objects representing the top 10 files with the most findings. Helps prioritize refactoring efforts.

#### review.systemic_issues — 系统性问题

Array of `{pattern, affected_files_count, finding_ids}` objects representing recurring patterns found across multiple files (e.g., "missing error handling", "inconsistent naming", "no input validation").

#### review.user_priorities — 用户优先级

| Field | Type | Description |
|-------|------|-------------|
| `mode` | enum\|null | How findings were prioritized. `"critical_high"` (auto-select critical+high), `"all"` (address everything), `"selected"` (user picks specific findings), `"custom"` (user-defined criteria). |
| `selected_findings` | string[] | Array of Finding IDs (e.g., `["D1-03", "D3-12", "D5-01"]`) that the user has approved for planning. |
| `confirmed_at` | ISO-8601\|null | When the user confirmed priorities. |

### brainstorm — 头脑风暴

Project-surgeon uses only 4 brainstorm trigger points (compared to workflow-architect's 7):

| Trigger | Phase | Purpose | Mode |
|---------|-------|---------|------|
| `bs1` | Analysis | Validate analysis completeness before moving to review | Reduced (3 steps) |
| `bs2` | Review | Validate review methodology and finding quality | Full (7 steps) |
| `bs3` | Planning | Task decomposition review (between Level 2 and Level 3 plans) | Reduced (3 steps) |
| `bs7_count` | Execution | Error recovery deep analysis (on-demand, repeatable) | Full (7 steps) |

**Note:** There are no bs4, bs5, or bs6 triggers. The numbering preserves bs7 for consistency with workflow-architect's error recovery brainstorm.

Each brainstorm entry follows this structure:

| Field | Type | Description |
|-------|------|-------------|
| `status` | enum | `"pending"`, `"completed"`, `"skipped"`. |
| `completed_at` | ISO-8601\|null | When the brainstorm finished. |
| `audit_score` | number\|null | Quality audit score (Full mode only, for bs2). |
| `artifact` | string\|null | Path to the persisted brainstorm artifact file, e.g., `".project-surgeon/brainstorm/bs-1.md"`. |

### planning — 计划阶段

Identical structure to workflow-architect's planning block.

| Field | Type | Description |
|-------|------|-------------|
| `status` | enum | `"pending"`, `"in_progress"`, `"completed"`, `"rejected"`. |
| `total_phases` | number | Number of execution phases in the plan. |
| `total_tasks` | number | Total number of tasks across all phases. |
| `plans_written.level_1` | boolean | Whether the Level 1 project plan has been written. |
| `plans_written.level_2_count` | number | Number of Level 2 phase plans written. |
| `plans_written.level_3_count` | number | Number of Level 3 task plans written. |

### execution — 执行阶段

Same structure as workflow-architect with the addition of `test_baseline` for the Preservation Gate.

| Field | Type | Description |
|-------|------|-------------|
| `status` | enum | `"pending"`, `"in_progress"`, `"completed"`, `"paused"`, `"aborted"`, `"error"`. |
| `current_phase_index` | number | Index of the currently executing phase (0-based). |
| `current_task_index` | number | Index of the currently executing task within the phase (0-based). |
| `total_phases` | number | Total number of execution phases. |
| `phases` | object | Nested object tracking each phase and its tasks (see schema above). |

#### execution.test_baseline — 测试基线 (Preservation Gate)

This sub-block is unique to project-surgeon. It stores the test suite baseline captured at the start of execution, used by the Preservation Gate to detect regressions.

| Field | Type | Description |
|-------|------|-------------|
| `has_tests` | boolean | Whether a test suite exists. If `false`, Preservation Gate is skipped. |
| `total_tests` | number | Total number of tests in the suite. |
| `passing` | number | Number of tests passing at baseline. |
| `failing` | number | Number of tests failing at baseline (pre-existing failures). |
| `failing_test_ids` | string[] | Identifiers of pre-existing failing tests. These are excluded from regression detection. |
| `captured_at` | ISO-8601\|null | When the baseline was captured. Updated on re-capture (e.g., after session resume). |

#### execution.deepwiki_cache — DeepWiki 缓存

| Field | Type | Description |
|-------|------|-------------|
| `phases_researched` | number[] | Indices of phases for which Tier 1 research has been completed. |
| `cache_dir` | string | Directory where DeepWiki research results are cached: `".project-surgeon/deepwiki-cache/"`. |

#### execution.error_log — 错误日志

Array of error entries. Each entry records a single strike attempt during error recovery.

| Field | Type | Description |
|-------|------|-------------|
| `phase` | number | Phase index where the error occurred. |
| `task` | number | Task index where the error occurred. |
| `strike` | number | Strike number (1, 2, or 3). |
| `error` | string | Error description. |
| `resolution` | string | How the error was resolved (or `"skipped"` / `"escalated"`). |
| `timestamp` | ISO-8601 | When the error was logged. |

### bug_fixer — Bug 修复状态

Added by the `project-surgeon:bug-fixer` add-on skill. Initialized on first Bug Fixer invocation (not at state.json creation).

| Field | Type | Description |
|-------|------|-------------|
| `reviews` | object[] | Array of review session records. |
| `reviews[].id` | number | Sequential review ID. |
| `reviews[].trigger` | enum | What triggered the review: `"standalone"`, `"3-strike"`, `"milestone"`, `"user-request"`. |
| `reviews[].target` | string | What was reviewed (file path, directory, or description). |
| `reviews[].started_at` | ISO-8601 | When the review started. |
| `reviews[].completed_at` | ISO-8601\|null | When the review finished. `null` if in progress. |
| `reviews[].findings_count` | number | Total findings from the review. |
| `reviews[].fixed_count` | number | How many findings were fixed. |
| `reviews[].skipped_count` | number | How many findings were skipped. |
| `reviews[].report_file` | string\|null | Path to the review report, e.g., `".project-surgeon/bug-fixer/review-1.md"`. |

**Directory structure:**
```
.project-surgeon/
├── bug-fixer/
│   ├── review-1.md
│   ├── review-2.md
│   └── ...
```

### change_requests — 变更请求状态

Added by the `project-surgeon:issue-changer` add-on skill. Initialized on first Issue Changer invocation (not at state.json creation).

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Sequential change request ID. |
| `mode` | enum | `"mid-workflow"` (during execution) or `"post-completion"` (after all phases done). |
| `description` | string | User's description of the requested change. |
| `requested_at` | ISO-8601 | When the change was requested. |
| `status` | enum | Lifecycle status: `"analyzing"` → `"approved"` → `"in_progress"` → `"completed"` (or `"rejected"`). |
| `impact.severity` | enum | `"light"`, `"moderate"`, `"major"`. |
| `impact.affected_phases` | number[] | Indices of phases affected by the change. |
| `impact.affected_tasks` | number[] | Indices of tasks affected by the change. |
| `impact.affected_files` | string[] | File paths affected by the change. |
| `impact.new_tasks_count` | number | Number of new tasks created by the change. |
| `resolution.approach` | enum | `"modify-tasks"`, `"modify-plans"`, `"rethink-review"`. Note: `"rethink-review"` replaces workflow-architect's `"rethink-design"`. |
| `resolution.plan_dir` | string\|null | Directory for change-specific plans, e.g., `".project-surgeon/changes/change-1/"`. |
| `resolution.completed_at` | ISO-8601\|null | When the change was fully applied. |

**Severity classification:**

| Severity | Criteria | Action |
|----------|----------|--------|
| light | Only affects current/future tasks, no new tasks needed | Modify Level 3 task plans in place |
| moderate | Requires new tasks or phase plan modifications | Return to Phase 3 for plan updates |
| major | Involves re-scoping the review or fundamental approach changes | Return to Phase 2 for re-review |

**Directory structure:**
```
.project-surgeon/
├── changes/
│   ├── change-1/
│   │   ├── change-plan.md
│   │   └── tasks/
│   │       ├── task-01-<name>.md
│   │       └── ...
│   ├── change-2/
│   │   └── ...
│   └── ...
```

## State Transition Diagram

```
                  +---- reject ----+
                  v                 |
  INIT --> ANALYSIS -----------> REVIEW
                  ^               |
                  |            approve
                  |               v
                  +-- reject -- PLANNING --> EXECUTION --> COMPLETED
```

### Transition Rules

| From       | To         | Condition                                         |
|------------|------------|---------------------------------------------------|
| (init)     | analysis   | Skill invoked; state.json created                 |
| analysis   | review     | Analysis complete + user confirms objective        |
| review     | planning   | User approves review priorities                    |
| review     | analysis   | User rejects review (needs more analysis)          |
| planning   | execution  | All L1/L2/L3 plans written + user approves         |
| planning   | analysis   | User rejects plans                                 |
| execution  | completed  | All tasks completed + final verification passes    |
| execution  | execution  | Session resume — continue from last checkpoint     |
| execution  | planning   | User requests course correction (modify plans)     |
| execution  | review     | User requests re-scoping (modify review priorities)|

## Persistence Rules

1. **When to write state.json:**
   - On Phase 1 start (initialize)
   - After each analysis step completes (update `steps_completed`)
   - On every phase transition
   - **After each brainstorm completion** (update `brainstorm.bsN.status` + `completed_at` + `audit_score`)
   - After each task completion in Phase 4
   - After each Preservation Gate run (update `test_baseline` if bonuses detected)
   - On error (log to `error_log`)

2. **Atomic writes:** Always write the complete state.json (never partial updates).

3. **Timestamp format:** ISO-8601 with timezone, e.g., `2026-04-01T14:30:00+08:00`.

## Session Resume Protocol

When the skill is invoked and `.project-surgeon/state.json` already exists:

1. Read state.json
2. Verify `skill` field is `"project-surgeon"` (not a workflow-architect state file)
3. Display progress summary:
   - Current phase
   - If in analysis: steps completed / total steps
   - If in review: dimensions completed / total dimensions
   - If in execution: completed tasks / total tasks with percentage
   - Last activity timestamp
4. Ask user: **Resume** (continue from current state) or **Restart** (begin from Phase 1, archive old state)
5. On resume: enter the current phase and continue from where it left off
6. On restart: rename `.project-surgeon/` to `.project-surgeon.bak.<timestamp>/`, create fresh `.project-surgeon/state.json`

## Rejection Back-Flow

When user rejects in Phase 2 (Review) or Phase 3 (Planning):

1. Log rejection in phase_history with `exit_reason: "rejected_to_analysis"`
2. Set `current_phase` to `"analysis"`
3. **Preserve** all existing analysis data in `analysis`
4. Reset relevant blocks based on user feedback
5. Increment rejection count or reset status as appropriate
6. Return to Phase 1 analysis, starting from the areas that need revision

## Error Recovery

If state.json is corrupted or missing mid-workflow:

1. Check for `.project-surgeon.bak.*` directories (archived by restart)
2. If backup exists: restore from latest backup's `state.json`
3. If no backup but plan files exist: reconstruct state from plan file structure
4. If nothing recoverable: inform user and offer to restart

## Brainstorm Artifact Persistence — 头脑风暴产物持久化

Brainstorm intermediate results are persisted to disk for traceability and context pressure relief.

<!-- 头脑风暴中间结果写入磁盘，用于可追溯性和减轻上下文压力。 -->

### Directory Structure

```
.project-surgeon/
├── brainstorm/
│   ├── bs-1.md        # Analysis completeness check results
│   ├── bs-2.md        # Review methodology brainstorm results
│   ├── bs-3.md        # Task decomposition review results
│   └── bs-7-N.md      # Error recovery brainstorm (N = occurrence count)
```

**Note:** Unlike workflow-architect (which has bs-1 through bs-6 plus bs-7), project-surgeon only has bs-1, bs-2, bs-3, and bs-7. There are no bs-4, bs-5, or bs-6 artifact files.

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

1. Create `.project-surgeon/brainstorm/` directory when the first brainstorm is triggered
2. Write the artifact file **after** all steps complete (not incrementally)
3. Update `brainstorm.bsN.status` and `brainstorm.bsN.artifact` in state.json
4. On session resume: read existing brainstorm artifacts to restore context
5. BS-7 files use incrementing suffix: `bs-7-1.md`, `bs-7-2.md`, etc.

## Review Report Persistence — 审查报告持久化

Phase 2 review findings are persisted to disk as the primary deliverable of the review phase.

<!-- 审查报告是 Phase 2 的核心交付物，持久化到磁盘供后续阶段引用。 -->

### Report File Location

```
.project-surgeon/review-report.md
```

### Purpose

Unlike workflow-architect's draft cache (which is a resume artifact), the review report is a **primary deliverable** that is directly referenced during Phase 3 planning. Every Level 3 task traces back to specific Finding IDs in this report.

### Persistence Rules

1. Create `.project-surgeon/review-report.md` when Phase 2 produces findings
2. **Update incrementally** as each dimension is reviewed
3. Update `review.dimensions_completed` array in state.json
4. On Phase 2 completion: finalize the report with summary statistics
5. On session resume in Phase 2: read the report to restore completed dimensions
6. The report persists through Phase 3 and Phase 4 as a reference document

## Bug Fixer State — Bug 修复状态

<!-- Bug Fixer 外挂技能在执行审查时更新此字段。 -->

### Field: `bug_fixer`

Added by the `project-surgeon:bug-fixer` add-on skill. Initialized on first Bug Fixer invocation (not at state.json creation).

**Persistence rules:**
1. Create `bug_fixer` field on first Bug Fixer invocation if it does not exist
2. Append a new review entry when a review session starts
3. Update `findings_count`, `fixed_count`, `skipped_count` as findings are processed
4. Set `completed_at` and `report_file` when the review session finishes
5. Review reports are persisted to `.project-surgeon/bug-fixer/review-N.md` (N = review id)

### Backward Compatibility

A state.json from version `"1.0"` (without `bug_fixer` field) remains valid. The Bug Fixer skill initializes the field on first use.

## Change Request State — 变更请求状态

<!-- Issue Changer 外挂技能在处理变更请求时更新此字段。 -->

### Field: `change_requests`

Added by the `project-surgeon:issue-changer` add-on skill. Initialized on first Issue Changer invocation (not at state.json creation).

**Persistence rules:**
1. Create `change_requests` array on first Issue Changer invocation if it does not exist
2. Append a new entry when a change request is received
3. Update `status` through the lifecycle: `analyzing` → `approved` → `in_progress` → `completed`
4. Update `impact` fields after impact analysis completes
5. Update `resolution` fields when the approach is determined and executed
6. For Mode B (post-completion): set `resolution.plan_dir` to `.project-surgeon/changes/change-N/`

### Backward Compatibility

A state.json from version `"1.0"` (without `change_requests` field) remains valid. The Issue Changer skill initializes the field on first use.

## Complete Directory Structure — 完整目录结构

```
.project-surgeon/
├── state.json                              # Workflow state (this document's schema)
├── analysis-report.md                      # Phase 1 output: project analysis report
├── review-report.md                        # Phase 2 output: code review findings
├── project-plan.md                         # Level 1: project plan
├── brainstorm/
│   ├── bs-1.md                             # Analysis completeness brainstorm
│   ├── bs-2.md                             # Review methodology brainstorm
│   ├── bs-3.md                             # Task decomposition brainstorm
│   └── bs-7-N.md                           # Error recovery brainstorms
├── phases/
│   ├── phase-1/
│   │   ├── phase-plan.md                   # Level 2: phase plan
│   │   └── tasks/
│   │       ├── task-01-<name>.md            # Level 3: task plans
│   │       └── ...
│   ├── phase-2/
│   │   └── ...
│   └── ...
├── deepwiki-cache/
│   ├── phase-1-research.md
│   └── ...
├── bug-fixer/
│   ├── review-1.md
│   └── ...
└── changes/
    ├── change-1/
    │   ├── change-plan.md
    │   └── tasks/
    │       └── ...
    └── ...
```
