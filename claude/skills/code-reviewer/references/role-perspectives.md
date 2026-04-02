# Role Perspectives — 角色视角

> 4 expert roles with their PRIMARY and SECONDARY dimension assignments.
> Each role brings a unique perspective to the code review.

---

## Role × Dimension Matrix

| Dimension | Developer | Security Expert | Architect | Ops/SRE |
|-----------|:---------:|:---------------:|:---------:|:-------:|
| D1 Security | - | **PRIMARY** | - | - |
| D2 Logic | **PRIMARY** | - | - | - |
| D3 Concurrency | **PRIMARY** | - | SECONDARY | - |
| D4 Performance | SECONDARY | - | **PRIMARY** | SECONDARY |
| D5 Error Handling | **PRIMARY** | SECONDARY | - | - |
| D6 Dependencies | - | **PRIMARY** (CVEs) | - | **PRIMARY** (freshness) |
| D7 Consistency | **PRIMARY** | - | **PRIMARY** | - |
| D8 Architecture | - | - | **PRIMARY** | - |
| D9 Testing | SECONDARY | - | SECONDARY | - |
| D10 Docs & CI/CD | - | - | - | **PRIMARY** |

**Quick Scan**: Developer + Security Expert + Architect (PRIMARY only)
**Full Audit**: All 4 roles (PRIMARY + SECONDARY)

---

## Role 1: Developer — 开发者视角

**Perspective:** "Does this code work correctly, handle errors properly, and follow project conventions?"

**PRIMARY dimensions:**
1. **D2 Logic Errors** — trace critical paths, check boundary conditions, verify type safety
2. **D3 Concurrency** — verify async/await patterns, check for race conditions on shared state
3. **D5 Error Handling** — ensure errors are caught, logged, and propagated properly
4. **D7 Consistency** — verify code follows project's established patterns and conventions

**SECONDARY dimensions (Full Audit only):**
- **D4 Performance** — flag obvious N+1 patterns and unnecessary computation in hot paths
- **D9 Testing** — check test coverage for the code being reviewed, flag missing tests

**Scan priority order:** D2 → D5 → D3 → D7 → D4 → D9

**Unique focus areas:**
- Readability and maintainability of the code
- Whether the code does what it's supposed to do
- Edge cases the original author may have missed
- Whether error messages are helpful for debugging

---

## Role 2: Security Expert — 安全专家视角

**Perspective:** "Can this code be exploited? Does it protect user data? Are dependencies safe?"

**PRIMARY dimensions:**
1. **D1 Security Vulnerabilities** — full OWASP scan: injection, XSS, auth issues, data exposure
2. **D6 Dependencies (CVEs)** — run native audit tools, check for known vulnerabilities

**SECONDARY dimensions (Full Audit only):**
- **D5 Error Handling** — check if error messages leak internal state or stack traces

**Scan priority order:** D1 → D6 → D5

**Unique focus areas:**
- User input entry points and their sanitization
- Authentication and authorization boundaries
- Data flow from untrusted sources to sensitive sinks
- Credential and secret management
- Third-party dependency vulnerability exposure

---

## Role 3: Architect — 架构师视角

**Perspective:** "Is the codebase well-structured, maintainable, and scalable?"

**PRIMARY dimensions:**
1. **D4 Performance** — identify architectural performance issues (N+1, missing caching layers, unbounded queries)
2. **D7 Consistency** — check for pattern consistency across the codebase, identify partial migrations
3. **D8 Architecture Quality** — evaluate module boundaries, coupling, layering, and separation of concerns

**SECONDARY dimensions (Full Audit only):**
- **D3 Concurrency** — review concurrency architecture (transaction boundaries, lock strategies)
- **D9 Testing** — evaluate test architecture (test isolation, fixture reuse, mock strategy)

**Scan priority order:** D8 → D7 → D4 → D3 → D9

**Unique focus areas:**
- Module dependency graph — circular deps, god modules
- Layer violations (presentation → data, bypassing business logic)
- Abstraction quality — too much or too little
- Scalability bottlenecks at the design level
- Configuration management and externalization

---

## Role 4: Ops/SRE — 运维/SRE 视角

> **Full Audit only.** Not active in Quick Scan mode.

**Perspective:** "Is this code production-ready? Can it be deployed, monitored, and maintained in production?"

**PRIMARY dimensions:**
1. **D6 Dependencies (freshness)** — check for outdated deps, abandoned packages, missing lockfiles
2. **D10 Docs & CI/CD** — verify CI/CD config, Dockerfile quality, deployment readiness, documentation

**SECONDARY dimensions:**
- **D4 Performance** — production-relevant performance: resource leaks, connection pool sizing, timeout configuration

**Scan priority order:** D10 → D6 → D4

**Unique focus areas:**
- Deployment configuration (Dockerfile, k8s manifests, env vars)
- Observability: logging, metrics, health checks
- Graceful shutdown and startup sequences
- Resource limits and timeout configuration
- Dependency freshness and supply chain security
- Documentation sufficient for oncall engineers

---

## Role Execution Notes

### Overlap Handling

Some dimensions are shared across roles (e.g., D7 is PRIMARY for both Developer and Architect). Each role scans from its own perspective:

- **Developer on D7:** "Does this code match the patterns used elsewhere in the project?"
- **Architect on D7:** "Are the patterns themselves well-chosen? Is there a migration in progress?"

The findings may differ even on the same dimension. Deduplication (see scan-protocol.md) merges findings at the same location, but keeps distinct observations.

### Scan Independence

Each role scans independently — do not skip a dimension because another role already covered it. Different perspectives catch different issues at the same location.

After all roles complete, the deduplication step merges findings to eliminate redundancy.
