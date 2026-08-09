# R01 安装决策

```text
VERDICT: INSTALLED-ACCEPTED
SOURCE_SHA: 6f23f0b6015573632ed830f59cc943e80f8daa63
INSTALLED_EXECUTABLE_SHA: 352f97e39185d1583702a1cfbac51a9c1ecd109a9ac1e239b6996dab3ef86c7b
SOURCE_TREE_STATE: clean
PROCESS_PID: 88560
CHECKS:
- swift test — PASS (22/22)
- test-native.sh — PASS
- native/worker/render harness — PASS
- source binding — PASS
- codesign — PASS
- installed UI acceptance — PASS
- shadow comparison — PASS (unexplained=0)
- formal UserDefaults unchanged — PASS
- rollback backup — PASS
BOUNDARIES:
- App install: performed
- Worker upgrade: not performed
- service deployment: not performed
- production release: not performed
```

上一轮针对旧 main 候选的 `DO-NOT-INSTALL` 是历史事实；本轮从已合并的新 live main 重新构建并完成独立验收后，本机安装门已闭环。
