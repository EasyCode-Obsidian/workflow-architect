# Phase 1: Requirements Collection — 需求收集

> This phase exhaustively gathers user requirements through a structured deep interview.
> Uses `AskUserQuestion` tool to ask one question at a time until coverage thresholds are met.

<!-- 本阶段的目标是通过结构化的深度访谈，全面收集用户需求。 -->

---

## Entry Protocol

1. Check if `.workflow/<name>/state.json` exists
   - If YES: read state, check if resuming Phase 1 (may be returning from Phase 2/3 rejection)
   - If NO: create `.workflow/` directory and initialize state.json with `current_phase: "requirements"`
2. If returning from rejection: load existing `requirements.answers`, identify coverage gaps, resume from gaps
3. Initialize coverage_map with all 10 categories set to `"missing"`
4. **Read Context Bus files:**
   - Read `.workflow/<name>/context/domain-knowledge.md` — incorporate domain understanding into question formulation
   - Read `.workflow/<name>/context/project-brief.md` — use as baseline context
   - Read `.workflow/<name>/context/hypothesis-tracker.md` — use to inform hypothesis generation in PQCP
   - These files were populated by Phase 0 pre-research and contain domain knowledge, competitive insights, and tech ecosystem data
5. Initialize `.workflow/<name>/context/interview-transcript.md` if it does not exist

## Question Taxonomy

<!-- 12 个类别，分为必需 (mandatory) 和可选 (desirable) 两组 -->

### Mandatory Categories (MUST reach "clear" before proceeding)

#### 1. Project Vision & Goals — 项目愿景与目标
- What problem does this project solve? 这个项目解决什么问题？
- Who benefits from this project? 谁从中受益？
- What does success look like? 成功的标准是什么？
- Is this a new project or extending an existing one? 新项目还是扩展已有项目？
- What is the expected timeline? 预期时间线是什么？
- **Production context:** What is the expected user base size at launch? At 6 months? At 1 year?

#### 2. Functional Scope — 功能范围
- What are the core features for launch? 上线的核心功能有哪些？
- What are explicit non-goals? 明确不做什么？
- Feature priority ranking? 功能优先级排序？
- Are there phases/milestones? 有没有分阶段/里程碑？
- Input/output of each feature? 每个功能的输入输出？
- **Production context:** What features are critical-path (downtime = business loss)? Which can degrade gracefully?

#### 3. User Personas & Journeys — 用户角色与旅程
- How many distinct user roles? 有几种用户角色？
- What is the primary user journey? 主要用户旅程是什么？
- Authentication/authorization needs? 认证授权需求？
- Admin vs end-user capabilities? 管理员 vs 终端用户的能力区别？

#### 4. Domain & Data Model — 领域与数据模型
- What are the core entities? 核心实体有哪些？
- Key relationships between entities? 实体间的关键关系？
- Important state transitions? 重要的状态转换？
- Expected data volume and growth? 预期数据量和增长？
- Data persistence requirements? 数据持久化需求？
- **Production context:** What data is sensitive/PII? What are the retention requirements? Backup strategy?

#### 5. Tech Stack & Architecture — 技术栈与架构
- Language preference? 语言偏好？
- Framework preference? 框架偏好？
- Monolith / Microservices / Serverless? 单体/微服务/无服务器？
- Deployment target (cloud, on-prem, local)? 部署目标？
- Existing codebase constraints? 现有代码库限制？
- **Production context:** What infrastructure are you comfortable operating? Managed services vs self-hosted?

#### 6. Performance & Scalability — 性能与可扩展性
- What are the latency targets (p50, p95, p99)? 延迟目标是什么？
- What throughput is expected (requests/sec, concurrent users)? 预期吞吐量？
- What is the expected growth curve? 预期的增长曲线是怎样的？
- Are there peak load events (flash sales, reporting deadlines)? 是否有峰值负载事件？
- Data volume projections (storage, bandwidth)? 数据量预估？
- Caching strategy preferences or constraints? 缓存策略偏好或限制？
- **Production context:** What SLAs/SLOs must be met? What happens if they're breached?

#### 7. Security & Compliance — 安全与合规
- What is the threat model? (who are attackers, what are they after?) 威胁模型是什么？
- What data must be encrypted (at rest, in transit)? 哪些数据需要加密？
- Authentication requirements (MFA, SSO, OAuth)? 认证需求？
- Authorization model (RBAC, ABAC, ReBAC)? 授权模型？
- Regulatory requirements (GDPR, HIPAA, SOC2, PCI-DSS)? 法规合规要求？
- Secrets management approach? 密钥管理方案？
- Audit logging requirements? 审计日志需求？
- **Production context:** What's the worst-case security breach scenario? What's the incident response plan?

### Desirable Categories (at least 4 must reach "partial" or better)

#### 8. Integration & Dependencies — 集成与依赖
- Third-party APIs to integrate? 需要集成的第三方 API？
- Existing systems to connect to? 需要连接的现有系统？
- Import/export data formats? 数据导入导出格式？
- **Production context:** What are the failure modes of each external dependency? Circuit breaker / retry strategy?

#### 9. Observability & Operations — 可观测性与运维
- Monitoring strategy (metrics, dashboards, alerting)? 监控策略？
- Logging approach (structured logging, log levels, aggregation)? 日志方案？
- Distributed tracing needs? 分布式追踪需求？
- Health check and readiness probe design? 健康检查设计？
- CI/CD pipeline requirements? CI/CD 流水线需求？
- Infrastructure as Code (IaC) preferences? 基础设施即代码偏好？
- Runbooks and operational documentation? 运维手册？
- **Production context:** Who gets paged at 3am? What's the on-call rotation?

#### 10. UX & Interaction Design — 用户体验与交互设计
- Interface type: CLI / Web / Mobile / API-only / Desktop? 界面类型？
- UI framework preference? UI 框架偏好？
- Key screens/pages? 关键页面？
- Responsive / mobile support? 响应式/移动端支持？
- Accessibility requirements? 无障碍需求？

#### 11. Development & Quality — 开发与质量
- Team size and experience level? 团队规模和经验水平？
- Testing strategy (unit, integration, e2e, load, chaos)? 测试策略？
- Code quality standards (linting, static analysis, code review)? 代码质量标准？
- Documentation requirements? 文档需求？
- **Production context:** What test coverage thresholds? What gates must pass before deploy?

#### 12. Edge Cases, Risk & Disaster Recovery — 边界情况、风险与灾备
- Known tricky scenarios? 已知的棘手场景？
- Migration from existing system? 从现有系统迁移？
- Backward compatibility requirements? 向后兼容性需求？
- Disaster recovery strategy (RPO, RTO)? 灾难恢复策略？
- Data backup and restore procedures? 数据备份恢复流程？
- Multi-region / failover needs? 多区域/故障转移需求？
- Regulatory / compliance? 法规合规？

## Questioning Protocol

### Rules

1. **One question at a time.** Use `AskUserQuestion` tool for each question. NEVER batch multiple questions.

2. **Smart question selection.** For each question:
   - Evaluate current coverage_map
   - Select the highest-impact category that is still "missing" or "partial"
   - Within that category, pick the question with highest `(Impact × Uncertainty)` score
   - Prefer mandatory categories before desirable ones

3. **Pre-Question Cognitive Protocol (PQCP).** Before formulating EACH question, execute these 3 steps internally:

   **A. SYNTHESIZE — Build current understanding:**
   - Summarize all `requirements.answers` collected so far
   - Identify the emerging project shape (what kind of project is forming?)
   - Note which categories have clear interconnections (e.g., "user mentioned real-time sync in scope, which implies WebSocket in tech stack")
   - Reference `.workflow/<name>/context/domain-knowledge.md` for domain background — do NOT re-derive domain knowledge that was already gathered in Phase 0

   **B. HYPOTHESIZE — Generate likely answers for the next topic:**
   - Based on the emerging project shape, predict 2-3 plausible answers
   - Rank hypotheses by likelihood, with reasoning
   - Identify what would CHANGE in the architecture if each hypothesis is wrong

   **B.5. RESEARCH (conditional) — Validate hypotheses with external data:**
   - **TRIGGER when** the current question targets categories 5 (Tech Stack), 6 (Performance), 7 (Security), 8 (Integration), or 9 (Observability), OR when the domain is unfamiliar:
     - Run 1 WebSearch query to validate your leading hypothesis: `"{technology/pattern} {specific concern} best practices {current year}"`
     - If the project involves known libraries/frameworks: If candidate libraries were identified in Phase 0 (check `.workflow/<name>/context/domain-knowledge.md` Tech Ecosystem section), run 1 DeepWiki `ask` query to verify capability assumptions — this is REQUIRED when candidates are known:
       `bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask "owner/repo" "Does <library> support <hypothesized capability>?"`
     - Integrate findings into hypothesis ranking. If research contradicts leading hypothesis, demote it.
   - **SKIP when** the question is purely about business logic, user preferences, or subjective choices (categories 1-4, 10-12 typically)

   **C. CHALLENGE — Self-interrogate before asking:**
   - "What assumption am I making that the user hasn't confirmed?"
   - "The user hasn't mentioned {X} — is it because it's irrelevant, or because they haven't thought of it?"
   - "If I were a different stakeholder (end-user / PM / security / ops), what would I care about?"

   **When presenting the question:**
   - Show your current understanding briefly: "Based on what you've shared about {A}, I'm thinking {B}..."
   - Present your leading hypothesis as the recommended option with your reasoning chain
   - Frame the question as hypothesis validation: "Does that match your thinking?" not open-ended "What do you want?"
   - The user should be able to see AND CORRECT your reasoning, not just answer a generic question

4. **Provide recommended answer.** Every question SHOULD include:
   - A "Recommended" option with 1-2 sentence reasoning (if inferable from context)
   - 2-4 concrete options when applicable (use AskUserQuestion's `options` field)
   - An open "Other" option is always available automatically

5. **Coverage-driven depth.** Question count is NOT fixed — it is driven entirely by coverage sufficiency:
   - The ONLY goal is to collect enough information to make sound architectural decisions
   - Keep asking as long as mandatory categories have NOT reached "clear"
   - Keep asking as long as fewer than 3 desirable categories have reached "partial"
   - When an answer opens new complexity (e.g., user mentions microservices, multi-tenancy, real-time sync), add follow-up questions — do NOT stop prematurely
   - Conversely, if a simple project's categories are quickly covered, stop early — do NOT pad with unnecessary questions
   - Typical ranges by complexity (for reference only, NOT enforced):
     - Simple project (CLI tool, utility): ~5-10 questions
     - Medium project (web app, API service): ~10-25 questions
     - Complex project (distributed system, platform): ~25-50+ questions

5. **Category completion.** After receiving an answer:
   - Update the category status in coverage_map:
     - `"clear"` — enough detail to make architectural decisions
     - `"partial"` — basic direction known, some details missing
     - `"missing"` — not yet addressed
   - Persist updated coverage_map and new answer to state.json
   - If a single answer covers multiple categories, update all relevant ones

6. **Post-Answer Reflection.** After receiving EACH answer, execute these checks:
   - **CONTRADICTION CHECK:** Does this answer conflict with any previous answer in `requirements.answers`?
     If yes: flag it immediately to the user and ask them to resolve before continuing.
   - **NEW DIMENSION CHECK:** Does this answer open a new area of questioning not in the 12 categories?
     If yes: add follow-up questions with elevated priority. Track: "Opened by answer about {topic}: {new area}"
   - **HYPOTHESIS UPDATE:** Were any of your PQCP hypotheses wrong?
     If yes: note what you learned and adjust your mental model for subsequent questions.
   - **FACT-CHECK (conditional):** If the user's answer includes a specific technology claim or performance assertion:
     - Run 1 WebSearch to verify: `"{claimed technology} {claimed capability} {current year}"`
     - If the user named a specific library/framework not yet researched: If the library was researched in Phase 0 or mentioned in domain-knowledge.md, query DeepWiki to verify:
       `bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask "owner/repo" "Does <library> actually support <claimed feature>?"`
     - If fact-check contradicts the user's claim: flag it diplomatically:
       "I looked into {X} and found that {actual situation}. Would you like to reconsider, or do you have specific context I'm missing?"
     - **SKIP when** the answer is about preferences, team composition, timelines, or other non-verifiable statements
   - **MODEL UPDATE:** How does this answer change your understanding of the overall project shape?
     Update your internal summary of the emerging project before selecting the next question.

7. **Follow-up intelligence.** If an answer reveals new complexity:
   - Add follow-up questions to the queue
   - Re-prioritize based on new information
   - There is NO hard question limit — pursue every thread until coverage is sufficient

8. **Never repeat.** Do not ask a question whose answer is already in `requirements.answers`.

9. **Context awareness.** If the skill was invoked in a non-empty project directory:
   - Read existing project files (package.json, go.mod, Cargo.toml, etc.)
   - Pre-fill coverage_map categories that can be inferred
   - Mark inferred categories as "partial" and confirm with user

10. **Context Bus updates.** After receiving each answer:
   - Append the Q&A pair to `.workflow/<name>/context/interview-transcript.md` in format:
     `### Q{N}: {question}\n**A:** {answer}\n**Category:** {category}\n**Timestamp:** {ISO-8601}\n---`
   - If the answer confirms or denies a hypothesis: update `.workflow/<name>/context/hypothesis-tracker.md` — change the hypothesis Status from OPEN to CONFIRMED/DENIED and add evidence reference

### Question Discipline — 提问纪律

There is **NO hard question limit**. The termination condition is coverage sufficiency, not a number.

However, avoid wasting the user's time:
- **Do NOT ask redundant questions** — if info is already in `requirements.answers`, skip it
- **Do NOT ask low-value questions** — if a category is already "clear", move on
- **DO combine related topics** — if one well-crafted question can cover two gaps, prefer that
- **DO periodically check in** — every ~10 questions, briefly show coverage progress so the user knows where things stand
- If the user signals fatigue or impatience, present the current coverage summary and ask if they want to proceed with what's collected or continue

## Coverage Assessment

After each answer, evaluate sufficiency:

### Sufficient Coverage (ready to proceed)

ALL of the following must be true:
- Categories 1-7 (mandatory) are ALL `"clear"`
- At least 4 of categories 8-12 (desirable) are `"partial"` or better

### Early Exit

The user can signal readiness at any time with phrases like:
- "够了" / "enough" / "proceed" / "继续" / "done" / "下一步"
- When detected: present coverage summary and confirm transition

### Forced Minimum

Even if user signals early exit:
- Category 1 (Project Vision) MUST be at least "partial"
- Category 2 (Functional Scope) MUST be at least "partial"
- If these are "missing": inform user these are essential and ask at least 1 question per category

## Exit Protocol

When coverage is sufficient OR user signals readiness:

### BS-1: Requirements Completeness Brainstorm

<STOP-GATE id="BS-1">

**STOP. Do NOT present the coverage summary or transition to Phase 2 yet.**

You MUST first complete the brainstorm protocol BS-1 (Layer 1 (Reduced — 3 steps)):

1. **Step 1 — Forced Research:** Run at least 2 WebSearch queries about common pitfalls and missed requirements in similar project types. Output the `🔍 Research Findings` block. **If a search returns 0 results:** retry with broader keywords; if still 0, label output as `⚠️ AI Inference (search unavailable)` — do NOT present model knowledge as search findings.
2. **Step 4 — Multi-Perspective Evaluation:** From each of the 6 roles (User/Dev/Architect/Security/Ops/Maintainer), ask: "Are we missing critical requirements?" Output the `🧠 Multi-Perspective Evaluation` block. Each role MUST reference research findings.
3. **Step 5 — Self-Interrogation + Synthesis:**
   - "If we proceed to Phase 2 now, what requirement is most likely to be missing?"
   - "The user didn't mention <domain> — is it because it's unimportant, or because they didn't think of it?"
   - "If the project scope turns out 3x larger than estimated, which requirements become critical but are currently ignored?"
   - Output the `💭 Self-Interrogation` and `✅ Decision` blocks.

**SELF-CHECK:**
- [ ] Research Findings block shown to user?
- [ ] Multi-Perspective Evaluation block shown to user?
- [ ] Self-Interrogation + Decision block shown to user?

**After ALL checks pass:** persist results to `.workflow/<name>/brainstorm/bs-1.md`, update `brainstorm.bs1` in state.json.

**Gap handling:**
- If any role or self-interrogation identifies a significant gap: **DO NOT present the coverage summary**. Generate follow-up questions for the identified gaps and continue Phase 1 questioning.
- If all roles are satisfied: proceed to coverage summary below.

</STOP-GATE>

### Coverage Summary

1. Present coverage summary table:

```
| Category                      | Status  |
|-------------------------------|---------|
| 1. Project Vision             | ✅ Clear  |
| 2. Functional Scope           | ✅ Clear  |
| 3. User Personas              | ✅ Clear  |
| 4. Domain & Data Model        | ✅ Clear  |
| 5. Tech Stack                 | ✅ Clear  |
| 6. Performance & Scalability  | ✅ Clear  |
| 7. Security & Compliance      | ✅ Clear  |
| 8. Integration                | 🟡 Partial|
| 9. Observability & Operations | 🟡 Partial|
| 10. UX & Design               | 🟡 Partial|
| 11. Development & Quality     | 🟡 Partial|
| 12. Edge Cases & Risk         | 🟡 Partial|
```

2. Ask user to confirm: "Requirements collected. Proceed to draft phase?" (需求收集已完成，是否进入草案阶段？)

3. On confirmation:
   - Update state.json: `current_phase: "draft"`, `requirements.status: "completed"`
   - Log phase transition in `phase_history`
   - Proceed to Phase 2

4. On "More to add" (还有补充): continue questioning from current coverage gaps

## Output

Phase 1 does NOT produce any disk artifacts beyond state.json.
All collected requirements are held in state.json's `requirements.answers` array
and in the conversation context for Phase 2 to consume.
