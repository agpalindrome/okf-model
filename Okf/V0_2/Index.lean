import Okf.V0_2.Document
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

§12 adds a second text: the root block is "the only place frontmatter is
permitted in an `index.md`". "Permitted" is a word about rules where §8's
"contain no frontmatter" was indicative, so the strict reading gains weight;
but it is not RFC 2119, and it says where a block may sit and not which keys
it may hold, so the field stays.

## §12: the version string's form

§12 says revisions "are versioned as `<major>.<minor>`" and writes the example
as the quoted string `"0.2"`. The strict reading, under `fieldTypes` like every
other shape: `okf_version`, when present on an index, is a scalar of digits, a
dot and digits. It is checked over `indexes`, where §8 and §12 place it; on a
concept it is an extension key under §4.1 and is not read. Whether a bundle
declaring some other version can be conformant "with OKF v0.2" (§11), the text
does not say, and the model has no second text to compare against; the first
`docs/findings.md` entry already carries what §12's bump rules did not catch.

## §11.3 gives §8 force, and moves the gap

§11.3 makes a bundle's conformance depend on every `index.md` following "the
structure in §8". That is the force this field was created for want of, and
the gap moves rather than closes: whether "contain no frontmatter" is part of
§8's structure, or only the sections-and-bullets body is. The two readings and
the field are the same; the reason is better. The body structure §11.3 binds is
not modelled beyond this, see below.

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

/-- Every key is `okf_version`; with unique keys, that is at most the one. -/
def Frontmatter.onlyOkfVersion (f : Frontmatter) : Bool :=
  f.entries.all fun kv => kv.1 == "okf_version"

/-- Digits, a dot, digits: §12's `<major>.<minor>`. -/
def isMajorMinor (s : String) : Bool :=
  match s.toList.span (· != '.') with
  | (major, '.' :: minor) =>
    !major.isEmpty && major.all Char.isDigit && !minor.isEmpty && minor.all Char.isDigit
  | _ => false

/-- §12's version string as a shape: `okf_version`, when present, has the
`<major>.<minor>` form. -/
def Value.isVersion : Value → Bool
  | .scalar s => isMajorMinor s
  | _ => false

/-- The strict reading of §12's shape over the bundle's index files. Whether it
binds is `Policy.fieldTypes`. -/
def Bundle.indexTypesHold (b : Bundle) : Bool :=
  b.indexes.all fun e => e.2.frontmatter.keyHolds "okf_version" Value.isVersion

/-- The `Prop` reading of `Bundle.indexTypesHold`. -/
def Bundle.IndexTypesHold (b : Bundle) : Prop :=
  ∀ e ∈ b.indexes, e.2.frontmatter.keyHolds "okf_version" Value.isVersion = true

theorem Bundle.indexTypesHold_iff (b : Bundle) :
    b.indexTypesHold = true ↔ b.IndexTypesHold := by
  simp [Bundle.indexTypesHold, Bundle.IndexTypesHold]

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
