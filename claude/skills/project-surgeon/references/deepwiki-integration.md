# DeepWiki Integration — API 研究协议

> Phase 4 execution enhancement: 3-tier research protocol using DeepWiki to query GitHub repository documentation before and during coding.

<!-- 在 Phase 4 编码前和编码中，通过 DeepWiki 三级研究协议查询 GitHub 仓库文档，确保 API 使用最佳实践。 -->

---

## Overview

DeepWiki provides AI-powered documentation for any GitHub repository. This integration uses DeepWiki's Streamable HTTP MCP endpoint directly — **no MCP configuration, no session restart required**.

<!-- 直接调用 DeepWiki 的 HTTP MCP 端点，无需配置 MCP，无需重启会话。 -->

### Available Operations

| Operation | Purpose | Rate Limit |
|-----------|---------|------------|
| `ask` | Ask a question about repo(s) — **core operation** | Moderate (retry on 429) |
| `structure` | Get documentation topic tree | Unrestricted |
| `contents` | Get full documentation text | Unrestricted |

### Script Location

Two scripts are provided for cross-platform support:

```
${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh    # Unix/macOS (bash + curl)
${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.ps1   # Windows (PowerShell + Invoke-WebRequest)
```

**Auto-detect platform:** Use `.ps1` on Windows (`OS` = `Windows_NT`), `.sh` otherwise.

Usage (Unix):
```bash
# Single repo
bash <script-path> ask "expressjs/express" "How to structure middleware?"

# Cross-repo query (max 10 repos)
bash <script-path> ask '["expressjs/express","prisma/prisma"]' "How to integrate Prisma with Express error handling?"

# Get documentation structure
bash <script-path> structure "expressjs/express"
```

Usage (Windows):
```powershell
# Single repo
powershell -File <script-path> ask "expressjs/express" "How to structure middleware?"

# Cross-repo query (max 10 repos)
powershell -File <script-path> ask '["expressjs/express","prisma/prisma"]' "How to integrate Prisma with Express?"

# Get documentation structure
powershell -File <script-path> structure "expressjs/express"
```

The script includes built-in retry with exponential backoff (10s → 30s → 60s) for 429 rate limiting.

---

## 3-Tier Research Protocol — 三级研究协议

### Design Principle — 设计原则

<!-- 三级查询从宽到窄，逐步聚焦：Phase 建立全局知识 → Task 聚焦任务上下文 → 编码时解决具体问题。 -->

```
Tier 1 (Phase)  ── broad knowledge base ──────── "What can this library do?"
Tier 2 (Task)   ── focused task context ──────── "How to use X for this task?"
Tier 3 (Coding) ── precise implementation ────── "What's the exact API signature for Y?"
```

Each tier narrows the query scope, building on knowledge acquired from the previous tier.

---

### Tier 1: Phase-Level Batch Research — 阶段级批量研究

<!-- 每个执行阶段开始时，批量查询该阶段涉及的所有库，建立全局知识基础。 -->

**When:** At the start of each execution phase, AFTER reading `phase-plan.md`, BEFORE executing any tasks.

**Purpose:** Build a broad knowledge foundation for the entire phase.

**Protocol:**

1. **Extract dependencies:** Read the phase plan's task table. Identify all libraries, frameworks, and tools referenced across all tasks in this phase.

2. **Map to GitHub repos:** Map each dependency to its `owner/repo` identifier:
   - Common mappings: `express` → `expressjs/express`, `react` → `facebook/react`, `prisma` → `prisma/prisma`
   - If unsure: search `https://github.com/<name>/<name>` or `https://github.com/<name>` first
   - Record the mapping for Tier 2/3 reuse

3. **Batch structure queries:** For each repo, run `structure` to understand available documentation topics:
   ```bash
   bash <script> structure "owner/repo"
   ```

4. **Batch ask queries:** For each repo, ask ONE broad question:
   ```
   "What are the core APIs and best practices for [library] relevant to [phase objective]?"
   ```

5. **Cross-repo integration query:** If the phase involves multiple libraries working together, ask ONE cross-repo question:
   ```bash
   bash <script> ask '["repo1","repo2","repo3"]' \
     "What are the integration patterns and common pitfalls when using these together?"
   ```

6. **Persist results:** Save research output to `.project-surgeon/deepwiki-cache/phase-N-research.md` for reference during task execution.

**Output:** Present a brief research summary to the user:
```
📚 DeepWiki Phase Research — Phase N: <name>
Libraries researched: express (expressjs/express), prisma (prisma/prisma), ...
Key findings:
- <finding 1>
- <finding 2>
- <cross-repo insight>
Cache: .project-surgeon/deepwiki-cache/phase-N-research.md
```

---

### Tier 2: Task-Level Focused Research — 任务级聚焦研究

<!-- 每个任务开始时，针对该任务涉及的具体 API 进行聚焦查询。 -->

**When:** At the start of each task, AFTER reading the task plan, BEFORE executing steps.

**Purpose:** Understand the specific APIs and patterns needed for this task.

**Protocol:**

1. **Identify task-specific APIs:** From the task plan's steps and file list, extract which specific APIs, methods, or patterns will be used.

2. **Formulate focused questions:** Ask about the specific APIs, not general overviews:
   - Good: `"How does Prisma's createMany handle duplicate keys and what are the error types?"`
   - Bad: `"Tell me about Prisma"` (too broad — that's Tier 1)

3. **Cross-repo for integration tasks:** If the task involves connecting multiple libraries:
   ```bash
   bash <script> ask '["prisma/prisma","expressjs/express"]' \
     "How to handle Prisma transaction errors in Express error-handling middleware?"
   ```

4. **Check Tier 1 cache first:** Before querying, check if the answer is already in the phase-level research cache. Only query DeepWiki if the cache doesn't cover the specific API.

**Question formulation rules:**
- Start with the specific API name or pattern
- Include the context of what you're trying to achieve
- Mention constraints (version, environment) if relevant
- One question per query — compound questions get unfocused answers

---

### Tier 3: Coding-Time Precise Research — 编码时精确研究

<!-- 编码过程中遇到 API 不确定时，即时查询精确用法。 -->

**When:** During step execution, when encountering API uncertainty while writing code.

**Purpose:** Get precise API signatures, parameter details, edge case handling.

**Trigger conditions (any one):**
- About to use an API method for the first time
- Unsure about parameter types, return values, or error behavior
- Implementing error handling for a library-specific error type
- Configuring library options with multiple valid approaches

**Protocol:**

1. **Ask precise questions:**
   - `"What are the exact parameters and return type of prisma.user.findUnique?"`
   - `"What errors does express res.sendFile throw and how to handle each?"`
   - `"What is the correct way to configure CORS with credentials in Express 5?"`

2. **Code-centric format:** When asking about implementation patterns, frame the question around the code you're writing:
   ```
   "I'm implementing JWT middleware in Express. What's the recommended pattern for
    verifying tokens and attaching user data to the request object?"
   ```

3. **No caching needed:** Tier 3 queries are one-off, context-specific. Results feed directly into the code being written.

**Anti-pattern: Do NOT use Tier 3 for:**
- General "how does X work" questions (that's Tier 1)
- Task-level planning questions (that's Tier 2)
- Questions already answered by Tier 1/2 research

---

## Library-to-Repo Mapping — 库名到仓库的映射

<!-- Phase 3 写计划时就应记录依赖的 GitHub 仓库地址，Phase 4 直接使用。 -->

### Phase 3 Integration

During Phase 3 (plan writing), task plans SHOULD include a `Dependencies` section listing GitHub repos:

```markdown
## Dependencies
- express → expressjs/express
- prisma → prisma/prisma
- jsonwebtoken → auth0/node-jsonwebtoken
```

This mapping is created once and reused across all three research tiers.

### Auto-Detection

If the project has a `package.json`, `requirements.txt`, `go.mod`, etc., the dependency-to-repo mapping can be partially automated:

```bash
# For Node.js: extract dependencies from package.json
cat package.json | jq -r '.dependencies // {} | keys[]'
```

Then map each package name to its GitHub repo using `npm info <pkg> repository.url` or equivalent.

### Common Mappings

| Package | GitHub Repo |
|---------|-------------|
| express | expressjs/express |
| react | facebook/react |
| next | vercel/next.js |
| prisma | prisma/prisma |
| fastify | fastify/fastify |
| nestjs | nestjs/nest |
| vue | vuejs/core |
| django | django/django |
| flask | pallets/flask |
| gin | gin-gonic/gin |
| spring-boot | spring-projects/spring-boot |

---

## Error Handling & Fallback — 错误处理与降级

<!-- 429 限流时重试，彻底失败时降级到 WebSearch。 -->

### Retry Strategy (built into script)

```
ask_question call:
  ├── Success → use result
  └── 429 → wait 10s → retry
         ├── Success → use result
         └── 429 → wait 30s → retry
                ├── Success → use result
                └── 429 → wait 60s → final retry
                       ├── Success → use result
                       └── Fail → fallback
```

### Fallback Chain

When DeepWiki is unavailable (network error, sustained 429, or service down):

1. **Fallback to `read_wiki_contents`:** Use the non-rate-limited `contents` command to get full documentation, then analyze it directly.
2. **Fallback to WebSearch:** Search for `"<library> <API> best practices site:github.com OR site:stackoverflow.com"`.
3. **Fallback to model knowledge:** Use existing knowledge with a clear disclaimer: `"⚠️ Based on model knowledge (DeepWiki unavailable)"`.

**Important:** Log all fallbacks in the execution output so the user knows which research sources were used.

---

## Cache Strategy — 缓存策略

<!-- 阶段级研究结果缓存到磁盘，支持会话恢复；任务级和编码级不缓存。 -->

### What to Cache

| Tier | Cache? | Location | Reason |
|------|--------|----------|--------|
| Tier 1 (Phase) | Yes | `.project-surgeon/deepwiki-cache/phase-N-research.md` | Expensive batch query; session may restart mid-phase |
| Tier 2 (Task) | No | — | Task-specific; re-query is cheap |
| Tier 3 (Coding) | No | — | One-off; context-specific |

### Cache Format

```markdown
# DeepWiki Research Cache — Phase N: <name>
# Generated: <ISO-8601>

## Repo Map
- express → expressjs/express
- prisma → prisma/prisma

## expressjs/express
### Structure
<wiki structure output>

### Research
**Q:** What are the core APIs and best practices for Express relevant to <phase objective>?
**A:** <answer>

## prisma/prisma
### Structure
<wiki structure output>

### Research
**Q:** <question>
**A:** <answer>

## Cross-Repo Integration
**Q:** <cross-repo question>
**A:** <answer>
```

### Session Resume

On Phase 4 session resume, if `.project-surgeon/deepwiki-cache/phase-N-research.md` exists for the current phase:
- Skip Tier 1 research for that phase
- Use cached results as context for Tier 2/3 queries

---

## Constraints — 约束条件

- **DO NOT** use DeepWiki in Phases 1-3. It is exclusively a Phase 4 coding tool.
- **DO NOT** ask more than 5 questions per task at Tier 2. If you need more, your task granularity may be too coarse.
- **DO NOT** ask vague questions. Every query should be specific and actionable.
- **DO** check Tier 1 cache before making Tier 2/3 queries.
- **DO** use cross-repo queries (`repoName` as array) when integrating multiple libraries — it produces better answers than separate queries.
- **DO** include the script path relative to the Skill directory when instructing the AI to run it.
