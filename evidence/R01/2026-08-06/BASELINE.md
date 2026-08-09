# R01 可重建基线执行记录

执行日期：2026-08-06 CST  
目标源码：`/Users/steven/Documents/Project/SIXLABPRControl`  
目标安装版：`/Users/steven/Applications/SIXLAB PR Control.app`

## 结论

- R01.1 事实冻结与恢复载体：**通过**。
- R01.2 干净 checkout、完整 Harness、候选 App 与只读实际交互：**通过**。
- R01.3 Legacy Facade：**前置契约、缓存三切片以及 Session、GitHub live、审核机 Runtime Facade 均通过**；默认仍为 legacyOnly，UI 权威尚未切换。合同见 `R01.3-CONTRACTS.md` 及四份 shadow 记录。
- 原源码工作树、原安装版和原运行进程均未被覆盖；未执行 reset、clean、rebase、checkout 覆盖或原仓 fetch。

## 版本与工作树事实

| 项目 | 冻结值 |
|---|---|
| 当前分支 | `codex/review-machine-high` |
| HEAD | `ec24809d604f620c2f95134d9ff19b18a4aeafb1` |
| live `origin/main` | `ee616fe177af2af3590f7b7a9679a5f984ebf569`，由 `git ls-remote` 只读核验 |
| 相对 `origin/main` | 5 ahead / 1 behind |
| tracked 修改 | 17 个 |
| untracked | 3 个 |
| tracked diff | 3122 insertions / 184 deletions |
| diff 校验 | `git diff --check` 通过 |

3 个未跟踪文件为：

- `HANDOFF-SIXLAB-PROJECT-CONTROL.md`
- `native/RoadmapClient.swift`
- `tests/NativeRoadmapSmoke.swift`

全部 20 个 modified/untracked 文件的哈希见 `SOURCE-MANIFEST.sha256`。冻结结束时再次生成 binary diff，其 SHA-256 仍为 `269a7ca1...`，与恢复载体一致，证明原工作树未发生漂移。

## 安装版与运行事实

| 项目 | 证据 |
|---|---|
| Bundle ID | `com.sixlab.pr-control` |
| 版本 | `1.0.0` / build `1` |
| 可执行文件 SHA-256 | `b781723e515a0a3543958a9ee8837c3d8e7da3a3ff106b65b572f36c9aca6dd0` |
| 签名 | ad-hoc；`codesign --verify --deep --strict` 通过 |
| 安装版/build/Harness | 三份可执行文件哈希完全一致 |
| 原安装版进程 | PID `18994`；冻结采样 0.0% CPU、约 68 MB RSS |

## 缓存与配置事实

- Application Support 存在，共 7 个 JSON 文件，冻结时约 492 KiB。
- 包含 PR 概览、PR 详情、路线图、审核机状态和三项目快照。
- 源码与缓存执行高置信 secret pattern 路径扫描，未发现私钥、GitHub token、OpenAI key、Slack token 或 AWS access key 形态。
- 文档与源码存在 `.env`、token、private key、Bark 等**配置引用**，仅记录路径，不读取或复制明文值。
- 缓存正文只进入 gitignore 排除的本地私有恢复归档，不进入公开证据文件。

## 恢复载体

本地私有载体位于 `private/`，由仓库 `.gitignore` 排除：

| 载体 | 用途 |
|---|---|
| `repository-all-refs.bundle` | 保存全部本地/远端 refs 与完整 Git 历史 |
| `tracked-worktree.patch` | 保存 17 个 tracked 修改的 full-index binary patch |
| `untracked-files.tar.gz` | 保存 3 个未跟踪文件 |
| `installed-app.zip` | 保存当前正式安装版 App |
| `application-support-cache.zip` | 保存冻结时缓存快照 |
| `candidate-baseline.bundle` | 保存干净候选基线与 Harness 可移植性修正 |
| `candidate-app.zip` | 保存通过完整 Harness 的候选 App |

`git bundle verify`、两个 ZIP 完整性检查均通过。恢复演练从 bundle 克隆 `ec24809d...`，应用 patch 并解包 untracked 文件后，与现场全部 tracked/untracked 文件逐字节一致。

完整载体哈希见 `SHA256SUMS`。

## 干净候选与 Harness

1. 在 `/private/tmp` 从恢复载体重建源码。
2. 将冻结快照提交为仅本地候选 commit `25ff2d374ec51fe98e36f19267d7b72b47445d60`，确认 checkout clean。
3. 首次 Harness 在 `NativeCodexSessionResolverSmoke` 失败：测试脚本记录 `/private/tmp/...`，而 Resolver 标准化为 `/tmp/...`，假 `rg` 因路径不一致返回 2。
4. 仅在隔离候选中把 fake-rg 期望路径改为 `standardizedFileURL.path`；修正 patch 为 `harness-portability.patch`。
5. 修正 commit `5eaa4267ffe9ac63ba63982b9c07c4f57532f793` 上重跑完整 Harness。

最终 12 项全部通过：

- Model、Detail Cache、Failure Reason、Author Identity
- Codex Session Resolver、Refresh Animation
- Review Machine SSH、Review Machine Queue
- Roadmap
- Dashboard Render、PR Detail Render
- Review Worker
- AppIcon Bundle 与候选 App codesign

候选 App 可执行文件 SHA-256 仍为 `b781723e...`，与正式安装版字节级一致；Info.plist、AppIcon 与两份字体也逐字节一致。

旧 Harness PNG 为 Retina 2x（940×1732），隔离命令环境新 PNG 为 1x（470×866），因此 PNG 哈希不同。人工检查确认布局、层级和内容结构一致；该差异记录为渲染 scale factor，不作为行为差异。

## 并行运行与实际交互

- 正式安装版 PID `18994` 与隔离候选同时运行；候选使用独立 `CFFIXED_USER_HOME` 和缓存副本。
- 候选把 `gh`、`ssh`、`codex` 指向 `/usr/bin/false`，防止外部刷新、Session 改名、审核机派发或网络写入。
- 因 Computer Use 无法读取纯菜单栏 `LSUIElement` 的 Popover，隔离验收分支仅在 `SIXLAB_R01_UI_HARNESS=1` 时把同一 `DashboardViewController` 承载进普通 NSWindow；默认生产路径仍是原 Popover。
- 通过真实可访问性树与点击完成：
  - OPCB → PR CONTROL 项目切换；
  - 打开 PR #884 详情；
  - 展开 `backend-tests` check 路由；
  - 打开路线图总控，读取 9/9 路线图与 42 个条目；
  - 打开“管理显示”，确认 9/9 显示状态。
- 未点击送审核机、Session、GitHub、SSH、刷新或任何外部写操作。
- 验收完成后已停止隔离候选进程；正式安装版 PID `18994` 继续运行，完成回退验证。

## 下一退出门

R03.1、R09.1、R12.1 的契约基础已在隔离候选中实现；路线图缓存首个只读 shadow 切片也已通过冻结快照比对。下一步必须：

1. 评审 `R01.3-CONTRACTS.md` 与三份 shadow 记录；
2. 选择 Session 解析作为下一个只读切片；
3. 对同一冻结输入并行运行旧、新读取，继续生成字段级差异；
4. 在任何候选读切换前补充实际 App shadow 启动与回退证据。

在 shadow 比对证据形成前，不修改原 App 编排，不切换生产读路径，也不删除旧 timer/cache。
