# R01 候选 App 阻断修复报告

执行时间：2026-08-08 18:00–18:18 CST

## 结论

`REMEDIATION-READY-FOR-PR`

上一轮 `DO-NOT-INSTALL` 仍然有效；本轮只证明修复提交可以进入当前 head 审查，不授权安装、合并、Worker 升级或部署。

## 来源与变更

- live `origin/main` 开始与发布前均为 `3241754693b3d2d10bc62df25b15a91567518b0a`。
- 修复分支：`codex/r01-candidate-remediation`。
- 修复提交：`87f5336967ab033c21636c9e4cdeeaae4f1d2044`。
- 在源码中增加受限 `SIXLAB_PR_DEFAULTS_SUITE`，把候选偏好写入显式测试 suite；生产默认仍使用 `UserDefaults.standard`。
- 把 `SIXLAB_R01_UI_HARNESS=1` 的普通 NSWindow 验收入口纳入源码；默认菜单栏 Popover 行为不变。
- App bundle Info.plist 增加 `OPCBSourceSHA` 与 `OPCBSourceTreeState`，测试脚本校验其与构建源码一致。
- Native 渲染测试也改用独立 suite，不再写 `UserDefaults.standard`。

## 构建与自动化验证

- dirty 开发态：`swift test` 22/22 通过；`./test-native.sh` 全部通过；来源绑定为 live main + `dirty`。
- clean 提交态：`swift test` 22/22 通过；`CI_EXPECTED_SHA=87f5336967ab033c21636c9e4cdeeaae4f1d2044 ./test-native.sh` 全部通过。
- clean 候选 bundle 来源绑定：`OPCBSourceSHA=87f5336967ab033c21636c9e4cdeeaae4f1d2044`，`OPCBSourceTreeState=clean`。
- 候选可执行文件 SHA-256：`4e19fd46df987de9927665361de021e3627abd939856da7899f31cd0339e33fd`；codesign 通过。
- 发布前 `git diff --check` 通过；相对最新 `origin/main` 的 `git merge-tree --write-tree` 成功，结果 tree `ba939c570e8f7cc51f3c6f12eff0c81ba4594732`。

## 隔离交互验证

候选使用以下边界运行：

- `CFFIXED_USER_HOME=/private/tmp/opcb-r01-remediation.fgMxu1/candidate-home`
- `SIXLAB_PR_DEFAULTS_SUITE=com.sixlab.pr-control.r01.87f5336.202608081812`
- `SIXLAB_R01_UI_HARNESS=1`
- GitHub、SSH、Codex 可执行入口均指向 `/usr/bin/false`
- 六路 Facade 全部为 `shadow`

实际检查了 4 个项目、PR #8 详情、CircleCI check、路线图总控和路线图显示管理。路线图外部读取失败时，UI 明确显示“最近同步失败，正在显示上次路线图快照”，没有把缓存伪装为 live。

路线图显示设置在隔离 suite 内完成 `11/11 -> 10/11 -> 11/11` 写入与恢复。隔离 suite 最终包含空的 `hiddenRoadmapDocumentPathsV1` 和选中仓库 `Steven-ZYH/sixlab-pr-control`。

所有触发的 PR、Session、GitHub Detail 等 Shadow 日志均为 `unexplained=0`，唯一差异字段为允许的 `observation.source.system`。

## 副作用与回退

- 正式偏好文件运行前后 SHA-256 均为 `61867867f6acef3a200cae538dc96fe0d6fa21228a94453f3b8342d0a2a32d23`。
- 候选 PID `60392` 已正常退出。
- 正式安装版仍为 PID `93306`；可执行文件 SHA-256 仍为 `7c5e06b84e047ffa7b1eecd6562dff48d907d8ce4bb6d46bb6e12cbb758c7fc9`，codesign 通过。
- 受保护脏工作树保持原分支和原改动集合；未在其中构建或切分支。
- 测试 suite `com.sixlab.pr-control.r01.87f5336.202608081812` 保留为本地验收证据；它与生产偏好域分离。
- 未安装、未合并、未部署、未升级 Worker。

## 下一道门

修复已发布为 Ready PR [#10](https://github.com/Steven-ZYH/sixlab-pr-control/pull/10)，并请求 `miaopantao` 审查。最终核对时：head 为 `87f5336967ab033c21636c9e4cdeeaae4f1d2044`，base 为 `3241754693b3d2d10bc62df25b15a91567518b0a`，`MERGEABLE`，CircleCI `native-build-and-test` 为 `SUCCESS`，尚无 review decision。

PR approval 必须绑定其当前 head；即使通过，也只授权后续合并决策，不自动授权安装或部署。只有修复合入新的 live main 后，才能从该新 SHA 重新构建并重新作出安装决定。
