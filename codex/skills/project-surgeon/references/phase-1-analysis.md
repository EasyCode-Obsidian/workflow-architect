# Phase 1: Analysis — 项目分析详细协议

> This phase performs an automated deep scan of an existing project to understand its structure,
> technology stack, dependency health, and overall architecture before any changes are made.
> The output is a comprehensive analysis report and a confirmed user objective.

<!-- 本阶段对已有项目进行自动化深度扫描，全面了解其结构、技术栈、依赖健康状况和整体架构。 -->

---

## Entry Protocol

1. Check if `.project-surgeon/state.json` exists
   - If YES: read state, check if resuming Phase 1 (may be returning from later phase rejection)
   - If NO: create `.project-surgeon/` directory and initialize state.json with `current_phase: "analysis"`
2. Verify the current working directory is a non-empty project (at least 1 source file or manifest file)
   - If empty: inform user and abort — project-surgeon requires an existing project
3. Initialize `analysis.steps_completed: []` in state.json

## 5-Step Scan Protocol

### Step 1 — Project Discovery Scan（项目发现扫描）

<!-- 扫描项目根目录，建立项目指纹。 -->

Objective: Establish a project fingerprint — what is this project, how big is it, and what does it use?

#### 1.1 Root Marker Detection

Detect project root directory markers in this order:

```
.git/              → Version-controlled project
package.json       → Node.js ecosystem
pyproject.toml     → Python (modern)
go.mod             → Go
Cargo.toml         → Rust
pom.xml            → Java (Maven)
build.gradle       → Java (Gradle)
*.csproj / *.sln   → .NET
Gemfile            → Ruby
composer.json      → PHP
```

If none found: warn user that no recognized project manifest was detected.

#### 1.2 Directory Tree Generation

Generate a depth-limited directory tree (max depth 4), **excluding**:

```
node_modules/  vendor/  .git/  dist/  build/  __pycache__/  .tox/
target/  bin/obj/  .next/  .nuxt/  coverage/  .idea/  .vscode/
```

Use `tree` command if available, fall back to recursive `ls` with Bash.

#### 1.3 File Statistics

Count files by extension and total lines:

- **Preferred**: Use `cloc` if installed (`cloc --json .`)
- **Fallback**: Use Glob (`**/*.<ext>`) + `wc -l` to count lines per extension
- Record: total files, total lines, language breakdown (top 10 extensions)

#### 1.4 Tech Stack Detection

Read manifest files and apply heuristic rules from [analysis-protocol.md](analysis-protocol.md):

- Primary language(s)
- Framework(s) detected
- Package manager
- Build tool(s)
- Test framework(s)
- Linter / formatter configuration

#### 1.5 Entry Documentation

Read the following files if present (first 200 lines each):

```
README.md / README.rst / README.txt
CHANGELOG.md / CHANGES.md / HISTORY.md
CONTRIBUTING.md
LICENSE / LICENSE.md
```

Extract: project description, stated purpose, installation instructions, contribution guidelines.

#### Output

Update state.json field: `analysis.project_fingerprint`

```json
{
  "analysis": {
    "project_fingerprint": {
      "root_markers": ["package.json", ".git/"],
      "directory_tree_depth": 4,
      "file_stats": {
        "total_files": 142,
        "total_lines": 18500,
        "by_extension": { ".ts": 85, ".json": 20, ".md": 12 }
      },
      "tech_stack": {
        "languages": ["TypeScript"],
        "frameworks": ["Express"],
        "package_manager": "npm",
        "build_tools": ["tsc"],
        "test_frameworks": ["jest"],
        "linters": ["eslint", "prettier"]
      },
      "entry_docs": ["README.md", "CONTRIBUTING.md"]
    }
  }
}
```

Update `analysis.steps_completed` — append `"project_discovery"`.

---

### Step 2 — Architecture Pattern Detection（架构模式检测）

<!-- 分析目录命名和代码结构，推断架构风格。 -->

Objective: Infer the project's architectural style, identify entry points, and map module dependencies.

#### 2.1 Directory Pattern Analysis

Analyze top-level and second-level directory names to infer architecture:

| Directory Pattern | Inferred Architecture |
|---|---|
| `controllers/`, `models/`, `views/` | MVC (Model-View-Controller) |
| `domain/`, `application/`, `infrastructure/` | Clean Architecture / Hexagonal |
| `packages/`, `apps/` | Monorepo |
| `services/`, `gateway/`, `api-gateway/` | Microservices |
| `src/` with flat file layout | Script / Utility |
| `routes/`, `middleware/`, `handlers/` | Express/Koa-style layered |
| `features/`, `modules/` | Feature-based / Modular |
| `pages/`, `components/`, `hooks/` | Frontend SPA (React/Vue/Svelte) |
| `cmd/`, `internal/`, `pkg/` | Go standard layout |
| `lib/`, `bin/`, `spec/` | Ruby gem / Rails-like |

If multiple patterns match: report as "hybrid" and list all detected patterns.

#### 2.2 Entry Point Detection

Search for entry points using Glob:

```
main.*  index.*  app.*  cli.*  server.*  start.*
cmd/*/main.*  bin/*  src/main.*  src/index.*  src/app.*
```

Record each entry point: file path, apparent purpose (web server, CLI, library export, etc.).

#### 2.3 Module Dependency Mapping

Use Grep to scan import/require statements across all source files:

- **JavaScript/TypeScript**: `import .* from`, `require(`, `import(`
- **Python**: `import `, `from .* import`
- **Go**: `import (`
- **Rust**: `use `, `mod `
- **Java**: `import `

Build a summary: which modules/packages are most imported (top 10 by frequency), which are leaf modules (imported but do not import others).

#### 2.4 Key Abstraction Identification

Search for architectural abstractions using Grep:

- `interface ` / `abstract class` / `trait ` / `protocol `
- Shared type definition files (`types.ts`, `types.go`, `models.py`, etc.)
- Configuration / registry patterns (`register`, `provider`, `factory`, `singleton`)
- Dependency injection patterns (`@Inject`, `@Injectable`, `inject(`, `container.`)

Record each abstraction: file path, name, apparent purpose.

#### Output

Update state.json field: `analysis.architecture_analysis`

```json
{
  "analysis": {
    "architecture_analysis": {
      "detected_patterns": ["MVC", "Layered"],
      "confidence": "high",
      "entry_points": [
        { "file": "src/server.ts", "purpose": "HTTP server" }
      ],
      "top_imports": [
        { "module": "express", "import_count": 24 },
        { "module": "./utils/logger", "import_count": 18 }
      ],
      "key_abstractions": [
        { "file": "src/types/index.ts", "type": "shared_types" }
      ]
    }
  }
}
```

Update `analysis.steps_completed` — append `"architecture_detection"`.

---

### Step 3 — Dependency Health Check（依赖健康检查）

<!-- 检查依赖的安全性、过时程度和使用情况。 -->

Objective: Assess the health of the project's dependency tree — vulnerabilities, outdated packages, and unused dependencies.

#### 3.1 Lockfile Detection

Read the lockfile (NOT the manifest) to get pinned versions:

| Ecosystem | Lockfile |
|---|---|
| Node.js | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` |
| Python | `Pipfile.lock`, `poetry.lock`, `requirements.txt` (pinned) |
| Go | `go.sum` |
| Rust | `Cargo.lock` |
| Java | `gradle.lockfile` |
| Ruby | `Gemfile.lock` |
| PHP | `composer.lock` |
| .NET | `packages.lock.json` |

If no lockfile exists: warn user — unpinned dependencies are a risk.

#### 3.2 Native Audit Tool Execution

Run the ecosystem-appropriate audit tool:

| Ecosystem | Audit Command |
|---|---|
| Node (npm) | `npm audit --json 2>/dev/null` |
| Node (yarn) | `yarn audit --json 2>/dev/null` |
| Node (pnpm) | `pnpm audit --json 2>/dev/null` |
| Python (pip) | `pip audit --format json 2>/dev/null` |
| Python (safety) | `safety check --json 2>/dev/null` |
| Rust | `cargo audit --json 2>/dev/null` |
| Go | `govulncheck -json ./... 2>/dev/null` |
| Ruby | `bundle audit check --format json 2>/dev/null` |
| Java (Maven) | `mvn dependency-check:check 2>/dev/null` |
| .NET | `dotnet list package --vulnerable --format json 2>/dev/null` |

**Fallback** (if audit tool not installed): Use WebSearch to check the top 5 critical dependencies (by import frequency from Step 2) for known CVEs.

#### 3.3 Outdated Major Version Detection

Compare lockfile versions with manifest constraints:

- Identify dependencies whose locked version is **2+ major versions behind** the latest
- For Node.js: parse `package.json` dependencies and check if major version in lockfile is far behind
- Flag any deprecated packages (if audit output includes deprecation notices)

#### 3.4 Unused Dependency Detection

Cross-reference manifest dependencies with actual import/require statements (from Step 2):

- For each declared dependency, Grep the source code for import references
- If a dependency appears in manifest but is never imported: flag as "potentially unused"
- **Exceptions**: Do NOT flag: build tools (`webpack`, `vite`, `tsc`), test frameworks, type packages (`@types/*`), plugins, PostCSS/Babel plugins, CLI tools declared in `scripts`

#### Output

Update state.json field: `analysis.dependency_health`

```json
{
  "analysis": {
    "dependency_health": {
      "total_dependencies": 87,
      "vulnerabilities": {
        "critical": 0,
        "high": 2,
        "medium": 5,
        "low": 3
      },
      "outdated_major": [
        { "name": "lodash", "current": "3.10.1", "latest": "4.17.21" }
      ],
      "potentially_unused": ["moment", "chalk"],
      "audit_tool_used": "npm audit",
      "audit_available": true
    }
  }
}
```

Update `analysis.steps_completed` — append `"dependency_health"`.

---

### Step 4 — Documentation & Configuration Inventory（文档与配置清单）

<!-- 盘点项目的文档、配置、CI/CD、容器化和基础设施代码。 -->

Objective: Inventory all documentation, configuration, and infrastructure artifacts.

#### 4.1 Documentation Files

List all documentation files and their last modification date:

- Use `git log -1 --format="%ai" -- <file>` if in a git repo
- Fall back to `stat` for non-git projects
- Files to search: `**/*.md`, `**/*.rst`, `**/*.txt` (excluding dependencies/build dirs)
- Special attention to: API docs, architecture decision records (ADRs), runbooks

#### 4.2 Configuration Management

Detect configuration approach:

| Pattern | Indicator |
|---|---|
| Environment variables | `.env`, `.env.example`, `.env.local`, `dotenv` in dependencies |
| Config modules | `config/`, `settings.*`, `*.config.js/ts`, `application.yml` |
| Feature flags | `flags.*`, `features.*`, LaunchDarkly/Unleash in dependencies |
| Secret management | `.env` in `.gitignore`, vault references, AWS SSM references |

**Security check**: Verify `.env` is in `.gitignore`. If not: flag as CRITICAL finding.

#### 4.3 Containerization

Detect container configuration:

- `Dockerfile` / `Dockerfile.*` (multi-stage?)
- `docker-compose.yml` / `docker-compose.*.yml`
- `.dockerignore`
- Container orchestration: `k8s/`, `kubernetes/`, `helm/`, `kustomize/`

#### 4.4 CI/CD Pipelines

Detect CI/CD configuration:

| CI System | Config File(s) |
|---|---|
| GitHub Actions | `.github/workflows/*.yml` |
| GitLab CI | `.gitlab-ci.yml` |
| Jenkins | `Jenkinsfile` |
| CircleCI | `.circleci/config.yml` |
| Travis CI | `.travis.yml` |
| Azure Pipelines | `azure-pipelines.yml` |
| Bitbucket Pipelines | `bitbucket-pipelines.yml` |

#### 4.5 Infrastructure as Code

Detect IaC:

- `terraform/`, `*.tf` → Terraform
- `pulumi/`, `Pulumi.yaml` → Pulumi
- `cloudformation/`, `template.yaml` → CloudFormation
- `cdk/`, `cdk.json` → AWS CDK
- `ansible/`, `playbook.yml` → Ansible

#### 4.6 Test Configuration

Detect test setup:

| Framework | Config File |
|---|---|
| Jest | `jest.config.*` |
| Vitest | `vitest.config.*` |
| Mocha | `.mocharc.*` |
| Pytest | `pytest.ini`, `pyproject.toml [tool.pytest]`, `conftest.py` |
| Go test | `*_test.go` files |
| RSpec | `.rspec`, `spec/` |
| JUnit | `src/test/` |
| xUnit/.NET | `*.Tests.csproj` |

Count test files and estimate test coverage configuration (look for coverage config in test framework config).

#### Output

Update state.json field: `analysis.documentation_inventory`

```json
{
  "analysis": {
    "documentation_inventory": {
      "doc_files": [
        { "path": "README.md", "last_modified": "2024-11-15" },
        { "path": "docs/api.md", "last_modified": "2024-08-03" }
      ],
      "config_approach": ["env_files", "config_module"],
      "env_in_gitignore": true,
      "containerization": {
        "dockerfile": true,
        "docker_compose": true,
        "orchestration": null
      },
      "ci_cd": ["github_actions"],
      "iac": null,
      "test_config": {
        "framework": "jest",
        "test_file_count": 34,
        "coverage_configured": true
      }
    }
  }
}
```

Update `analysis.steps_completed` — append `"documentation_inventory"`.

---

### Step 5 — Generate Report + Collect User Goal（生成报告 + 收集目标）

<!-- 综合前 4 步结果，生成分析报告，收集用户目标。 -->

Objective: Synthesize all findings into a readable report, present it to the user, and collect their objective.

#### 5.1 Report Generation

Write `.project-surgeon/analysis-report.md` using the analysis-report template. The report must include:

1. **Project Overview** — Name, size, tech stack, architecture style
2. **Architecture Summary** — Detected patterns, entry points, key abstractions
3. **Dependency Health** — Vulnerability summary, outdated packages, unused dependencies
4. **Documentation & Infrastructure** — Config approach, CI/CD, containerization, test coverage
5. **Key Observations** — Notable findings, potential risks, areas of concern
6. **Recommendations** — Suggested areas for improvement (brief, not prescriptive)

#### 5.2 Present Summary to User

Display a condensed summary (NOT the full report) to the user:

```
## Project Analysis Summary

- **Project**: <name> (<size> — <N> files, <N> lines)
- **Stack**: <language(s)> / <framework(s)>
- **Architecture**: <detected pattern>
- **Vulnerabilities**: <critical>C / <high>H / <medium>M / <low>L
- **Outdated deps**: <count> packages behind major version
- **Test coverage**: <configured/not configured>
- **CI/CD**: <detected or none>
- **Key concerns**: <1-3 bullet points>
```

#### 5.3 Collect User Objective

**Pre-Question Analysis (PQCP-lite):** Before presenting the goal options, synthesize your findings into a hypothesis:

```
□ Based on the analysis findings, form a hypothesis about what the user likely wants:
  - If HIGH security findings dominate → hypothesis: "Fix specific problems (security-focused)"
  - If architecture issues dominate → hypothesis: "Comprehensive refactoring"
  - If dependencies are severely outdated → hypothesis: "Modernize"
  - If code quality is generally good → hypothesis: "Add new features"
□ Present your hypothesis alongside the options:
  "Based on the analysis, I noticed {key findings}. I suspect your priority is {hypothesis}
   because {reasoning}. But here are all the options:"
```

Use `AskUserQuestion` to ask the user their objective:

```
What would you like to do with this project?
你希望对这个项目做什么？

(A) Comprehensive refactoring — 全面重构
    Systematically improve code quality, architecture, and patterns across the project.

(B) Fix specific problems — 修复特定问题
    Address known bugs, vulnerabilities, or issues identified in the analysis.

(C) Add new features — 新增功能
    Extend the project with new capabilities while improving the surrounding code.

(D) Modernize — 现代化升级
    Update the tech stack, dependencies, and patterns to current standards.

(E) Custom — 自定义目标
    Describe your own objective in detail.
```

**If user chooses (E) Custom:** Do NOT accept the first description at face value. Probe deeper:
- "Can you elaborate on WHY this is the priority? What triggered this need?"
- "How does this relate to the issues found in the analysis?"
- "What would success look like specifically?"
This ensures custom goals are well-understood before proceeding to planning.

Record the user's choice (and any elaboration for option E) to `analysis.user_objective` in state.json:

```json
{
  "analysis": {
    "user_objective": {
      "type": "comprehensive_refactoring",
      "description": "User-provided description if Custom, or standard description",
      "confirmed_at": "ISO-8601"
    }
  }
}
```

#### 5.4 BS-1: Validate Analysis Coverage

<STOP-GATE id="BS-1">

**STOP. Do NOT proceed to Phase 2 yet.**

Execute BS-1 brainstorm (Reduced Mode — 3 steps):

1. **Step 1 — Forced Research:** Run at least 2 WebSearch queries about common pitfalls when performing the chosen objective type on this tech stack. Output the `🔍 Research Findings` block. **If a search returns 0 results:** retry with broader keywords; if still 0, label output as `⚠️ AI Inference (search unavailable)` — do NOT present model knowledge as search findings.
2. **Step 4 — Multi-Perspective Evaluation:** From each of 6 roles (User/Dev/Architect/Security/Ops/Maintainer), evaluate: "Did the analysis miss anything critical for this objective?" Output the `🧠 Multi-Perspective Evaluation` block.
3. **Step 5 — Self-Interrogation + Synthesis:**
   - "Is the detected architecture accurate, or could it be misleading?"
   - "Are there hidden dependencies not captured by the manifest scan?"
   - "If this project is 3x more complex than the scan suggests, what did we miss?"
   - Output the `💭 Self-Interrogation` and `✅ Decision` blocks.

**Gap handling:**
- If significant gaps found: run additional targeted scans before proceeding.
- If all perspectives satisfied: proceed to exit protocol.

</STOP-GATE>

Persist results to `.project-surgeon/brainstorm/bs-1.md`, update `brainstorm.bs1` in state.json.

Update `analysis.steps_completed` — append `"report_and_objective"`.

---

## Exit Conditions

<!-- 退出条件：分析报告生成 + 用户目标确认 + 用户批准 → Phase 2 -->

ALL of the following must be true to proceed to Phase 2:

- [ ] Analysis report generated at `.project-surgeon/analysis-report.md`
- [ ] All 5 steps completed (`analysis.steps_completed` contains all 5 step IDs)
- [ ] User objective recorded in `analysis.user_objective`
- [ ] BS-1 brainstorm completed and persisted
- [ ] User approves transition to Phase 2

Present approval gate to user:

```
Analysis complete. Ready to proceed to Phase 2 (Code Review)?
分析完成。是否进入 Phase 2（代码审查）？

(A) Approve — proceed to Phase 2
(B) Re-scan — run additional analysis on specific areas
(C) Abort — stop here (report is saved)
```

On approval:
- Update state.json: `current_phase: "review"`, `analysis.status: "completed"`
- Log phase transition in `phase_history`
- Proceed to Phase 2

## State Updates

After each step, update `analysis.steps_completed` array:

```json
{
  "analysis": {
    "steps_completed": [
      "project_discovery",
      "architecture_detection",
      "dependency_health",
      "documentation_inventory",
      "report_and_objective"
    ]
  }
}
```

This allows resumption from any step if the session is interrupted.
