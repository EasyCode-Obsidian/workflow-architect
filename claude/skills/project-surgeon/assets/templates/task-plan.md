# Task {{TASK_NUMBER}}: {{TASK_NAME}}

> Phase: {{PHASE_NUMBER}} — {{PHASE_NAME}}
> Status: {{STATUS}}

---

## Objective

<!-- 用一句话描述本任务的目标 -->

{{OBJECTIVE}}

## Related Findings — 关联发现

| Finding ID | Severity | File | Description |
|-----------|----------|------|-------------|
| {{FINDING_ID}} | {{SEVERITY}} | {{FILE}} | {{DESCRIPTION}} |

## Files

**Create:**
{{FILES_TO_CREATE}}

**Modify:**
{{FILES_TO_MODIFY}}

**Test:**
{{TEST_FILES}}

## Dependencies

<!-- 本任务涉及的外部库及其 GitHub 仓库映射，供 DeepWiki 查询使用 -->

| Library | GitHub Repo | Usage in This Task |
|---------|-------------|-------------------|
| {{LIB_1}} | {{OWNER/REPO_1}} | {{USAGE_1}} |
| {{LIB_2}} | {{OWNER/REPO_2}} | {{USAGE_2}} |

## Steps

<!-- 每一步都必须是原子操作，使用动词开头 -->

### Step 1: {{STEP_1_TITLE}}

{{STEP_1_INSTRUCTIONS}}

```{{LANG}}
{{STEP_1_CODE_OR_COMMAND}}
```

### Step 2: {{STEP_2_TITLE}}

{{STEP_2_INSTRUCTIONS}}

```{{LANG}}
{{STEP_2_CODE_OR_COMMAND}}
```

<!-- ... more steps as needed ... -->

## Verification

<!-- 本任务完成的验证方式 -->

### Baseline Tests — 基线测试

- [ ] Run test suite before task: `{{TEST_COMMAND}}`
- [ ] Record baseline: {{BASELINE_PASS}} passing, {{BASELINE_FAIL}} failing
- [ ] Run test suite after task
- [ ] Verify no new failures (Preservation Gate)

- [ ] {{VERIFY_1}}
- [ ] {{VERIFY_2}}

**Test command:**
```bash
{{TEST_COMMAND}}
```

**Expected output:**
```
{{EXPECTED_OUTPUT}}
```

## Commit

```
{{COMMIT_TYPE}}: {{COMMIT_MESSAGE}} (Phase {{PHASE_NUMBER}}, Task {{TASK_NUMBER}})
```
