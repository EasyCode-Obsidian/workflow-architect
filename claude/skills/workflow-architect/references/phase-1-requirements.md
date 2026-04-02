# Phase 1: Requirements Collection — 需求收集

> This phase exhaustively gathers user requirements through a structured deep interview.
> Uses `AskUserQuestion` tool to ask one question at a time until coverage thresholds are met.

<!-- 本阶段的目标是通过结构化的深度访谈，全面收集用户需求。 -->

---

## Entry Protocol

1. Check if `.workflow/state.json` exists
   - If YES: read state, check if resuming Phase 1 (may be returning from Phase 2/3 rejection)
   - If NO: create `.workflow/` directory and initialize state.json with `current_phase: "requirements"`
2. If returning from rejection: load existing `requirements.answers`, identify coverage gaps, resume from gaps
3. Initialize coverage_map with all 10 categories set to `"missing"`

## Question Taxonomy

<!-- 10 个类别，分为必需 (mandatory) 和可选 (desirable) 两组 -->

### Mandatory Categories (MUST reach "clear" before proceeding)

#### 1. Project Vision & Goals — 项目愿景与目标
- What problem does this project solve? 这个项目解决什么问题？
- Who benefits from this project? 谁从中受益？
- What does success look like? 成功的标准是什么？
- Is this a new project or extending an existing one? 新项目还是扩展已有项目？
- What is the expected timeline? 预期时间线是什么？

#### 2. Functional Scope — 功能范围
- What are the core features (MVP)? 核心功能有哪些？
- What are explicit non-goals? 明确不做什么？
- Feature priority ranking? 功能优先级排序？
- Are there phases/milestones? 有没有分阶段/里程碑？
- Input/output of each feature? 每个功能的输入输出？

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

#### 5. Tech Stack & Architecture — 技术栈与架构
- Language preference? 语言偏好？
- Framework preference? 框架偏好？
- Monolith / Microservices / Serverless? 单体/微服务/无服务器？
- Deployment target (cloud, on-prem, local)? 部署目标？
- Existing codebase constraints? 现有代码库限制？

### Desirable Categories (at least 3 must reach "partial" or better)

#### 6. Integration & Dependencies — 集成与依赖
- Third-party APIs to integrate? 需要集成的第三方 API？
- Existing systems to connect to? 需要连接的现有系统？
- Import/export data formats? 数据导入导出格式？

#### 7. Non-Functional Requirements — 非功能需求
- Performance targets (response time, throughput)? 性能指标？
- Scalability expectations? 可扩展性期望？
- Availability / uptime requirements? 可用性要求？
- Security requirements beyond auth? 认证以外的安全需求？

#### 8. UX & Interaction Design — 用户体验与交互设计
- Interface type: CLI / Web / Mobile / API-only / Desktop? 界面类型？
- UI framework preference? UI 框架偏好？
- Key screens/pages? 关键页面？
- Responsive / mobile support? 响应式/移动端支持？
- Accessibility requirements? 无障碍需求？

#### 9. Development Constraints — 开发约束
- Team size? 团队规模？
- CI/CD requirements? 持续集成/交付需求？
- Testing strategy (unit, integration, e2e)? 测试策略？
- Documentation requirements? 文档需求？
- Code style / conventions? 代码风格约定？

#### 10. Edge Cases & Risk — 边界情况与风险
- Known tricky scenarios? 已知的棘手场景？
- Migration from existing system? 从现有系统迁移？
- Backward compatibility? 向后兼容性？
- Regulatory / compliance? 法规合规？

## Questioning Protocol

### Rules

1. **One question at a time.** Use `AskUserQuestion` tool for each question. NEVER batch multiple questions.

2. **Smart question selection.** For each question:
   - Evaluate current coverage_map
   - Select the highest-impact category that is still "missing" or "partial"
   - Within that category, pick the question with highest `(Impact × Uncertainty)` score
   - Prefer mandatory categories before desirable ones

3. **Provide recommended answer.** Every question SHOULD include:
   - A "Recommended" option with 1-2 sentence reasoning (if inferable from context)
   - 2-4 concrete options when applicable (use AskUserQuestion's `options` field)
   - An open "Other" option is always available automatically

4. **Coverage-driven depth.** Question count is NOT fixed — it is driven entirely by coverage sufficiency:
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

6. **Follow-up intelligence.** If an answer reveals new complexity:
   - Add follow-up questions to the queue
   - Re-prioritize based on new information
   - There is NO hard question limit — pursue every thread until coverage is sufficient

7. **Never repeat.** Do not ask a question whose answer is already in `requirements.answers`.

8. **Context awareness.** If the skill was invoked in a non-empty project directory:
   - Read existing project files (package.json, go.mod, Cargo.toml, etc.)
   - Pre-fill coverage_map categories that can be inferred
   - Mark inferred categories as "partial" and confirm with user

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
- Categories 1-5 (mandatory) are ALL `"clear"`
- At least 3 of categories 6-10 (desirable) are `"partial"` or better

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

You MUST first complete the brainstorm protocol BS-1 (Reduced Mode — 3 steps):

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

**After ALL checks pass:** persist results to `.workflow/brainstorm/bs-1.md`, update `brainstorm.bs1` in state.json.

**Gap handling:**
- If any role or self-interrogation identifies a significant gap: **DO NOT present the coverage summary**. Generate follow-up questions for the identified gaps and continue Phase 1 questioning.
- If all roles are satisfied: proceed to coverage summary below.

</STOP-GATE>

### Coverage Summary

1. Present coverage summary table:

```
| Category               | Status  |
|------------------------|---------|
| 1. Project Vision      | ✅ Clear  |
| 2. Functional Scope    | ✅ Clear  |
| 3. User Personas       | ✅ Clear  |
| 4. Domain & Data Model | ✅ Clear  |
| 5. Tech Stack          | ✅ Clear  |
| 6. Integration         | 🟡 Partial|
| 7. Non-Functional      | ⬜ Missing|
| 8. UX & Design         | 🟡 Partial|
| 9. Dev Constraints      | 🟡 Partial|
| 10. Edge Cases         | ⬜ Missing|
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
