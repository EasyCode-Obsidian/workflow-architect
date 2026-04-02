# State Schema — project-surgeon-lite

## File Location

`.project-surgeon-lite/state.json`

## Schema

```json
{
  "version": "1.0",
  "skill": "project-surgeon-lite",
  "project_name": "string",
  "project_path": "/absolute/path",
  "current_phase": "understand | execute | completed",
  "created_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "scan": {
    "tech_stack": ["node", "typescript"],
    "total_files": 0,
    "total_lines": 0,
    "has_tests": false,
    "test_framework": null,
    "test_command": null
  },
  "findings_summary": {
    "total": 0,
    "by_severity": { "high": 0, "medium": 0, "low": 0 },
    "by_dimension": {
      "security": 0,
      "logic": 0,
      "error_handling": 0,
      "consistency": 0
    }
  },
  "user_goal": {
    "type": "fix | refactor | custom",
    "description": ""
  },
  "plan_approved": false,
  "plan_file": ".project-surgeon-lite/plan.md",
  "test_baseline": {
    "has_tests": false,
    "passing": 0,
    "failing": 0,
    "test_command": "npm test",
    "captured_at": null
  },
  "tasks": [
    {
      "id": 1,
      "name": "Task name",
      "status": "pending | in_progress | completed | error",
      "related_findings": [],
      "started_at": null,
      "completed_at": null
    }
  ]
}
```

## Field Rules

| Field | Required | Updated When |
|-------|----------|-------------|
| `version` | Yes | Never (always "1.0") |
| `skill` | Yes | Never (always "project-surgeon-lite") |
| `project_name` | Yes | Phase 1 scan |
| `project_path` | Yes | Phase 1 start |
| `current_phase` | Yes | Phase transition |
| `scan` | Yes | Phase 1 auto-scan |
| `findings_summary` | Yes | Phase 1 review |
| `user_goal` | Yes | Phase 1 goal collection |
| `test_baseline` | Yes | Phase 2 gate setup, after regressions |
| `tasks` | Yes | Plan approval, task start, task completion |

## Phase Transitions

Only 3 valid transitions:

```
init → understand    (on first invocation)
understand → execute (on findings approval + user goal set)
execute → completed  (on all tasks done)
```

No back-transitions. To restart: delete `.project-surgeon-lite/` and re-invoke.

## Persistence Rules

Write state.json on:
- □ Phase transition
- □ Scan completion
- □ Review completion
- □ Task status change
- □ Test baseline update (after regression acceptance)

Always update `updated_at` on every write.

## Session Resume Protocol

1. □ Read `.project-surgeon-lite/state.json`
2. □ If `current_phase` is `"understand"`: re-enter Phase 1 (skip completed scan steps)
3. □ If `current_phase` is `"execute"`: re-capture test baseline, find first pending task, resume
4. □ If `current_phase` is `"completed"`: inform user project improvement is done
5. □ Always display current state summary before continuing
