# Dimension Catalog — 维度目录

> 10 audit dimensions with Grep patterns, check items, and severity criteria.
> Referenced during SCAN phase for each role's assigned dimensions.

---

## D1: Security Vulnerabilities — 安全漏洞

**Check items:**
- Injection (SQL, NoSQL, command, LDAP): user input in queries/commands without sanitization
- Broken Authentication: hardcoded credentials, weak tokens, missing session invalidation
- Sensitive Data Exposure: secrets in code/logs, missing encryption, PII leakage
- XSS (Stored, Reflected, DOM): unsanitized output in HTML/JS contexts
- CSRF: state-changing endpoints without tokens
- SSRF: user-controlled URLs in server-side requests
- Path Traversal: user-controlled file paths without sanitization
- Insecure Defaults: debug mode, permissive CORS, overly broad permissions

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `exec\(` | Command injection |
| `eval\(` | Code injection |
| `system\(` | Shell command execution |
| `subprocess` | Python subprocess calls |
| `innerHTML` | DOM XSS |
| `dangerouslySetInnerHTML` | React XSS |
| `\.raw\(` | Template literal injection |
| `password\s*=\s*["']` | Hardcoded credentials |
| `secret\s*=\s*["']` | Hardcoded secrets |
| `api[_-]?key\s*=\s*["']` | Hardcoded API keys |
| `PRIVATE.KEY` | Embedded private keys |
| `document\.cookie` | Cookie access |
| `localStorage\.(set\|get)Item` | Client-side storage |
| `\.query\(.*\+` | SQL concatenation |
| `format\(.*%s` | Format string injection |
| `cors.*origin.*\*` | Permissive CORS |
| `verify\s*=\s*False` | Disabled SSL verification (Python) |
| `NODE_TLS_REJECT_UNAUTHORIZED` | Disabled TLS (Node.js) |

**Severity criteria:**
- CRITICAL: Exploitable injection, credential exposure, auth bypass
- HIGH: XSS, CSRF, SSRF, path traversal
- MEDIUM: Insecure defaults, missing headers, weak crypto
- LOW: Informational security suggestions

---

## D2: Logic Errors — 逻辑错误

**Check items:**
- Off-by-one errors in loops and array access
- Null/undefined dereference without guards
- Type confusion (implicit coercion, wrong type assumptions)
- Inverted conditions, missing break/return
- Boolean logic errors (De Morgan violations)
- Floating-point equality comparisons
- Empty collection handling gaps

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `== null` | Loose null check |
| `!= null` | Loose null check |
| `=== undefined` | Undefined check |
| `\.length > 0` | Empty check (may miss length === 0) |
| `\.length == ` | Loose length comparison |
| `if \(.*&&.*\|\|` | Complex boolean logic |
| `\[.*- 1\]` | Off-by-one candidate |
| `catch.*\{\s*\}` | Empty catch (also D5) |
| `TODO\|FIXME\|HACK\|XXX` | Known issues left in code |
| `== ` (JS/TS files only) | Loose equality |

**Severity criteria:**
- CRITICAL: Null deref in critical path, data corruption logic
- HIGH: Off-by-one causing wrong behavior, type confusion in API
- MEDIUM: Edge case gaps, complex boolean logic
- LOW: Style issues, unnecessary complexity

---

## D3: Concurrency Issues — 并发问题

**Check items:**
- Race conditions: shared mutable state without synchronization
- TOCTOU (time-of-check-time-of-use)
- Deadlocks: lock ordering violations, nested locks
- Unhandled promise rejections, missing await
- Database concurrency: missing transactions, lost updates

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `async ` | Async function definitions |
| `await ` | Await expressions |
| `Promise\.all` | Parallel promise execution |
| `Promise\.race` | Race condition patterns |
| `setTimeout` | Timer-based async |
| `setInterval` | Recurring async |
| `\.lock\(` | Lock acquisition |
| `mutex` | Mutex usage |
| `global ` | Global mutable state |
| `shared` | Shared state indicators |
| `thread` | Thread references |
| `goroutine\|go func` | Go concurrency |
| `\.acquire\(\|\.release\(` | Semaphore patterns |

**Severity criteria:**
- CRITICAL: Race condition on financial/auth data, deadlock risk
- HIGH: Missing await in critical path, unhandled promise rejection
- MEDIUM: Potential race under high load, missing transaction
- LOW: Missing timeout on async operation

---

## D4: Performance Issues — 性能问题

**Check items:**
- N+1 queries: ORM calls inside loops
- Memory leaks: event listeners not removed, growing collections
- O(n^2) or worse in hot paths
- Redundant computation in loops, missing caching
- Unclosed connections/streams/files
- Unbounded query results, missing pagination

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `for.*for\|while.*while` | Nested loops |
| `forEach.*query\|forEach.*find\|forEach.*fetch` | N+1 query pattern |
| `\.find\(.*loop\|\.query\(.*for` | DB call in loop |
| `new .*Listener` | Listener creation (check cleanup) |
| `addEventListener` | Event listener (check removeEventListener) |
| `setInterval` | Interval (check clearInterval) |
| `\.push\(` in loop | Growing array in loop |
| `JSON\.parse\(JSON\.stringify` | Deep clone by serialization |
| `\.map\(.*\.map\(` | Nested map operations |
| `SELECT \*` | Unbounded select |
| `LIKE '%` | Leading wildcard (full table scan) |

**Severity criteria:**
- CRITICAL: N+1 on high-traffic endpoint, memory leak in long-running process
- HIGH: O(n^2) on large datasets, unclosed DB connection
- MEDIUM: Missing pagination, redundant computation
- LOW: Minor optimization opportunity

---

## D5: Error Handling — 错误处理

**Check items:**
- Silent failures: empty catch blocks, swallowed errors
- Missing error handling on async operations
- Error propagation: errors not re-thrown or logged
- Resource cleanup on error path (missing finally)
- Error info leakage: stack traces in responses
- Retry without backoff

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `catch.*\{\s*\}` | Empty catch block |
| `catch.*pass` | Python empty except |
| `except.*pass` | Python swallowed exception |
| `\.catch\(\)` | Empty promise catch |
| `console\.error` | Error logging (verify handling) |
| `logger\.error` | Error logging (verify handling) |
| `throw new Error\(` | Error creation (verify catch exists) |
| `process\.exit` | Hard exit (verify cleanup) |
| `os\.exit\|sys\.exit` | Hard exit (Python/Go) |
| `panic\(` | Go panic (verify recover) |
| `unwrap\(\)` | Rust unwrap (verify safety) |

**Severity criteria:**
- CRITICAL: Silent failure on data write, missing error handling on payment/auth
- HIGH: Empty catch on network call, error info leaked to client
- MEDIUM: Missing finally for resource cleanup, no retry strategy
- LOW: Inconsistent error logging style

---

## D6: Dependency Risks — 依赖风险

**Check items:**
- Known CVEs via native audit tools
- Outdated dependencies with security issues
- License conflicts
- Abandoned/archived packages
- Unpinned versions without lockfile
- Unused dependencies

**Native audit commands (run via Bash):**

| Ecosystem | Command |
|-----------|---------|
| npm | `npm audit --json` |
| yarn | `yarn audit --json` |
| pnpm | `pnpm audit --json` |
| Python | `pip audit --format json` |
| Go | `govulncheck ./...` |
| Rust | `cargo audit --json` |
| Ruby | `bundle audit check` |
| PHP | `composer audit --format json` |

**Fallback** (if native tool unavailable): Read manifest, use `WebSearch` for top 5 critical deps.

**Grep patterns (supplementary):**

| Pattern | What it catches |
|---------|----------------|
| `"dependencies"` | Package manifest section |
| `require\(\|import ` | Import statements |
| `from ["']` | Module imports |

**Severity criteria:**
- CRITICAL: Known exploitable CVE (CVSS ≥ 9.0)
- HIGH: Known CVE (CVSS 7.0-8.9), abandoned critical dependency
- MEDIUM: Outdated major version, missing lockfile
- LOW: Minor version behind, unused dependency

---

## D7: Consistency — 一致性

**Check items:**
- Naming convention violations (mixed camelCase/snake_case)
- Inconsistent error handling patterns across files
- Inconsistent API response formats
- Partially migrated code (old pattern in some files, new in others)
- Configuration drift across environments

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `camelCase` vs `snake_case` in same scope | Naming inconsistency |
| Mixed `async/await` and `.then()` | Promise style inconsistency |
| Mixed `var`/`let`/`const` | Variable declaration inconsistency |
| `module\.exports` vs `export` | Module system inconsistency |
| `require\(` vs `import` | Import style inconsistency |

**Scan approach:**
1. Sample 3-5 representative files to identify dominant patterns
2. Grep for counter-patterns in the target scope
3. Flag deviations from the dominant pattern

**Severity criteria:**
- HIGH: Inconsistency causing bugs (e.g., mixed error handling → some errors unhandled)
- MEDIUM: Pattern deviation reducing maintainability
- LOW: Style inconsistency

---

## D8: Architecture Quality — 架构质量

**Check items:**
- Circular dependencies between modules
- God objects/files (single file > 500 lines with mixed concerns)
- Layer violations (e.g., UI directly accessing database)
- Missing abstraction boundaries (tight coupling)
- Single responsibility violations
- Hardcoded configuration that should be externalized

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `import.*from ['"]\.\.\/\.\.\/\.\.\/` | Deep relative imports (coupling) |
| `require\(.*\.\.\/\.\.\/\.\.\/` | Deep relative imports |
| `process\.env\.\w+` (outside config files) | Scattered env access |
| `os\.environ\[` (outside config files) | Scattered env access (Python) |
| `hardcoded` port/host/url patterns | Hardcoded config |

**Scan approach:**
1. Use `Glob` to map project structure (directories, file counts)
2. Identify large files (> 500 lines) — read and check for mixed concerns
3. Trace import graphs for top-level modules — detect circular deps
4. Check layer boundaries (does controller import from data layer directly?)

**Severity criteria:**
- HIGH: Circular dependency, layer violation causing tight coupling
- MEDIUM: God file, missing abstraction, scattered config
- LOW: Minor structural improvement

---

## D9: Test Quality — 测试质量

**Check items:**
- Test coverage gaps: critical paths without tests
- Flaky test indicators: sleep/delay in tests, time-dependent assertions
- Missing edge case tests (boundary values, error paths)
- Test isolation: tests depending on execution order or shared state
- Mock overuse: mocking what should be tested, testing implementation details
- Missing assertion: test that runs but never asserts

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `\.skip\(\|\.only\(` | Skipped or focused tests |
| `sleep\|delay\|setTimeout` (in test files) | Flaky test indicator |
| `Date\.now\|new Date` (in test files) | Time-dependent test |
| `expect\(.*\)\.toBe\(true\)` | Weak assertion |
| `assert True` | Weak assertion (Python) |
| `\.toMatchSnapshot` | Snapshot test (check staleness) |
| `mock\|Mock\|stub\|Stub\|spy\|Spy` | Mock usage (check overuse) |
| `it\(.*\{\s*\}\)` | Empty test body |
| `test\(.*\{\s*\}\)` | Empty test body |
| `xit\(\|xdescribe\(` | Disabled tests |

**Scan approach:**
1. Use `Glob` to find test files: `**/*.test.*`, `**/*.spec.*`, `**/test_*`, `**/*_test.*`
2. Count test files vs source files — flag if ratio < 0.3
3. Grep for skip/only/empty patterns
4. For critical source files (auth, payment, data access): check if corresponding test exists

**Severity criteria:**
- HIGH: No tests for critical path (auth, payment), disabled tests forgotten
- MEDIUM: Flaky test indicators, mock overuse, missing edge cases
- LOW: Weak assertions, snapshot staleness

---

## D10: Documentation & CI/CD — 文档与 CI/CD

**Check items:**
- Missing README or outdated README
- Undocumented public APIs
- Missing or broken CI/CD configuration
- No linter/formatter configuration
- Missing contributing guidelines for open-source projects
- Dockerfile issues (running as root, no .dockerignore, large images)

**Grep patterns:**

| Pattern | What it catches |
|---------|----------------|
| `# TODO.*doc\|# FIXME.*doc` | Documentation debt |
| `@param\|@returns\|@throws` | JSDoc presence |
| `Args:\|Returns:\|Raises:` | Python docstring presence |
| `USER root` (in Dockerfile) | Docker running as root |
| `COPY \. \.` (in Dockerfile) | No .dockerignore |

**File checks (Glob):**

| File | What it indicates |
|------|------------------|
| `README.md` | Project documentation |
| `.github/workflows/*.yml` | GitHub Actions CI |
| `.gitlab-ci.yml` | GitLab CI |
| `Jenkinsfile` | Jenkins CI |
| `.eslintrc*`, `.prettierrc*` | JS/TS linting |
| `pyproject.toml` `[tool.ruff]` | Python linting |
| `.editorconfig` | Editor consistency |
| `Dockerfile` | Container config |
| `.dockerignore` | Docker build exclusions |
| `CONTRIBUTING.md` | Contribution guidelines |

**Severity criteria:**
- HIGH: No CI/CD for production project, Dockerfile running as root
- MEDIUM: Missing README, undocumented public APIs, no linter
- LOW: Missing .editorconfig, incomplete docs
