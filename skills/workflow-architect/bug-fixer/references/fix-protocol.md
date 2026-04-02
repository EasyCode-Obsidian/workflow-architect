# Fix Protocol — Bug 修复循环协议

> Structured cycle for reproducing, analyzing, fixing, and verifying each finding.
> Applied after user approves which findings to fix.

<!-- 结构化修复循环：复现 → 根因分析 → 修复 → 验证。用户批准后执行。 -->

---

## Overview

The Fix Protocol processes approved findings one at a time, in severity order (critical first).
Each finding goes through a 5-step cycle. If a fix breaks something, it is reverted before proceeding.

<!-- 修复协议按严重程度逐个处理已批准的发现（critical 优先）。每个发现经历 5 步循环。 -->

## Fix Cycle — 修复循环

```
FOR each approved finding F (sorted by severity: critical → high → medium → low):

    Step 1: REPRODUCE (if applicable)
    Step 2: ROOT CAUSE ANALYSIS
    Step 3: FIX DESIGN → present to user
    Step 4: IMPLEMENT FIX (after user confirms)
    Step 5: VERIFY

    IF verification fails:
        Revert fix
        Report to user
        Ask: (A) Try alternative fix  (B) Skip this finding  (C) Stop fixing
```

---

## Step 1: Reproduce — 复现

<!-- 尝试复现问题以确认其真实存在。 -->

Not all findings can be reproduced (e.g., security vulnerabilities, performance issues).
For findings that can be reproduced:

1. Identify a test case or command that demonstrates the issue
2. Run the test/command and capture output
3. Document: `Reproduction: <command> → <observed behavior> (expected: <correct behavior>)`

For findings that cannot be reproduced:
1. Document: `Reproduction: Static analysis finding — verified by code inspection`
2. Proceed to Step 2

**When to skip reproduction:**
- Pure static analysis findings (unused imports, type issues)
- Security patterns (injection, XSS) identified by code pattern
- Dependency version issues

## Step 2: Root Cause Analysis — 根因分析

<!-- 识别问题的根本原因，而非仅仅是症状。 -->

1. Identify the **root cause**, not just the symptom
2. Trace the causal chain: `<surface issue> ← <intermediate cause> ← <root cause>`
3. Determine the **blast radius** — what else might be affected by the same root cause
4. Check if other findings share the same root cause (batch fix opportunity)

**Output format:**
```
Root Cause: <concise description>
Causal Chain: <symptom> ← <cause> ← <root cause>
Blast Radius: <files/functions potentially affected>
Related Findings: <IDs of findings with same root cause, if any>
```

## Step 3: Fix Design — 修复方案

<!-- 设计修复方案并向用户展示。 -->

1. Design the minimal fix that addresses the root cause
2. Consider side effects: does this fix change behavior for other callers?
3. Present to user:

```
Fix for [D<N>-<M>] <description>:
  File: <path>
  Change: <what will be changed>
  Rationale: <why this fix is correct and minimal>
  Side effects: <none | description of behavioral changes>
```

4. Wait for user confirmation before proceeding to Step 4

**Design principles:**
- **Minimal:** Change as little code as possible
- **Targeted:** Fix the root cause, not just the symptom
- **Safe:** Preserve existing behavior for unaffected code paths
- **Testable:** The fix should be verifiable by an existing or simple new test

## Step 4: Implement Fix — 实施修复

<!-- 使用 Edit 工具实施修复。 -->

1. Apply the fix using the `Edit` tool
2. Use the **smallest possible edit** — context lines should be sufficient to uniquely identify the location
3. If multiple files need changes (same root cause): apply all changes, then verify as a batch
4. Document the exact changes made

**Rules:**
- **ONE finding at a time** — do not batch unrelated fixes
- **Shared root cause findings** may be batched if they share the same fix
- **NEVER** modify code unrelated to the finding
- **NEVER** add comments like `// fixed`, `// FIXED: ...` — the git history is the record

## Step 5: Verify — 验证

<!-- 确认修复正确且未引入新问题。 -->

1. **Targeted verification:** Run the reproduction test from Step 1 (if applicable)
2. **Regression check:** Run the project's test suite (if available):
   - Detect test framework from project files (package.json scripts, pytest.ini, Makefile, etc.)
   - Run the relevant test subset (not necessarily the full suite)
3. **Build check:** If the project has a build step, verify it still passes
4. **Manual inspection:** Re-read the changed code to confirm correctness

**Verification result handling:**

| Result | Action |
|--------|--------|
| All pass | Mark finding as fixed, proceed to next finding |
| Targeted test fails | Fix didn't work — revert, report, ask user |
| Regression test fails | Fix introduced new bug — revert, report, ask user |
| Build fails | Fix broke compilation — revert, report, ask user |

**Revert protocol:**
1. Use `Edit` to restore original code (reverse the change)
2. Re-run verification to confirm revert is clean
3. Report to user with options: (A) Try alternative fix, (B) Skip finding, (C) Stop fixing

---

## Batch Fix for Shared Root Cause — 共因批量修复

<!-- 多个发现共享相同根因时的批量修复策略。 -->

When multiple findings share the same root cause (identified in Step 2):

1. Group the findings
2. Design a single fix that addresses the root cause
3. Present the grouped fix to user: "Findings [D1-2, D2-5, D5-1] share root cause X. Applying one fix."
4. Apply the fix once
5. Verify against all affected findings

## Progress Tracking — 进度追踪

After each finding is processed, output:

```
[Fix Progress] <completed>/<total> | Fixed: <count> | Skipped: <count> | Failed: <count>
  Latest: [D<N>-<M>] <status: fixed | skipped | reverted>
```

## Fix Summary — 修复总结

After all approved findings are processed:

```
═══════════════════════════════════════════════
BUG FIXER — FIX SUMMARY
═══════════════════════════════════════════════

Approved findings: <total>
Fixed: <count>
Skipped: <count> (user chose to skip)
Failed: <count> (fix reverted)

Changes made:
- <file1>:<line> — <brief description>
- <file2>:<line> — <brief description>

Verification: All tests passing ✅ | Tests failing ⚠️
═══════════════════════════════════════════════
```

## Integrated Mode — State Update

<!-- 集成模式下的状态更新。 -->

When running in Integrated Mode (within workflow-architect):

1. After fix summary, update `.workflow/state.json`:
   - Initialize `bug_fixer.reviews` array if not present
   - Append review entry with all counts and report file path
2. Persist full review report to `.workflow/bug-fixer/review-<id>.md`
3. If triggered by 3-Strike:
   - If fix resolves the original error: reset strike counter, signal to resume execution
   - If fix does NOT resolve: report back, re-offer 3-Strike options (B/C/D)
4. If triggered at milestone: return control to milestone checkpoint flow

## Review Report File Format — 审查报告格式

<!-- 持久化到磁盘的审查报告格式。 -->

```markdown
# Bug Fixer Review Report #<N>

- **Date:** <ISO-8601>
- **Mode:** Standalone | Integrated (<trigger>)
- **Target:** <file/directory/description>
- **Files Scanned:** <count>

## Findings Summary

| Severity | Count | Fixed | Skipped |
|----------|-------|-------|---------|
| Critical | 0     | 0     | 0       |
| High     | 0     | 0     | 0       |
| Medium   | 0     | 0     | 0       |
| Low      | 0     | 0     | 0       |
| Info     | 0     | 0     | 0       |

## Detailed Findings

### [D1-1] <severity> — <description>
- **File:** <path>:<line>
- **Root Cause:** <description>
- **Status:** fixed | skipped | failed
- **Fix Applied:** <description of change, or "N/A">

...
```
