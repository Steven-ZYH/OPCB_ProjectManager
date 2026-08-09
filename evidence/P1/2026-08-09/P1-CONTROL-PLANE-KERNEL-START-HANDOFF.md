# P1 控制平面内核启动 Handoff

生成时间：2026-08-09 CST

执行仓库：`Steven-ZYH/sixlab-pr-control`

Handoff 类型：**START HANDOFF**。本文是下一 P 的启动输入；生成本文时未新建 checkout、分支或 PR。收到 Steven 明确的“开始”后，执行者可从执行时 live `main` 建立隔离 checkout，完成 P1 第一交付切片的本地实现、测试、分支和 PR；仍不授权 merge、安装替换、Worker 升级或部署。

## 一句话目标

从已关闭的 R01 基线模块出发，把当前只有 `ProjectControlDomain` 的包扩成可强制依赖方向的内核骨架，并交付第一个可合并切片：**模块边界 + RegistryStore 持久化／迁移／校验的最小闭环**。本切片不改 UI 行为，不切换 Facade，不引入外部写能力。

## 已确认起点

- R01 基线／Facade／候选安装模块已关闭；关闭记录见 [R01-MODULE-CLOSURE.md](../../R01/2026-08-09/R01-MODULE-CLOSURE.md)。
- 最后一次已验证 live main 为 `6f23f0b6015573632ed830f59cc943e80f8daa63`；开始执行时必须重新查询，不得永久 pin。
- 该 SHA 的 `Package.swift` 只有 `ProjectControlDomain` target。
- R03.1 Registry schema/fixture、R09.1 AuditEvent envelope、R12.1 `Observed<T>`/Freshness 基础合同已存在且通过 22 个测试。
- P1.1 的上述领域词汇基础已由 R01.3 提前完成；`CommandIntent`／`PolicyDecision` 的完整词汇和反例仍缺失，延后与 P1.6 Policy Engine 一起完成，不阻塞先建立包边界。
- 六路 Legacy Facade 只有 `legacyOnly` 与 `shadow`；默认旧实现继续驱动 UI、缓存、刷新与通知。
- 正式安装版已绑定 clean main 来源并通过验收，但安装不构成 P1 代码门或切流授权。

## 为什么先做这一切片

原路线图把 P1.2–P1.8 串成正确的大依赖链，但当前现实是合同层已经先由 R01.3 落地，运行时与持久化层仍为空。若直接进入主窗口、SQLite、Policy 或 Facade 切流，会继续让 AppDelegate 和单体 native 源承担事实所有权。先建立包边界和 RegistryStore，能为后续 Normalizer、Store、Policy 与 Runtime 提供稳定依赖方向，同时保持用户行为不变。

## 本 PR 范围

### 必须交付

1. 扩展 Swift Package targets：
   - `ProjectControlDomain`：纯模型与合同；
   - `ProjectControlStore`：Registry 持久化端口与文件实现；
   - `ProjectControlAdapters`：只保留协议／测试桩所需的最小边界，不接外部写命令；
   - `ProjectControlPolicy` 与 `ProjectControlUI` 只建立空骨架或延后，不为凑 target 引入无验证代码。
2. 强制依赖方向：Domain 不依赖 AppKit、SQLite3、Process、shell 或具体 provider；Store 依赖 Domain，native App 通过兼容 Facade 接入。
3. 实现 RegistryStore v1 最小闭环：
   - Application Support 下版本化文件；
   - 临时文件 + fsync/rename 或等价原子替换；
   - schema 校验、重复 projectID/repository 拒绝；
   - 内置 catalog / `SIXLAB_PR_PROJECTS` 幂等导入；
   - 失败不覆盖上一有效版本；
   - 不保存 token、私钥、secret 正文。
4. 提供迁移与恢复测试：空目录、首次导入、重复导入、旧版本迁移、未知版本、损坏文件、写入中断、重启恢复。
5. 保持 `build-native.sh`、`swift test`、完整 `test-native.sh` 与默认菜单栏行为通过。
6. 记录 P1.1 的剩余合同缺口，不在本 PR 内用空类型假装完成 `CommandIntent`／`PolicyDecision`。

### 明确不做

- 不新增主窗口或改视觉；
- 不实现 SQLite 事件账本、Policy 决策、CommandBus 或 XPC；
- 不把 Registry 配置视为 GitHub/SSH/审核机/部署授权；
- 不加入 `candidatePrimary`，不切换任何生产读路径；
- 不删除旧 catalog、环境变量兼容、timer、cache、client；
- 不修改受保护脏工作树；
- 不安装候选 App，不升级 Worker，不部署。

## 开始前冻结

1. 通过 GitHub Connector 读取仓库默认分支、live `main` 和开放 PR；Git clone/fetch 走 SSH。
2. 记录：
   - `SOURCE_SHA=<live main full SHA>`；
   - 当前安装版可执行文件 SHA、`OPCBSourceSHA`、签名和进程路径；
   - 受保护工作树 branch/HEAD/status，仅只读。
3. 新建 `/private/tmp` 隔离 clone 或 worktree，detached 到 `SOURCE_SHA`；`status --porcelain` 必须为空。
4. 若 main、安装版或权威合同在执行期间漂移，停止并重新冻结，不混用证据。

## 推荐实现顺序

1. 写依赖方向测试和 RegistryStore 行为测试，使其先失败。
2. 拆出 Store target 与 protocol，不移动无关 UI/network 代码。
3. 实现 file-backed RegistryStore、原子写、last-known-good 与迁移。
4. 接入 native 兼容入口：只替换 Registry 的持久化来源，不改变项目列表、顺序、刷新或能力语义。
5. 运行单元、故障注入、完整 native Harness。
6. 生成候选 bundle 仅用于验证；不得安装。
7. 对最新 main 再做 merge-tree、diff-check、完整测试并创建 Ready PR。

## 验收门

| 门 | 必须证据 |
|---|---|
| 精确来源 | clean checkout、完整 `SOURCE_SHA`、执行末尾 main/head 复核 |
| 模块边界 | target 依赖图与禁止依赖测试；Domain 无 AppKit/Process/provider |
| 持久化 | 首次导入、幂等、迁移、损坏、写中断、跨进程重启测试 |
| 安全 | Registry 序列化不含 token、secret、私钥正文；项目能力默认最小 |
| 兼容 | 当前四项目及顺序语义不回退；旧 catalog/env 可只读回退 |
| 全量回归 | `swift test`、完整 `test-native.sh`、bundle source binding、codesign 全通过 |
| 权限边界 | 无外部写、无安装、无 Worker/部署、无 Facade 切流 |

## PR 规则

- 分支使用 `codex/` 前缀。
- PR 必须绑定 exact head，列出 target 依赖图、迁移格式、失败恢复和完整测试。
- 作者侧实现、验证与风险披露完成后标记 Ready，并请求 `miaopantao`；不要主动请求或 @ 通知 Xia Mingsheng。
- 任一 push 后重新读取 current head、approval、checks、threads 和 mergeability；旧 SHA 的审核不可复用。
- 本 Handoff 不授权 merge。收到独立“过了，合并”后仍需 fresh current-head 复核。

## 停止条件

- 需要修改或清理 `/Users/steven/Documents/Project/SIXLABPRControl` 才能继续；
- 需要把项目配置写成第二套 canonical roadmap 或 GitHub 权限源；
- Registry 迁移会覆盖唯一有效配置且无可恢复备份；
- 为通过测试需要弱化 unknown/invalid/unsupported 为成功；
- 需要同时实现 SQLite、Policy、Runtime、主窗口或切流才能让本 PR 成立；
- live main/head 漂移但证据未重跑；
- 需要安装、Worker、SSH 写入或部署授权。

## 下一切片（不在本 PR）

RegistryStore 合并后，按以下顺序继续：

1. P1.4 State Normalizer + generation/CAS；
2. P1.5 SQLite 事件账本 + projection rebuild；
3. P1.6 Policy Engine；
4. P1.7 Runtime Actor 单一所有权；
5. P1.8 + R01.4 的第一个只读切流。

在 Runtime Actor 和统一 projection 完成前，不启动 P2 主窗口实现。

## 执行回报格式

```text
VERDICT: READY-FOR-REVIEW | DO-NOT-REVIEW
SOURCE_SHA: <live main full sha>
HEAD_SHA: <branch full sha>
SCOPE:
- package boundaries — PASS/FAIL
- RegistryStore persistence/migration — PASS/FAIL
CHECKS:
- swift test — PASS/FAIL
- test-native.sh — PASS/FAIL
- source binding/codesign — PASS/FAIL
BOUNDARIES:
- protected dirty worktree — untouched/violated
- external writes — none/details
- facade cutover — not performed
- install/worker/deploy — not performed
MISSING OR DEFERRED:
- <explicit list>
NEXT AUTHORITY NEEDED: review | remediation
```
