# R01 修复版 App 安装报告

执行时间：2026-08-09 00:53–01:03 CST

## 结论

`INSTALLED-ACCEPTED`

已从 live main `6f23f0b6015573632ed830f59cc943e80f8daa63` 重新构建、安装并验收 SIXLAB PR Control。该结论只覆盖本机 App 安装，不包含 Worker 升级、服务部署或生产发布。

## 来源与构建

- live `origin/main`：`6f23f0b6015573632ed830f59cc943e80f8daa63`。
- 隔离 worktree：detached、clean、精确位于该 SHA。
- `swift test`：PASS，22/22。
- `CI_EXPECTED_SHA=6f23f0b… ./test-native.sh`：PASS。
- Native smoke/render、Worker smoke、AppIcon、bundle 与 codesign 全部通过。
- 标准安装候选可执行文件 SHA-256：`352f97e39185d1583702a1cfbac51a9c1ecd109a9ac1e239b6996dab3ef86c7b`。
- bundle 来源：`OPCBSourceSHA=6f23f0b6015573632ed830f59cc943e80f8daa63`，`OPCBSourceTreeState=clean`。

## 安装前冻结与备份

- 旧安装版 PID：`93306`。
- 旧可执行文件 SHA-256：`7c5e06b84e047ffa7b1eecd6562dff48d907d8ce4bb6e12cbb758c7fc9`。
- 正式偏好 SHA-256：`0868d342b15042deea261ca1173f90b8bc6d9d91d311bd02f484e1ccc68b0bb6`。
- App 备份 ZIP：`private/pre-install-app.zip`，SHA-256 `22edbeb750fb771b2d6babcc9b6caebe92a62f48156e390e82d93494163fbfc7`，`unzip -t` 通过。
- Application Support 备份 ZIP：`private/pre-install-application-support.zip`，SHA-256 `092100f956ba2715b7b9220f43485e4b976a60ff103ead57d97a6856dc8aec56`，`unzip -t` 通过。
- 偏好字节备份：`private/pre-install-preferences.plist`，SHA-256 `0868d342b15042deea261ca1173f90b8bc6d9d91d311bd02f484e1ccc68b0bb6`。
- 旧 App 的即时回滚副本位于 `private/SIXLAB PR Control.previous.app`，可执行文件哈希与旧安装版一致；它已移出 Applications，避免重复 bundle identifier 干扰按应用名启动。
- Applications 中另有两个安装前已存在的历史备份：`SIXLAB PR Control.before-http404-fix.app` 与 `SIXLAB PR Control.before-github-error-fix.app`。本轮未修改或删除它们；最终进程路径已核对为正式 `SIXLAB PR Control.app`。

## 替换与验收

- 候选先复制到 Applications 内隐藏暂存路径，并再次核对哈希、来源和签名。
- 旧进程正常停止后，在同一目录完成目标 App 与暂存候选的原子替换。
- 安装后可执行文件 SHA-256：`352f97e39185d1583702a1cfbac51a9c1ecd109a9ac1e239b6996dab3ef86c7b`。
- 安装后 bundle 来源仍为 live main + `clean`，codesign 通过。
- 默认菜单栏模式无普通窗口，因此使用源码内门控 `SIXLAB_R01_UI_HARNESS=1` 验收同一已安装二进制；偏好写入独立 suite `com.sixlab.pr-control.install.6f23f0b.20260809`。
- UI 验收：OPCB 与 PR CONTROL 项目切换正常；动态标题显示 `PR CONTROL`；PR CONTROL 显示当前 1 个 Draft PR；路线图显示 11 张、42 个条目、11/11。
- 已触发 Shadow 日志均为 `unexplained=0`。
- 正式偏好在安装、门控验收和默认重启后始终保持 SHA-256 `0868d342b15042deea261ca1173f90b8bc6d9d91d311bd02f484e1ccc68b0bb6`。

## 最终状态

- 正式 App 路径：`/Users/steven/Applications/SIXLAB PR Control.app`。
- 默认菜单栏进程 PID：`88560`。
- 安装 SHA：`352f97e39185d1583702a1cfbac51a9c1ecd109a9ac1e239b6996dab3ef86c7b`。
- 来源 SHA：`6f23f0b6015573632ed830f59cc943e80f8daa63`。
- 签名：valid on disk / satisfies Designated Requirement。
- 未升级 Worker，未部署任何服务。

## 回滚

若需要回滚：先停止当前进程，将当前 App 移出目标路径，再把 `private/SIXLAB PR Control.previous.app` 恢复为 `/Users/steven/Applications/SIXLAB PR Control.app`；如需恢复状态，再使用 private 目录中的 Preferences 和 Application Support 备份。回滚属于新的显式操作，本报告不自动执行。
