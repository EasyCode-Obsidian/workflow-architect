# Phase 2: Execute

## Entry Checklist

- □ State.json loaded, `current_phase` is `"execute"`
- □ `proposal_approved` is `true`
- □ Approved proposal is in conversation context

## Step 1: Write Plan to Disk

Using the [plan template](../assets/templates/plan.md), write `.workflow-lite/plan.md`:

- □ Fill project name, overview, tech stack table from the approved proposal
- □ Create a **flat task list** — all tasks numbered sequentially (no phase grouping)
- □ Each task row: number, name, files to create/modify, estimated steps count
- □ Add 3-5 success criteria as checkboxes
- □ Total tasks should match the proposal's estimate

## Step 2: Write Task Files

For each task, write `.workflow-lite/tasks/task-NN.md` using the [task template](../assets/templates/task.md):

- □ Objective: 1-2 sentences
- □ Files: list of files to create and modify
- □ Steps: numbered, brief (1 line each)
- □ Verification: checklist of how to confirm the task works
- □ Commit message: pre-written conventional commit

## Step 3: Plan Approval

Present a summary to the user:
- Total tasks count
- Brief list of all task names
- Estimated scope

Ask via asking the user:
- **(A) Approve** — start execution
- **(B) Revise** — specify changes

On approval:
- □ Populate `tasks` array in state.json (all tasks with status `"pending"`)

## Step 4: Execute Tasks

For each task in order:

```
□ Read task file (.workflow-lite/tasks/task-NN.md)
□ Mark task "in_progress" in state.json
□ Create task tracking entry for visibility
□ Execute each step sequentially
□ Run verification checks from the task file
□ If verification passes:
    □ Git commit with the pre-written message
    □ Mark task "completed" in state.json
    □ Update task tracking update to completed
    □ Print: "✓ Task N/Total: {name} — completed"
□ If verification fails:
    → Go to Error Recovery
```

## Error Recovery (1-Strike)

On task failure:

```
Strike 1:
  □ Read the error message carefully
  □ Identify root cause
  □ Apply a targeted fix
  □ Re-run verification

If Strike 1 fails:
  □ STOP. Present the error to the user.
  □ Ask via asking the user:
    (A) "I'll provide guidance" — user gives hints, retry
    (B) "Skip this task" — mark as "error", continue to next task
```

No further escalation. No brainstorm. No bug-fixer integration.

## Step 5: Completion

After all tasks are done (or skipped):

- □ Run a final check: list any tasks with status "error"
- □ Present completion report:

```
## Completion Report
- Project: {name}
- Tasks completed: X/Y
- Tasks skipped: Z
- Files created: [list]
- Files modified: [list]
```

- □ Update state.json: `current_phase` → `"completed"`
- □ Final git commit if any uncommitted changes remain

## Session Resume

If resuming a previous session:

- □ Read state.json → find last completed task index
- □ Display: "Resuming from Task N+1: {name}"
- □ Read the task file for the next pending task
- □ Continue the execution loop from Step 4
