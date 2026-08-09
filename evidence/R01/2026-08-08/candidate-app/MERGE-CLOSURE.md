# R01 修复 PR #10 合并闭环

执行时间：2026-08-09 00:33–00:43 CST

## 结论

`MERGED-NOT-INSTALLED`

- PR：[Steven-ZYH/sixlab-pr-control#10](https://github.com/Steven-ZYH/sixlab-pr-control/pull/10)
- PR head：`87f5336967ab033c21636c9e4cdeeaae4f1d2044`
- 合并方式：squash，使用 expected-head SHA 保护
- merge SHA / live `origin/main`：`6f23f0b6015573632ed830f59cc943e80f8daa63`
- 合并时间：2026-08-09 00:42:42 CST

## 合并前 current-head 证据

- `miaopantao` 的 `APPROVED` review 明确绑定 commit `87f5336967ab033c21636c9e4cdeeaae4f1d2044`。
- PR 非 Draft，`reviewDecision=APPROVED`，无 review threads。
- CircleCI `native-build-and-test=SUCCESS`。
- 合并前 live main 已从 PR 创建时的 `3241754…` 前进到 `d33d11b…`（PR #8）。
- 对最新 main 与 PR head 重新执行 `git merge-tree --write-tree`，结果 tree 为 `a76d051c9bf16392c6abd8cb62e2a67d9b4e1637`；`git diff --check` 通过。

## 最新 main 合成验收

为验证 PR #8 与 PR #10 对 Native UI/渲染测试的重叠改动，基于 merge tree 创建临时合成 commit `82a42b725f492a26f30edba61de99f0f091e3094`：

- `swift test`：PASS，22/22。
- `CI_EXPECTED_SHA=82a42b… ./test-native.sh`：PASS。
- Native smoke/render、Worker smoke、AppIcon、App bundle 和 codesign 全部通过。
- Source binding：PASS，SHA 为合成 commit，tree state 为 `clean`。

## 合并后边界

- GitHub 返回 `merged=true`，PR 状态复核为 `MERGED`。
- SSH 刷新后 `origin/main` 精确为 `6f23f0b6015573632ed830f59cc943e80f8daa63`。
- merge SHA 当前没有独立 commit status；不能把 PR head 的 CircleCI 结果描述为 main commit CI。
- 正式安装版仍为 PID `93306`，可执行文件 SHA-256 仍为 `7c5e06b84e047ffa7b1eecd6562dff48d907d8ce4bb6d46bb6e12cbb758c7fc9`。
- 受保护脏工作树仍在 `codex/review-machine-high`，原有修改/未跟踪集合保留。
- 未安装 App、未升级 Worker、未部署。

## 下一道门

历史 `DO-NOT-INSTALL` 决策不会因代码合并自动失效。若继续安装流程，应从 live main `6f23f0b…a63` 重新构建候选并完成独立安装验收与授权。
