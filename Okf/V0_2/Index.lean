import Okf.V0_2.Structure
import Okf.V0_2.Policy

/-!
# §8 Index files — one rule without force, and a carrier reopened

§8 is the section that reopened `Bundle`: it gives `index.md` content, so the
carrier has to hold files that are not concepts. `Okf.V0_2.Basic` and
`Okf.V0_2.Structure` carry that revision; this module carries §8's one rule.

## "Index files contain no frontmatter"

§8 says so in the indicative, then excepts a bundle-root `index.md`, which MAY
carry an `okf_version` key. No RFC 2119 keyword attaches to the rule itself.
An `index.md` with `title:` in its frontmatter conforms if the sentence is
description and not if it binds. `Policy.indexFrontmatter` holds the choice.
It is a separate field from `fieldTypes`: a reader can hold §4's shape
descriptions as conventions and still hold this one as binding, because §3.1's
MUST NOT, that a reserved filename is not used for a concept document, stands
behind it, and frontmatter on an index file is the one way that violation is
visible. `docs/findings.md`, 2026-10-26, "§8 says index files contain no
frontmatter, without force".

The strict reading: an index file's frontmatter is empty, or at the bundle
root holds `okf_version` and nothing else. The root is the one-segment path.
`okf_version` is held as a key name; §12 gives its meaning and is not read.

## What is not modelled

The body "uses one or more sections, each grouping concepts under a heading",
with bullet entries of link and description. Indicative, and `Body` is a
`String`; a MUST here would have forced structure, and there is none. Entries
SHOULD carry the linked concept's `description`, a cross-document SHOULD that
reads bodies. Producers MAY generate an index and consumers MAY synthesize one.
An `index.md` MAY appear in any directory. All recorded, none a clause.
-/

namespace Okf.V0_2

/-- A file at the bundle root: one segment. -/
def Path.isRoot (p : Path) : Bool :=
  p.length == 1

/-- No keys at all. -/
def Frontmatter.isEmpty (f : Frontmatter) : Bool :=
  f.entries.isEmpty

/-- Every key is `okf_version`; with unique keys, that is at most the one. -/
def Frontmatter.onlyOkfVersion (f : Frontmatter) : Bool :=
  f.entries.all fun kv => kv.1 == "okf_version"

/-- The strict reading of §8 for one index file at `p`. -/
def Document.indexFrontmatterClean (p : Path) (d : Document) : Bool :=
  if p.isRoot then d.frontmatter.onlyOkfVersion else d.frontmatter.isEmpty

/-- The strict reading over the bundle's index files. Whether it binds is
`Policy.indexFrontmatter`. -/
def Bundle.indexFrontmatterClean (b : Bundle) : Bool :=
  b.indexes.all fun e => e.2.indexFrontmatterClean e.1

/-- The `Prop` reading of `Bundle.indexFrontmatterClean`. -/
def Bundle.IndexFrontmatterClean (b : Bundle) : Prop :=
  ∀ e ∈ b.indexes, e.2.indexFrontmatterClean e.1 = true

theorem Bundle.indexFrontmatterClean_iff (b : Bundle) :
    b.indexFrontmatterClean = true ↔ b.IndexFrontmatterClean := by
  simp [Bundle.indexFrontmatterClean, Bundle.IndexFrontmatterClean]

end Okf.V0_2
