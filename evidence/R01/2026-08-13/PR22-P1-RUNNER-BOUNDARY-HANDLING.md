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
- Status: `READY_FOR_CURRENT_HEAD_REVIEW`, not merge-authorized

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

Local CI machine proof is also available from GitHub Actions run `31586647799`, attempt 2, on prior head `d2f1c8a0d554ce5c71c4d2ed45844d12fea6868d`: checkout, exact RevisionGuard, native Harness, post-checkout, and job completion all succeeded. The current workflow intentionally runs only after merge on a `main` push, so this prior run proves the machine/toolchain path, not execution of current PR head `e0c1817e…`.

## Live GitHub state after push

- Open: yes
- Draft: no
- Mergeable: yes
- Requested reviewers: `StevenZYHhome`, `miaopantao`
- Current-head reviews: none; the valid `StevenZYHhome` approval on `e0c1817e…` became stale after the CI-retirement commits
- Reviewer identity correction: `StevenZYHhome` is the repository-configured review-machine account and is distinct from PR author `Steven-ZYH`; its current-head approval is valid independent review evidence
- Unresolved review thread: one, anchored to the deleted old PR workflow; it was intentionally not author-resolved
- Current-head status contexts: none; CircleCI emitted no status for `71e3c83…`

The current CI authority is the local CI machine: exact-head local acceptance before merge and the self-hosted `main`-push workflow after merge. CircleCI is no longer the repository-native CI gate. Live GitHub repository inspection found no remaining webhooks and no remaining deploy keys, which verifies the repository-side CircleCI connection removal without deleting historical CircleCI project data.

## Gate separation

This handling pushed the author fix and CI-authority cutover, then requested fresh exact-head reviews from the configured review-machine account and `miaopantao`. It did not dismiss reviews, resolve reviewer threads, merge PR #22, install or replace `/Users/steven/Applications/OPCB Project Manager.app`, enroll real Secrets, publish audit data, modify runner registration, or deploy anything.
