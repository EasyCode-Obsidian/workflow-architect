# Reference Index — 参考文件索引

> This index lists all reference files and when to load them.
> Load files on demand only — do not load everything at once.

<!-- 本索引列出所有参考文件及其加载时机。 -->

---

| File | When to Read | Description |
|------|-------------|-------------|
| [state-management.md](state-management.md) | Session start, phase transitions, error recovery | JSON schema, state transitions, persistence rules |
| [brainstorm-protocol.md](brainstorm-protocol.md) | Every brainstorm trigger point (BS-1 through BS-7) | Multi-perspective analysis, alternative exploration, devil's advocate |
| [phase-1-requirements.md](phase-1-requirements.md) | Entering Phase 1 (requirements collection) | 10-category taxonomy, questioning protocol, coverage assessment |
| [phase-2-draft.md](phase-2-draft.md) | Entering Phase 2 (draft proposal) | Draft content structure, presentation protocol, approval gate |
| [phase-3-planning.md](phase-3-planning.md) | Entering Phase 3 (execution planning) | 3-level plan hierarchy, writing protocol, naming conventions |
| [phase-4-execution.md](phase-4-execution.md) | Entering Phase 4 (plan execution) | Execution loop, 3-Strike error recovery, progress tracking |
| [deepwiki-integration.md](deepwiki-integration.md) | Phase 4 — before coding each phase/task | 3-tier DeepWiki research protocol, script usage, caching |

## Add-on Skills — 外挂技能

| Skill | Entry Point | When to Load |
|-------|------------|-------------|
| [Bug Fixer](../bug-fixer/SKILL.md) | `bug-fixer` | 3-Strike Option E, milestone code review, standalone code audit |
| [Issue Changer](../issue-changer/SKILL.md) | `issue-changer` | Mid-execution change requests, post-completion changes |

Each add-on skill has its own `references/` directory. See their respective `references/index.md` for sub-references.

## Plan Templates

Located in `assets/templates/`:

| Template | Used In | Purpose |
|----------|---------|---------|
| [project-plan.md](../assets/templates/project-plan.md) | Phase 3, Level 1 | Overall project execution plan |
| [phase-plan.md](../assets/templates/phase-plan.md) | Phase 3, Level 2 | Per-phase execution plan |
| [task-plan.md](../assets/templates/task-plan.md) | Phase 3, Level 3 | Per-task detailed instructions |

## Scripts

Located in `assets/scripts/`:

| Script | Used In | Purpose |
|--------|---------|---------|
| [deepwiki.sh](../assets/scripts/deepwiki.sh) | Phase 4, all tiers | DeepWiki MCP HTTP wrapper — ask, structure, contents commands |
