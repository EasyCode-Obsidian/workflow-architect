# Brainstorm Protocol — 头脑风暴协议

> This protocol defines a two-tier deep-thinking process at critical decision points.
> **Lightweight Mode** runs automatically at every trigger point — inline self-reflection, no Agent calls.
> **Full Mode** runs only when the user explicitly requests it — Agent-based, expensive but thorough.

---

## Core Principle — 核心原则

**Every important decision must undergo multi-dimensional review, not follow the first intuition.**

Brainstorming is not template-filling — it is a mechanism that forces the model to **genuinely alter its reasoning path**.

**Two-tier design rationale:** Full Mode (3 Agents + Audit) costs ~30,000-40,000 tokens per point. Three consecutive Full Mode brainstorms in Phase 2 would consume ~100,000+ tokens before any code is written — often exceeding what the context window can sustain. Lightweight Mode achieves ~80% of the value at ~10% of the cost by using structured self-reflection instead of Agent-based generation.

---

## Tier 1: Lightweight Mode (Default) — 轻量模式（默认）

**Runs automatically** at every trigger point. Cannot be skipped.

**Steps (inline, no Agent calls):**

1. **Research** — Run 1-2 WebSearch queries for relevant external facts. Output `🔍 Research Findings` block.
   - If searches return 0 results: retry with broader keywords; if still 0, label as `⚠️ AI Inference`
2. **Multi-Perspective Self-Evaluation** — Review from 6 role perspectives (User/Dev/Architect/Security/Ops/Maintainer) inline. Each role produces 1-2 sentences. Output `🧠 Multi-Perspective` block.
3. **Self-Interrogation + Synthesis** — Select recommendation, raise 3 sharp challenges against it, respond. If a challenge reveals a genuine problem, change the recommendation. Output `💭 Self-Interrogation` and `✅ Decision` blocks.

**Cost:** ~2,000-3,000 tokens per point.

**Output must include:** Decision + Confidence (High/Medium/Low) + Top 2 risks.

---

## Tier 2: Full Mode (User Opt-In) — 完整模式（用户按需）

**Runs ONLY when the user explicitly requests deeper analysis** (e.g., "I want deeper analysis", "run full brainstorm", or `/brainstorm`).

Full Mode adds Agent-based alternative generation, quality gate, and independent audit on top of the Lightweight steps.

---

## Trigger Points — 触发点

**Lightweight Mode** runs automatically at every trigger point. **Full Mode** runs only when the user explicitly requests it.

<!-- 轻量模式在每个触发点自动运行。完整模式仅在用户显式请求时运行。 -->

| Trigger ID | Phase | When | Default Mode | Full Mode Available |
|------------|-------|------|-------------|---------------------|
| BS-1 | Phase 1 → 2 | Requirements collected, before entering draft | Lightweight | ✅ On request |
| BS-2 | Phase 2 | Before producing architecture design (Section 2) | Lightweight | ✅ On request |
| BS-3 | Phase 2 | Before producing tech stack selection (Section 3) | Lightweight | ✅ On request |
| BS-4 | Phase 2 | Before producing algorithm & design strategy (Section 4) | Lightweight | ✅ On request |
| BS-5 | Phase 2 → 3 | Draft approved, before writing plans to disk | Lightweight | ✅ On request |
| BS-6 | Phase 3 | When dividing implementation phases and tasks | Lightweight | ✅ On request |
| BS-7 | Phase 4 | During 3-Strike error recovery | — | ✅ User opt-in only |

**BS-7 is special:** It does NOT run Lightweight by default. It is only triggered when the user explicitly selects Option A (BS-7 deep analysis) after a 3-Strike failure.

---

## Brainstorm Execution — 执行流程

### Mode Determination — 模式判定

<!-- 模式判定规则：默认轻量，用户请求时升级为完整。 -->

At each trigger point:

1. **Default: Lightweight Mode** — always runs automatically (see Tier 1 above)
2. **Upgrade to Full Mode** — only if user explicitly requests deeper analysis (e.g., "run full brainstorm", `/brainstorm`, "I want deeper analysis on this")
3. **BS-7 exception** — user opt-in only, always Full Mode when triggered

**User-preference shortcut (BS-2/3/4):**
When the user specified strong preferences during Phase 1 (e.g., "use React"), Lightweight Mode uses **validation focus**: research validates the choice, multi-perspective evaluates fit, self-interrogation challenges the choice. Flag concerns if found; do NOT generate alternatives the user didn't ask for.

### Disk Persistence — 磁盘持久化

After completing brainstorm (either tier), persist results to `.workflow/brainstorm/bs-N.md`.
This serves two purposes:
1. **Traceability** — the user and future sessions can verify brainstorm was executed
2. **Context relief** — on session resume, results can be re-read instead of re-generated

Update `brainstorm.bsN` in state.json after writing the artifact file.

### Context Management — 上下文管理

Phase 2 triggers up to 4 brainstorms in sequence (BS-2, BS-3, BS-4, BS-5). If any use Full Mode, context can grow substantially. Even Lightweight Mode benefits from these rules.

<!-- Phase 2 最多连续触发 4 次头脑风暴。如果任何一个使用完整模式，上下文会显著增长。 -->

**Rules:**

1. **Persist immediately, summarize in context.** After each brainstorm completes and is persisted to disk (`.workflow/brainstorm/bs-N.md`), keep only a **concise summary** (decision + confidence + top 2 risks) in the conversation. The full artifact is on disk for reference.

2. **Do NOT carry Agent proposals forward (Full Mode).** After Synthesis produces a decision, the 3 Agent proposals, divergence check details, and audit scores are no longer needed in conversation context. They are preserved in the disk artifact.

3. **Reference by file, not by repetition.** When a later brainstorm needs to reference an earlier decision (e.g., BS-4 depends on BS-2's architecture choice), reference the disk artifact: "Per BS-2 decision (see `.workflow/brainstorm/bs-2.md`): chose MVC pattern." Do NOT re-paste the full BS-2 output.

4. **Cumulative summary block.** After each brainstorm, maintain a running summary block:
   ```
   📋 Brainstorm Progress:
   - BS-2 (Architecture): ✅ MVC + Repository pattern | Confidence: High | Mode: Lightweight
   - BS-3 (Tech Stack): ✅ React + Express + MySQL | Confidence: High | Mode: Full
   - BS-4: ⏳ pending
   - BS-5: ⏳ pending
   ```

5. **Lightweight Mode is context-friendly.** Most brainstorms will use Lightweight (~2-3K tokens each), keeping total Phase 2 brainstorm overhead under ~12K tokens.

---

## Full Mode Steps (Tier 2) — 完整模式步骤

The following Steps 1-7 define the Full Mode protocol. **These are ONLY executed when the user requests Full Mode** (or for BS-7 user opt-in). Lightweight Mode uses Steps 1, 4, and 5 inline (see Tier 1 above).

<!-- 以下 Step 1-7 定义完整模式协议。仅在用户请求完整模式时执行。轻量模式使用内联版本的 Step 1/4/5。 -->

### Step 1: Forced Research — 强制信息检索

**Before producing any proposal**, you MUST use the `WebSearch` tool to obtain external facts.
This step breaks the limitation of reasoning purely from training data, constraining thinking with real-world up-to-date information.

<!-- 在产出任何方案之前，必须先用 WebSearch 获取外部事实，打破模型仅靠训练数据推理的局限。 -->

**Rules:**
- For BS-2 (Architecture): Search "<project type> architecture best practices <current year>", known architecture anti-patterns
- For BS-3 (Tech Stack): Search latest versions, known issues, community reviews, and benchmark comparisons for each candidate technology
- For BS-4 (Algorithm): Search real-world performance data and applicable scenario case studies for relevant algorithms
- For BS-7 (Error Recovery): Search the error message itself; look for known solutions
- For BS-1/5/6: Search common pitfalls and best practices in the project's domain

**Output format:**
```
🔍 Research Findings:

Search: "<query>"
- Finding 1: <fact with source>
- Finding 2: <fact with source>
- Finding 3: <fact with source>

Search: "<query>"
- Finding 1: ...
```

**Constraints:**
- Execute at least 2 searches, extracting at least 2 relevant facts per search
- **Search result validation:** After each WebSearch call, check if actual results were returned (result count > 0). If a search returns 0 results:
  - Retry with a rephrased, broader query (e.g., drop year, simplify keywords)
  - If the retry also returns 0 results: label findings from that search as `⚠️ AI Inference (search unavailable)` instead of `🔍 Research Findings`. Do NOT present model-internal knowledge as if it came from search results
  - At least 1 of the 2+ searches MUST return real results. If ALL searches fail, add a prominent warning: `⚠️ All searches failed — findings below are AI inference only, not externally validated`
- Search results MUST be referenced in subsequent steps — do not search and then ignore
- If search results contradict model internal knowledge, defer to search results and annotate the discrepancy

### Step 2: Independent Alternative Generation — 独立方案生成

**For trigger points requiring proposal comparison (BS-2, BS-3, BS-4, BS-7), use the Agent tool to decompose proposal generation into independent subtasks.**

<!-- 对于需要方案对比的触发点，使用 Agent 工具将方案生成拆解为独立子任务。 -->

This step prevents cross-contamination between proposals through physical isolation. Each Agent only sees the requirements, not other proposals.

**Pre-Step: Mutual Exclusion Constraint Derivation — 互斥约束推导**

Before launching Agents, derive exclusion constraints from Step 1 research findings to **structurally prevent convergence**:

<!-- 在启动 Agent 前，从 Step 1 研究结果中推导互斥约束，从结构上防止方案趋同。 -->

1. From Step 1 research, identify the **top 3 mainstream choices** for the decision at hand (e.g., for tech stack: React, Vue, Angular; for database: PostgreSQL, MySQL, MongoDB)
2. Assign each Agent a **hard exclusion constraint** — a specific mainstream choice it is **forbidden** from using:
   - Agent A: BANNED from using Choice #1 (the most popular/default)
   - Agent B: BANNED from using Choice #2
   - Agent C: BANNED from using Choice #3
3. If fewer than 3 mainstream choices exist (niche domain), use **architectural exclusion** instead:
   - Agent A: MUST use a monolithic approach
   - Agent B: MUST use a service-oriented approach
   - Agent C: MUST use an event-driven/serverless approach

The exclusion constraint is appended to each Agent's prompt as a non-negotiable rule.

<!-- 互斥约束作为不可违反的规则附加到每个 Agent 的 prompt 中。 -->

**Execution:**

1. Compile the requirements context into a concise brief (including Step 1 research findings)
2. Launch **3 independent Agents** in parallel (using the Agent tool), each with a different prompt AND a different model for genuine cognitive diversity:
   - **Agent A (Conservative)** — `model: haiku`: "You are an architect who prefers mature, proven technologies. Based on the following requirements, propose your solution. Prioritize stability, community support, and low risk. **HARD CONSTRAINT: You are BANNED from using {{exclusion_A}}. You must find an alternative.**"
   <!-- 你是一个偏好成熟、经过验证的技术的架构师。硬约束：禁止使用 {{exclusion_A}}。 -->
   - **Agent B (Innovative)** — `model: opus`: "You are an architect who prefers cutting-edge technologies and innovative design. Based on the following requirements, propose your solution. Prioritize performance, scalability, and technical advancement. **HARD CONSTRAINT: You are BANNED from using {{exclusion_B}}. You must find an alternative.**"
   <!-- 你是一个偏好前沿技术和创新设计的架构师。硬约束：禁止使用 {{exclusion_B}}。 -->
   - **Agent C (Minimalist)** — `model: sonnet`: "You are a minimalist architect. Based on the following requirements, propose the simplest viable solution. Prioritize implementation speed, code simplicity, and lowest maintenance cost. **HARD CONSTRAINT: You are BANNED from using {{exclusion_C}}. You must find an alternative.**"
   <!-- 你是一个极简主义架构师。硬约束：禁止使用 {{exclusion_C}}。 -->
3. Each Agent must return:
   - Proposal name and one-sentence description
   - Core architecture/technology choices with rationale
   - Key advantages (3 points)
   - Key risks (3 points)
   - Applicable scenarios
4. Collect results from all 3 Agents, proceed to Step 3

**Why different models matter:** Using `haiku`, `opus`, and `sonnet` provides genuine cognitive diversity — different model sizes have different reasoning patterns, knowledge emphasis, and solution preferences. This is structurally stronger than giving the same model different "personalities" via prompt.

<!-- 使用不同模型提供真正的认知多样性——不同大小的模型有不同的推理模式和偏好。 -->

**For trigger points that do not require proposal comparison (BS-1, BS-5, BS-6), skip this step.**

**Output format:**
```
🏗️ Independent Proposals Generated:

Mutual Exclusion Constraints:
- Agent A (haiku): BANNED from <choice_1>
- Agent B (opus): BANNED from <choice_2>
- Agent C (sonnet): BANNED from <choice_3>

[Agent A — Conservative / haiku]: <one-sentence proposal description>
[Agent B — Innovative / opus]: <one-sentence proposal description>
[Agent C — Minimalist / sonnet]: <one-sentence proposal description>
```

### Step 3: Quality Gate — 思考质量自检

**Before proceeding, verify that generated proposals have genuine divergence. This is a quantitative check against "fake diversity".**

<!-- 在继续之前，验证生成的方案是否有真正的差异性。这是防止"伪多样性"的量化检查。 -->

**Divergence Check:**

For the 3 proposals, answer the following questions:

1. **Core tech/pattern difference:** Do the 3 proposals have fundamental differences in core technology choices or architecture patterns?
   - If Proposal A and B use the same framework and same architecture pattern with only naming differences → FAIL
   <!-- 如果方案 A 和 B 用了相同的框架、相同的架构模式，只是命名不同 → 不合格 -->
2. **Trade-off difference:** Does each proposal make different trade-offs along different dimensions?
   - What does Proposal A sacrifice to gain what? Proposal B? If trade-offs are identical → FAIL
   <!-- 方案 A 牺牲了什么来换取什么？如果取舍相同 → 不合格 -->
3. **Scenario difference:** Is there a specific scenario where Proposal A clearly outperforms B, AND another scenario where B clearly outperforms A?
   - If no such scenarios can be found → proposals are not different enough
   <!-- 如果找不到这样的场景 → 方案不够不同 -->
4. **Core technology overlap (MANDATORY PASS):** Do ≥2 proposals share the same primary technology choice (framework, database, OR architecture pattern)?
   - If Agent A and B both chose React + PostgreSQL → FAIL, even if architecture patterns differ
   - This check enforces the mutual exclusion constraints from Step 2 — if proposals converge despite exclusion constraints, the constraints were too narrow
   <!-- 核心技术去重（必须通过）：如果 ≥2 个方案选了相同的主要技术 → 不合格 -->

**Decision rules:**
- At least 3 out of 4 questions answered "Yes" AND Question 4 MUST pass → PASS, continue to Step 4
- Question 4 fails → **FAIL regardless of other scores**, must regenerate with stricter exclusion constraints
- Fewer than 3 "Yes" (with Question 4 passing) → **FAIL, must regenerate proposals**
  - When regenerating, explicitly identify which dimensions lack divergence; instruct Agents to diverge on those dimensions
  - Maximum 4 retries (5 rounds total). Each retry includes the previous round's specific criticism as input
  - If still failing after 5 rounds, the decision likely has only one reasonable approach — record the reason and escalate to user arbitration
  <!-- 如果 5 轮后仍不通过，说明该决策可能确实只有一种合理方案——记录原因并降级为用户裁决 -->

**Output format:**
```
🔬 Divergence Check:

1. Core tech/pattern difference: ✅ Yes / ❌ No — <explanation>
2. Trade-off difference: ✅ Yes / ❌ No — <explanation>
3. Scenario difference: ✅ Yes / ❌ No — <explanation>
4. Core technology overlap: ✅ No overlap / ❌ Overlap detected — <explanation>

Result: PASS (3/4 + #4 pass) / FAIL (2/4 — regenerating...) / FAIL (#4 failed — tightening exclusion constraints...)
```

### Step 4: Multi-Perspective Evaluation — 多角色评估

**With genuinely different proposals and external facts in hand, evaluate from 6 role perspectives.**

<!-- 现在有了真正不同的方案和外部事实，从 6 个角色视角进行评估。 -->

Review each proposal from the following 6 role perspectives. Each role must produce **at least 1 non-obvious** observation or concern:

| Role | Perspective | Key Questions |
|------|------------|---------------|
| **User / Product** | End users and product managers | Does this deliver user value? How is the UX? Does it solve real pain points? |
| **Developer** | Developers | How complex is implementation? Is code maintainable? Is DX good? |
| **Architect** | System architects | Is it scalable? How is coupling? Does it follow design principles? |
| **Security** | Security engineers | What are the attack surfaces? How is data protected? Does it follow security best practices? |
| **Ops / SRE** | Operations and reliability | Easy to deploy? How to monitor? How to recover from failures? |
| **Future Maintainer** | Future maintainers | Will it still be understandable in 6 months? How hard for newcomers? Tech debt risk? |

**Constraints:**
- Each role's observation must reference Step 1 research findings or Step 2 proposal details — no unsupported opinions
- If a role says "no issues", it must explain WHY there are no issues, not simply skip

**Output format:**
```
🧠 Multi-Perspective Evaluation:

Evaluating: <Approach A> vs <Approach B> vs <Approach C>

👤 User/Product: <non-obvious observation, referencing research or proposal details>
💻 Developer: <observation>
🏗️ Architect: <observation>
🔒 Security: <observation>
⚙️ Ops/SRE: <observation>
🔮 Future Maintainer: <observation>
```

### Step 5: Self-Interrogation Chain — 自问自答链

**After selecting a recommended proposal, force self-challenge. This is the key mechanism to break "first intuition = final conclusion".**

<!-- 选出推荐方案后，强制执行自我质疑。这是打破"第一直觉即最终结论"的关键机制。 -->

**Process:**

1. **Produce initial recommendation:** Based on Steps 1-4, select one recommended proposal and write the rationale
2. **Forced self-challenge:** Immediately raise **3 of the sharpest possible challenges** against your recommendation:
   - Challenges must be **genuinely capable of overturning the recommendation** — not token soft questions
   - Format: "If <assumption/condition>, then this proposal will <severe consequence>, because <reason>"
3. **Respond to each challenge:** For each challenge, give a serious response:
   - If the response is strong → record it, recommendation holds
   - If the response is weak → **must reconsider the recommendation**, potentially switch to another proposal
4. **Final verdict:** Based on the self-interrogation results, confirm or change the recommendation

**Constraints:**
- At least 1 of the 3 challenges must directly challenge "why not choose the other proposal"
- All 3 challenges concluding "recommendation holds" without substantive argumentation is NOT allowed
- If the self-interrogation reveals a genuine serious problem, you **MUST switch proposals** — this is not failure, it is the success of deep thinking
<!-- 如果自答过程中发现推荐确实有严重问题，必须切换方案——这不是失败，是深度思考的成功 -->

**Output format:**
```
💭 Self-Interrogation:

Initial recommendation: <Approach X>

❓ Challenge 1: If <condition>, then <consequence>, because <reason>
💬 Response: <answer>
📊 Verdict: Recommendation holds / Recommendation weakened

❓ Challenge 2: Why not choose <Approach Y>? It is clearly superior on <dimension>
💬 Response: <answer>
📊 Verdict: Recommendation holds / Recommendation weakened

❓ Challenge 3: <sharpest possible challenge>
💬 Response: <answer>
📊 Verdict: Recommendation holds / Recommendation weakened

Final: Recommendation confirmed / Changed to <Approach Y>
Reason: <why, based on the self-interrogation>
```

### Step 6: Independent Audit Agent — 独立审计

**After the self-interrogation chain completes, launch a completely new independent Agent to audit the entire brainstorm's quality.**
This is the key mechanism to solve the "model evaluating itself" problem — the audit Agent has an independent context,
sees only the final output, and is not influenced by the generation process's cognitive inertia.

**The audit Agent MUST use a different model from the primary generation model** to provide genuine independence.
If the main conversation uses `opus`, launch the audit Agent with `model: sonnet` (or vice versa).
This ensures different model weights evaluate the output, not the same model pretending to be independent.

<!-- 审计 Agent 必须使用与主对话不同的模型，确保真正的评估独立性。 -->

**Execution:**

1. Launch an independent Agent (using the Agent tool with `model: sonnet` if main conversation is opus, or `model: opus` if main conversation is sonnet), passing in:
   - The decision topic
   - The final recommended proposal and rationale
   - The 3 self-interrogation challenges and responses
   - Summaries of the 3 alternative proposals

2. Audit Agent prompt:
   ```
   You are an independent technical decision auditor. Your job is to review the thinking
   quality of an architecture decision. You must be rigorous, objective, and unforgiving.
   You do not know what happened during the generation process — you only see the final output.

   Evaluate the following:

   1. Challenge sharpness (1-5): Could the 3 challenges genuinely overturn the recommendation?
      - 1: All soft questions, cannot shake the recommendation
      - 3: Some force but still predictable
      - 5: At least 1 challenge makes you seriously consider switching proposals

   2. Response substance (1-5): Do the responses to challenges have real content?
      - 1: Hollow "this is not a problem" type responses
      - 3: Has arguments but not specific enough
      - 5: References specific research findings or technical facts

   3. Proposal divergence (1-5): Are the 3 proposals genuinely different?
      - 1: Same proposal with different names
      - 3: Different on some dimensions but core is similar
      - 5: Fundamentally different in architecture thinking, technical trade-offs, and applicable scenarios

   Decision rules:
   - Total score across 3 dimensions >= 10 AND no single dimension <= 2 → PASS
   - Otherwise → FAIL, provide specific improvement requirements
   ```

3. Audit result handling:
   - **PASS:** Continue to Step 7 (Synthesis)
   - **FAIL:** Enter redo loop (see below)

**Redo Loop (maximum 5 rounds):**

<!-- 重做循环（最多 5 轮） -->

```
Round 1: Initial generation → Audit → FAIL
                                       ↓
Round 2: Redo Steps 2-5 based on audit criticism → Audit → FAIL
                                       ↓
Round 3: Redo based on criticism → Audit → FAIL
                                       ↓
Round 4: Redo based on criticism → Audit → FAIL
                                       ↓
Round 5: Redo based on criticism → Audit → FAIL
                                       ↓
         Escalation: Stop redoing, present all 5 rounds to user
         User decides: choose a version / provide specific guidance / accept current result
```

**Redo rules:**
- Each redo receives the audit Agent's **specific criticism and scores** as input to the generation steps
- Generation steps must **address the criticism with improvements**, not ignore criticism and repeat the same output
- The audit Agent is **freshly launched each round** (independent context), not influenced by prior audit rounds
- If scores do not improve for 2 consecutive rounds (e.g., Round 3 and Round 4 have the same total), escalate to user arbitration early

<!-- 如果连续 2 轮分数没有提升，提前降级为用户裁决 -->

**Escalation display format:**
```
⚖️ Audit Escalation — Escalated to User Arbitration

After N audit rounds, quality threshold was not met. Round-by-round comparison:

| Round | Challenge Sharpness | Response Substance | Proposal Divergence | Total | Auditor Notes |
|-------|--------------------|--------------------|---------------------|-------|---------------|
| 1     | X/5                | X/5                | X/5                 | XX    | <criticism summary> |
| 2     | X/5                | X/5                | X/5                 | XX    | <criticism summary> |
| ...   |                    |                    |                     |       |               |

Current best version: Round N (highest total score)

Please choose:
(A) Accept the current best version
(B) Specify which aspects need improvement
(C) Tell me directly which proposal you prefer
```

**Output format (on PASS):**
```
🔍 Independent Audit:

Scores:
- Challenge sharpness: X/5
- Response substance: X/5
- Proposal divergence: X/5
- Total: XX/15

Verdict: PASS ✅
Auditor notes: <brief assessment>
```

### Step 7: Synthesis — 综合判断

Synthesize all information from all steps into a final decision:

<!-- 最终综合所有步骤的信息，产出决策 -->

1. **Evidence chain:** The decision must be traceable to specific research findings, proposal comparisons, role evaluations, and self-interrogation
2. **Confidence level:** Based on self-interrogation results
   - All 3 challenges responded to strongly → High
   - 1-2 challenges responded to weakly but not fatally → Medium
   - A challenge caused a proposal switch → Medium (new proposal) or Low (no perfect proposal)
3. **Unverified assumptions:** List assumptions the decision depends on that have not been validated with external data

**Output format:**
```
✅ Decision: <what was decided>
🎯 Confidence: High / Medium / Low
📚 Key evidence: <1-2 most important research findings that support this>
⚠️ Open risks: <if any remain>
❓ Need to verify with user: <if any assumptions are unvalidated>
```

---

## Trigger-Specific Behavior — 各触发点权威位置

<!-- 每个触发点的详细执行指令（STOP-GATE）定义在各 phase 文件中，此处仅作索引。
     修改触发点行为时，只修改 phase 文件中的 STOP-GATE，不要在此文件中重复。 -->

Each trigger point's detailed execution checklist (STOP-GATE block) lives in the corresponding phase file.
**Do NOT duplicate trigger-specific instructions here** — the phase file is the single source of truth.
This section serves only as a quick-reference index.

| Trigger | Default | Full Mode | Phase File | Location |
|---------|---------|-----------|-----------|----------|
| BS-1 | Lightweight (auto) | On request | [phase-1-requirements.md](phase-1-requirements.md) | `<STOP-GATE id="BS-1">` near end of file |
| BS-2 | Lightweight (auto) | On request | [phase-2-draft.md](phase-2-draft.md) | `<STOP-GATE id="BS-2">` before Section 2 |
| BS-3 | Lightweight (auto) | On request | [phase-2-draft.md](phase-2-draft.md) | `<STOP-GATE id="BS-3">` before Section 3 |
| BS-4 | Lightweight (auto) | On request | [phase-2-draft.md](phase-2-draft.md) | `<STOP-GATE id="BS-4">` before Section 4 |
| BS-5 | Lightweight (auto) | On request | [phase-2-draft.md](phase-2-draft.md) | `<STOP-GATE id="BS-5">` before approval gate |
| BS-6 | Lightweight (auto) | On request | [phase-3-planning.md](phase-3-planning.md) | `<STOP-GATE id="BS-6">` between Level 2 and Level 3 |
| BS-7 | — (user opt-in only) | Always Full | [phase-4-execution.md](phase-4-execution.md) | `<STOP-GATE id="BS-7">` in error recovery section |

### Mode Quick Reference

- **Lightweight (3 steps, inline):** Research (1-2 WebSearch) → Multi-Perspective self-evaluation (6 roles) → Self-Interrogation (3 challenges) + Synthesis. No Agent calls. ~2-3K tokens.
- **Full (7 steps, with Agents):** Research → Independent Agents (3 parallel, mixed models, mutual exclusion) → Quality Gate → Multi-Perspective → Self-Interrogation → Independent Audit → Synthesis. ~30-40K tokens.

### Execution Rule

When a STOP-GATE is reached during execution:
1. **Default:** Run Lightweight Mode inline (no Agent calls needed)
2. **If user requests Full Mode:** Read this file (`brainstorm-protocol.md`) for Full Mode step definitions (Steps 1-7), output formats, quality gate thresholds
3. Read the specific STOP-GATE block in the phase file for trigger-specific instructions (focus areas, self-check items)
4. The STOP-GATE block in the phase file takes precedence if there is any conflict

---

## Presentation Rules — 展示规则

1. **Always show brainstorm results to the user.** This is NOT an internal-only process.
   The user should see research findings, multi-perspective evaluation, and self-interrogation results.
   In Full Mode, also show independent proposals, quality gate check, and audit scores.

2. **Use the output formats defined above.** Consistent formatting helps users parse the analysis.

3. **Be concise within the structure.** Each role's observation should be 1-3 sentences.
   Each self-interrogation challenge should be 1-2 sentences. The value is in structural rigor, not verbosity.

4. **Mark unvalidated assumptions clearly.** If the brainstorm reveals something that needs user input,
   ask immediately — do not defer.

5. **Show the evidence chain.** For each key decision, the user should be able to trace:
   - Lightweight: Research finding → Perspective evaluation → Self-challenge → Decision
   - Full Mode: Research → Proposal detail → Quality gate → Perspective → Self-challenge → Audit → Decision

---

## Anti-Patterns — 反模式（必须避免）

- **Fake diversity (Full Mode):** Generating 3 "alternatives" that are essentially the same thing with cosmetic differences.
  The Step 3 Quality Gate exists specifically to catch this — if it fails, regenerate.

- **Confirmation bias brainstorm:** Going through the motions but always concluding the first idea was best.
  The self-interrogation must genuinely try to break the recommendation. If all 3 challenges are soft
  ("what if the team is slightly larger?"), the interrogation is not deep enough.

- **Shallow multi-perspective:** Writing "Security: looks fine" without actually thinking about attack surfaces.
  Each role must reference specific research findings or proposal details — no unsupported opinions.

- **Skipping Lightweight under pressure:** If the context is long or the user seems impatient,
  Lightweight brainstorm is still mandatory at trigger points. It costs only ~2-3K tokens — there is no valid reason to skip it.

- **User-prompt anchoring:** If the user says "use React", do NOT blindly accept it without analysis,
  but also do NOT waste time generating alternatives the user didn't ask for.
  In Lightweight Mode, use **validation focus**: research validates the choice, multi-perspective evaluates fit.
  If React is a good fit, confirm it with evidence. If it has significant issues for this project,
  flag the concern and let the user decide — do not override their preference silently.

- **Research-washing:** Running a WebSearch but not incorporating the results into the analysis.
  Every research finding must appear in at least one subsequent step — otherwise it wasn't useful
  and should be replaced with a more relevant search.

- **Search fabrication:** Presenting model-internal knowledge as "Research Findings" when WebSearch
  returned 0 results. If search fails, the output MUST be labeled `⚠️ AI Inference (search unavailable)`.
  Never disguise inference as externally validated research.

- **Fake self-interrogation:** Asking soft questions like "What if requirements change slightly?"
  that can always be dismissed. Challenges must be specific, concrete, and tied to the project context.
  At least one challenge must name a specific alternative approach and argue for it.
