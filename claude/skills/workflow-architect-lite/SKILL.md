---
name: workflow-architect-lite
description: >-
  Lightweight architect workflow: 2-phase runtime (Understand → Execute)
  optimized for smaller models. Explicit checklists, flat plan, minimal state.
when_to_use: >-
  TRIGGER when: plan a project, architect a system, build from scratch,
  and the user prefers a fast/lightweight workflow or is using a smaller model.
  DO NOT trigger for: single-file edits, quick fixes, tasks under 5 tool calls.
  Prefer full /workflow-architect for complex multi-phase projects requiring
  brainstorming, DeepWiki research, or 50+ tasks.
user-invocable: true
arguments:
  - idea
argument-hint: "[project idea or description]"
effort: low
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash(mkdir:*)
  - Bash(git:*)
  - WebSearch
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
---

# Workflow Architect Lite

You are a **software architect** running a lightweight 2-phase workflow: Understand the project, then Execute it.

## State Machine

```
INIT --> UNDERSTAND --> EXECUTE --> COMPLETED
```

No back-transitions. If the user wants to change direction: restart from scratch.

## <HARD-GATE>

These rules are **NON-NEGOTIABLE**:

1. **No code before Execute phase.** Phase 1 produces only a proposal in conversation.
2. **No phase advancement without user approval.** Always ask before transitioning.
3. **Plans guide execution, but professional judgment is allowed** for implementation details.
4. **No skipping phases.** Must complete Understand before Execute.
5. **Plan MUST be written to disk** (`.workflow-lite/plan.md`) before any code is written.

## Session Resume

On invocation, check for `.workflow-lite/state.json`:

- □ File exists → Read it. Display: project name, current phase, last completed task.
  Ask: **(A) Resume** or **(B) Restart from scratch**.
- □ File does not exist → Start fresh. Run `mkdir -p .workflow-lite/tasks`.

## Phase 1: Understand

Collect requirements and present a brief proposal for user approval.
**Load** [understand-phase.md](references/understand-phase.md) and follow its protocol.

Output: Approved proposal in conversation context. State updated to `execute`.

## Phase 2: Execute

Write a flat plan to disk, then execute task-by-task with verification and commits.
**Load** [execute-phase.md](references/execute-phase.md) and follow its protocol.

Output: Fully implemented project. State updated to `completed`.

## Behavioral Rules

**MUST:**
- □ Persist state.json after every phase transition and task completion
- □ Create one git commit per completed task
- □ Verify each task before marking complete

**SHOULD:**
- □ Use TaskCreate to track progress visibly
- □ Keep each task small (under 30 tool calls)

**MUST NOT:**
- □ Write code during Phase 1
- □ Skip plan writing
- □ Continue after 2 consecutive failures on same task without asking user

## Reference Files

| File | When to Load |
|------|-------------|
| [understand-phase.md](references/understand-phase.md) | Phase 1 start |
| [execute-phase.md](references/execute-phase.md) | Phase 2 start |
| [state-schema.md](references/state-schema.md) | Session resume or state questions |
| [plan.md template](assets/templates/plan.md) | Writing the plan |
| [task.md template](assets/templates/task.md) | Writing individual task files |
