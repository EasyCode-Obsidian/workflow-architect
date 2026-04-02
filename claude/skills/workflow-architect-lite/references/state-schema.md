# State Schema — workflow-architect-lite

## File Location

`.workflow-lite/state.json`

## Schema

```json
{
  "version": "1.0",
  "skill": "workflow-architect-lite",
  "project_name": "string",
  "current_phase": "understand | execute | completed",
  "created_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "proposal_approved": false,
  "plan_file": ".workflow-lite/plan.md",
  "tasks": [
    {
      "id": 1,
      "name": "Task name",
      "status": "pending | in_progress | completed | error",
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
| `skill` | Yes | Never (always "workflow-architect-lite") |
| `project_name` | Yes | Phase 1 start |
| `current_phase` | Yes | Phase transition |
| `created_at` | Yes | Initial creation |
| `updated_at` | Yes | Every write |
| `proposal_approved` | Yes | Phase 1 approval |
| `plan_file` | Yes | Plan written |
| `tasks` | Yes | Plan approval, task start, task completion |

## Phase Transitions

Only 3 valid transitions:

```
init → understand    (on first invocation)
understand → execute (on proposal approval)
execute → completed  (on all tasks done)
```

No back-transitions. To restart: delete `.workflow-lite/` and re-invoke.

## Persistence Rules

Write state.json on:
- □ Phase transition
- □ Task status change (pending → in_progress → completed/error)
- □ Session resume

Always update `updated_at` on every write.

## Session Resume Protocol

1. □ Read `.workflow-lite/state.json`
2. □ If `current_phase` is `"understand"`: re-enter Phase 1 (re-ask remaining questions)
3. □ If `current_phase` is `"execute"`: find first task with status `"pending"` or `"in_progress"`, resume from there
4. □ If `current_phase` is `"completed"`: inform user project is done
5. □ Always display current state summary before continuing
