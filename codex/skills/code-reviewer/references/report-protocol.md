# Report Protocol — 报告协议

> Defines how to generate the structured review report from raw findings.

---

## Report Generation Steps

### Step 1: Collect Raw Findings

After all roles complete scanning, gather all raw findings into a single list.
Each finding has: file, line, severity, dimension, role, description, suggestion.

### Step 2: Deduplicate

Apply the dedup algorithm from scan-protocol.md:

```
□ Sort by (file_path, line_number)
□ Group: same file AND line difference ≤ 3 → same group
□ Merge each group:
  - Severity: keep highest
  - Roles: union of all
  - Dimensions: union of all
  - Description: prefer most detailed, merge complementary details
□ Assign IDs: F-001, F-002, ...
```

### Step 3: Cross-Role Hot Spots

Identify files flagged by multiple roles:

```
□ Group findings by file
□ For each file: count distinct roles that found issues
□ Files with ≥ 2 roles = "hot spot"
□ Sort hot spots by: (role count DESC, finding count DESC, max severity DESC)
```

### Step 4: Dimension Coverage Matrix

Build a matrix showing which dimensions were covered by which roles and how many findings each produced:

```
□ For each dimension D1-D10:
  □ For each role:
    □ Count findings in this (dimension, role) pair
□ Mark cells: "P" (PRIMARY), "S" (SECONDARY), "-" (not assigned)
□ Append finding count to each active cell
```

### Step 5: Prioritized Recommendations

Sort findings into actionable recommendations:

```
Priority scoring:
  CRITICAL = 4 points
  HIGH     = 3 points
  MEDIUM   = 2 points
  LOW      = 1 point

  Multi-role finding bonus: +1 per additional role

  Effort estimation (based on description):
    Quick fix (1 line change)     → LOW effort
    Localized fix (< 10 lines)   → MEDIUM effort
    Cross-file refactor           → HIGH effort

Final priority = severity_score + multi_role_bonus - effort_penalty
  (effort_penalty: LOW=0, MEDIUM=0.5, HIGH=1)

Sort by final priority DESC.
```

### Step 6: Executive Summary

Generate summary statistics:

```
□ Total findings (after dedup)
□ Breakdown by severity: CRITICAL / HIGH / MEDIUM / LOW / INFO
□ Files scanned vs total project files
□ Top 3 risks (highest priority findings)
□ Scan mode used (Quick Scan / Full Audit)
□ Roles that participated
```

---

## Report Structure

The report follows this order:

1. **Executive Summary** — stats + top risks (always shown in conversation)
2. **Findings by Role** — organized by role perspective, each finding with full details
3. **Cross-Role Hot Spots** — files flagged by multiple roles
4. **Dimension Coverage Matrix** — 10×4 grid showing coverage and finding counts
5. **Prioritized Recommendations** — action items sorted by priority

---

## Output Formats

### Quick Scan: Conversation Only

Present the full report in conversation. Use this format:

```
═══════════════════════════════════════════════════
CODE REVIEW REPORT — {PROJECT_NAME}
Mode: Quick Scan | Scope: {TARGET}
═══════════════════════════════════════════════════

SUMMARY: {N} findings (C: {n}, H: {n}, M: {n}, L: {n}, I: {n})
Files scanned: {N} | Roles: Developer, Security, Architect

TOP RISKS:
1. [F-001] {description} — {file}:{line}
2. [F-002] {description} — {file}:{line}
3. [F-003] {description} — {file}:{line}

── DEVELOPER PERSPECTIVE ─────────────────────────
[F-XXX] {severity} | D{N} | {file}:{line}
  {description}
  ↳ Suggestion: {suggestion}
...

── SECURITY EXPERT PERSPECTIVE ───────────────────
...

── ARCHITECT PERSPECTIVE ─────────────────────────
...

── CROSS-ROLE HOT SPOTS ─────────────────────────
| File | Roles | Findings | Top Severity |
|------|-------|----------|-------------|
...

── RECOMMENDATIONS ───────────────────────────────
| # | Finding | Action | Effort |
|---|---------|--------|--------|
...
═══════════════════════════════════════════════════
```

### Full Audit: Conversation Summary + Disk Report

1. Present **Executive Summary** + **Top 10 Findings** in conversation
2. Write full report to `.review/report.md` using the [report template](../assets/templates/report.md)
3. Inform user: "Full report written to `.review/report.md`"

---

## State Updates (Full Audit Only)

After report generation, update `.review/state.json`:

```json
{
  "current_phase": "done",
  "findings_total": <N>,
  "findings_by_severity": {
    "critical": <n>, "high": <n>, "medium": <n>, "low": <n>, "info": <n>
  },
  "hot_spots": ["<file1>", "<file2>"],
  "report_file": ".review/report.md",
  "updated_at": "<ISO>"
}
```
