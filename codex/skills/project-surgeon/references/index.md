# Reference Files Index — 参考文件索引

> This index lists all reference files and when to load them.
> Load files on demand only — do not load everything at once.

<!-- 本索引列出所有参考文件及其加载时机。按需加载，不要一次性全部加载。 -->

---

| File | Description | When to Load |
|------|-------------|-------------|
| [state-management.md](state-management.md) | State management specification — 状态管理完整规范 | Session start, phase transitions, error recovery |
| [phase-1-analysis.md](phase-1-analysis.md) | Phase 1 detailed protocol — Phase 1 详细协议 | Entering Phase 1 (project analysis) |
| [analysis-protocol.md](analysis-protocol.md) | Tech stack detection heuristics — 技术栈检测启发式 | Phase 1 Step 1 (project discovery scan) |
| [phase-2-review.md](phase-2-review.md) | Phase 2 detailed protocol — Phase 2 详细协议 | Entering Phase 2 (code review) |
| [phase-3-planning.md](phase-3-planning.md) | Phase 3 detailed protocol — Phase 3 详细协议 | Entering Phase 3 (execution planning) |
| [phase-4-execution.md](phase-4-execution.md) | Phase 4 detailed protocol — Phase 4 详细协议 | Entering Phase 4 (plan execution) |
| [deepwiki-integration.md](deepwiki-integration.md) | DeepWiki integration protocol — DeepWiki 集成协议 | Phase 4 — before coding each task |
| [brainstorm-protocol.md](brainstorm-protocol.md) | Brainstorm full protocol — 头脑风暴完整协议 | Every BS trigger point (BS-1 through BS-N) |

## Add-on Skills — 外挂技能

| Skill | Invocation | Integration Points |
|-------|-----------|-------------------|
| [Bug Fixer](../bug-fixer/SKILL.md) | `project-surgeon:bug-fixer` | Phase 4 3-Strike Option E, milestone code review |
| [Issue Changer](../issue-changer/SKILL.md) | `project-surgeon:issue-changer` | Mid-execution change requests, post-completion changes |

Each add-on skill has its own `references/` directory. See their respective `references/index.md` for sub-references.
