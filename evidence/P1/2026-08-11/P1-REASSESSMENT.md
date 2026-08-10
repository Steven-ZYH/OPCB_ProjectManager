# P1 后续顺序与当前缺口重评估

评估时间：2026-08-11 CST

基线：`sixlab-pr-control@846344a6481d93070e47338c06abf207e7b43d2d`

## 结论

原来的依赖主序仍然正确，但需要收紧切片边界：下一步只交付**纯状态归一化内核**，
不提前建立第二套 timer/refresh owner。RefreshCoordinator 的生命周期、取消、重连和
调度所有权应与 P1.7 Runtime Actor 一起落地。

## 重新确认的执行顺序

1. **P1.4-A State Normalizer reducer／generation／CAS（NEXT）**
   - 建立按 `project + resource` 隔离的 normalized projection。
   - 用显式 monotonic generation 和 expected-generation CAS 拒绝晚到响应。
   - 定义 begin/accept/fail/expire、duplicate/late/conflict 结果和部分失败语义。
   - 只做纯 reducer、内存测试桩和 adapter envelope；不启动新 timer。
2. **P1.5 SQLite 事件账本与 projection rebuild**
   - append-only events、evidence refs、migration、备份、rebuild、redaction。
   - 先证明崩溃恢复和投影可重建，再让 runtime 成为长期事实所有者。
3. **P1.6 Policy Engine**
   - 补齐 `CommandIntent`／`PolicyDecision` 词汇和 allow/confirm/deny 反例。
   - merge、deploy、secret-use、环境与 actor scope 独立 fail-closed。
4. **P1.7 Runtime Actor + RefreshCoordinator**
   - 单一拥有 adapters、timers、cancellation、store、policy 和 projection stream。
   - 到这里才迁移 AppDelegate 的多 timer／Set 去重逻辑，避免中间双 owner。
5. **P1.8 + R01.4 首个只读切流**
   - 一次只切一个 projection，先 shadow/candidate，再安装验收和回退观察。

P2 主窗口仍不得提前。P1.3-B 的 App 内 Registry 管理和外部访问健康检查归入
P2.2；它们依赖 P1 normalizer/store/runtime，但不阻塞下一内核切片。

## 当前缺少的内容

### P1.4

- `ObservationMerger` 只有两个值的纯比较，没有 keyed projection 或 CAS store。
- legacy Facade 用时间戳派生 generation，缺少每资源单调 generation allocator。
- 没有 refresh request/correlation ID、expected generation、started/finished 边界。
- 没有 begin-fetch、失败保留旧值、逐资源 partial 合成和 expire reducer。
- late/duplicate/conflict 结果没有成为可持久化的 typed decision。
- AppDelegate 仍用 4 个 Timer 与 `refreshingRepositories` Set 拥有刷新并发。

### P1.5–P1.8

- 无 SQLite schema、migration、transaction、projection rebuild、backup/recovery。
- `AuditEvent.attributes` 仅允许极少数字段，尚无完整 typed payload/version 策略。
- `CommandIntent`／`PolicyDecision`、required facts、risk/confirmation token 尚缺。
- 无 Runtime Actor、projection subscription、统一 cancellation/reconnect。
- 六路 Facade 仍为 `legacyOnly`／`shadow`，无 `candidatePrimary` 和退休记录。

### 延后到 P2.2

- Registry 原生新增/编辑/禁用/排序与保存前差异。
- repository access、default branch、checkout/provider/environment health projection。
- 新项目默认只读、review-machine capability 显式启用和跨项目故障隔离 UI。

## 停止线

若下一切片需要引入 SQLite、真实 timer、AppDelegate 切流、UI、外部命令或安装部署
才能成立，说明范围已经越过 P1.4-A，应停止并重新拆分。
