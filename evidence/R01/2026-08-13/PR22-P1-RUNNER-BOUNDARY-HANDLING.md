# PR #22 P1 runner-boundary handling

- Date: 2026-08-13
- Repository: `Steven-ZYH/sixlab-pr-control`
- PR: [#22 — feat: add invoke-only secret access and project indexes](https://github.com/Steven-ZYH/sixlab-pr-control/pull/22)
- Base: `main@834a99e418278a3809e3a0e274bf4850b67e89c0`
- Current head: `7182906d537cc10507f673626a2019e9372eda79`
- Author-fix commit: `7182906d537cc10507f673626a2019e9372eda79`
- Status: `READY_FOR_CURRENT_HEAD_REVIEW`, not merge-authorized

## Blocker handled

The prior head added a `pull_request` workflow that automatically checked out and executed same-repository PR code on a persistent local Mac self-hosted runner. Fork checks, a read-only repository token, clean checkout, and exact-SHA verification did not isolate the host filesystem, Login Keychain/session, local services/network, or persistent state from candidate code.

The unsafe lane was removed from PR #22 completely:

- deleted `.github/workflows/local-mac-native.yml`;
- removed the README claim that PR code is accepted by that persistent runner;
- removed the runner-only `xcrun` toolchain delta from `test-native.sh`;
- retained the Local Vault, trusted-principal, audit, and project-index feature tree unchanged.

Negative dispatch evidence: the current repository tree has no workflow containing a self-hosted `runs-on` target. An unapproved same-repository PR therefore cannot obtain the removed self-hosted labels through this repository configuration.

Any future native self-hosted lane requires a separate design using an ephemeral zero-secret environment or a base-owned/manual immutable-ref boundary with independent operational proof.

## Exact-head validation

- `git diff --check origin/main...HEAD`: PASS
- `git merge-tree --write-tree origin/main HEAD`: PASS, tree `0df6f00c7283ed107afb530a0ad7336dd34dce35`
- Current head tree equals the previously fully tested feature tree at `622378be75bc6fad7222b2df79698e365e1a1b50`: PASS
- Repository workflow scan for self-hosted `runs-on`: none
- RevisionGuard: PASS at `7182906d537cc10507f673626a2019e9372eda79`
- Swift Package tests: PASS
- Complete native smoke/render harness: PASS
- `NativeSecretControlSmoke`: PASS
- `NativeDashboardRender`: PASS
- Review-worker smoke: PASS
- App build, product identity, App icon, exact SourceBinding, and strict codesign: PASS

## Live GitHub state after push

- Open: yes
- Draft: no
- Mergeable: yes
- Requested reviewer: `miaopantao`
- Current-head reviews: none
- Unresolved review thread: one, anchored to the deleted workflow; it was intentionally not author-resolved so the reviewer can verify the new head
- CircleCI `ci/circleci: native-build-and-test` run 68: failure

GitHub exposes no diagnostic detail for run 68. The unauthenticated CircleCI API returned 404 and the CircleCI page was not readable from the available browser connection, so the failure remains an evidence gap rather than a diagnosed code failure. The successful repository-native exact-head harness does not convert that external red status into green CI.

## Gate separation

This handling pushed an author fix and requested a fresh independent review. It did not merge PR #22, install or replace `/Users/steven/Applications/OPCB Project Manager.app`, enroll real Secrets, publish audit data, modify runner registration, or deploy anything.
