# Workflow Architect

**Senior Architect Workflow — 从想法到完整实现的四阶段治理运行时**

[English Version](README.en.md) [前排友链：Linux.do](https://linux.do/)

---

> 一个为 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 和 [OpenAI Codex CLI](https://github.com/openai/codex) 设计的高级技能（Skill），将 AI 编程助手升级为**高级软件架构师**。通过严格的四阶段工作流（需求收集 → 草案产出 → 执行计划 → 计划执行），引导项目从模糊想法走向完整、可运行的代码实现。

## 为什么需要 Workflow Architect？

直接让 AI "帮我写一个 XXX 项目" 的问题：

- AI 会**跳过需求分析**，直接开始写代码 — 方向可能完全错误
- **架构决策不经推敲**，用的是模型的第一直觉，而非经过对比分析的最优选择
- **没有计划**，边做边改，最终代码结构混乱
- 长任务中**无法回退、无法变更需求**，只能推倒重来

Workflow Architect 解决这些问题：

| 痛点 | 解决方案 |
|------|---------|
| 需求不清就动手 | Phase 1 深度访谈，10 类问题覆盖所有维度 |
| 架构拍脑袋 | Phase 2 头脑风暴协议，多角度评估 + 自我质疑 |
| 无计划裸写代码 | Phase 3 三级计划层次，任务粒度到每一步操作 |
| 长任务失控 | Phase 4 里程碑检查、3-Strike 容错、变更管理 |
| 改需求要重来 | Issue Changer 影响分析 + 增量修改 |
| 代码质量靠运气 | Bug Fixer 7 维度系统化审查 |

---

## 核心特性

- **四阶段治理工作流** — 需求 → 草案 → 计划 → 执行，每个阶段都有准入/准出门控
- **头脑风暴双层协议** — Lightweight（自动，~2K tokens）+ Full Mode（按需，3 Agent + 审计，~30K tokens）
- **三级计划层次** — 项目总体计划 → 阶段计划 → 任务详情，全部落盘持久化
- **DeepWiki 三级研究** — 编码前自动查询 GitHub 仓库文档，确保 API 最佳实践
- **3-Strike 容错机制** — 三次尝试逐步升级策略，失败后多种恢复选项
- **外挂技能生态** — Bug Fixer（7 维度代码审查）+ Issue Changer（变更请求管理）
- **会话恢复** — 所有状态持久化到 `.workflow/state.json`，中断后可无损恢复
- **跨平台支持** — 同时提供 Bash 和 PowerShell 脚本，支持 macOS/Linux/Windows

---

## 工作流架构

### 状态机

```
                 +---- reject ----+
                 v                |
  INIT --> REQUIREMENTS -----> DRAFT
                 ^              |
                 |           approve
                 |              v
                 +-- reject -- PLANNING --> EXECUTION --> COMPLETED
```

四个阶段，严格有序。不可跳过任何阶段。Phase 2 或 Phase 3 被拒绝时回退到 Phase 1，保留已有答案。

### 四阶段详解

#### Phase 1: 需求收集 (Requirements)

通过结构化深度访谈，全面收集用户需求。每次只问一个问题，提供推荐答案。

**10 类问题分类：**

| 类别 | 级别 | 涵盖内容 |
|------|------|---------|
| 项目愿景与目标 | 必需 | 解决什么问题、成功标准、时间线 |
| 功能范围 | 必需 | 核心功能、MVP 边界、非目标 |
| 用户角色与旅程 | 必需 | 用户类型、权限、主要流程 |
| 领域与数据模型 | 必需 | 实体、关系、存储策略 |
| 技术栈与架构 | 必需 | 语言、框架、部署方式 |
| 集成与依赖 | 可选 | 外部 API、第三方服务 |
| 非功能性需求 | 可选 | 性能、安全、可扩展性 |
| 用户体验设计 | 可选 | 界面类型、关键页面 |
| 开发约束 | 可选 | 团队规模、CI/CD、测试策略 |
| 边界场景与风险 | 可选 | 异常情况、合规要求 |

**准出条件：** 5 个必需类别全部达到 "clear"，至少 3 个可选类别达到 "partial"。

#### Phase 2: 草案产出 (Draft)

将需求综合为完整的架构方案，在对话中呈现（不写入磁盘）。

**8 个草案章节：**

1. **项目概述** — 核心问题与解决方案
2. **架构设计** — 分层结构、组件图、设计模式 `← 触发 BS-2 头脑风暴`
3. **技术栈选型** — 每个选择的理由与对比 `← 触发 BS-3 头脑风暴`
4. **算法与设计策略** — 关键算法、安全设计 `← 触发 BS-4 头脑风暴`
5. **项目结构** — 目录布局、模块组织
6. **实施阶段划分** — 逻辑阶段、依赖关系
7. **风险评估** — TOP 风险及缓解策略
8. **复杂度评估** — 总体难度、工作量预估

渐进式呈现：Sections 1-3 → 确认 → Sections 4-5 → 确认 → Sections 6-8 → 最终审批。

#### Phase 3: 执行计划 (Planning)

将草案转化为三级计划层次，全部写入磁盘。

```
.workflow/
├── state.json                          # 状态持久化
├── project-plan.md                     # Level 1: 项目总体计划
└── phases/
    ├── phase-1/
    │   ├── phase-plan.md               # Level 2: 阶段计划
    │   └── tasks/
    │       ├── task-01-<name>.md        # Level 3: 任务详情
    │       └── task-02-<name>.md
    ├── phase-2/
    │   ├── phase-plan.md
    │   └── tasks/
    │       └── ...
    └── ...
```

每个 Level 3 任务计划包含：前提条件、具体步骤、预期产出、验证命令、提交信息。

#### Phase 4: 计划执行 (Execution)

严格按计划执行所有任务，同时允许专业判断提升代码质量。

**执行流程：**

```
读取项目计划 → 逐阶段执行
  ├── DeepWiki Tier 1: 阶段级研究（批量查询 API 文档）
  └── 逐任务执行
      ├── DeepWiki Tier 2: 任务级研究（精确 API 查询）
      ├── 逐步骤执行
      │   └── DeepWiki Tier 3: 编码时即时查询
      ├── 运行验证
      ├── Git 提交
      └── 更新进度
  └── 里程碑检查点 → 用户审查
```

**专业判断空间：** 可添加类型注解、防御性检查、规范命名、惯用模式。不可添加计划外的功能、端点或行为。

**3-Strike 容错：**

| 尝试 | 策略 |
|------|------|
| Strike 1 | 分析根因，定向修复 |
| Strike 2 | 替代方案，同一目标 |
| Strike 3 | 质疑假设，研究验证 |
| 3 次失败 | 停止，提供 5 种恢复选项 |

恢复选项：(A) BS-7 深度头脑风暴 (B) 用户自行修复 (C) 跳过任务 (D) 中止执行 (E) Bug Fixer 7 维度审查

---

## 头脑风暴协议

在关键决策点触发，确保每个重要决定都经过多维度审视。

### Tier 1: Lightweight Mode（默认，自动运行）

在每个触发点自动执行，无需 Agent 调用，成本约 ~2,000-3,000 tokens。

```
1. 研究 — 1-2 次 WebSearch 查询，获取外部事实
2. 多角色自评 — 从 6 个角色视角审视（用户/开发者/架构师/安全/运维/维护者）
3. 自我质疑 + 综合 — 提出 3 个尖锐挑战，逐一回应，输出决策
```

### Tier 2: Full Mode（按需，用户显式请求）

用户请求时升级执行（如输入 `/brainstorm`），成本约 ~30,000-40,000 tokens。

```
1. 强制研究 — 2+ WebSearch 查询
2. 独立方案生成 — 3 个 Agent 并行（互斥约束 + 混合模型 haiku/opus/sonnet）
3. 质量门 — 4 项发散度检查（含核心技术去重，必须通过）
4. 多角色评估 — 6 个角色视角
5. 自我质疑链 — 3 个挑战，可能推翻推荐
6. 独立审计 — 不同模型的审计 Agent 评分（≥10/15 通过）
7. 综合判断 — 最终决策 + 置信度 + 风险
```

### 触发点

| ID | 阶段 | 时机 | 默认模式 |
|----|------|------|---------|
| BS-1 | Phase 1→2 | 需求完整性检查 | Lightweight |
| BS-2 | Phase 2 | 架构设计前 | Lightweight |
| BS-3 | Phase 2 | 技术栈选型前 | Lightweight |
| BS-4 | Phase 2 | 算法策略前 | Lightweight |
| BS-5 | Phase 2→3 | 草案完整性检查 | Lightweight |
| BS-6 | Phase 3 | 任务分解审查 | Lightweight |
| BS-7 | Phase 4 | 3-Strike 错误恢复 | 仅用户请求 |

---

## 外挂技能

### Bug Fixer — 代码审查与 Bug 修复

```
调用方式: /workflow-architect:bug-fixer [目标文件/目录/Bug描述]
```

**7 维度审查协议：**

| 维度 | 检查内容 |
|------|---------|
| 安全漏洞 | 注入、XSS、认证缺陷、敏感数据泄露 |
| 逻辑错误 | 边界条件、Off-by-one、类型混淆、空值处理 |
| 并发问题 | 竞态条件、死锁、资源泄漏 |
| 性能问题 | N+1 查询、内存泄漏、不必要的计算 |
| 错误处理 | 未捕获异常、静默失败、错误信息暴露 |
| 依赖风险 | 原生包管理器审计（npm audit / pip audit / govulncheck 等） |
| 一致性 | 命名规范、模式一致性、API 契约 |

**两种模式：**
- **独立模式** — 直接审查任意代码库
- **集成模式** — 在 workflow-architect 工作流内，利用计划上下文做精准审查

**智能扫描：**
- 支持 git diff 增量扫描（仅审查变更文件）
- 分层扫描策略（Grep 筛选 → 精读命中文件 → 深度分析），上下文预算 30 个文件

### Issue Changer — 变更请求管理

```
调用方式: /workflow-architect:issue-changer [变更描述]
```

**两种工作模式：**

| 模式 | 场景 | 处理方式 |
|------|------|---------|
| Mode A | Phase 4 执行中用户提出变更 | 暂停 → 影响分析 → 修改计划 → 恢复执行 |
| Mode B | 项目完成后新增需求 | 精简需求收集 → 影响分析 → 增量计划 → 增量执行 |

**影响分析分级：**

| 严重程度 | 影响范围 | 处理方式 |
|---------|---------|---------|
| Light | 仅影响当前/未来任务 | 直接修改 Level 3 任务计划 |
| Moderate | 需要新任务或阶段计划调整 | 回退到 Phase 3 修改计划 |
| Major | 涉及架构变更 | 回退到 Phase 2 重新设计 |

**三级置信度自动检测（执行中）：**

| 置信度 | 条件 | 行为 |
|--------|------|------|
| HIGH (≥5分) | 显式调用或明确变更语句 | 直接进入变更流程 |
| MEDIUM (3-4分) | 变更动词 + 具体对象 | 单次确认后决定 |
| LOW (≤2分) | 不确定语气 / 疑问句 | 不触发，任务完成后提示 |

---

## Project Surgeon — 已有项目接管

```
调用方式: /project-surgeon [项目路径，或 '.' 表示当前目录]
```

专为**已有项目**设计的系统化分析、审查和改进技能。与 Workflow Architect（从零创建项目）互补。

**四阶段工作流：**

| 阶段 | 目的 | 核心交付物 |
|------|------|-----------|
| Phase 1: 分析 | 自动扫描项目结构、技术栈、依赖健康、架构模式 | `.project-surgeon/analysis-report.md` |
| Phase 2: 审查 | 复用 Bug Fixer 7 维度协议做全面代码审查 | `.project-surgeon/review-report.md` |
| Phase 3: 计划 | 按风险/优先级生成三级改进计划 | `.project-surgeon/project-plan.md` + phases/ |
| Phase 4: 执行 | 逐任务执行改进，含 Preservation Gate 保护 | 改进后的代码 |

**Preservation Gate（独有安全机制）：**

每个任务执行前后对比测试套件结果，新增失败自动回滚。确保改进过程不破坏现有功能。

**使用外挂技能：**

```
/project-surgeon:bug-fixer src/              # 审查 src 目录的代码
/project-surgeon:issue-changer 加一个缓存层   # 提交变更请求
```

---

## 目录结构

```
workflow-architect/                         # 仓库根目录
├── README.md                               # 本文档（中文）
├── README.en.md                            # English version
├── LICENSE                                 # 许可证
├── claude/                                 # Claude Code 版本
│   └── skills/
│       ├── workflow-architect/             # Claude Code Skill（含专有 frontmatter）
│       │   ├── SKILL.md
│       │   ├── assets/
│       │   ├── bug-fixer/
│       │   ├── issue-changer/
│       │   └── references/
│       └── project-surgeon/               # 已有项目接管 Skill
│           ├── SKILL.md
│           ├── assets/
│           ├── bug-fixer/
│           ├── issue-changer/
│           └── references/
└── codex/                                  # OpenAI Codex CLI 版本
    └── skills/
        ├── workflow-architect/             # Codex Skill（通用 frontmatter）
        │   ├── SKILL.md
        │   ├── assets/
        │   ├── bug-fixer/
        │   ├── issue-changer/
        │   └── references/
        └── project-surgeon/               # 已有项目接管 Skill
            ├── SKILL.md
            ├── assets/
            ├── bug-fixer/
            ├── issue-changer/
            └── references/
```

两个版本的技能内容完全一致，仅在以下方面有差异：
- **frontmatter 字段**：Claude Code 版包含 `allowed-tools`、`when_to_use` 等专有字段；Codex 版仅保留 `name` + `description`
- **工具引用**：Claude Code 版引用 `AskUserQuestion`、`TaskCreate` 等专有工具名；Codex 版使用通用描述

---

## 安装

### Claude Code 安装

#### 前提条件

- 已安装 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)（CLI、桌面应用、VS Code 扩展 或 JetBrains 扩展均可）

#### 一键安装

在 Claude Code 中直接发送以下提示词即可安装：

```
请帮我安装 Claude Code Skill。
仓库地址：https://github.com/EasyCode-Obsidian/workflow-architect

安装步骤：
1. 克隆仓库到临时目录：
   git clone https://github.com/EasyCode-Obsidian/workflow-architect.git /tmp/workflow-architect-repo
2. 将 Claude Code 版技能复制到 skills 目录：
   cp -r /tmp/workflow-architect-repo/claude/skills/workflow-architect ~/.claude/skills/workflow-architect
   cp -r /tmp/workflow-architect-repo/claude/skills/project-surgeon ~/.claude/skills/project-surgeon
3. 清理临时目录：
   rm -rf /tmp/workflow-architect-repo
4. 验证安装：确认 ~/.claude/skills/workflow-architect/SKILL.md 和 ~/.claude/skills/project-surgeon/SKILL.md 文件存在
5. Windows 用户路径为：%USERPROFILE%\.claude\skills\
```

#### 手动安装

**macOS / Linux:**
```bash
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git /tmp/wa-repo
cp -r /tmp/wa-repo/claude/skills/workflow-architect ~/.claude/skills/workflow-architect
cp -r /tmp/wa-repo/claude/skills/project-surgeon ~/.claude/skills/project-surgeon
rm -rf /tmp/wa-repo
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git "$env:TEMP\wa-repo"
Copy-Item -Recurse "$env:TEMP\wa-repo\claude\skills\workflow-architect" "$env:USERPROFILE\.claude\skills\workflow-architect"
Copy-Item -Recurse "$env:TEMP\wa-repo\claude\skills\project-surgeon" "$env:USERPROFILE\.claude\skills\project-surgeon"
Remove-Item -Recurse -Force "$env:TEMP\wa-repo"
```

**ccw / npx 安装（推荐）：**

```bash
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git ~/.claude/skills-repos/workflow-architect
ln -s ~/.claude/skills-repos/workflow-architect/claude/skills/workflow-architect ~/.claude/skills/workflow-architect
ln -s ~/.claude/skills-repos/workflow-architect/claude/skills/project-surgeon ~/.claude/skills/project-surgeon
```

安装后重启 Claude Code 即可生效。

### OpenAI Codex CLI 安装

#### 前提条件

- 已安装 [Codex CLI](https://github.com/openai/codex)

#### 手动安装

**macOS / Linux:**
```bash
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git /tmp/wa-repo
cp -r /tmp/wa-repo/codex/skills/workflow-architect ~/.codex/skills/workflow-architect
cp -r /tmp/wa-repo/codex/skills/project-surgeon ~/.codex/skills/project-surgeon
rm -rf /tmp/wa-repo
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/EasyCode-Obsidian/workflow-architect.git "$env:TEMP\wa-repo"
Copy-Item -Recurse "$env:TEMP\wa-repo\codex\skills\workflow-architect" "$env:USERPROFILE\.codex\skills\workflow-architect"
Copy-Item -Recurse "$env:TEMP\wa-repo\codex\skills\project-surgeon" "$env:USERPROFILE\.codex\skills\project-surgeon"
Remove-Item -Recurse -Force "$env:TEMP\wa-repo"
```

安装后重启 Codex CLI 即可生效。

---

## 快速开始

### 启动新项目

```
/workflow-architect 一个任务管理 Web 应用，支持团队协作和看板视图
```

Workflow Architect 将引导你完成四个阶段：

1. **需求收集** — 逐个提问，帮你梳理清楚需求
2. **草案呈现** — 展示架构方案供你审批（可修改、可拒绝）
3. **计划落盘** — 生成详细的三级执行计划
4. **逐步执行** — 按计划编码，每个任务完成后提交

### 接管已有项目

```
/project-surgeon .
```

Project Surgeon 将引导你完成四个阶段：

1. **项目分析** — 自动扫描技术栈、架构、依赖健康
2. **代码审查** — 7 维度系统化审查，输出审查报告
3. **改进计划** — 按风险优先级生成三级执行计划
4. **改进执行** — 逐任务执行，Preservation Gate 保护现有功能

### 使用外挂技能

```
/workflow-architect:bug-fixer src/          # 审查 src 目录的代码
/workflow-architect:bug-fixer "登录失败"    # 追踪特定 Bug
/workflow-architect:issue-changer 加一个消息通知系统   # 提交变更请求
/project-surgeon:bug-fixer src/             # 在接管项目中审查代码
/project-surgeon:issue-changer 加一个缓存层  # 在接管项目中提交变更
```

### 会话恢复

中途退出后，再次调用对应技能即可恢复：

```
/workflow-architect    # 恢复从零创建的项目
/project-surgeon       # 恢复接管的项目
```

系统会自动检测状态文件（`.workflow/state.json` 或 `.project-surgeon/state.json`），显示当前进度，询问是恢复还是重新开始。

---

## 技术细节

### 状态管理

所有工作流状态持久化到 `.workflow/state.json`，包含：

- 当前阶段与状态
- 阶段历史（含回退记录）
- 需求覆盖率地图
- 头脑风暴完成状态
- 执行进度（阶段/任务级别）
- 错误日志
- 变更请求记录

### DeepWiki 集成

Phase 4 编码时通过 DeepWiki 查询 GitHub 仓库文档，三级研究协议：

| 级别 | 时机 | 目的 |
|------|------|------|
| Tier 1 | 阶段开始前 | 批量查询本阶段涉及的所有库/框架 |
| Tier 2 | 任务开始前 | 精确查询本任务涉及的 API |
| Tier 3 | 编码过程中 | 遇到不确定的 API 用法时即时查询 |

脚本通过 HTTP 直接调用 DeepWiki MCP 端点，无需安装 MCP 配置。

### 上下文管理

针对大型项目（10+ 阶段 / 50+ 任务）的优化策略：

- **延迟加载** — 不一次性读取所有计划，按需加载当前阶段/任务
- **已完成阶段摘要** — 完成的阶段压缩为 5-10 行摘要
- **会话分段** — 上下文接近上限时提示开新会话
- **任务条目分批** — 50+ 任务时分阶段创建 TaskCreate 条目

### HARD-GATE 规则

以下规则不可违反：

1. Phase 4 之前不写代码
2. 未经用户批准不推进阶段
3. 计划指导执行，但允许专业判断（类型注解、防御性检查等）
4. 不可跳过任何阶段
5. 草案（Phase 2）不写入磁盘
6. 计划（Phase 3）必须全部写入磁盘

---

## 许可证

本项目采用 [自定义限制性许可证](LICENSE)。

**允许：** 个人使用（安装、运行、调用）

**禁止：** 复制、分发、修改、创建衍生作品、参考设计用于其他项目

详见 [LICENSE](LICENSE) 文件。
