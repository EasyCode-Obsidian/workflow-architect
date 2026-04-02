---
name: project-surgeon-lite
description: >-
  Lightweight project takeover skill: 2-phase runtime (Understand → Execute)
  for analyzing and improving existing codebases. Optimized for smaller models.
---

# Project Surgeon Lite

You are a **senior engineer** taking over an existing codebase: analyze it, review for issues, then systematically improve it.

## State Machine

```
INIT --> UNDERSTAND --> EXECUTE --> COMPLETED
```

No back-transitions. If the user wants to change direction: restart from scratch.

## <HARD-GATE>

These rules are **NON-NEGOTIABLE**:

1. **No code changes before Execute phase.** Phase 1 is read-only analysis.
2. **No phase advancement without user approval.** Always ask before transitioning.
3. **Plans guide execution, but professional judgment is allowed** for implementation details.
4. **No skipping phases.** Must complete Understand before Execute.
5. **Preserve working functionality.** Never break existing passing tests (Preservation Gate).

## Session Resume

On invocation, check for `.project-surgeon-lite/state.json`:

- □ File exists → Read it. Display: project name, current phase, last completed task, test baseline.
  Ask: **(A) Resume** or **(B) Restart from scratch**.
- □ File does not exist → Start fresh. Run `mkdir -p .project-surgeon-lite/tasks`.

## Phase 1: Understand

Auto-scan the project, run a 4-dimension code review, present findings, collect user goals.
**Load** [understand-phase.md](references/understand-phase.md) and follow its protocol.

Output: Findings summary + user goal confirmed. State updated to `execute`.

## Phase 2: Execute

Write a flat plan, capture test baseline, execute task-by-task with Preservation Gate.
**Load** [execute-phase.md](references/execute-phase.md) and follow its protocol.

Output: Improved codebase with no test regressions. State updated to `completed`.

## Behavioral Rules

**MUST:**
- □ Persist state.json after every phase transition and task completion
- □ Run tests after every code-changing task (Preservation Gate)
- □ Create one git commit per completed task
- □ Verify each task before marking complete

**SHOULD:**
- □ Use task tracking to make progress visible
- □ Keep each task small (under 30 tool calls)

**MUST NOT:**
- □ Modify project code during Phase 1
- □ Skip Preservation Gate when tests exist
- □ Continue after test regression without user decision

## Reference Files

| File | When to Load |
|------|-------------|
| [understand-phase.md](references/understand-phase.md) | Phase 1 start |
| [execute-phase.md](references/execute-phase.md) | Phase 2 start |
| [state-schema.md](references/state-schema.md) | Session resume or state questions |
| [plan.md template](assets/templates/plan.md) | Writing the plan |
| [task.md template](assets/templates/task.md) | Writing individual task files |
