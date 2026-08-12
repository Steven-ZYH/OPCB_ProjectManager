# P1 后续顺序与当前缺口重评估

评估时间：2026-08-12 CST

基线：`sixlab-pr-control@7af0430230bebd4c4a1477b48cd9b624072e0b76`

## 结论

P1.4-A、P1.5、P1.6 与 P1.7 已关闭，P1 主依赖顺序进入 **P1.8/R01.4 cutover**。
当前工作包已选择 Roadmap 作为第一次只读 projection 的 shadow/candidate 切流；不得提前
安装 App、接真实 command/provider 或启动 P2 主窗口。

P1.6 不应只补一组名词或 UI 按钮。它的退出门必须同时包含：typed CommandIntent／
PolicyDecision、exact required facts、actor/environment scope、merge/deploy/secret-use 权限
不推导、confirmation binding、确定性 fail-closed evaluator 和负向回归。真实 token
issuance/consumption、CommandBus、Runtime Actor 与 side effect 继续留到 P1.7。

## 重新确认的执行顺序

1. **P1.5 SQLite 事件账本与 projection rebuild（CLOSED）**
   - 版本化 normalization event/decision payload 与单调 ledger position。
   - append-only event、expected-generation projection CAS 和 checkpoint 同一事务提交。
   - event/correlation 幂等、精确大小写资源身份、逐资源隔离。
   - schema migration、replay/rebuild、备份、损坏／中断恢复和 redaction。
2. **P1.6 Policy Engine（CLOSED）**
   - 补齐 `CommandIntent`／`PolicyDecision`、required facts、actor/environment scope。
   - allow/confirm/deny 及 merge、deploy、secret-use 相互独立的 fail-closed 反例。
3. **P1.7 Runtime Actor + RefreshCoordinator（CLOSED）**
   - 单一拥有 adapters、timers、cancellation、store、policy 和 projection stream。
   - 到这里才迁移 AppDelegate 的多 timer／Set 去重逻辑，避免形成双 owner。
4. **P1.8 + R01.4 首个只读切流**
   - 首个 projection 固定为 Roadmap cache；先完成代码级 candidate-primary 与 fail-closed
     回退，再单独进入候选构建、安装验收和回退观察。

P2 主窗口仍不得提前。P1.3-B 的 App 内 Registry 管理和 repository access／default
branch／checkout/provider/environment health projection 继续归入 P2.2；它们依赖 P1
normalizer/store/runtime，但不阻塞 P1.5。

## 已确认完成

### P1.2／P1.3-A

- Swift Package 的 Domain／Store／只读 Adapters 强制依赖边界已建立。
- Registry v1 的 migration、隐私校验、原子替换、last-known-good 恢复已关闭并安装。

### P1.4-A

- `NormalizedResourceKey` 以 `projectID + ResourceRef` 建立精确、大小写敏感身份。
- refresh/observation envelope 已绑定 generation、correlation、source 和 timeline。
- `StateNormalizer` 已覆盖 begin/accept/fail/expire 与 late/duplicate/conflict/invalid。
- `InMemoryProjectionStore` 已提供 expected-generation CAS，但明确只作进程内测试桩。
- PR #14 已合并至 main `7d50c14e9e926a3bc3a3a31c9554ff6f63403642`；PR head 与
  合并后 main 的 CircleCI 均成功，merged-main 完整 Native Harness 通过。

### P1.5

- schema v2 SQLite ledger 已包含 typed event/decision、materialized projection、cursor 和
  checkpoint；v1→v2 migration 与未来版本 fail-closed 已验证。
- event append、decision、expected-generation projection CAS 和 cursor 在同一 transaction
  内提交；幂等、并发 writer 与两处 fault injection 已覆盖。
- full/checkpoint rebuild 只复用 `StateNormalizer`；checkpoint 必须等于 ledger 到对应位置的
  确定性结果，损坏／漂移不会覆盖有效 projection。
- backup/recovery、0600/0700 私有权限、typed codec、隐私反例和跨进程 reopen 已关闭。
- PR #15 已 squash merge 为 `c7ee54ae1e8c33318a414e670fd80c57faa8df87`；PR head 与
  main CircleCI 均成功，actual merge commit 完整 Native Harness 通过。
- P1.6 只能通过 `DurableProjectionReading.projection(for:)` 的 exact-resource read-only port
  消费事实；不得读取 SQLite internals 或推断 sibling resource 健康。

## 当前缺少的内容

### P1.6 已补齐

- typed intent/decision/fact/confirmation、三类 action 不互相授权、exact durable fact reader、
  deterministic fail-closed matrix 与 privacy/architecture regression 已进入 main。
- PR #17 已 merge 为 `d02ffea3e9bc92d7d5ba94d490740b580d9fd89c`；PR/main CI 与
  actual merge commit Native Harness 均成功。

### P1.8 仍缺

- P1.7 Runtime Actor、projection stream、统一 cancellation、business schedule ownership、
  authoritative confirmation 和 durable command replay 已随 PR #19 合并为
  `acca75a10ae0a707f6398f957feca42a585428f6`。
- Runtime 仍只接 closed/fake executor；claim-before-execute crash window 明确保留为
  `claimed` unknown，不允许自动重试。
- 六路 Facade 仍为 `legacyOnly`／`shadow`，无 `candidatePrimary` 和退休记录。

### 延后到 P2.2

- Registry 原生新增/编辑/禁用/排序与保存前差异。
- repository access、default branch、checkout/provider/environment health projection。
- 新项目默认只读、review-machine capability 显式启用和跨项目故障隔离 UI。

## 停止线

若 P1.7 形成第二个 timer/in-flight/confirmation/command owner，或需要真实 provider command、
secret retrieval、Facade 切流、安装或部署才能成立，应停止并重新拆分。corrupt/unknown journal、
late generation 或重复 token/command 不得被弱化为 safe-to-execute。

## 下一执行入口

- [P1.4 模块关闭记录](./P1.4-STATE-NORMALIZER-MODULE-CLOSURE.md)
- [P1.5 模块关闭记录](./P1.5-SQLITE-EVENT-LEDGER-MODULE-CLOSURE.md)
- [P1.6 Policy Engine START Handoff](./P1.6-POLICY-ENGINE-START-HANDOFF.md)
- [P1.6 Policy Engine 模块关闭记录](./P1.6-POLICY-ENGINE-MODULE-CLOSURE.md)
- [P1.7 Runtime Actor START Handoff](./P1.7-RUNTIME-ACTOR-START-HANDOFF.md)
- [P1.7 Runtime Actor 执行报告](./P1.7-RUNTIME-ACTOR-EXECUTION-REPORT.md)
- [P1.7 Runtime Actor 模块关闭记录](./P1.7-RUNTIME-ACTOR-MODULE-CLOSURE.md)
- [P1.8 Roadmap 首个只读切流 START Handoff](../2026-08-12/P1.8-ROADMAP-READ-CUTOVER-START-HANDOFF.md)
