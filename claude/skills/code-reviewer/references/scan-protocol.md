# Scan Protocol — 扫描协议

> Defines DETECT and SCAN phases: tech stack detection, scope determination,
> role-first scanning loop, and finding deduplication.

---

## DETECT Phase — 项目检测

Run these checks to understand the project before scanning.

### Step 1: Tech Stack Detection

Use `Glob` to check for manifest files:

| Manifest | Ecosystem | Primary Language |
|----------|-----------|-----------------|
| `package.json` | Node.js | JavaScript/TypeScript |
| `tsconfig.json` | TypeScript | TypeScript |
| `requirements.txt`, `pyproject.toml`, `setup.py` | Python | Python |
| `go.mod` | Go | Go |
| `Cargo.toml` | Rust | Rust |
| `pom.xml`, `build.gradle` | Java/Kotlin | Java/Kotlin |
| `Gemfile` | Ruby | Ruby |
| `composer.json` | PHP | PHP |
| `*.csproj`, `*.sln` | .NET | C# |
| `Package.swift` | Swift | Swift |

Record detected ecosystems — they determine which Grep patterns to prioritize in each dimension.

### Step 2: Scope Determination

Parse the `$target` argument:

- **File path** → review that single file. Budget: 1 file.
- **Directory path** → scan code files in that directory tree.
- **`--diff` flag** → use `git diff --name-only HEAD` (uncommitted) or `git diff --name-only <base>..HEAD`. Only changed files enter the scan.
- **No target** → ask user via `AskUserQuestion`: "What should I review? (file, directory, or --diff for changed files)"

### Step 3: File Budget

| Mode | Max Files (Tier 2 reads) | Max Trace Files (Tier 3) |
|------|-------------------------|-------------------------|
| Quick Scan | 30 | 10 |
| Full Audit | 50 | 15 |

If file count exceeds budget: sort by Grep hit density (matches per file), take top N.

### Step 4: Git Diff Mode

When `--diff` or inside a git repo:

```
□ Check: git rev-parse --is-inside-work-tree
□ If yes and --diff not specified: offer via AskUserQuestion:
    (A) Review only changed files (recommended)
    (B) Review all files in target
□ For --diff: git diff --name-only HEAD → file list
□ Filter to code files only (exclude binary, assets, lockfiles)
```

### Step 5: State Initialization (Full Audit Only)

```
□ mkdir -p .review
□ Write .review/state.json:
  {
    "version": "1.0",
    "skill": "code-reviewer",
    "project_name": "<detected>",
    "mode": "full_audit",
    "current_phase": "detect",
    "tech_stack": ["<detected>"],
    "scope": "<target>",
    "file_count": <N>,
    "roles_completed": [],
    "findings": [],
    "created_at": "<ISO>",
    "updated_at": "<ISO>"
  }
```

---

## SCAN Phase — 角色驱动扫描

### Tiered Scanning Strategy

Each dimension scan follows a 3-tier funnel to manage context:

```
Tier 1: GREP SCAN (pattern matching, no file reading)
  → Run Grep patterns from dimension-catalog.md against target files
  → Output: candidate file list + matching lines
  → Context cost: minimal (paths + line snippets)

Tier 2: TARGETED READ (only Grep-hit files)
  → Read files that had Grep matches in Tier 1
  → Respect file budget (30 Quick / 50 Full)
  → If over budget: sort by match density, take top N
  → Review matched regions + surrounding context

Tier 3: DEEP ANALYSIS (only HIGH/CRITICAL findings)
  → For findings classified HIGH or CRITICAL in Tier 2:
  → Trace call chains, data flow, cross-file dependencies
  → Read additional files only for tracing (within trace budget)
```

### Role-First Scanning Loop

```
FOR each active role (order: Developer → Security Expert → Architect → [Ops/SRE]):
    □ Load role perspective from role-perspectives.md
    □ Create TaskCreate entry: "[Code Review] <Role> scanning"

    FOR each PRIMARY dimension of this role:
        □ Load dimension patterns from dimension-catalog.md
        □ Tier 1: Run Grep patterns against scope files
        □ Tier 2: Read top hit files (within budget)
        □ Classify each finding: CRITICAL / HIGH / MEDIUM / LOW / INFO
        □ Record: { file, line, severity, dimension, role, description }

    IF Full Audit mode:
        FOR each SECONDARY dimension of this role:
            □ Same Tier 1 → Tier 2 process, but lighter depth
            □ Only escalate to Tier 3 for CRITICAL findings

    □ Mark role as completed
    □ Update state.json (Full Audit only)
```

### Active Roles by Mode

| Mode | Active Roles |
|------|-------------|
| Quick Scan | Developer, Security Expert, Architect |
| Full Audit | Developer, Security Expert, Architect, Ops/SRE |

### Severity Definitions

| Severity | Criteria |
|----------|----------|
| CRITICAL | Exploitable vulnerability, data loss risk, system crash, security breach |
| HIGH | Likely bug causing incorrect behavior, data corruption, significant perf degradation |
| MEDIUM | Potential issue under edge conditions, code smell with moderate risk |
| LOW | Minor improvement, defensive coding suggestion, non-critical optimization |
| INFO | Observation, style note, or documentation suggestion — no defect |

---

## Finding Deduplication — 去重合并

Multiple roles may flag the same code location. Deduplicate before reporting.

### Dedup Algorithm

```
1. Collect all raw findings from all roles
2. Sort by (file_path, line_number)
3. Group: findings with same file AND line difference ≤ 3 → same group
4. For each group:
   a. Merge into single Finding
   b. Keep: highest severity across all roles
   c. Keep: union of all role tags
   d. Keep: union of all dimension tags
   e. Merge descriptions (prefer most detailed)
5. Assign unique IDs: F-001, F-002, ...
6. Sort final list by severity (CRITICAL first)
```

### Finding Schema

```
{
  "id": "F-001",
  "file": "src/auth.ts",
  "line": 42,
  "severity": "HIGH",
  "dimensions": ["D1", "D5"],
  "roles": ["Security Expert", "Developer"],
  "description": "SQL injection via unsanitized user input in login query",
  "suggestion": "Use parameterized queries instead of string concatenation"
}
```

---

## Context Budget Summary

| Item | Quick Scan | Full Audit |
|------|-----------|------------|
| Tier 2 file reads | 30 | 50 |
| Tier 3 trace reads | 10 | 15 |
| Total max reads | 40 | 65 |
| Roles | 3 | 4 |
| Dimensions per role | PRIMARY only | PRIMARY + SECONDARY |
