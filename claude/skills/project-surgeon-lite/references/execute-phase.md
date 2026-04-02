# Phase 2: Execute

## Entry Checklist

- □ State.json loaded, `current_phase` is `"execute"`
- □ Findings and user goal are in state.json
- □ Project scan data available

## Step 1: Preservation Gate Setup

If `scan.has_tests` is true:

- □ Detect test command from scan data (npm test / pytest / cargo test / go test / dotnet test)
- □ Run the test suite
- □ Record results in state.json:
  ```json
  "test_baseline": {
    "has_tests": true,
    "passing": N,
    "failing": M,
    "test_command": "npm test",
    "captured_at": "ISO-8601"
  }
  ```
- □ Display: "Baseline captured: {N} passing, {M} failing"

If no tests: set `test_baseline.has_tests` to `false`. Skip all gate checks during execution.

## Step 2: Write Plan to Disk

Using the [plan template](../assets/templates/plan.md), write `.project-surgeon-lite/plan.md`:

- □ Fill project name, detected tech stack
- □ Add findings summary from Phase 1
- □ Create a **flat task list** ordered by priority:
  1. HIGH severity findings first (security, critical bugs)
  2. MEDIUM findings (logic, error handling improvements)
  3. LOW findings and refactoring (consistency, cleanup)
- □ Each task row: number, name, related finding IDs, files, estimated steps
- □ Success criteria: "All HIGH findings addressed" + "Test pass count not decreased"

## Step 3: Write Task Files

For each task, write `.project-surgeon-lite/tasks/task-NN.md` using the [task template](../assets/templates/task.md):

- □ Objective: what to fix/improve
- □ Related findings: which findings this task addresses
- □ Files to modify
- □ Steps: numbered, brief
- □ Verification: how to confirm the fix works
- □ Preservation Gate: checkbox for test comparison
- □ Commit message: pre-written

## Step 4: Plan Approval

Present summary to user. Ask via AskUserQuestion:

- **(A) Approve** — start execution
- **(B) Revise** — specify changes

On approval: populate `tasks` array in state.json.

## Step 5: Execute Tasks

For each task in order:

```
□ Read task file (.project-surgeon-lite/tasks/task-NN.md)
□ Mark task "in_progress" in state.json
□ Create TaskCreate entry for visibility
□ Execute each step sequentially
□ Run task-specific verification

□ PRESERVATION GATE (if tests exist):
  □ Run test suite using the recorded test command
  □ Compare passing count with baseline:
    - Pass count DECREASED:
      □ ALERT: "⚠ Test regression: {baseline.passing} → {current_passing}"
      □ Show which tests are now failing
      □ Ask user via AskUserQuestion:
        (A) "Revert changes" — run: git checkout -- . (revert task's changes)
        (B) "Continue anyway" — accept the regression, update baseline
    - Pass count SAME or INCREASED:
      □ Continue. If increased, update baseline.

□ Git commit with pre-written message
□ Mark task "completed" in state.json
□ Update TaskUpdate to completed
□ Print: "✓ Task N/Total: {name} — completed"
```

## Error Recovery (1-Strike)

On task failure (not test regression — code/build error):

```
Strike 1:
  □ Read the error message carefully
  □ Identify root cause
  □ Apply a targeted fix
  □ Re-run verification

If Strike 1 fails:
  □ STOP. Present the error to the user.
  □ Ask via AskUserQuestion:
    (A) "I'll provide guidance" — user gives hints, retry
    (B) "Skip this task" — mark as "error", continue to next
```

## Step 6: Completion

After all tasks are done (or skipped):

- □ Run final test suite (if tests exist), compare with original baseline
- □ Present completion report:

```
## Completion Report
- Project: {name}
- Tasks completed: X/Y
- Tasks skipped: Z
- Findings addressed: {HIGH: A/B, MEDIUM: C/D, LOW: E/F}
- Test baseline: {original_passing} → {final_passing}
- Files modified: [list]
```

- □ Update state.json: `current_phase` → `"completed"`

## Session Resume

If resuming a previous session:

- □ Read state.json → find last completed task
- □ Re-capture test baseline (run tests now, compare with stored baseline)
- □ Display: "Resuming from Task N+1: {name}. Baseline: {passing} passing."
- □ Continue execution loop from Step 5
