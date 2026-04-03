# Task {{TASK_NUMBER}}: {{TASK_NAME}}

> Phase: {{PHASE_NUMBER}} — {{PHASE_NAME}}
> Status: {{STATUS}}

---

## Objective

<!-- 用一句话描述本任务的目标 -->

{{OBJECTIVE}}

## Files

**Create:**
{{FILES_TO_CREATE}}

**Modify:**
{{FILES_TO_MODIFY}}

**Test:**
{{TEST_FILES}}

## Dependencies (**REQUIRED** — Task Research Agent reads this table)

<!-- 本任务涉及的外部库及其 GitHub 仓库映射，供 DeepWiki / Task Research Agent 查询使用 -->
<!-- 如果本任务不使用外部库，写 "None" 而不是删除本节 -->

| Library | GitHub Repo | APIs Used | Usage in This Task |
|---------|-------------|-----------|-------------------|
| {{LIB_1}} | {{OWNER/REPO_1}} | {{API_LIST_1}} | {{USAGE_1}} |
| {{LIB_2}} | {{OWNER/REPO_2}} | {{API_LIST_2}} | {{USAGE_2}} |

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
