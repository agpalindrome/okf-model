import Okf.V0_2.Basic

/-!
# §3 Bundle structure — the first clause

§3 states two RFC 2119 keywords. The MAY, on distribution, is not modelled. The
MUST NOT, §3.1's reserved filenames, is the first conformance clause in the
model and the whole of this module's Lean.

## The map survives §3

§3 adds "directory tree", "level" and "subdirectory" to §2's "hierarchical",
and still constrains no directory as a thing: nothing about an empty one,
nothing one must or may contain. Only files carry rules, so the §2 argument for
a map keyed on `Path` stands unchanged. "At any level of the hierarchy" is why
`Path.isReserved` looks at the last segment and ignores the depth.

## What is not modelled, and why

**Distribution.** A git repository, an archive, or "a subdirectory within a
larger repository" are bytes, below the trust boundary in
`docs/scope-and-stance.md`. The third form does say something the model relies
on: `Path` is relative to the bundle root, not to any repository root. How that
root is found, the spec does not say; upstream's in-flight PR on §3.2 is about
exactly that (`docs/pinned-revision.md`), so the model takes the root as given.

**`index.md` and `log.md` themselves.** §3.1 puts them in the tree and outside
the set of concept documents, so `Bundle`, which holds concepts only, cannot
hold them. Their content is handed to §8 and §9, and that is where the carrier
is reopened — as `Frontmatter` is reopened at §4.1. Widening it now would
assert a shape those sections have not given.

**Non-markdown files.** §3 says the tree is "of markdown files" and §3.1 scopes
its rule to `.md`. Neither says what a `.txt` beside them is: ignored,
forbidden, or part of the bundle. That is the gap `conceptId`'s `Option`
already carries from §2, and §3 was the section that should have answered it.
It is recorded in `docs/findings.md` (2026-10-26). It gets no `Policy` field
because the carrier cannot represent the separating bundle, and widening the
carrier to hold files the text never names would model our worry rather than
the text. Upstream's pending §3.2 corpus definition would settle it.

## One commitment, recorded

`Index.md` is not reserved. The match is exact, like `uniquePaths` a commitment
rather than a `Policy` field: case folding is filesystem behaviour, and a path
reaches the model already as segments, with that question settled below the
trust boundary.
-/

namespace Okf.V0_2

/-- §3.1's reserved filenames, as a list so that §8 and §9 can name the same
two strings rather than their own copies. -/
def reservedFilenames : List String := ["index.md", "log.md"]

/-- Whether a path's file is one §3.1 reserves. Depth is ignored: the names
"have defined meaning at any level of the hierarchy". -/
def Path.isReserved (p : Path) : Bool :=
  match p.getLast? with
  | some name => reservedFilenames.contains name
  | none => false

/-- §3.1: reserved filenames "MUST NOT be used for concept documents".

A bundle's entries are concept documents by type, so the clause is a condition
on their paths. -/
def Bundle.noReservedConcepts (b : Bundle) : Bool :=
  b.entries.all fun e => !e.1.isReserved

/-- The `Prop` reading of `Bundle.noReservedConcepts`. -/
def Bundle.NoReservedConcepts (b : Bundle) : Prop :=
  ∀ e ∈ b.entries, e.1.isReserved = false

theorem Bundle.noReservedConcepts_iff (b : Bundle) :
    b.noReservedConcepts = true ↔ b.NoReservedConcepts := by
  simp [Bundle.noReservedConcepts, Bundle.NoReservedConcepts]

/-- The bundle with no concepts. §3 does not say whether it is a bundle; it is
here as the smallest value the clause can be checked on. -/
def Bundle.empty : Bundle := ⟨[], List.nodup_nil⟩

/-- A concept with nothing in it, for building witnesses. It fails §4.1, which
is no matter here: §3.1 is a condition on paths. -/
def Concept.blank : Concept := ⟨Frontmatter.empty, ""⟩

/-- A bundle whose one concept sits at the root as `index.md`. -/
def indexAsConcept : Bundle := ⟨[(["index.md"], Concept.blank)], by simp⟩

/-- A bundle whose one concept sits two levels down as `log.md`. -/
def nestedLogAsConcept : Bundle :=
  ⟨[(["a", "b", "log.md"], Concept.blank)], by simp⟩

/-- A bundle whose one concept sits at the root as `Index.md`. -/
def capitalisedIndex : Bundle := ⟨[(["Index.md"], Concept.blank)], by simp⟩

/-- §3.1 is satisfiable. -/
theorem empty_noReservedConcepts : Bundle.empty.noReservedConcepts = true := by decide

/-- §3.1 is violable: a concept named `index.md` at the root. -/
theorem indexAsConcept_violates : indexAsConcept.noReservedConcepts = false := by decide

/-- §3.1 reaches every level: a concept named `log.md` two directories down. -/
theorem nestedLogAsConcept_violates : nestedLogAsConcept.noReservedConcepts = false := by
  decide

/-- The commitment the module docstring records: the match is exact, so
`Index.md` is not reserved. -/
theorem capitalisedIndex_passes : capitalisedIndex.noReservedConcepts = true := by decide

end Okf.V0_2
