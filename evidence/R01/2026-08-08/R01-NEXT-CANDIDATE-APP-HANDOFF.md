# R01 下一阶段：候选 App 重建、行为等价与安装决策 Handoff

生成时间：2026-08-08 CST

仓库：`Steven-ZYH/sixlab-pr-control`

目标 App：`/Users/steven/Applications/SIXLAB PR Control.app`

Handoff 性质：**仅交接文档；生成本文时未创建 checkout、未构建、未启动候选 App、未安装。**

## 一句话结论

R01 Strangler/Legacy Facade 已进入 `main`，CircleCI macOS 已生效；下一位执行者应从执行当时的 live `main` 建立全新隔离 checkout，重建候选 App并对当前安装版做行为等价验收，最终只输出 `READY-TO-INSTALL`、`NO-INSTALL-NEEDED` 或 `DO-NOT-INSTALL`。本 Handoff 不授权覆盖安装版。

## 已完成事实

### R01 代码基线

- PR [#4](https://github.com/Steven-ZYH/sixlab-pr-control/pull/4) 已合并。
- PR #4 head：`afd210053f2ab14b68d3a453e3be1a05b7817447`。
- PR #4 squash commit：`0ca19067ae043b92d137c923f5019de0c2f0ec0d`。
- Project Registry、`Observed<T>`、Audit Event、Shadow Comparison 与六路 Legacy Facade 已进入 `main`。
- 六路 Facade 默认仍为 `legacyOnly`；旧结果继续驱动 UI、缓存、刷新和通知。
- 审核机写命令的 Shadow 只比较 intent/receipt，不允许重复执行 SSH、enqueue、status 或 monitor。

### CI 基线

- PR [#7](https://github.com/Steven-ZYH/sixlab-pr-control/pull/7) 已合并。
- PR #7 head：`a3aa115d0f3cdafbc12acaeba2c6a5b8158fddb0`。
- PR #7 squash commit：`7a65580d7d24352bc52d895a43250893f4874bd2`。
- CircleCI `native-build-and-test` 已在该合并提交上成功：<https://circleci.com/gh/Steven-ZYH/sixlab-pr-control/2>。
- CircleCI 只运行源码 checkout、精确 SHA 校验与 `./test-native.sh`；没有上传候选 App、渲染产物、签名材料或部署秘密。

以上 SHA 是最后一次已验证事实，不是永久 pin。执行者开始工作时必须重新读取 live `main`，并把完整 SHA 写入执行报告；不得凭本文假设 `main` 没有推进。

## 当前本机事实快照

只读采样时间：2026-08-08 CST。

### 原源码工作树

- 路径：`/Users/steven/Documents/Project/SIXLABPRControl`
- 分支：`codex/review-machine-high`
- HEAD：`b26a029752055f950ebe44b42ee617fa6948942e`
- 相对其 upstream：`behind 8`
- 仍存在多项 tracked 修改与 3 个 untracked 文件。
- remote 已是 SSH：`git@github.com:Steven-ZYH/sixlab-pr-control.git`。

这份工作树是受保护现场，不是候选构建输入。禁止在其中 fetch 后 merge、pull、reset、clean、rebase、checkout 覆盖、构建候选或安装。

### 当前安装版

- 路径：`/Users/steven/Applications/SIXLAB PR Control.app`
- Bundle 版本：`1.0.0` / build `1`
- 可执行文件 SHA-256：`7c5e06b84e047ffa7b1eecd6562dff48d907d8ce4bb6d46bb6e12cbb758c7fc9`
- `codesign --verify --deep --strict`：通过。
- 采样时进程：PID `93306`，可执行文件来自上述安装路径。

注意：2026-08-06 的 `BASELINE.md` 记录过旧哈希 `b781723e...`，它已不是当前安装版事实。执行者必须在开始和结束时重新采样安装版哈希、签名和 PID；若期间发生变化，立即停止并标记 `BASELINE_DRIFT`。

## 本阶段目标

1. 从执行时 live `main` 的精确 SHA 重建候选 App。
2. 证明 Swift Package、Native/Worker Harness、签名与 App bundle 完整。
3. 在隔离 HOME、隔离缓存副本及外部命令禁用条件下，与当前安装版并行运行。
4. 对菜单栏 PR、路线图、Session、审核机状态、缓存/刷新/通知语义做行为等价核对。
5. 判断安装是否有真实收益；不因“构建成功”直接安装。
6. 形成可审计证据与明确安装结论。

## 明确非目标

- 不修改原脏工作树。
- 不在本阶段把任何 Facade 切为 candidate-primary。
- 不删除旧 client、timer、cache 或兼容 alias。
- 不安装或升级 Review Machine Worker。
- 不触发 SSH、审核队列、GitHub 写入、Session 改名、通知发送或部署。
- 不读取、复制或写入明文 token、私钥、Bark secret、Codex auth 或签名材料。
- 不把候选 App、渲染图、缓存正文或签名材料上传到 CircleCI/GitHub。
- 不把本 Handoff 当成安装、合并或部署授权。

## 执行环境

- 使用公司授权的 macOS 构建主机；个人 Mac/审核机不得成为常驻 CI Runner。
- Git clone/fetch 走 SSH；GitHub PR、Review、权限与状态读取走已认证 Connector。
- 候选工作目录必须是新建的临时目录或独立 worktree，不能复用原脏工作树或旧候选目录。
- 若构建机缺少与 CircleCI 基线相容的 Xcode/Swift/XCTest，停止并报告工具链缺口，不得用部分测试冒充完整通过。

## 执行顺序

### 1. 冻结执行时事实

只读记录以下内容：

```bash
git ls-remote git@github.com:Steven-ZYH/sixlab-pr-control.git refs/heads/main
git -C /Users/steven/Documents/Project/SIXLABPRControl status --short --branch
shasum -a 256 "/Users/steven/Applications/SIXLAB PR Control.app/Contents/MacOS/SIXLABPRControl"
codesign --verify --deep --strict "/Users/steven/Applications/SIXLAB PR Control.app"
pgrep -fl SIXLABPRControl
```

把 live main SHA 记为 `SOURCE_SHA`。从这一刻起，构建、测试、候选 manifest、Shadow 记录和结论必须全部绑定同一个 `SOURCE_SHA`。若 `main` 推进，不得混用旧测试；重新开始一次完整验收。

### 2. 建立干净候选 checkout

建议流程：

```bash
WORK_DIR="$(mktemp -d /private/tmp/opcb-r01-next.XXXXXX)"
git clone git@github.com:Steven-ZYH/sixlab-pr-control.git "$WORK_DIR/repo"
git -C "$WORK_DIR/repo" checkout --detach "$SOURCE_SHA"
git -C "$WORK_DIR/repo" status --porcelain
git -C "$WORK_DIR/repo" rev-parse HEAD
```

验收：`status --porcelain` 必须为空，`HEAD` 必须等于 `SOURCE_SHA`。不要从原工作树复制源码，也不要把其未提交文件混入候选。

### 3. 重建与测试

在干净 checkout 中执行：

```bash
swift test
./test-native.sh
```

必须保存完整退出码和摘要。最低预期：

- ProjectControlDomain XCTest 全部通过；当前历史基线为 22 tests，但以 `SOURCE_SHA` 实际测试数为准。
- Native/Worker smoke 全部通过。
- AppIcon bundle、Dashboard render、PR Detail render 通过。
- `build/SIXLAB PR Control.app` 生成成功。
- `codesign --verify --deep --strict` 通过。

不得只运行 `build-native.sh` 后宣布通过；完整 `test-native.sh` 与 Swift Package 都是门槛。

### 4. 生成三方 manifest

分别生成并保留：

- `SOURCE-MANIFEST.sha256`：精确源码与关键构建脚本。
- `CANDIDATE-MANIFEST.sha256`：候选 App bundle。
- `INSTALLED-MANIFEST.sha256`：当前安装版 bundle。

至少比较：可执行文件、Info.plist、AppIcon、字体和 bundle 内其他资源。哈希不同不是自动失败，但每个差异都必须能追溯到 `SOURCE_SHA` 的明确变更；无法解释的差异为 `DO-NOT-INSTALL`。

### 5. 隔离并行运行

复制缓存到临时隔离 HOME，不得让候选写入正式 `~/Library/Application Support/SIXLABPRControl/`。禁用所有外部命令并启用六路 Shadow：

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

如需把同一 Dashboard 暴露给可访问性 Harness，只允许在候选进程设置 `SIXLAB_R01_UI_HARNESS=1`；生产安装路径不得携带该变量。

预期：

- 已触发 Shadow 路径 `unexplained=0`。
- 被禁用的 GitHub/SSH/Codex 保持 unavailable/failure，不得伪造 live 成功。
- SSH、enqueue、status、monitor 实际执行次数为 0。
- 候选停止后，正式安装版仍运行且缓存未漂移。

### 6. 实际交互清单

只做只读交互：

- 切换 OPCB、PR CONTROL、OPCB FDE 项目。
- 打开一个 PR 详情并展开 checks。
- 打开路线图总控，核对文档与条目数量。
- 打开“管理显示”，核对显示状态。
- 核对 Session、Review Machine、缓存年龄、partial/unreachable/unknown 的语义。
- 核对刷新周期和通知配置未被候选改写。

禁止点击送审核机、刷新 live、Session 写操作、GitHub 写操作或任何外部命令入口。

### 7. 回退演练

停止候选进程，移除全部 Shadow/UI Harness 环境变量，确认：

- 候选无残留进程。
- 正式安装版仍来自原安装路径。
- 正式缓存目录没有被候选写入。
- 当前安装版 SHA、签名和核心只读交互与开始时一致。

## 安装决策规则

### `READY-TO-INSTALL`

只有全部满足才可给出：

- checkout clean 且所有证据绑定同一 live main SHA；
- `swift test` 与完整 `./test-native.sh` 通过；
- 候选签名通过；
- 所有 bundle 差异有明确来源；
- 六路 Shadow 的所有已触发路径均为 `unexplained=0`；
- 实际只读交互通过；
- 正式安装版与缓存回退演练通过；
- 无外部写操作、秘密读取或产物上传。

该结论只表示“可以请求安装授权”，不等于已经获准安装。

### `NO-INSTALL-NEEDED`

若候选与当前安装版的可执行文件、关键资源和行为等价，且 `SOURCE_SHA` 没有带来 App 侧新增能力，明确返回该结论。不要为了形式完成而覆盖同一版本。

### `DO-NOT-INSTALL`

任一测试失败、工具链缺失、baseline 漂移、candidate/installed 差异无法解释、Shadow 有 unexplained、候选触发外部写操作或无法完成回退时使用。

## 安装阶段边界

本 Handoff **不授权安装**。收到 Steven 明确的“安装这个候选 App”后，另开安装步骤：

1. 再次确认候选 SHA、`SOURCE_SHA` 与验收报告一致。
2. 把当前安装版完整复制到本地私有、gitignored 的可恢复备份并记录哈希。
3. 不删除 Application Support 缓存。
4. 先在临时目标验证签名，再进行可恢复替换；不得边复制边运行。
5. 启动新 App，完成菜单栏、PR、路线图、Session、审核机状态的只读 smoke。
6. 任一失败立即恢复旧 App并验证旧哈希和运行能力。

安装授权仍不授权 Review Machine Worker 升级、仓库 rename、Organization transfer 或其他部署。

## 必须交付的证据

建议写入 `evidence/R01/<execution-date>/candidate-app/`：

- `EXECUTION-REPORT.md`
- `SOURCE-MANIFEST.sha256`
- `CANDIDATE-MANIFEST.sha256`
- `INSTALLED-MANIFEST.sha256`
- `TEST-SUMMARY.txt`
- `SHADOW-SUMMARY.md`
- `INTERACTION-CHECKLIST.md`
- `INSTALL-DECISION.md`

候选 App ZIP、缓存副本和详细 Shadow 日志属于本地私有证据，放入 gitignored `private/`；不得提交或上传。

## 停止条件

遇到以下任一项立即停止，不要自行扩大权限：

- live `main` 在验收期间变化；
- 当前安装版 SHA、签名或 PID 无预期变化；
- 原脏工作树被意外修改；
- 缺 Xcode/XCTest/Swift 工具链；
- 测试不能完整运行；
- 需要读取秘密或连接审核机才能继续；
- 候选触发任何外部副作用；
- 需要覆盖安装版才能完成行为验收。

## 执行者回报格式

```text
VERDICT: READY-TO-INSTALL | NO-INSTALL-NEEDED | DO-NOT-INSTALL
SOURCE_SHA: <full main sha>
INSTALLED_SHA: <sha256>
CANDIDATE_SHA: <sha256>
CHECKS:
- swift test — PASS/FAIL/NOT-RUN
- ./test-native.sh — PASS/FAIL/NOT-RUN
- codesign — PASS/FAIL
- shadow comparison — PASS/FAIL/NOT-RUN
- isolated interaction — PASS/FAIL/NOT-RUN
- rollback — PASS/FAIL/NOT-RUN
DIFFERENCES:
- <field/resource/behavior — explained or unexplained>
BOUNDARIES:
- original dirty worktree: untouched / violated
- external writes: none / details
- install: not performed
- worker/deploy: not performed
NEXT AUTHORITY NEEDED: install authorization | none | remediation decision
```

## 既有证据入口

- [R01 可重建基线](../2026-08-06/BASELINE.md)
- [R01.3 契约记录](../2026-08-06/R01.3-CONTRACTS.md)
- [R01 Runtime Legacy Facade 收口](../2026-08-06/R01.3-SHADOW-RUNTIME-FACADES.md)
- [PR #4 审核 Handoff](../2026-08-06/R01-PR4-REVIEW-HANDOFF.md)

本文是执行交接输入，不是候选通过证明、安装授权或部署授权。
