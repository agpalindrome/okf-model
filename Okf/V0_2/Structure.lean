import Okf.V0_2.Basic

/-!
# §3 Bundle structure — kind by path

§3 states two RFC 2119 keywords. The MAY, on distribution, is not modelled. The
MUST NOT, §3.1's reserved filenames, is carried by the filters this module
defines, and not by a clause. Revised at §8; the history is below.

## The map survives §3

§3 adds "directory tree", "level" and "subdirectory" to §2's "hierarchical",
and still constrains no directory as a thing: nothing about an empty one,
nothing one must or may contain. Only files carry rules, so the §2 argument for
a map keyed on `Path` stands unchanged. "At any level of the hierarchy" is why
`Path.isReserved` looks at the last segment and ignores the depth.

## Why the §3.1 MUST NOT is a filter and not a clause

Until §8 this module held `Bundle.noReservedConcepts`: no entry, each then a
`Concept` by type, at a reserved path. §8 gave `index.md` content, so the
carrier had to hold index files, and the way §3.1 says to tell files apart is
by name: reserved filenames "have defined meaning", "all other `.md` files are
concept documents". So `Bundle.concepts` is the entries at unreserved paths and
`Bundle.indexes` the entries at `index.md`, and nothing at a reserved path is a
concept.

That removes the clause rather than weakening it. What it checked was the label
a parser had put on an entry, and the parser is below the trust boundary in
`docs/scope-and-stance.md`; a parser that follows §3.1 can never produce the
violation. The MUST NOT is not erased either: no reading of the text lets a
concept live at `index.md`, so there is no gap for the type to hide. A producer
who writes concept content into `index.md` is visible only as frontmatter on an
index file, and `Okf.V0_2.Index` carries that under `Policy.indexFrontmatter`.

## What is not modelled, and why

**Distribution.** A git repository, an archive, or "a subdirectory within a
larger repository" are bytes, below the trust boundary in
`docs/scope-and-stance.md`. The third form does say something the model relies
on: `Path` is relative to the bundle root, not to any repository root. How that
root is found, the spec does not say; upstream's in-flight PR on §3.2 is about
exactly that (`docs/pinned-revision.md`), so the model takes the root as given.

**Non-markdown files.** §3 says the tree is "of markdown files" and §3.1 scopes
its rule to `.md`. Neither says what a `.txt` beside them is: ignored,
forbidden, or part of the bundle. That is the gap `conceptId`'s `Option`
already carries from §2, and §3 was the section that should have answered it.
It is recorded in `docs/findings.md` (2026-10-26). It gets no `Policy` field
because the carrier cannot represent the separating bundle, and widening the
carrier to hold files the text never names would model our worry rather than
the text. Upstream's pending §3.2 corpus definition would settle it. The
question is live in the text's own example: Appendix A's tree lists two `.py`
files (`Okf.V0_2.AppendixA`).

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

/-- Whether a path's file is `index.md`, at any level. -/
def Path.isIndex (p : Path) : Bool :=
  p.getLast? == some "index.md"

/-- §3.1: "all other `.md` files are concept documents". -/
def Bundle.concepts (b : Bundle) : List (Path × Document) :=
  b.entries.filter fun e => !e.1.isReserved

/-- Whether a path's file is `log.md`, at any level. -/
def Path.isLog (p : Path) : Bool :=
  p.getLast? == some "log.md"

/-- §3.1 and §8: the bundle's index files. -/
def Bundle.indexes (b : Bundle) : List (Path × Document) :=
  b.entries.filter fun e => e.1.isIndex

/-- §3.1 and §9: the bundle's log files. -/
def Bundle.logs (b : Bundle) : List (Path × Document) :=
  b.entries.filter fun e => e.1.isLog

/-- The bundle with no files. §3 does not say whether it is a bundle; it is
here as the smallest value the clauses can be checked on. -/
def Bundle.empty : Bundle := ⟨[], List.nodup_nil⟩

/-- A document with nothing in it, for building witnesses. -/
def Document.blank : Document := ⟨Frontmatter.empty, ""⟩

/-- A bundle whose one file sits at the root as `index.md`. -/
def indexAtRoot : Bundle := ⟨[(["index.md"], Document.blank)], by simp⟩

/-- A bundle whose one file sits two levels down as `log.md`. -/
def nestedLog : Bundle := ⟨[(["a", "b", "log.md"], Document.blank)], by simp⟩

/-- A bundle whose one file sits at the root as `Index.md`. -/
def capitalisedIndex : Bundle := ⟨[(["Index.md"], Document.blank)], by simp⟩

/-- §3.1: a file named `index.md` is not a concept. -/
theorem indexAtRoot_concepts : indexAtRoot.concepts = [] := by decide

/-- §3.1 and §8: it is an index. -/
theorem indexAtRoot_indexes : indexAtRoot.indexes = indexAtRoot.entries := rfl

/-- §3.1 reaches every level: `log.md` two directories down is not a concept. -/
theorem nestedLog_concepts : nestedLog.concepts = [] := by decide

/-- §3.1 and §9: it is a log. -/
theorem nestedLog_logs : nestedLog.logs = nestedLog.entries := rfl

/-- The commitment the module docstring records: the match is exact, so a file
named `Index.md` is a concept. -/
theorem capitalisedIndex_concepts : capitalisedIndex.concepts = capitalisedIndex.entries := rfl

end Okf.V0_2
