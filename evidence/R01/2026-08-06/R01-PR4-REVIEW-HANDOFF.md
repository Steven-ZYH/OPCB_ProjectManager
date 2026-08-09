# PR #4 Review Handoff

生成时间：2026-08-06 14:48 CST  
仓库：`Steven-ZYH/sixlab-pr-control`  
PR：[R01: preserve legacy behavior with strangler facades](https://github.com/Steven-ZYH/sixlab-pr-control/pull/4)  
Base：`main` @ `029ba8b15aff6459327e8832157a8fa74a153faa`  
Current head：`f48c32137f0da5e5d76fc13f2302eca13ab299cd`  
请求审核人：`StevenZYHhome`（仓库权限：`read`）

## 一句话结论

这是 R01 P0 行为保全与 Strangler 边界 PR：把原脏工作树中的已运行能力冻结进可重建分支，建立版本化 Domain 契约和六路独立 Legacy Facade；默认仍由旧实现驱动 UI，写命令在 Shadow 模式只执行一次。

## 当前审核状态

- PR：Ready、Open、未 merge。
- 当前 head：`f48c321`；请只对这个 SHA 提交结论，head 变化后旧结论失效。
- Reviews：0。
- Review threads：0。
- `native-ci` run `31078066733`：`completed / success`，绑定当前 head `f48c321`。
- 当前 head 本地复验：Swift Package 22/22；Native/Worker Harness 16/16；AppIconBundle 与两张 render 通过。
- 本地三方合并：`git merge-tree --write-tree` 成功，tree `2e407f88bfdcedc2edf43c12b42617e6573f3de8`。
- `git diff --check`：通过。

## 变更范围

当前 PR 相对 `main`：43 files，约 7,573 additions / 290 deletions。规模大的原因是它同时保全了未提交但已工作的业务能力，并加入 R01 迁移边界；不是单纯样式重写。

### 1. 行为保全

- 菜单栏 PR 总览、分组、current-head 审批与 CI 语义；
- 多项目标签、路线图、Session 解析与活动状态；
- Review Machine SSH、队列、实时 monitor、签名审计、额度和通知；
- 原缓存位置、刷新间隔、降级状态和操作习惯；
- 原 Native/Worker Harness 与渲染验收。

### 2. 新 Domain 契约

重点目录：`Sources/ProjectControlDomain/`

- `ProjectRegistry`：稳定项目身份、repository alias、配置来源及 schema 迁移；
- `Observed<T>`：live/cached/stale/partial/unknown/unreachable 等证据状态；
- `AuditEvent`：claim、intent、execution、verification 分离；
- `ShadowComparison`：字段级差异、允许差异和未解释差异；
- 未知 schema、敏感字段、重复身份和迟到 generation 均 fail-closed。

### 3. 六路 Legacy Facade

| 开关 | Shadow 范围 |
|---|---|
| `OPCB_PR_OVERVIEW_FACADE_MODE` | PR 概览缓存 |
| `OPCB_ROADMAP_FACADE_MODE` | 路线图缓存 |
| `OPCB_REVIEW_MACHINE_STATUS_FACADE_MODE` | Review Machine 状态缓存 |
| `OPCB_SESSION_FACADE_MODE` | Session 解析与活动结果 |
| `OPCB_GITHUB_LIVE_FACADE_MODE` | GitHub overview/detail live 结果 |
| `OPCB_REVIEW_MACHINE_RUNTIME_FACADE_MODE` | SSH、enqueue、status、monitor 意图与回执 |

所有开关默认 `legacyOnly`。只有显式值 `shadow` 才旁路比较；候选值不驱动 UI。

审核机写路径必须重点确认：Shadow 只比较 typed intent 和 receipt，不能重复发送 SSH、enqueue、status 或 monitor 命令。

### 4. 当前 head 新增 alias

`f48c321` 在原 R01 head `ecef3c3` 之后增加：

- `OPCB-AI/OPCB` 作为第三个 OPCB repository alias；
- 与 `Steven-ZYH/sixlab`、`Steven-ZYH/OPCB` 共享稳定项目 ID 和审核机 checkout；
- Worker candidate version 从 `1.8.0` 更新到 `1.8.2`；
- Native 与 Worker smoke 增加 alias 去重和 checkout 断言。

这部分是当前 head 的新增审查重点，不能用 `ecef3c3` 的 CI 或旧审核结论替代。

## 建议审查顺序

### P0：阻塞项

1. **写命令单次执行**  
   检查 `native/RuntimeLegacyFacades.swift` 与 `native/AppDelegate.swift`：Facade 不得因 Shadow 再调用一次旧 client；enqueue/SSH/monitor 必须只有一次外部副作用。

2. **current-head 与审核语义**  
   检查 `native/GitHubClient.swift`、`native/ReviewMachineQueue.swift`、`review-worker/sixlab_review_queue.py`：历史 approval、旧 head 回执、unsigned completed 或 alias 变化不能冒充当前批准。

3. **证据状态 fail-closed**  
   检查缺文件、损坏 JSON、未知 schema、超时、partial/unreachable 是否仍保持区别，不能补成空、健康或完成。

4. **OPCB alias 隔离与去重**  
   检查三个 OPCB slug 只映射到稳定 `opcb` identity 和同一审核 checkout；不得把非 OPCB 仓库误归并，也不得为同一 PR/head 重复派单。

5. **审核机安全边界**  
   确认 reviewer 子进程仍不能读取 GitHub token、签名私钥、Codex auth、Bark secret 或 SSH agent；PR 不得引入 merge/push/deploy 权限。

### P1：行为等价

1. 缓存成功后才替换，失败时保留旧快照及年龄；
2. Session active/archived、processing/merging/waiting 解析没有退化；
3. PR 分组、current-head approval、CI unknown/partial 和 menu badge 语义一致；
4. 路线图刷新周期、可见性设置和本地/GitHub 打开规则一致；
5. Review Machine 状态、额度、新闻与通知未被 UI Facade 丢失。

### P2：维护性

1. 新模块不读取 UI 全局状态；
2. 绝对路径不成为项目身份；
3. 每个 Facade 有独立回退开关和字段级日志；
4. 没有行为证据的旧代码未被提前删除。

## 复现命令

从 PR head 的独立 checkout 执行：

```bash
git fetch origin main codex/r01-contract-foundation
git merge-tree --write-tree origin/main origin/codex/r01-contract-foundation
git diff --check origin/main...origin/codex/r01-contract-foundation
swift test
./test-native.sh
```

预期基线：

- Swift Package：22 tests，0 failures；
- Native/Worker Harness：16 checks PASS；
- AppIconBundle、Dashboard render、PR Detail render 通过；
- `native-ci` run `31078066733` 已在 `f48c321` 上完成并成功；head 变化后必须重新验证。

## 候选 App Shadow 验收边界

如需实跑，请使用隔离 HOME 并禁用外部命令：

```bash
SIXLAB_PR_GH=/usr/bin/false \
SIXLAB_PR_SSH=/usr/bin/false \
CODEX_BINARY=/usr/bin/false \
OPCB_PR_OVERVIEW_FACADE_MODE=shadow \
OPCB_ROADMAP_FACADE_MODE=shadow \
OPCB_REVIEW_MACHINE_STATUS_FACADE_MODE=shadow \
OPCB_SESSION_FACADE_MODE=shadow \
OPCB_GITHUB_LIVE_FACADE_MODE=shadow \
OPCB_REVIEW_MACHINE_RUNTIME_FACADE_MODE=shadow \
"build/SIXLAB PR Control.app/Contents/MacOS/SIXLABPRControl"
```

预期：已触发的 Shadow 路径 `unexplained=0`。GitHub/SSH 被显式禁用时必须保持失败或 unavailable，不能伪造 live 成功。移除全部开关后不应再出现 Shadow 日志。

## 明确排除项

- 不安装候选 App；
- 不安装或升级审核机 Worker；
- 不 merge PR；
- 不触发 test、staging 或 production deploy；
- 不把 Ready、评审请求或绿色 CI 当成 approval；
- 不因“视觉不再兼容 DJI 4G”删除业务能力；视觉另行验收。

## 审核结论格式

请按 current head `f48c321` 返回：

```text
VERDICT: SHIP | SHIP-WITH-NOTES | DO-NOT-SHIP
HEAD: f48c32137f0da5e5d76fc13f2302eca13ab299cd
FINDINGS:
- [P0-P3] title — file:line — evidence and impact
CHECKS:
- command — PASS/FAIL/NOT-RUN — concise evidence
BOUNDARIES:
- merge: not authorized
- deploy: not authorized
```

没有发现也应明确写 `FINDINGS: none`。任何测试未运行、证据缺失或 current head 变化都必须直说，不能用旧 head 结论补齐。

## 证据入口

- [R01 Runtime Facade 收口记录](./R01.3-SHADOW-RUNTIME-FACADES.md)
- [R01.3 契约记录](./R01.3-CONTRACTS.md)
- [Review Machine 状态 Shadow](./R01.3-SHADOW-REVIEW-STATUS.md)
- [PR 概览 Shadow](./R01.3-SHADOW-PR-OVERVIEW.md)
- [路线图 Shadow](./R01.3-SHADOW-ROADMAP.md)
- [证据 SHA-256](./SHA256SUMS)

本 handoff 是审核输入，不是批准、merge 授权或部署授权。
