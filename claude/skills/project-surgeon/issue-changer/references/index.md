# Issue Changer Reference Index — 参考文件索引

> Reference files for the Issue Changer add-on skill.
> Load files on demand only — do not load everything at once.

<!-- Issue Changer 外挂技能的参考文件索引。按需加载。 -->

---

| File | When to Read | Description |
|------|-------------|-------------|
| [impact-analysis.md](impact-analysis.md) | Starting any change request (both modes) | Impact analysis protocol: parse intent, scan plans/code, classify severity |
| [mid-workflow-protocol.md](mid-workflow-protocol.md) | Mode A — mid-workflow change | Pause-analyze-modify-resume protocol for execution-phase changes |
| [post-completion-protocol.md](post-completion-protocol.md) | Mode B — post-completion change | Abbreviated mini-workflow for changes after project completion |

## Parent Workflow References

These files belong to the parent `project-surgeon` skill and are needed for plan modification and execution:

| File | When to Read | Description |
|------|-------------|-------------|
| [state-management.md](../../references/state-management.md) | State schema and transitions | JSON schema, persistence rules, change_requests field |
| [phase-3-planning.md](../../references/phase-3-planning.md) | Creating/modifying plan files | 3-level plan hierarchy, templates, consistency checks |
| [phase-4-execution.md](../../references/phase-4-execution.md) | Resuming execution after changes | Execution loop, resume protocol, progress tracking |
