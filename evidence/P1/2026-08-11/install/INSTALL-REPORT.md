# P1 RegistryStore 正式安装与运行部署报告

执行时间：2026-08-11 CST

## 结论

`INSTALLED-DEPLOYED-ACCEPTED`

已从 `Steven-ZYH/sixlab-pr-control` 的 merged live main
`846344a6481d93070e47338c06abf207e7b43d2d` 重新构建、安装并启动
SIXLAB PR Control。该结论覆盖本机原生 App 的正式安装和运行态部署；本切片没有
服务端产物，也没有修改 Review Machine Worker。

## 精确来源与门禁

- PR：[#13](https://github.com/Steven-ZYH/sixlab-pr-control/pull/13)，squash
  merge commit `846344a6481d93070e47338c06abf207e7b43d2d`。
- clean detached worktree 精确位于该 SHA。
- `CI_EXPECTED_SHA=846344a… ./test-native.sh`：PASS。
- Harness 总计 18 个入口：SwiftPackageTests、16 个 native/AppKit smoke/render、
  ReviewWorkerSmoke 全部通过。
- Swift package：38/38 PASS，其中 RegistryStore 11/11 PASS。
- bundle 来源：`OPCBSourceSHA=846344a6481d93070e47338c06abf207e7b43d2d`，
  `OPCBSourceTreeState=clean`。
- candidate 与安装后 codesign 均通过。

## 安装前冻结与回滚载体

- 旧正式 App 来源：`6f23f0b6015573632ed830f59cc943e80f8daa63`，tree `clean`。
- 旧二进制 SHA-256：
  `352f97e39185d1583702a1cfbac51a9c1ecd109a9ac1e239b6996dab3ef86c7b`。
- 旧进程 PID：`88560`；替换前已正常退出。
- 正式偏好 SHA-256：
  `3b1039909325066c0006750be660a0e9371aaafccae90620ffcf7157f9720e2e`。
- 私有回滚 App：`private/SIXLAB PR Control.previous.app`。
- App 备份 ZIP：`private/pre-install-app.zip`，SHA-256
  `4939a793dbacf9a56f519779712284c14189d614c802729adeb0e39cba4e235a`；
  `unzip -t` 通过。
- Application Support 备份 ZIP：
  `private/pre-install-application-support.zip`，SHA-256
  `03a06889ecc775068bb3c4409117fcd6ba39fdf6101ff76da015a40a00e5117d`；
  `unzip -t` 通过。
- 偏好备份：`private/pre-install-preferences.plist`，SHA-256 与安装前正式偏好一致。

`private/` 由仓库 `.gitignore` 排除，不进入公开证据或 Git 历史。

## 替换、启动与运行验收

- 候选先复制到 Applications 同目录隐藏暂存路径，再核对 SHA、来源和签名。
- 旧 App 先移动到同目录回滚路径；候选随后原子改名为正式路径。
- 正式路径：`/Users/steven/Applications/SIXLAB PR Control.app`。
- 安装后二进制 SHA-256：
  `820d65448bad53cfe3760784ff19b8772b890e56fb3651334f3886f72f38922f`，
  与 clean candidate 完全一致。
- 正式进程 PID：`30180`；持续运行超过 2 分钟，进程路径精确指向正式 App。
- 首次启动生成
  `~/Library/Application Support/SIXLABPRControl/Registry/v1/registry.json`：
  mode `0600`、schema v1、4 个项目，顺序为 OPCB、PR CONTROL、OPCB FDE、
  OPCB_Vault。
- 正式偏好安装前后 SHA-256 未变化。
- 同一安装二进制曾以隔离 preferences suite 和临时 Registry 启动 UI Harness；
  Computer Use 无法取得该 accessory/menu-bar App 的 AX window，因此不声明新的
  人工点击结论。可见布局仍由同哈希候选的 Dashboard/PR Detail render 与完整
  native Harness 覆盖。

## Worker／服务部署判定

PR #13 没有修改 `review-worker/`。merged main 中候选 Worker 为 `1.8.6`，
SHA-256 `365f135b47be9722ce7bf0edbb35e0abd2d163de82f9fc7786d177f4206b6970`；
审核机 live Worker 为 `1.10.5-fast.1`，SHA-256
`cb4d2ea484d22880704d283d4109cf74aa3c9b4e0e7f121911fdcef0482b83eb`，
检查时 queue depth `0`、active job count `0`。

因此没有执行 `install-review-worker.sh`：覆盖会构成明确降级，而且本模块没有
Worker 变更需要发布。这是安全的 `NOT-APPLICABLE / PRESERVED-NEWER-LIVE`，
不是遗漏部署。

## 回滚

若需回滚：停止当前正式进程，把当前 App 移出正式路径，再将
`private/SIXLAB PR Control.previous.app` 恢复到 Applications；如需恢复状态，
再使用 private 目录中的 Application Support 与 Preferences 备份。回滚是新的
显式操作，本报告不自动执行。
