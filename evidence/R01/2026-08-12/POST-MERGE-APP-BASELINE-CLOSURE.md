# OPCB Project Manager post-merge App baseline closure

- Date: 2026-08-12
- Verdict: `NO-INSTALL-NEEDED`
- Merged main: `834a99e418278a3809e3a0e274bf4850b67e89c0`
- Merged PR head: `0b85c25ca4c936fe47caca40e01ac9c7accc379d`
- Installed App: `/Users/steven/Applications/OPCB Project Manager.app`

## Conclusion

The installed App is product-content-equivalent to the merged `origin/main`. No installation was performed in this closure. Replacing the installed bundle would only rewrite its source-binding SHA from the merged PR head to the squash commit and regenerate the corresponding code signature; it would not change source content, executable code, or resources.

Future product development must start from a clean worktree based on current `origin/main`. The old PR Control surface is frozen at this boundary and is not the target for further feature expansion.

## Merge and CI evidence

- Live `origin/main`: `834a99e418278a3809e3a0e274bf4850b67e89c0`
- CircleCI context `ci/circleci: native-build-and-test`: `success` (run 62)
- Exact-main native harness: PASS
- Revision guard: PASS for `CI_EXPECTED_SHA=834a99e418278a3809e3a0e274bf4850b67e89c0`
- Swift package tests: PASS
- All 18 native smoke/render tests: PASS
- Review worker smoke: PASS
- App icon bundle, product identity, source binding, and deep/strict code-sign verification: PASS

The clean exact-main candidate was produced at:

`/private/tmp/opcb-main-834a99e-baseline/build/harness/app/OPCB Project Manager.app`

## Source equivalence

- Main squash commit tree: `8abb7ca99c94fe27c2cb43298f34e4ad06db5d0d`
- Installed-App source commit tree: `8abb7ca99c94fe27c2cb43298f34e4ad06db5d0d`
- Git tree diff: empty
- Exact-main candidate `OPCBSourceTreeState`: `clean`
- Installed App `OPCBSourceTreeState`: `clean`

The differing commit identifiers are caused by GitHub's squash merge. Their complete source trees are identical.

## Bundle equivalence

The clean exact-main candidate and installed App have identical resource hashes:

| File | SHA-256 |
|---|---|
| `AppIcon.icns` | `9cac380210f48a019fd2e5d2783ce458af70129c8dbcc3ac805b8a32be13475f` |
| bundled font | `6f4fe7d37853b91df3698daa84cde2dbe1c9695d88c986e6510134910337d426` |
| `OFL.txt` | `ec9603b3152b50f407bb2b07af9fbe0f367cf1d1e30fbadb858db049245c91e2` |
| `_CodeSignature/CodeResources` | `b75903e76cfba392c1828423b55935cb95f7abe9f00462534f192153c8bdfe3b` |

After removing signatures from temporary executable copies, both Mach-O files were byte-identical:

`6da569c3c55d5dd82751a194533405dbbd58d600a9d6fb21ea662ef3ddd4a7e5`

Both original bundles pass `codesign --verify --deep --strict`.

The only `Info.plist` difference is:

- exact-main candidate `OPCBSourceSHA`: `834a99e418278a3809e3a0e274bf4850b67e89c0`
- installed App `OPCBSourceSHA`: `0b85c25ca4c936fe47caca40e01ac9c7accc379d`

After removing `OPCBSourceSHA` from temporary plist copies, the files are byte-identical. The signed executable hashes therefore differ only because the embedded source-binding metadata changes the generated code signature.

## Installation decision

Status: `NO-INSTALL-NEEDED`.

No files under `/Users/steven/Applications/OPCB Project Manager.app` were replaced in this closure. This decision is based on exact source-tree equality, exact unsigned-executable equality, exact resource equality, clean source binding, passing exact-main validation, and passing signatures on both bundles.

## Concurrent next-feature work

An initial inspection found uncommitted next-feature work in `/private/tmp/opcb-local-secret-vault`, concerning a unified local Vault folder and AI invoke-only secret bindings. That worktree was left untouched. During this closure, the concurrent author flow committed and pushed the work independently, then produced a current-main formalization in `/private/tmp/opcb-invoke-only-secret-access`.

Live end-of-closure state:

- PR: [#22 — feat: add invoke-only secret access and audit logs](https://github.com/Steven-ZYH/sixlab-pr-control/pull/22)
- Base: `main@834a99e418278a3809e3a0e274bf4850b67e89c0`
- Head: `e2f6e0ebb2dc108db5b9a853cb9699d833727502`
- Draft: no
- Mergeable: yes
- CircleCI `native-build-and-test`: success (run 64)
- Requested reviewer: `miaopantao`
- Submitted reviews: none
- Review threads: none

PR #22 is a review candidate only. It is not merged, installed, or deployed, and it does not alter the `NO-INSTALL-NEEDED` conclusion for the already merged App baseline.
