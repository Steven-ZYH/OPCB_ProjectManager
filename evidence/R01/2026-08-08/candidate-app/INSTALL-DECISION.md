# R01 安装决策

```text
VERDICT: DO-NOT-INSTALL
SOURCE_SHA: 3241754693b3d2d10bc62df25b15a91567518b0a
INSTALLED_SHA: 7c5e06b84e047ffa7b1eecd6562dff48d907d8ce4bb6d46bb6e12cbb758c7fc9
CANDIDATE_SHA: 1b284fa53949b75468b7060d62cfadd0d7c2f66b133fc1eee20015f8e93b229f
CHECKS:
- swift test — PASS (22/22)
- ./test-native.sh — PASS
- codesign — PASS
- shadow comparison — PASS (all triggered comparisons unexplained=0)
- isolated interaction — FAIL (formal UserDefaults domain was modified)
- rollback — PASS (candidate stopped; installed PID/hash/signature unchanged)
DIFFERENCES:
- Info.plist, AppIcon, fonts, CodeResources — identical
- executable — different; current main includes Native GitHub failure-reason changes, but installed binary lacks verifiable SOURCE_SHA provenance, so the complete byte delta is not fully attributable
- formal preferences — changed during candidate project switching because CFFIXED_USER_HOME did not isolate UserDefaults
BOUNDARIES:
- original dirty worktree: untouched
- external writes: no remote writes; one local formal UserDefaults preference change occurred
- install: not performed
- worker/deploy: not performed
NEXT AUTHORITY NEEDED: remediation decision
```

本结论不授权安装。修复偏好隔离、提供源码内门控 UI Harness，并补足 bundle 来源绑定后，必须从新的 live `main` 重新执行完整验收。
