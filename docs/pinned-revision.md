# Pinned OKF revision

Every model module and every finding in this repo is read against **one exact
revision of the spec text**, recorded here.

## Current pin

| | |
| --- | --- |
| Declared version | **v0.2** (§13 of `SPEC.md`) |
| Repository | `GoogleCloudPlatform/open-knowledge-format` |
| Path | `SPEC.md` |
| Commit | `ad30107c31c06aec8a7d5636e0d1058118604e6f` (2026-08-21) |
| Blob SHA | `c06e3eede0c910d0ecf12524c34204156f8795ac` (37748 bytes) |
| Permalink | <https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/ad30107c31c06aec8a7d5636e0d1058118604e6f/SPEC.md> |

Pinned 2026-09-21.

## Earlier pins

| Pinned | Repository and path | Commit | Blob SHA | Unpinned |
| --- | --- | --- | --- | --- |
| 2026-07-31 | `GoogleCloudPlatform/knowledge-catalog`, `okf/SPEC.md` | `3fcbb9f828c2f23d109c855ee403c3a4c81f3a96` (2026-07-24) | `a516d50128f5aa1f5746d1464661a39f7143e875` (37544 bytes) | 2026-09-21 |

The 2026-09-21 re-pin moved repositories as well as commits. OKF left
`knowledge-catalog` for its own repository on 2026-08-21
([knowledge-catalog#324][pr324]), and `knowledge-catalog/okf/README.md` now marks
the copy under `okf/` a frozen snapshot and tells readers to stop using it. At
the frozen tip that copy is byte-identical to the new pin, blob `c06e3eed`.

The one normative difference from the earlier pin is the timestamp edit made
upstream on 2026-08-20 and 2026-08-21 (`knowledge-catalog` `62432a0`,
`open-knowledge-format` `3dc3029`). Every timestamp-valued key becomes an ISO
8601 datetime with an explicit UTC offset, and staleness compares against `now`
rather than `today`. The version string did not change, which the
[findings log][silent] records.

The namespace decision this required, made by the owner on 2026-09-21:
**re-pin in place.** `Okf.V0_2` binds to this pin rather than to a new
namespace. `main` had no model module when the pin moved, but the unmerged
`feat/okf-v0-2` branch (`662cbe9`, `2559764`) adds `Okf.V0_2` and models §2
against the earlier pin. §2 is byte-identical in the two texts, so the content
of `Okf/V0_2/Basic.lean` holds under this pin. Only its docstrings, which cite
`knowledge-catalog`'s `okf/SPEC.md`, need repointing when that branch lands.

[pr324]: https://github.com/GoogleCloudPlatform/knowledge-catalog/pull/324
[silent]: findings.md#2026-09-21--v02-changed-its-timestamp-type-without-a-version-change

## Why a SHA and not "v0.2"

Upstream has **no tags and no releases**. "v0.2" exists only as prose inside §13
of `SPEC.md`, and that file is edited in place. It has happened twice: the
earlier pin was itself a follow-up edit to the v0.2 migration commit
(`780fe9d3`), made the same day, and the current pin changes the type of every
timestamp field, a month later. Both carry the same version string. A model
pinned to the string "v0.2" is pinned to a moving target.

So the SHA is the real identifier, and the declared version is metadata about
it. Cite both, in that order, in every finding.

## Known in-flight change to the pinned text

[knowledge-catalog#232][pr232] is still **open** as of 2026-09-21. It adds a
§3.2 defining a single bundle root and a conformance corpus of "regular `.md`
file entries recursively beneath that root, excluding symbolic-link entries",
and rewrites §11's list in those terms.

It was opened against the repository OKF has since left, so it cannot land in
the pinned file as it stands. A change like it would now arrive through
`open-knowledge-format`, which is where to watch.

This matters whenever §3 and §11 are modelled. The model reads the **pinned
text**, not the PR. If that change lands, the ambiguity it resolves stops being
a gap — and re-pinning is how that enters this repo, not an edit in place.

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
4. The earlier pin moved to *Earlier pins*, with the date it was replaced.

Nothing here obliges tracking upstream promptly. The model is descriptive of a
revision; an old pin is a correct model of an old revision, not a stale one.
