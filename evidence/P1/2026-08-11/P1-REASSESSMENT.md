# P1 后续顺序与当前缺口重评估

评估时间：2026-08-11 CST

基线：`sixlab-pr-control@7d50c14e9e926a3bc3a3a31c9554ff6f63403642`

## 结论

P1.4-A 已关闭，P1 主依赖顺序仍保持 **P1.5 persistence -> P1.6 policy ->
P1.7 runtime -> P1.8/R01.4 cutover**。当前不应提前实现 Policy、Runtime、UI 或真实
provider 接线；下一工作包必须先把 P1.4 的纯 reducer 变成可审计、可事务提交、可重建
的持久化事实链。

P1.5 不拆成一个“空 schema PR”和一个不确定的后续 PR。它的退出门必须同时包含：
版本化事件、SQLite 追加账本、同事务 projection 更新、确定性 replay、migration、备份／
恢复以及故障注入。内部可以按 schema -> transaction -> rebuild 的顺序实现，但不能在
只有表结构或 append API 时宣称 P1.5 完成。

## 重新确认的执行顺序

1. **P1.5 SQLite 事件账本与 projection rebuild（NEXT）**
   - 版本化 normalization event/decision payload 与单调 ledger position。
   - append-only event、expected-generation projection CAS 和 checkpoint 同一事务提交。
   - event/correlation 幂等、精确大小写资源身份、逐资源隔离。
   - schema migration、replay/rebuild、备份、损坏／中断恢复和 redaction。
2. **P1.6 Policy Engine**
   - 补齐 `CommandIntent`／`PolicyDecision`、required facts、actor/environment scope。
   - allow/confirm/deny 及 merge、deploy、secret-use 相互独立的 fail-closed 反例。
3. **P1.7 Runtime Actor + RefreshCoordinator**
   - 单一拥有 adapters、timers、cancellation、store、policy 和 projection stream。
   - 到这里才迁移 AppDelegate 的多 timer／Set 去重逻辑，避免形成双 owner。
4. **P1.8 + R01.4 首个只读切流**
   - 一次只切一个 projection，先 shadow/candidate，再安装验收和回退观察。

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

## 当前缺少的内容

### P1.5 必须补齐

- `ProjectControlStore` 尚无 SQLite system-library 接线、数据库路径／权限和连接策略。
- 尚无 schema metadata、顺序稳定的 ledger position、DDL migration 或未来版本
  fail-closed 行为。
- `NormalizationEvent<Value>`／`NormalizationDecision` 可 Codable，但尚无持久化
  record 的 payload type/version、value type discriminator 与兼容策略。
- `AuditEvent.attributes` 只允许两个 shadow 计数字段，不能被滥用为 normalization
  payload；尚缺受保护 payload 与 value-free audit decision 的明确分层。
- 尚无 event ID／correlation ID 幂等约束、精确资源 key 约束或 ledger 顺序保证。
- 尚无 event append、expected-generation projection CAS、last-applied position 的同事务
  原子边界；也无中途故障回滚测试。
- 尚无按 ledger replay 的 projection rebuild、空库重建、重复 replay、断点恢复或原子
  替换旧 projection。
- 尚无数据库备份、损坏检测、恢复、schema migration、并发 writer/lock 行为和跨进程
  reopen 测试。
- 尚无持久化层隐私扫描／redaction；provider message、value 和审计 decision 的落盘边界
  未经证明。

### P1.6–P1.8 仍缺

- `CommandIntent`／`PolicyDecision`、required facts、risk/confirmation token 尚缺。
- 无 Runtime Actor、projection subscription、统一 cancellation/reconnect。
- AppDelegate 仍拥有 4 个 Timer 与 `refreshingRepositories` Set。
- 六路 Facade 仍为 `legacyOnly`／`shadow`，无 `candidatePrimary` 和退休记录。

### 延后到 P2.2

- Registry 原生新增/编辑/禁用/排序与保存前差异。
- repository access、default branch、checkout/provider/environment health projection。
- 新项目默认只读、review-machine capability 显式启用和跨项目故障隔离 UI。

## 停止线

若 P1.5 需要真实 timer、AppDelegate/runtime 所有权、UI、provider 外部读取、Policy
决策、Registry v1 格式变化、安装或部署才能成立，应停止并重新拆分。若只创建数据库／
表但不能从 ledger 确定性重建 projection，也不得宣称 P1.5 完成。

## 下一执行入口

- [P1.4 模块关闭记录](./P1.4-STATE-NORMALIZER-MODULE-CLOSURE.md)
- [P1.5 SQLite Event Ledger START Handoff](./P1.5-SQLITE-EVENT-LEDGER-START-HANDOFF.md)
