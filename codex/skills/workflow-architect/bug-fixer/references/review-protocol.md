# 7-Dimension Review Protocol — 七维度审查协议

> Systematic code audit covering security, logic, concurrency, performance,
> error handling, dependencies, and consistency.

<!-- 系统化代码审计，覆盖安全、逻辑、并发、性能、错误处理、依赖和一致性七个维度。 -->

---

## Overview

The 7-Dimension Review is a structured scan protocol. Each dimension targets a specific class of defects.
Execute ALL 7 dimensions for every review. In Integrated Mode, prioritize dimensions based on trigger type,
but do not skip any.

<!-- 七维度审查是结构化的扫描协议。每个维度针对一类特定缺陷。所有审查均须执行全部 7 个维度。 -->

## Execution Protocol

<!-- 分层扫描策略：先 Grep 粗筛，再精读命中文件，最后深度分析确认的发现。 -->

### Scan Mode Selection — 扫描模式选择

When the target is a directory (not a single file), first determine the scan mode:

**If inside a git repository**, offer scan mode selection to the user:
- **(A) Incremental scan (recommended)** — only scan files changed since last commit (`git diff`) or since a specified base (`git diff <base>..HEAD`)
- **(B) Full scan** — scan all code files in the target directory

**If NOT inside a git repository**, or target is a single file: proceed with full scan.

Incremental mode drastically reduces file count and context usage while focusing on the most relevant code (recently changed = most likely to contain new bugs).

### Tiered Scanning Strategy — 分层扫描策略

To prevent context window exhaustion on large codebases, the review uses a 3-tier funnel:

```
Tier 1: GREP SCAN (pattern matching, no file reading)
  → Run Grep with each dimension's key patterns against all target files
  → Output: candidate file list + matching lines
  → Context cost: minimal (file paths + line snippets only)

Tier 2: TARGETED READ (only Grep-hit files)
  → Read only files that had Grep matches in Tier 1
  → Context budget: max 30 files
  → If > 30 files matched: sort by match density (matches per file), take top 30
  → For each file: review the matched regions + surrounding context

Tier 3: DEEP ANALYSIS (only confirmed findings)
  → For findings classified as critical or high in Tier 2:
  → Trace call chains, data flow, and cross-file dependencies
  → Read additional files only as needed for tracing
```

**Context budget rules:**
- Tier 1: unlimited files (Grep is lightweight)
- Tier 2: max 30 files read via `Read` tool
- Tier 3: max 10 additional files for tracing
- Total: never exceed ~40 files read per review session

**For single-file targets:** skip Tier 1, go directly to Tier 2 (read the file) and Tier 3.

```
FOR each dimension D (1-7):
    Tier 1: Grep target with dimension D patterns → candidate files
    Tier 2: Read candidates (within budget) → classify findings
    Tier 3: Deep trace critical/high findings → confirm or dismiss
    Output: dimension summary (finding count by severity)
```

**Severity definitions:**

| Severity | Criteria |
|----------|----------|
| critical | Exploitable vulnerability, data loss, system crash, security breach |
| high | Likely bug causing incorrect behavior, data corruption, significant performance degradation |
| medium | Potential issue under edge conditions, code smell with moderate risk |
| low | Minor improvement, defensive coding suggestion, non-critical optimization |
| info | Observation, style note, or suggestion — no defect |

---

## Dimension 1: Security Vulnerabilities — 安全漏洞

<!-- OWASP Top 10 及常见安全问题 -->

**What to look for:**

- **Injection** (SQL, NoSQL, command, LDAP): user input concatenated into queries or commands without sanitization
- **Broken Authentication**: hardcoded credentials, weak token generation, missing session invalidation
- **Sensitive Data Exposure**: secrets in code/logs, missing encryption at rest/transit, PII leakage
- **XXE/Deserialization**: unsafe XML parsing, deserializing untrusted data
- **Broken Access Control**: missing authorization checks, IDOR, privilege escalation paths
- **XSS** (Stored, Reflected, DOM): unsanitized output in HTML/JS contexts
- **CSRF**: state-changing endpoints without CSRF tokens
- **SSRF**: user-controlled URLs in server-side requests
- **Path Traversal**: user-controlled file paths without sanitization
- **Insecure Defaults**: debug mode enabled, permissive CORS, overly broad permissions

**Scan approach:**
1. Search for user input entry points (request parameters, form data, file uploads)
2. Trace data flow from entry to usage (sinks)
3. Check for sanitization/validation at each step
4. Use `Grep` with patterns: `exec(`, `eval(`, `system(`, `subprocess`, `innerHTML`, `dangerouslySetInnerHTML`, `raw(`, `query(.*\+`, `format(.*%s`

## Dimension 2: Logic Errors — 逻辑错误

<!-- 边界条件、空值处理、类型错误、状态管理 -->

**What to look for:**

- **Boundary conditions**: off-by-one errors, empty collection handling, integer overflow/underflow
- **Null/undefined handling**: missing null checks before dereferencing, optional chaining gaps
- **Type confusion**: implicit type coercion (JS `==` vs `===`), wrong type assumptions
- **State management**: race between state read and update, stale state usage, missing state initialization
- **Control flow**: unreachable code, missing break/return, inverted conditions, short-circuit logic errors
- **Boolean logic**: De Morgan's law violations, complex conditions that don't cover all cases
- **Comparison errors**: wrong comparison operator, comparing different types, floating-point equality

**Scan approach:**
1. Trace critical code paths manually — focus on conditionals and loops
2. Check edge cases: empty inputs, max values, null/undefined, zero, negative numbers
3. Verify state transitions are complete and consistent
4. Use `Grep` for patterns: `== null`, `!= null`, `=== undefined`, `.length > 0`, `if (.*&&.*\|\|`

## Dimension 3: Concurrency Issues — 并发问题

<!-- 竞态条件、死锁、线程安全 -->

**What to look for:**

- **Race conditions**: shared mutable state without synchronization, TOCTOU (time-of-check-time-of-use)
- **Deadlocks**: lock ordering violations, nested locks, resource acquisition cycles
- **Thread safety**: non-atomic read-modify-write, shared collections without synchronization
- **Async issues**: unhandled promise rejections, missing await, callback hell, event ordering assumptions
- **Database concurrency**: missing transactions, read-then-write without locking, lost updates

**Scan approach:**
1. Identify shared mutable state (global variables, singleton state, database records)
2. Check synchronization mechanisms (locks, mutexes, transactions, atomic operations)
3. Look for async/await patterns — verify all promises are properly awaited
4. Use `Grep` for patterns: `global `, `async `, `await `, `.lock(`, `setTimeout`, `Promise.all`, `shared`

## Dimension 4: Performance Issues — 性能问题

<!-- N+1 查询、内存泄漏、算法复杂度 -->

**What to look for:**

- **N+1 queries**: ORM calls inside loops, missing eager loading/joins
- **Memory leaks**: event listeners not removed, growing collections without cleanup, circular references
- **Algorithm complexity**: O(n²) or worse in hot paths, unnecessary nested loops
- **Unnecessary work**: redundant computation in loops, missing caching for expensive operations
- **Resource management**: unclosed connections/streams/files, missing connection pooling
- **Payload size**: unbounded query results, missing pagination, oversized responses

**Scan approach:**
1. Look for database/API calls inside loops
2. Check for resource cleanup in finally/defer/disposable patterns
3. Analyze loop nesting depth and data size assumptions
4. Use `Grep` for patterns: `for.*for`, `while.*while`, `forEach.*query`, `.find(.*loop`, `new .*Listener`

## Dimension 5: Error Handling — 错误处理

<!-- 未捕获异常、错误传播、静默失败 -->

**What to look for:**

- **Silent failures**: empty catch blocks, swallowed errors, `catch (e) {}` patterns
- **Missing error handling**: unhandled promise rejections, uncaught exceptions in callbacks
- **Error propagation**: errors not re-thrown or logged, misleading error messages
- **Resource cleanup on error**: missing finally blocks, resources leaked on exception path
- **Error information leakage**: stack traces exposed to users, internal details in error responses
- **Retry without backoff**: infinite retry loops, retry without delay or max attempts

**Scan approach:**
1. Find all catch/except blocks — verify they handle errors meaningfully
2. Check async functions for try/catch or .catch() on all promise chains
3. Verify error responses don't leak internal state
4. Use `Grep` for patterns: `catch.*\{\s*\}`, `catch.*pass`, `except.*pass`, `.catch(`, `console.error`, `logger.error`

## Dimension 6: Dependency Risks — 依赖风险

<!-- 过时依赖、已知 CVE、许可证冲突。优先使用原生审计工具，web search 仅作回退。 -->

**What to look for:**

- **Known vulnerabilities**: packages with published CVEs or security advisories
- **Outdated dependencies**: significantly outdated versions with known issues
- **License conflicts**: dependencies with incompatible licenses for the project's use case
- **Abandoned packages**: dependencies with no recent commits/releases, archived repos
- **Version pinning**: unpinned dependencies that may break on update (using `^` or `*` without lockfile)
- **Unnecessary dependencies**: packages imported but not used, or used for trivial functionality

**Scan approach — Native Audit First (原生审计优先):**

Step 1: Detect project ecosystem by checking for manifest files using `Glob`:

| Manifest File | Ecosystem | Native Audit Command |
|---------------|-----------|---------------------|
| `package.json` + `package-lock.json` | Node.js (npm) | `npm audit --json` |
| `package.json` + `yarn.lock` | Node.js (yarn) | `yarn audit --json` |
| `package.json` + `pnpm-lock.yaml` | Node.js (pnpm) | `pnpm audit --json` |
| `requirements.txt` or `pyproject.toml` | Python | `pip audit --format json` |
| `go.mod` | Go | `govulncheck ./...` |
| `Cargo.toml` | Rust | `cargo audit --json` |
| `pom.xml` | Java (Maven) | `mvn dependency-check:check` |
| `build.gradle` / `build.gradle.kts` | Java/Kotlin (Gradle) | `./gradlew dependencyCheckAnalyze` |
| `Gemfile.lock` | Ruby | `bundle audit check` |
| `composer.lock` | PHP | `composer audit --format json` |

Step 2: Run the native audit command via `Bash`. Parse the JSON/text output for:
- Vulnerability count by severity
- Affected package names and versions
- Recommended fix versions (if available)

Step 3: If native audit command is **not available** (tool not installed, command fails):
- Log: `⚠️ Fallback: native audit tool not available for this ecosystem`
- Fall back to manual checks:
  1. Read the manifest file to extract dependency list
  2. Search the web to check the top 5 most critical dependencies (by centrality) for known CVEs
  3. Mark all web-search-sourced findings as `⚠️ web search fallback — verify manually`

Step 4: Regardless of audit method, also check:
- Verify lockfile exists and is committed to git
- Cross-reference imported packages with manifest — find unused or missing declarations
- Check for `*` or overly broad version ranges without a lockfile

## Dimension 7: Consistency — 一致性

<!-- 与项目已有模式的偏差 -->

**What to look for:**

- **Pattern deviation**: code that doesn't follow the project's established patterns (error handling style, API response format, naming conventions)
- **Convention violations**: mixed naming conventions (camelCase vs snake_case), inconsistent file structure
- **Incomplete migrations**: partially migrated code (old pattern in some files, new pattern in others)
- **Copy-paste errors**: duplicated code with subtle differences that should be identical
- **Configuration drift**: inconsistent configs across environments (dev vs prod vs test)

**Scan approach:**
1. Identify the dominant patterns in the codebase by sampling 3-5 representative files
2. Compare the target code against those patterns
3. Check for recently changed files that deviate from older established patterns
4. In Integrated Mode: compare against the task plan's specified patterns and conventions

---

## Prioritization in Integrated Mode — 集成模式优先级

When triggered from the parent workflow-architect:

| Trigger | Priority Dimensions | Rationale |
|---------|-------------------|-----------|
| 3-Strike escalation | #2 Logic → #5 Error Handling → #1 Security | Code is failing — focus on correctness first |
| Milestone checkpoint | All 7 equally | Comprehensive review of phase deliverables |
| User request | Based on user's description | User knows what concerns them |

In all cases: execute all 7 dimensions, but allocate more attention (deeper scan, more patterns) to priority dimensions.

## Output Format — 输出格式

Each dimension produces a section in the review report:

```markdown
### Dimension N: <Name>

Findings: X (C critical, H high, M medium, L low, I info)

| ID | Severity | File:Line | Description | Suggested Fix |
|----|----------|-----------|-------------|---------------|
| D<N>-1 | critical | src/auth.ts:42 | SQL injection via unsanitized user input | Use parameterized queries |
| D<N>-2 | high | src/api.ts:118 | Missing null check before .length | Add optional chaining or guard clause |
```

Finding IDs use the format `D<dimension>-<sequence>`, e.g., `D1-3` = Dimension 1, finding 3.
