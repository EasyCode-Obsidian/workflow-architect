# Phase 1: Understand

## Entry Checklist

- □ State.json loaded (or created fresh)
- □ `current_phase` set to `"understand"`
- □ `.project-surgeon-lite/` directory exists
- □ Project directory is non-empty

## Step 1: Auto-Scan

Detect the project's tech stack automatically. Check these manifest files:

| Ecosystem | Manifest Files | Test Runner |
|-----------|---------------|-------------|
| Node.js/TS | `package.json`, `tsconfig.json` | `npm test`, `npx jest`, `npx vitest` |
| Python | `pyproject.toml`, `setup.py`, `requirements.txt` | `pytest`, `python -m unittest` |
| Go | `go.mod` | `go test ./...` |
| Rust | `Cargo.toml` | `cargo test` |
| Java | `pom.xml`, `build.gradle` | `mvn test`, `gradle test` |
| .NET | `*.csproj`, `*.sln` | `dotnet test` |

For each detected ecosystem:
- □ Read the manifest file to identify dependencies
- □ Count total files: `Glob("**/*")` excluding `node_modules`, `vendor`, `.git`, `__pycache__`, `target`, `dist`, `build`
- □ Detect test framework presence (look for test directories, test config files)
- □ Read `README.md` first 80 lines (if exists)

Record scan results to state.json `scan` field.

## Step 2: 4-Dimension Review

Run a focused code review across 4 dimensions using Grep + Read:

### D1: Security
Grep patterns:
- Hardcoded secrets: `password\s*=\s*["']`, `api[_-]?key\s*=\s*["']`, `secret\s*=\s*["']`
- SQL injection: `\+.*query`, `f".*SELECT`, `format.*SELECT`
- Dangerous functions: `eval\(`, `exec\(`, `dangerouslySetInnerHTML`

### D2: Logic
Grep patterns:
- Unchecked null: `\.length` without null check, `undefined` access patterns
- Empty catch: `catch.*\{\s*\}`, `except.*pass`
- TODO/FIXME markers: `TODO|FIXME|HACK|XXX|BUG`

### D3: Error Handling
Grep patterns:
- Swallowed errors: `catch.*\{\s*\}`, `except.*pass`, `_ = err`
- Missing error propagation: `console.log(err)` without throw/return
- Unhandled promises: `\.then\(` without `.catch`

### D4: Consistency
Grep patterns:
- Mixed naming: both `camelCase` and `snake_case` in same file type
- Inconsistent imports: both `require()` and `import` in same project
- Style violations: mixed indentation (tabs vs spaces)

For each dimension:
- □ Run Grep across all source files
- □ Count hits per file
- □ Read the **top 20 files** by hit density
- □ Classify each finding: **HIGH** / **MEDIUM** / **LOW**
- □ Record finding counts in state.json `findings_summary`

## Step 3: Present Findings

Display to the user:

```
## Project Fingerprint
- Tech Stack: {detected ecosystems}
- Total Files: {count}
- Has Tests: {yes/no} ({framework})

## Review Findings
| Dimension | HIGH | MEDIUM | LOW |
|-----------|------|--------|-----|
| Security  |  X   |   X    |  X  |
| Logic     |  X   |   X    |  X  |
| Error Handling | X | X    |  X  |
| Consistency |  X  |   X   |  X  |

## Top 5 Hot Spots
1. {file} — {N findings}
2. ...
```

## Step 4: Collect User Goal

Before presenting options, share your hypothesis:
"Based on the scan, I think the priority should be {X} because {Y findings dominate}."

Ask the user via AskUserQuestion:

- **(A) Fix problems** — focus on HIGH findings first
- **(B) Refactor and improve** — address findings + clean up code
- **(C) Custom goal** — user describes what they want

Record to state.json `user_goal` field.

## Step 5: Self-Check

Before proceeding, verify internally:

- □ Did the scan miss any critical area of the codebase?
- □ Are the findings consistent with the detected architecture?
- □ Is the scope realistic for one workflow run?

If any concern: raise it to the user before asking for approval.

## Step 6: Approval Gate

Ask: Ready to proceed to execution?

- **(A) Approve** — proceed to Execute phase
- **(B) Re-scan** — scan specific areas the user points out

On approval:
- □ Update state.json: `current_phase` → `"execute"`
- □ Proceed to Phase 2
