# R01 候选 App 执行报告

执行时间：2026-08-08 17:34–17:48 CST

## 结论

`DO-NOT-INSTALL`

候选源码、测试、签名和已触发 Shadow 比对均通过，但隔离交互暴露了一个安装阻断：`CFFIXED_USER_HOME` 隔离了 Application Support，却没有隔离 `UserDefaults`。候选切换项目时改写了正式偏好域 `com.sixlab.pr-control`。本轮未覆盖安装版，也未尝试猜测或恢复旧偏好。

## 冻结事实

- GitHub SSH 身份：`Steven-ZYH`。
- live `main` 开始与结束均为 `3241754693b3d2d10bc62df25b15a91567518b0a`。
- 临时 checkout：`/private/tmp/opcb-r01-next.bta6w8/repo`。
- 首次 clone 写入了 `origin/main` ref 但缺当前 commit 对象；对同一远端执行一次显式 `git fetch --no-tags origin refs/heads/main` 后对象完整，随后 detached checkout 到精确 SHA。
- 精确候选构建前 `git status --porcelain` 为空，`HEAD` 等于 `SOURCE_SHA`。
- 原脏工作树开始与结束状态相同；未在其中 fetch、merge、pull、reset、clean、rebase、checkout 或构建。

## 构建与测试

- Apple Swift 6.3.3，Xcode 26.6，arm64。
- `swift test`：22/22 tests，0 failures。
- `CI_EXPECTED_SHA=3241754693b3d2d10bc62df25b15a91567518b0a ./test-native.sh`：revision guard 通过；15 个 Native smoke/render、1 个 Worker smoke、AppIcon、App bundle 和 codesign 全部通过。
- 精确候选 App 可执行文件 SHA-256：`1b284fa53949b75468b7060d62cfadd0d7c2f66b133fc1eee20015f8e93b229f`。
- 当前安装版可执行文件 SHA-256：`7c5e06b84e047ffa7b1eecd6562dff48d907d8ce4bb6d46bb6e12cbb758c7fc9`。
- 两个 bundle 的 Info.plist、AppIcon、两份字体与 CodeResources 逐字节相同；只有可执行文件不同。
- 当前 main 明确包含 #6 的 Native GitHub 失败原因诊断变化和 #9 的 Worker 仓库扩展，但安装版没有嵌入可核验的 `SOURCE_SHA`，因此不能把全部可执行文件字节差异完整绑定到已知源码差异。

精确候选已保存在 gitignored 私有证据：`private/SIXLAB-PR-Control-exact-candidate.zip`，ZIP SHA-256 为 `fdaaf7f3eb9644c06c06cf044c16db7a0b2cc6fce547c22675b5b16a464d30ae`，`unzip -t` 通过。

## 隔离交互与 Shadow

精确 `main` 没有 handoff 所述的 `SIXLAB_R01_UI_HARNESS` 实现，Computer Use 无法读取纯菜单栏 Popover。为完成只读检查，先保留精确候选不动，再在临时 checkout 添加仅受 `SIXLAB_R01_UI_HARNESS=1` 控制的普通 NSWindow 夹具；夹具 diff SHA-256 为 `a6960d34eccfbbdcd5f55cf6ab59cbf36b21dc38a767ff542be79af52143017c`，不属于安装候选。

候选运行参数：

- `CFFIXED_USER_HOME=/private/tmp/opcb-r01-next.bta6w8/candidate-home`
- `SIXLAB_PR_GH=/usr/bin/false`
- `SIXLAB_PR_SSH=/usr/bin/false`
- `CODEX_BINARY=/usr/bin/false`
- 六路 Facade 全部为 `shadow`

实际只读检查完成：OPCB、PR CONTROL、OPCB FDE 项目切换；另观察到 OPCB VAULT；PR #8 详情和 CircleCI check 展开；路线图 11 张、42 个条目；管理显示为 5/11。未点击 Refresh、SSH、送审核机、Session、GitHub 或路线图外链。

已触发的 PR、Roadmap、Review Status、Session、GitHub Detail、Review Runtime Shadow 均为 `unexplained=0`；唯一差异路径为允许的 `observation.source.system`。

## 阻断证据

正式偏好文件开始 SHA-256：

`0868d342b15042deea261ca1173f90b8bc6d9d91d311bd02f484e1ccc68b0bb6`

结束 SHA-256：

`61867867f6acef3a200cae538dc96fe0d6fa21228a94453f3b8342d0a2a32d23`

结束修改时间：`2026-08-08T17:48:08+0800`。候选临时 `Library/Preferences` 为空；正式偏好最终显示 `selectedPRProjectRepositoryV1 = Steven-ZYH/sixlab-pr-control`。候选首次展示时选中 OPCB VAULT，随后只读验收切换项目并最终停在 PR CONTROL，因此该变化可归因于候选的 `UserDefaults.standard.set` 路径。

正式 Application Support 在期间也被正在运行的正式 App后台刷新；候选自己的 Application Support 副本位于临时 Foundation 用户目录。没有证据表明候选写入正式缓存正文，但正式缓存本身不是静止基线，不能用起止哈希单独证明写入者。

## 回退

- 验收候选已停止，无候选残留进程。
- 正式安装版仍为 PID `93306`，路径仍为 `/Users/steven/Applications/SIXLAB PR Control.app/Contents/MacOS/SIXLABPRControl`。
- 正式安装版结束哈希仍为 `7c5e06…c7fc9`，codesign 仍通过。
- 未安装、未升级 Worker、未部署、未触发远端写操作。
- 未恢复正式偏好，因为开始时未保存可验证的偏好内容副本，不能安全猜测旧值。

## 下一步

1. 为候选增加显式、可测试的 UserDefaults suite/偏好目录隔离，不依赖 `CFFIXED_USER_HOME`。
2. 把门控 UI Harness 纳入源码或提供等价的正式 UI 自动化入口。
3. 在 bundle 中记录可核验的 `SOURCE_SHA`，消除安装版与候选可执行文件来源不明。
4. 修复后从新的 live `main` 重新执行完整验收；本轮证据不授权安装。
