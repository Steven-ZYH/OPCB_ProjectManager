# R01 Shadow 摘要

## 结果

Shadow 比对本身：`PASS`

整体安装决策：`DO-NOT-INSTALL`，原因不是 Shadow 差异，而是候选改写了正式 UserDefaults 偏好域。

## 已触发通道

| 通道 | 结果 | 差异 |
|---|---|---|
| PR Overview | PASS | `differences=1`, `unexplained=0`, `observation.source.system` |
| Roadmap | PASS | `differences=1`, `unexplained=0`, `observation.source.system` |
| Review Machine Status | PASS | `differences=1`, `unexplained=0`, `observation.source.system` |
| Session | PASS | `differences=1`, `unexplained=0`, `observation.source.system` |
| GitHub Detail | PASS | `differences=1`, `unexplained=0`, `observation.source.system` |
| Review Machine Runtime | PASS | `differences=1`, `unexplained=0`, `observation.source.system` |

GitHub live overview命令由 `/usr/bin/false` 阻断，未产生可比较的成功结果；未伪造成 live 成功。所有实际出现的比较记录均为 `unexplained=0`。

## 外部副作用边界

- GitHub CLI、SSH、Codex 入口均为 `/usr/bin/false`。
- 未点击 SSH、送审核机、Refresh、Session、GitHub 或路线图外链。
- 没有远端 GitHub 写入、审核队列写入、Session 改名、通知发送或部署。
- 发生一次本地正式偏好域副作用：项目切换写入 `selectedPRProjectRepositoryV1`。这是整体安装阻断项。
