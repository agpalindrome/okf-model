import Okf.V0_2.Provenance
import Okf.V0_2.Log
import Okf.V0_2.Policy

/-!
# §5.1's footnote join — parked twice, modelled at §10

§5.1 attributes a claim with "a markdown footnote whose label is a
`sources[].id`", and says `id` SHOULD be present when the body cites the
source. Neither sentence carries a keyword on the join itself. The rule needed
a `Body` that could be read, so it was parked at §5 for §6, and at §6 for §10.
§9 set the precedent of reading a body by lines, and §10.2's example
demonstrates the join with `[^rev-policy]` against `id: rev-policy`, so this is
where it is modelled.

## What is read

A footnote definition is a line opening `[^`, with the label running to the
first `]`, which must be followed by `:`. Inline references in prose, `[^x]`
mid-sentence, are not read: that is inline markdown, past what a line-based
reading reaches, and a definition with no reference is harmless where a
reference with no definition is a markdown matter and not an OKF one. The
strict reading: every footnote definition's label is the `id` of some `sources`
entry. `Policy.footnoteLabels` holds whether it binds. The SHOULD on `id`
presence is a SHOULD and is not a clause. `docs/findings.md`, 2026-10-26, "§5.1
keys footnotes to `sources[].id` without force".
-/

namespace Okf.V0_2

/-- The label of a footnote definition line, if the line is one. -/
def footnoteLabel (line : List Char) : Option String :=
  if "[^".toList.isPrefixOf line then
    let afterOpen := line.drop 2
    let label := afterOpen.takeWhile (· != ']')
    match afterOpen.drop label.length with
    | ']' :: ':' :: _ => some (String.mk label)
    | _ => none
  else none

/-- The labels of the body's footnote definitions. -/
def Body.footnoteLabels (b : Body) : List String :=
  (splitLines b.toList).filterMap footnoteLabel

/-- The `id` of each `sources` entry that has one. -/
def Frontmatter.sourceIds (f : Frontmatter) : List String :=
  match f.get? "sources" with
  | some v => v.items.filterMap fun e => match e.get? "id" with
    | some (.scalar s) => some s
    | _ => none
  | none => []

/-- The strict reading of §5.1's join: every footnote definition names a
source. -/
def Document.footnotesJoined (d : Document) : Bool :=
  d.body.footnoteLabels.all fun label => d.frontmatter.sourceIds.contains label

/-- The strict reading over the bundle's concepts. -/
def Bundle.footnotesJoined (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.footnotesJoined

/-- The `Prop` reading of `Bundle.footnotesJoined`. -/
def Bundle.FootnotesJoined (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.footnotesJoined = true

theorem Bundle.footnotesJoined_iff (b : Bundle) :
    b.footnotesJoined = true ↔ b.FootnotesJoined := by
  simp [Bundle.footnotesJoined, Bundle.FootnotesJoined]

end Okf.V0_2
