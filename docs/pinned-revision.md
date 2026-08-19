# Pinned OKF revision

Every model module and every finding in this repo is read against **one exact
revision of the spec text**, recorded here.

## Current pin

| | |
| --- | --- |
| Declared version | **v0.2** (§13 of `SPEC.md`) |
| Repository | `GoogleCloudPlatform/knowledge-catalog` |
| Path | `okf/SPEC.md` |
| Commit | `3fcbb9f828c2f23d109c855ee403c3a4c81f3a96` (2026-07-24) |
| Blob SHA | `a516d50128f5aa1f5746d1464661a39f7143e875` (37544 bytes) |
| Permalink | <https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/3fcbb9f828c2f23d109c855ee403c3a4c81f3a96/okf/SPEC.md> |

Pinned 2026-07-31.

## Why a SHA and not "v0.2"

Upstream has **no tags and no releases**. "v0.2" exists only as prose inside §13
of `SPEC.md`, and that file is edited in place — the pinned commit above is
itself a follow-up edit to the v0.2 migration commit (`780fe9d3`), made the same
day, under the same version string. A model pinned to the string "v0.2" is
pinned to a moving target.

So the SHA is the real identifier, and the declared version is metadata about
it. Cite both, in that order, in every finding.

## Known in-flight change to the pinned text

[PR #232][pr232] is **open** as of the pin date. It adds a §3.2 defining a single
bundle root and a conformance corpus of "regular `.md` file entries recursively
beneath that root, excluding symbolic-link entries", and rewrites §11's list in
those terms.

This matters to the first modelling pass, which covers §3 and §11 directly. The
model reads the **pinned text**, not the PR. If #232 lands, the ambiguity it
resolves stops being a gap — and re-pinning is how that enters this repo, not an
edit in place.

[pr232]: https://github.com/GoogleCloudPlatform/knowledge-catalog/pull/232

## Re-pinning

Re-pinning is deliberate work, not maintenance. It obliges, at minimum:

1. A diff of the two SPEC.md blobs, summarized in the commit message.
2. A decision — recorded, not assumed — on whether the new text goes in a **new
   revision namespace** (`Okf.V0_3`) or updates the existing one. A new declared
   version means a new namespace. A silent edit under an unchanged version string
   is the harder case, and is itself worth logging in `findings.md`.
3. A re-read of every open finding: a gap the new text closes should be marked
   closed with the SHA that closed it, not deleted.

Nothing here obliges tracking upstream promptly. The model is descriptive of a
revision; an old pin is a correct model of an old revision, not a stale one.
