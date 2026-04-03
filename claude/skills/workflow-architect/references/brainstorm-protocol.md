# Brainstorm Protocol — 头脑风暴协议

> This protocol defines a two-layer deep-thinking process at critical decision points.
> **Layer 1: Context-Enriched Self-Reflection** runs automatically at every trigger point — inline self-reflection, no Agent calls.
> **Layer 2: Agent-Based Challenge** runs only when the user explicitly requests it — Agent-based, expensive but thorough.

---

## Core Principle — 核心原则

**Every important decision must undergo multi-dimensional review, not follow the first intuition.**

Brainstorming is not template-filling — it is a mechanism that forces the model to **genuinely alter its reasoning path**.

**Two-layer design rationale:** Layer 2 (2 challenger Agents) costs ~15,000-25,000 tokens per trigger point. Three consecutive Layer 2 brainstorms in Phase 2 would consume substantial tokens before any code is written — often exceeding what the context window can sustain. Layer 1 achieves ~80% of the value at ~10% of the cost by using structured context-enriched self-reflection instead of Agent-based generation.

---

## Layer 1: Context-Enriched Self-Reflection (Default) — 轻量模式（默认）

**Runs automatically** at every trigger point. Cannot be skipped.

**Steps (inline, no Agent calls):**

1. **Context + Research** — First, read `.workflow/context/domain-knowledge.md` and `.workflow/context/hypothesis-tracker.md` to ground yourself in accumulated knowledge. Then run 1-2 WebSearch queries for relevant external facts.
   **DeepWiki enhancement (BS-2/3/4 only):** If the decision involves specific library/framework capabilities identified in domain-knowledge.md, run 1 DeepWiki `ask` query to verify actual API support (REQUIRED when candidates are known, not optional):
   `bash ${CLAUDE_SKILL_DIR}/assets/scripts/deepwiki.sh ask "owner/repo" "<specific capability question>"`
   Output `🔍 Research Findings` block (label DeepWiki results as `📚 DeepWiki` to distinguish from WebSearch).
   - If searches return 0 results: retry with broader keywords; if still 0, label output as `⚠️ AI Inference (search unavailable)`.
2. **Multi-Perspective Self-Evaluation** — Review from 6 role perspectives (User/Dev/Architect/Security/Ops/Maintainer) inline. Each role produces 1-2 sentences. Output `🧠 Multi-Perspective` block.
3. **Self-Interrogation + Synthesis** — Select recommendation, raise 3 sharp challenges against it, respond. If a challenge reveals a genuine problem, change the recommendation. Output `💭 Self-Interrogation` and `✅ Decision` blocks.

**Cost:** ~2,000-3,000 tokens per point.

**Output must include:** Decision + Confidence (High/Medium/Low) + Top 2 risks.

---

## Layer 2: Agent-Based Challenge (User Opt-In) — 完整模式（用户按需）

**Runs ONLY when the user explicitly requests deeper analysis** (e.g., "I want deeper analysis", "run full brainstorm", or `/brainstorm`).

Layer 2 adds Agent-based challenge, quality gate on top of the Layer 1 steps.

---

## Trigger Points — 触发点

**Layer 1** runs automatically at every trigger point. **Layer 2** runs only when the user explicitly requests it.

<!-- 轻量模式在每个触发点自动运行。完整模式仅在用户显式请求时运行。 -->

| Trigger ID | Phase | When | Default Mode | Layer 2 Available |
|------------|-------|------|-------------|---------------------|
| BS-1 | Phase 1 → 2 | Requirements collected, before entering draft | Layer 1 | ✅ On request |
| BS-2 | Phase 2 | Before producing architecture design (Section 2) | Layer 1 | ✅ On request |
| BS-3 | Phase 2 | Before producing tech stack selection (Section 3) | Layer 1 | ✅ On request |
| BS-4 | Phase 2 | Before producing algorithm & design strategy (Section 4) | Layer 1 | ✅ On request |
| BS-5 | Phase 2 → 3 | Draft approved, before writing plans to disk | Layer 1 | ✅ On request |
| BS-6 | Phase 3 | When dividing implementation phases and tasks | Layer 1 | ✅ On request |
| BS-7 | Phase 4 | During 3-Strike error recovery | — | ✅ User opt-in only |

**BS-7 is special:** It does NOT run Layer 1 by default. It is only triggered when the user explicitly selects Option A (BS-7 deep analysis) after a 3-Strike failure.

---

## Brainstorm Execution — 执行流程

### Mode Determination — 模式判定

<!-- 模式判定规则：默认轻量，用户请求时升级为完整。 -->

At each trigger point:

1. **Default: Layer 1** — always runs automatically (see Layer 1 above)
2. **Upgrade to Layer 2** — only if user explicitly requests deeper analysis (e.g., "run full brainstorm", `/brainstorm`, "I want deeper analysis on this")
3. **BS-7 exception** — user opt-in only, always Layer 2 when triggered

**User-preference shortcut (BS-2/3/4):**
When the user specified strong preferences during Phase 1 (e.g., "use React"), Layer 1 uses **validation focus**: research validates the choice, multi-perspective evaluates fit, self-interrogation challenges the choice. Flag concerns if found; do NOT generate alternatives the user didn't ask for.

### Disk Persistence — 磁盘持久化

After completing brainstorm (either layer), persist results to `.workflow/brainstorm/bs-N.md`.
This serves two purposes:
1. **Traceability** — the user and future sessions can verify brainstorm was executed
2. **Context relief** — on session resume, results can be re-read instead of re-generated

Update `brainstorm.bsN` in state.json after writing the artifact file.

### Context Management — 上下文管理

Phase 2 triggers up to 4 brainstorms in sequence (BS-2, BS-3, BS-4, BS-5). If any use Layer 2, context can grow substantially. Even Layer 1 benefits from these rules.

<!-- Phase 2 最多连续触发 4 次头脑风暴。如果任何一个使用完整模式，上下文会显著增长。 -->

**Rules:**

1. **Persist immediately, summarize in context.** After each brainstorm completes and is persisted to disk (`.workflow/brainstorm/bs-N.md`), keep only a **concise summary** (decision + confidence + top 2 risks) in the conversation. The full artifact is on disk for reference.

2. **Do NOT carry Agent proposals forward (Layer 2).** After Synthesis produces a decision, the 2 Agent challenges, divergence check details are no longer needed in conversation context. They are preserved in the disk artifact.

3. **Reference by file, not by repetition.** When a later brainstorm needs to reference an earlier decision (e.g., BS-4 depends on BS-2's architecture choice), reference the disk artifact: "Per BS-2 decision (see `.workflow/brainstorm/bs-2.md`): chose MVC pattern." Do NOT re-paste the full BS-2 output.

4. **Cumulative summary block.** After each brainstorm, maintain a running summary block:
   ```
   📋 Brainstorm Progress:
   - BS-2 (Architecture): ✅ MVC + Repository pattern | Confidence: High | Mode: Layer 1
   - BS-3 (Tech Stack): ✅ React + Express + MySQL | Confidence: High | Mode: Layer 2
   - BS-4: ⏳ pending
   - BS-5: ⏳ pending
   ```

5. **Layer 1 is context-friendly.** Most brainstorms will use Layer 1 (~2-3K tokens each), keeping total Phase 2 brainstorm overhead under ~12K tokens.

---

## Layer 2 Steps — 完整模式步骤

The following Steps 1-5 define the Layer 2 protocol. **These are ONLY executed when the user requests Layer 2** (or for BS-7 user opt-in). Layer 1 uses Steps 1, 4, and 5 inline (see Layer 1 above).

<!-- 以下 Step 1-5 定义完整模式协议。仅在用户请求完整模式时执行。轻量模式使用内联版本的 Step 1/4/5。 -->

### Step 1: Context + Forced Research — 强制信息检索

**Before producing any proposal**, you MUST first read Context Bus files (`.workflow/context/domain-knowledge.md`, `.workflow/context/hypothesis-tracker.md`, `.workflow/context/project-brief.md`) and then use the `WebSearch` tool to obtain external facts.
This step breaks the limitation of reasoning purely from training data, constraining thinking with real-world up-to-date information.

<!-- 在产出任何方案之前，必须先用 WebSearch 获取外部事实，打破模型仅靠训练数据推理的局限。 -->

**Rules:**
- For BS-2 (Architecture): Search "<project type> architecture best practices <current year>", known architecture anti-patterns. Query DeepWiki for candidate framework's architectural capabilities.
- For BS-3 (Tech Stack): Search latest versions, known issues, community reviews, and benchmark comparisons for each candidate technology. Query DeepWiki for each candidate's actual API documentation to verify capabilities beyond marketing claims.
- For BS-4 (Algorithm): Search real-world performance data and applicable scenario case studies for relevant algorithms. If a specific library implements the algorithm, query DeepWiki for implementation details.
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

### Step 2: Agent-Based Challenge — 挑战者代理

**For trigger points requiring deep analysis (BS-2, BS-3, BS-4, BS-7), use the Agent tool to launch 2 challenger Agents that attack and expand on the main model's proposal.**

<!-- 对于需要深度分析的触发点，使用 Agent 工具启动 2 个挑战者代理来攻击和扩展主模型的方案。 -->

This step prevents the main model from anchoring on its first intuition by introducing genuine external challenge via independent Agents that read accumulated project context.

**Execution:**

1. Compile the main model's initial proposal and reasoning chain from Step 1
2. **Agent-Based Challenge** — Launch 2 challenger Agents in parallel.

   Both agents MUST read Context Bus files first. Include this block in each agent prompt:
   ```
   Before starting, read these files for accumulated project context:
   1. .workflow/context/project-brief.md
   2. .workflow/context/domain-knowledge.md
   3. .workflow/context/hypothesis-tracker.md
   4. .workflow/context/interview-transcript.md (if it exists)
   ```

   **Agent 1 — Devil's Advocate (魔鬼辩护者):**
   ```
   You are a Devil's Advocate. The main model proposes: {decision_description}.
   Its reasoning: {reasoning_chain}.

   Your job is to ATTACK this decision:
   1. What evidence contradicts this choice? Run 1-2 WebSearch queries for counter-evidence.
   2. What scenarios would make this choice fail catastrophically?
   3. What has the main model assumed without evidence?
   4. Check .workflow/agent-outputs/agent-b-competitive.md — did any competitor try this approach and fail?

   Write your challenge to .workflow/agent-outputs/brainstorm-{id}-challenge.md
   Return a 150-word summary of your strongest objection.
   ```

   **Agent 2 — Lateral Thinker (横向思考者):**
   ```
   You are a Lateral Thinker. The main model proposes: {decision_description}.

   Your job is to find COMPLETELY DIFFERENT approaches:
   1. Propose 2-3 alternative approaches that solve the same problem differently.
   2. For each, explain WHY it might be better. Run 1-2 WebSearch queries for unconventional solutions.
   3. Identify an analogous problem in another domain — how was it solved there?
   4. Check .workflow/agent-outputs/agent-c-tech.md — are there libraries that enable a different paradigm?

   Write your alternatives to .workflow/agent-outputs/brainstorm-{id}-alternatives.md
   Return a 150-word summary of your best alternative.
   ```

   Output the `🏗️ Agent-Based Challenge Results` block with both agents' summaries.

3. Collect results from both Agents, proceed to Step 3

**For trigger points that do not require proposal comparison (BS-1, BS-5, BS-6), skip this step.**

**Output format:**
```
🏗️ Agent-Based Challenge Results:

[Agent 1 — Devil's Advocate]: <150-word summary of strongest objection>
[Agent 2 — Lateral Thinker]: <150-word summary of best alternative>
```

### Step 3: Quality Gate — 思考质量自检

**Before proceeding, verify that the challenger agents provided genuine challenge to the main model's proposal. This is a check against "rubber-stamp" agents.**

<!-- 在继续之前，验证挑战者代理是否对主模型方案提供了真正的挑战。 -->

**Challenge Verification:**

Compare the Devil's Advocate criticism + Lateral Thinker alternative against the main model's proposal:

1. **Does the Devil's Advocate identify a flaw not addressed by the main model?**
   - If the criticism only restates known trade-offs already acknowledged → WEAK
   - If the criticism reveals a genuinely unaddressed risk or blind spot → STRONG
2. **Does the Lateral Thinker's alternative avoid this flaw?**
   - If the alternative suffers from the same flaw → NOT USEFUL
   - If the alternative genuinely avoids the flaw while solving the same problem → VALUABLE

**Decision rules:**
- Both (1) STRONG and (2) VALUABLE → **ESCALATE to user.** The main model's proposal has a genuine gap, and a viable alternative exists. Present both to the user for decision.
- (1) STRONG but (2) NOT USEFUL → **PROCEED with caution.** The flaw is real but no better alternative exists. Flag the flaw as an open risk in the decision.
- (1) WEAK → **PROCEED.** The main model's proposal withstood challenge. Continue to Step 4.
- If both agents identify the **SAME fundamental flaw** → **STRONGLY suggests the main model should reconsider.** Escalate to user with the converging criticism.

<!-- 如果两个代理都识别出相同的根本缺陷 → 强烈建议主模型重新考虑 -->

**Output format:**
```
🔬 Challenge Verification:

1. Devil's Advocate flaw identification: ✅ STRONG / ⚠️ WEAK — <explanation>
2. Lateral Thinker alternative viability: ✅ VALUABLE / ⚠️ NOT USEFUL — <explanation>
3. Converging criticism detected: Yes / No

Result: PROCEED / PROCEED with caution (open risk: <flaw>) / ESCALATE to user
```

### Step 4: Multi-Perspective Evaluation — 多角色评估

**With the main model's proposal, challenger agent results, and external facts in hand, evaluate from 6 role perspectives.**

<!-- 现在有了主模型方案、挑战者代理结果和外部事实，从 6 个角色视角进行评估。 -->

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
- Each role's observation must reference Step 1 research findings or Step 2 agent challenge results — no unsupported opinions
- If a role says "no issues", it must explain WHY there are no issues, not simply skip

**Output format:**
```
🧠 Multi-Perspective Evaluation:

Evaluating: <Main Proposal> (incorporating Devil's Advocate criticism + Lateral Thinker alternatives)

👤 User/Product: <non-obvious observation, referencing research or agent challenge results>
💻 Developer: <observation>
🏗️ Architect: <observation>
🔒 Security: <observation>
⚙️ Ops/SRE: <observation>
🔮 Future Maintainer: <observation>
```

### Step 5: Self-Interrogation Chain + Synthesis — 自问自答链 + 综合判断

**After the multi-perspective evaluation, force self-challenge and then synthesize a final decision. This is the key mechanism to break "first intuition = final conclusion".**

<!-- 选出推荐方案后，强制执行自我质疑并综合最终决策。这是打破"第一直觉即最终结论"的关键机制。 -->

**Process:**

1. **Produce initial recommendation:** Based on Steps 1-4, select one recommended approach and write the rationale. Incorporate any valid criticism from the Devil's Advocate and viable elements from the Lateral Thinker.
2. **Forced self-challenge:** Immediately raise **3 of the sharpest possible challenges** against your recommendation:
   - Challenges must be **genuinely capable of overturning the recommendation** — not token soft questions
   - Format: "If <assumption/condition>, then this proposal will <severe consequence>, because <reason>"
3. **Respond to each challenge:** For each challenge, give a serious response:
   - If the response is strong → record it, recommendation holds
   - If the response is weak → **must reconsider the recommendation**, potentially switch to the Lateral Thinker's alternative
4. **Final verdict:** Based on the self-interrogation results, confirm or change the recommendation

**Constraints:**
- At least 1 of the 3 challenges must directly address the Devil's Advocate's strongest objection or argue for the Lateral Thinker's alternative
- All 3 challenges concluding "recommendation holds" without substantive argumentation is NOT allowed
- If the self-interrogation reveals a genuine serious problem, you **MUST switch approaches** — this is not failure, it is the success of deep thinking
<!-- 如果自答过程中发现推荐确实有严重问题，必须切换方案——这不是失败，是深度思考的成功 -->

**Output format:**
```
💭 Self-Interrogation:

Initial recommendation: <Approach X>

❓ Challenge 1: If <condition>, then <consequence>, because <reason>
💬 Response: <answer>
📊 Verdict: Recommendation holds / Recommendation weakened

❓ Challenge 2: The Devil's Advocate argues <objection>. Why is this not fatal?
💬 Response: <answer>
📊 Verdict: Recommendation holds / Recommendation weakened

❓ Challenge 3: <sharpest possible challenge>
💬 Response: <answer>
📊 Verdict: Recommendation holds / Recommendation weakened

Final: Recommendation confirmed / Changed to <Lateral Thinker's alternative>
Reason: <why, based on the self-interrogation>
```

**Synthesis — 综合判断:**

After the self-interrogation, synthesize all information from all steps into a final decision:

<!-- 最终综合所有步骤的信息，产出决策 -->

1. **Evidence chain:** The decision must be traceable to specific research findings, agent challenges, role evaluations, and self-interrogation
2. **Confidence level:** Based on self-interrogation results
   - All 3 challenges responded to strongly → High
   - 1-2 challenges responded to weakly but not fatally → Medium
   - A challenge caused an approach switch → Medium (new approach) or Low (no perfect approach)
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

| Trigger | Default | Layer 2 | Phase File | Location |
|---------|---------|-----------|-----------|----------|
| BS-1 | Layer 1 (auto) | On request | [phase-1-requirements.md](phase-1-requirements.md) | `<STOP-GATE id="BS-1">` near end of file |
| BS-2 | Layer 1 (auto) | On request | [phase-2-draft.md](phase-2-draft.md) | `<STOP-GATE id="BS-2">` before Section 2 |
| BS-3 | Layer 1 (auto) | On request | [phase-2-draft.md](phase-2-draft.md) | `<STOP-GATE id="BS-3">` before Section 3 |
| BS-4 | Layer 1 (auto) | On request | [phase-2-draft.md](phase-2-draft.md) | `<STOP-GATE id="BS-4">` before Section 4 |
| BS-5 | Layer 1 (auto) | On request | [phase-2-draft.md](phase-2-draft.md) | `<STOP-GATE id="BS-5">` before approval gate |
| BS-6 | Layer 1 (auto) | On request | [phase-3-planning.md](phase-3-planning.md) | `<STOP-GATE id="BS-6">` between Level 2 and Level 3 |
| BS-7 | — (user opt-in only) | Always Layer 2 | [phase-4-execution.md](phase-4-execution.md) | `<STOP-GATE id="BS-7">` in error recovery section |

### Mode Quick Reference

- **Layer 1 (3 steps, inline):** Context + Research (read context files + 1-2 WebSearch) → Multi-Perspective self-evaluation (6 roles) → Self-Interrogation (3 challenges) + Synthesis. No Agent calls. ~2-3K tokens.
- **Layer 2 (5 steps, with 2 Agents):** Context + Research → Agent-Based Challenge (Devil's Advocate + Lateral Thinker, context-enriched) → Quality Gate → Multi-Perspective → Self-Interrogation + Synthesis. ~15-25K tokens.

### Execution Rule

When a STOP-GATE is reached during execution:
1. **Default:** Run Layer 1 inline (no Agent calls needed)
2. **If user requests Layer 2:** Read this file (`brainstorm-protocol.md`) for Layer 2 step definitions (Steps 1-5), output formats, quality gate thresholds
3. Read the specific STOP-GATE block in the phase file for trigger-specific instructions (focus areas, self-check items)
4. The STOP-GATE block in the phase file takes precedence if there is any conflict

---

## Presentation Rules — 展示规则

1. **Always show brainstorm results to the user.** This is NOT an internal-only process.
   The user should see research findings, multi-perspective evaluation, and self-interrogation results.
   In Layer 2, also show agent challenges, quality gate check.

2. **Use the output formats defined above.** Consistent formatting helps users parse the analysis.

3. **Be concise within the structure.** Each role's observation should be 1-3 sentences.
   Each self-interrogation challenge should be 1-2 sentences. The value is in structural rigor, not verbosity.

4. **Mark unvalidated assumptions clearly.** If the brainstorm reveals something that needs user input,
   ask immediately — do not defer.

5. **Show the evidence chain.** For each key decision, the user should be able to trace:
   - Layer 1: Research finding → Perspective evaluation → Self-challenge → Decision
   - Layer 2: Research → Agent challenge → Quality gate → Perspective → Self-challenge → Decision

---

## Anti-Patterns — 反模式（必须避免）

- **Fake diversity (Layer 2):** Generating challenges that don't genuinely attack the proposal.
  The Step 3 Quality Gate exists specifically to catch this — if both agents fail to identify real issues, the challenge is not deep enough.

- **Confirmation bias brainstorm:** Going through the motions but always concluding the first idea was best.
  The self-interrogation must genuinely try to break the recommendation. If all 3 challenges are soft
  ("what if the team is slightly larger?"), the interrogation is not deep enough.

- **Shallow multi-perspective:** Writing "Security: looks fine" without actually thinking about attack surfaces.
  Each role must reference specific research findings or agent challenge results — no unsupported opinions.

- **Skipping Layer 1 under pressure:** If the context is long or the user seems impatient,
  Layer 1 brainstorm is still mandatory at trigger points. It costs only ~2-3K tokens — there is no valid reason to skip it.

- **User-prompt anchoring:** If the user says "use React", do NOT blindly accept it without analysis,
  but also do NOT waste time generating alternatives the user didn't ask for.
  In Layer 1, use **validation focus**: research validates the choice, multi-perspective evaluates fit.
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
