# R01 基线／Facade／候选安装模块关闭记录

关闭时间：2026-08-09 CST

模块状态：**CLOSED**

范围：R01.1 事实冻结、R01.2 可重建行为基线、R01.3 Legacy Facade/Shadow，以及从合并后 live `main` 重建、安装和验收候选 App。

## 关闭结论

本模块已经完成代码、独立审核、合并、main CI、候选重建、安装验收、回滚载体和现场清理。正式安装版仍保持默认菜单栏形态，旧实现继续作为权威读路径；因此本关闭结论不等于 R01.4 的模块切流或旧编排退休完成。

| 门 | 当前事实 |
|---|---|
| 代码 | PR #10 head `87f5336967ab033c21636c9e4cdeeaae4f1d2044` 已合并 |
| 合并 | squash commit / live main `6f23f0b6015573632ed830f59cc943e80f8daa63` |
| 审核 | `miaopantao` approval 绑定 PR #10 当前 head；合并前无未解决 thread |
| CI | PR head 与合并后 main 的 CircleCI 均成功 |
| 构建 | clean detached checkout；`swift test` 22/22、`test-native.sh`、bundle 与 codesign 通过 |
| 安装 | `/Users/steven/Applications/SIXLAB PR Control.app`，可执行文件 SHA-256 `352f97e39185d1583702a1cfbac51a9c1ecd109a9ac1e239b6996dab3ef86c7b` |
| 来源绑定 | `OPCBSourceSHA=6f23f0b6015573632ed830f59cc943e80f8daa63`，`OPCBSourceTreeState=clean` |
| 运行 | PID `88560` 从正式安装路径持有该可执行文件；磁盘签名复核通过 |
| UI/Shadow | 已安装二进制只读交互通过；已触发 Shadow `unexplained=0` |
| 回滚 | 安装前 App、Application Support、Preferences 的私有备份和 manifest 保留 |

## 偏好与现场一致性

- 安装验收时的正式偏好字节哈希是点时事实；随后 CFPreferences 把 plist 重写为 SHA-256 `3b1039909325066c0006750be660a0e9371aaafccae90620ffcf7157f9720e2e`。
- 与安装前备份的规范化 XML 和语义值比较无差异：`didPresentNativeDashboardV1=true`、6 个隐藏路线图路径、选中项目 `OPCB-AI/OPCB_Vault` 均保持一致。
- 生产域 `com.sixlab.pr-control` 保留；9 个安装／Dashboard／Model／Window Harness 非生产测试 plist 已删除。

## 收口清理

- 已删除远端已合并分支 `codex/r01-candidate-remediation`。
- 已删除仅属于 R01 的候选 checkout、Swift build/cache、UI/Window Harness home、安装验收目录和临时事件 JSON，释放约 1.6 GB；这些临时文件不可恢复。
- 可恢复的私有安装前备份继续保存在 `evidence/R01/2026-08-09/install/private/`，未进入 manifest 以外的公开证据。
- 受保护脏工作树 `/Users/steven/Documents/Project/SIXLABPRControl` 未清理、未 reset、未 rebase、未覆盖。
- Applications 中两个早于本模块存在的历史备份 App 未修改。

## 关闭边界

以下内容明确不属于本模块已完成事实：

- Review Machine Worker 升级；
- 服务部署、staging、canary 或 production 发布；
- Facade `candidate-primary` 切换；
- 旧 timer/cache/client 删除；
- R01.4 全部完成。

R01.4 保留为 P2–P4 横向退出门：每个 Registry、事实、Session、PR、Roadmap 或命令切片必须独立切流、验证和保留回退，然后才能退休相应旧编排。

## 后续顺序

下一主阶段为 P1 控制平面内核。重排后的顺序是：

1. 完成 Swift Package 模块边界；
2. 完成 Registry 持久化／迁移／健康检查；
3. 完成 State Normalizer、generation 与晚到保护；
4. 完成 SQLite 事件账本和物化视图重建；
5. 完成 Policy Engine；
6. 建立 Runtime Actor 单一所有权；
7. 以菜单栏一个只读切片进入 P1.8／R01.4 首次切流。

启动执行以 [P1 Handoff](../../P1/2026-08-09/P1-CONTROL-PLANE-KERNEL-START-HANDOFF.md) 为准。

## 证据入口

- [R01 契约记录](../2026-08-06/R01.3-CONTRACTS.md)
- [候选执行报告](../2026-08-08/candidate-app/EXECUTION-REPORT.md)
- [PR #10 合并闭环](../2026-08-08/candidate-app/MERGE-CLOSURE.md)
- [安装报告](./install/INSTALL-REPORT.md)
- [安装决策](./install/INSTALL-DECISION.md)
- [安装 manifest](./install/INSTALL-MANIFEST.sha256)
