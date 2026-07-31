-- Not yet used by any model module: imported so the skeleton actually exercises
-- its one dependency. A declared-but-never-imported dependency is a dependency
-- nobody has checked resolves and builds.
import Batteries

/-!
# okf-model

A **descriptive** formalization of the Open Knowledge Format. The model mirrors
what the OKF text gives us; it does not drive OKF, and where the spec is
contradictory or silent it represents the gap rather than resolving it.

This root module imports the revision modules in dependency order. It is empty
of revisions today, on purpose: the toolchain skeleton lands green and empty so
that a later red build has exactly one possible cause.

The first revision namespace will be `Okf.V0_2`, pinned to the `okf/SPEC.md`
commit recorded in `docs/pinned-revision.md` — not to the string "v0.2", which
upstream edits in place and does not tag.

See `docs/scope-and-stance.md` for what this repo does and does not certify.
-/
