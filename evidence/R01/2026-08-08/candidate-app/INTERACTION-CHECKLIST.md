# R01 隔离交互清单

总体：`FAIL`。核心界面行为可读且 Shadow 通过，但偏好隔离失败。

| 检查项 | 结果 | 证据 |
|---|---|---|
| OPCB 项目切换 | PASS | 缓存视图显示 2 个 open PR，system state clear |
| PR CONTROL 项目切换 | PASS | 缓存视图显示 PR #8、PR #5 |
| OPCB FDE 项目切换 | PASS | 缓存视图显示 PR #2 |
| OPCB VAULT | OBSERVED | 配置存在，缓存视图显示 8 个 open PR |
| PR 详情 | PASS | 打开 PR #8，显示当前 head 待审核语义 |
| Checks 展开 | PASS | CircleCI `native-build-and-test` 通过；展开后显示无更细步骤 |
| 路线图总控 | PASS | 11 张路线图、42 个条目；当前 5/11 显示 |
| 管理显示 | PASS | 5 个“已显示”、6 个“已隐藏” |
| Session | PASS | 外部命令禁用时显示 `NO SESSION` / `SESSION --`，未伪造可用状态 |
| Review Machine | PASS | 只读取缓存 snapshot；未点击 SSH、送审核机或 monitor 写入口 |
| partial/unreachable/unknown | PARTIAL | unavailable Session 可见；本次缓存样本没有覆盖所有 partial/unreachable UI 状态，相关语义由 XCTest/Native smoke 覆盖 |
| 刷新周期 | PASS | AppDelegate 仍为 GitHub 120s、Review Machine 5min、Roadmap 30min；本轮未点击 Refresh |
| 通知/显示配置不改写 | FAIL | `UserDefaults` 未被 `CFFIXED_USER_HOME` 隔离；正式偏好文件哈希改变 |
| 正式缓存不被候选写入 | PASS WITH CAVEAT | Candidate Application Support 位于临时目录；正式 App 自身后台刷新导致正式缓存起止哈希变化 |
| 回退 | PASS | 候选退出；正式 PID `93306`、安装路径、可执行文件哈希与签名保持一致 |

验收窗口是临时 checkout 上的门控 NSWindow 夹具，仅复用同一 `DashboardViewController`，不属于精确安装候选。精确候选 bundle 在添加夹具前已单独保存。
