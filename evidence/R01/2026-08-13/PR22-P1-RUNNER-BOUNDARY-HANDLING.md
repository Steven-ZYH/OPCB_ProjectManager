# PR #22 P1 runner-boundary handling

- Date: 2026-08-13
- Repository: `Steven-ZYH/sixlab-pr-control`
- PR: [#22 — feat: add invoke-only secret access and project indexes](https://github.com/Steven-ZYH/sixlab-pr-control/pull/22)
- Base: `main@834a99e418278a3809e3a0e274bf4850b67e89c0`
- Current head: `71e3c8353396fa7d221a2f5e980f5d1645b1190c`
- Runner-removal commit: `7182906d537cc10507f673626a2019e9372eda79`
- Post-merge-only runner commit: `e0c1817e27015945572ccdc4c878655c8aa26715`
- CircleCI-retirement commit: `ae5fae559ed1b8e66422dbe4e53144e7b18c73f0`
- CircleCI-connection closure commit: `71e3c8353396fa7d221a2f5e980f5d1645b1190c`
- Status: merged; post-merge local CI run skipped by merge commit message

## Blocker handled

The prior head added a `pull_request` workflow that automatically checked out and executed same-repository PR code on a persistent local Mac self-hosted runner. Fork checks, a read-only repository token, clean checkout, and exact-SHA verification did not isolate the host filesystem, Login Keychain/session, local services/network, or persistent state from candidate code.

The unsafe PR lane was removed from PR #22 completely:

- deleted `.github/workflows/local-mac-native.yml`;
- removed the README claim that PR code is accepted by that persistent runner;
- removed the runner-only `xcrun` toolchain delta from `test-native.sh`;
- retained the Local Vault, trusted-principal, audit, and project-index feature tree unchanged;
- added `.github/workflows/local-mac-postmerge.yml`, which triggers only on `push` to `main`;
- added `LocalMacWorkflowBoundarySmoke`, which rejects `pull_request`, `pull_request_target`, and `workflow_dispatch` triggers;
- removed `.circleci/config.yml` and the retired CircleCI emergency runbook;
- made the boundary smoke fail if the CircleCI adapter is reintroduced.

Negative dispatch evidence: the self-hosted workflow has no candidate-code or manual trigger and checks out only the `main` push event's `github.sha`. An unapproved same-repository PR therefore cannot obtain the self-hosted labels through this repository configuration.

Any future native self-hosted lane requires a separate design using an ephemeral zero-secret environment or a base-owned/manual immutable-ref boundary with independent operational proof.

## Exact-head validation

- `git diff --check origin/main...HEAD`: PASS
- `git merge-tree --write-tree origin/main HEAD`: PASS, tree `9b8ffe1810b22f19abbb34e7479fd4b1f70fb29f`
- `LocalMacWorkflowBoundarySmoke`: PASS, main push only
- RevisionGuard: PASS at `71e3c8353396fa7d221a2f5e980f5d1645b1190c`
- Swift Package tests: 112 PASS, 0 failures
- Complete native smoke/render harness: PASS
- `NativeSecretControlSmoke`: PASS
- `NativeDashboardRender`: PASS
- Review-worker smoke: PASS
- App build, product identity, App icon, exact SourceBinding, and strict codesign: PASS

Local CI machine proof is also available from GitHub Actions run `31586647799`, attempt 2, on prior head `d2f1c8a0d554ce5c71c4d2ed45844d12fea6868d`: checkout, exact RevisionGuard, native Harness, post-checkout, and job completion all succeeded. The final workflow intentionally runs only after merge on a `main` push, so this prior run proves the machine/toolchain path, not execution of final PR head `71e3c83…`.

## Final pre-merge GitHub state

- Open: yes
- Draft: no
- Mergeable: yes
- Requested reviewers: none after completion
- Exact current-head approvals: `StevenZYHhome`, `miaopantao`
- Reviewer identity correction: `StevenZYHhome` is the repository-configured review-machine account and is distinct from PR author `Steven-ZYH`; its current-head approval is valid independent review evidence
- Unresolved review thread: one, anchored to the deleted old PR workflow; it was intentionally not author-resolved
- Current-head status contexts: none; CircleCI emitted no status for `71e3c83…`

The current CI authority is the local CI machine: exact-head local acceptance before merge and the self-hosted `main`-push workflow after merge. CircleCI is no longer the repository-native CI gate. Live GitHub repository inspection found no remaining webhooks and no remaining deploy keys, which verifies the repository-side CircleCI connection removal without deleting historical CircleCI project data.

## Gate separation

Before merge authorization, this handling pushed the author fix and CI-authority cutover, then obtained fresh exact-head reviews from the configured review-machine account and `miaopantao`. It did not dismiss reviews or resolve reviewer threads. The later authorized merge is recorded separately below; App installation, Secret enrollment, audit publication, runner mutation, and deployment remained outside scope.

## Merge closure

The user explicitly authorized merge after the final status refresh.

- Final PR head: `71e3c8353396fa7d221a2f5e980f5d1645b1190c`
- Final base before merge: `834a99e418278a3809e3a0e274bf4850b67e89c0`
- GitHub aggregate before merge: `APPROVED`, `MERGEABLE`, `CLEAN`
- Exact-head approvals: `StevenZYHhome`, `miaopantao`
- Final merge tree: `9b8ffe1810b22f19abbb34e7479fd4b1f70fb29f`
- Merge method: squash with expected-head protection
- Merged main commit: `02b5db04b7609dd25c813768f57af73a0005eb57`
- PR state after merge: closed and merged
- Live `origin/main` after fetch: `02b5db04b7609dd25c813768f57af73a0005eb57`

The post-merge `Local Mac Post-merge Native CI` workflow did not create a run for the merged main commit. The squash commit message contains the source commit subject `ci: finalize CircleCI retirement [ci skip]`. GitHub applies `[ci skip]` found in a commit message to workflows triggered by `push`, so the new `main`-push workflow was skipped. Repeated GitHub Actions queries for commit `02b5db04…` returned no run.

Therefore the closure is:

- merge: PASS;
- source/main synchronization: PASS;
- pre-merge exact-head native validation: PASS;
- post-merge local CI: `SKIPPED / NOT RUN`;
- App installation: not performed;
- Secret enrollment, audit publication, runner mutation, deployment, and release: not performed.

Correcting the skipped post-merge validation would require a new authorized `main` push or a separately reviewed workflow change. It is not implied by the merge authorization and was not performed in this closure.

## Follow-up trigger repair (2026-08-14)

The user separately and explicitly authorized changing the persistent runner's
trusted event model after the `push`-triggered run was skipped. The follow-up is
[PR #24 — ci: make post-merge local Mac validation skip-proof](https://github.com/Steven-ZYH/sixlab-pr-control/pull/24).

- Base: `main@02b5db04b7609dd25c813768f57af73a0005eb57`
- Current head: `199a5a99a3289c48857f997d26e03b1367455b2b`
- State: Open, Ready for review, not merged
- Requested reviewers: `StevenZYHhome`, `miaopantao`
- Local full-Harness result on the exact clean head: PASS
- RevisionGuard and SourceBinding: PASS at `199a5a99…`, `state=clean`
- Current-main merge tree: `b80b59eeab4a654cbd7d42119ec52c6e2b1784eb`
- GitHub Actions runs on the PR head: none; the lane remains post-merge only

The proposed workflow uses `pull_request_target: closed` for PRs targeting
`main`, allocates the self-hosted job only when GitHub reports `merged == true`,
and checks out only `github.event.pull_request.merge_commit_sha`. Repository
permissions remain read-only, checkout credentials are not persisted, and the
static regression locks the complete trigger block while rejecting candidate
head/fork/merge refs and all other workflow triggers. Consecutive merged
revisions queue rather than cancelling an in-progress validation.

Draft PR #23 independently proposes `repository_dispatch` for trusted-main
remote dispatch and overlaps the same workflow/test/docs files. PR #24 does not
absorb or modify #23. If #23 merges first, #24 must be rebased, revalidated, and
reviewed again as an explicit security-policy choice; the two trigger models
must not be combined implicitly.

This follow-up has not merged, installed or replaced the App, enrolled secrets,
published audit data, updated the Worker, or deployed any service.
