# main 分支保护配置指南

## 前置条件

1. 仓库已推送到 GitHub 并配置 remote：
   ```bash
   git remote add origin git@github.com:<org>/<repo>.git
   git push -u origin main
   ```
2. Evidence Gate CI 工作流已合并到 main 分支并至少成功运行一次

## 配置步骤

### 1. 启用分支保护

前往 **GitHub → Settings → Branches → Add branch protection rule**

- **Branch name pattern**: `main`
- 勾选以下选项：

| 选项 | 说明 |
|------|------|
| **Require a pull request before merging** | 禁止直接推送，必须通过 PR |
| **Require approvals** (1) | 至少 1 人审查后才可合并 |
| **Require status checks to pass** | 搜索并添加 `Evidence Gate` |
| **Require branches to be up to date** | 合并前必须与 main 同步 |
| **Do not allow bypassing** | 管理员也不能绕过保护 |

### 2. 配置 Status Check

在 "Require status checks to pass" 下，搜索并添加以下 check：

- `Evidence Gate / 证据文件格式验证`
- `Evidence Gate / SHA256 校验和完整性`
- `Evidence Gate / Markdown 证据结构检查`

### 3. 验证保护生效

```bash
# 尝试直接推送（应被拒绝）
echo "test" >> test-file.txt
git add test-file.txt
git commit -m "test: direct push attempt"
git push origin main
# 预期：GitHub 拒绝此推送

# 正确流程：创建分支 → PR → 审查 → 合并
git checkout -b test/protection-verify
git push origin test/protection-verify
# 然后在 GitHub 上创建 PR 到 main
```

## CI 门禁行为

- **PR 触发**：每次 PR 创建/更新都会运行 Evidence Gate
- **推送触发**：直接推送到 main 时也会运行（作为事后审计）
- **失败阻断**：任何 check 失败都会阻止 PR 合并
- **格式验证**：SHA256 校验和、Markdown 结构、大文件限制

## 本地预检

在提交前本地运行验证：

```bash
bash scripts/validate-evidence.sh
```
