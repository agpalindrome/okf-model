import Okf.V0_2.Structure
import Okf.V0_2.Policy

/-!
# §9 Log files — the first clause that reads a body

§9 states a MAY on where `log.md` may appear, a MUST on the form of its date
headings, and describes the order of entries without a keyword. The MUST is the
first rule in the spec over body text, so this module is where the model reads
a `Body` for the first time, and it says exactly how far it reads.

## A line-based reading of "date heading"

A date heading is a line that begins `## `, and its text is everything after
those three characters, as written. That is an approximation of markdown, made
knowingly: it does not see that a `## ` line inside a code fence is not a
heading, it does not see setext headings, and it does not strip trailing
spaces or closing hashes. A markdown parser would; a markdown parser is the
abstraction step `docs/scope-and-stance.md` leaves unverified. The alternative,
recording §9's only MUST as not carried, was weighed and declined on
2026-10-26: a stated line-based reading loses less than dropping the clause,
and the same question returns at §10. The helpers work on character lists so
that `decide` can evaluate them.

## The MUST: date headings in `YYYY-MM-DD` form

"Form" is read as shape: ten characters, digits in eight positions and hyphens
in two, so `2026-13-45` has the form. Whether §9 also means a valid calendar
date, the text does not say, and the model does not add it.

## The gap: "newest first" carries no keyword

The format "is a flat list of date-grouped entries, newest first", in the
indicative. `Policy.logOrdering` holds the choice, and it is the field
`docs/scope-and-stance.md` sketched before any Lean existed. The strict
reading is non-increasing order, compared as strings, which is chronological
order whenever the MUST holds; it admits a repeated date, where "date-grouped"
might mean one heading per date. That is a pick inside the strict reading,
recorded here and not given a field. `docs/findings.md`, 2026-10-26, "§9 says
newest first without force".

## §11.3 gives §9 force, and moves the gap

§11.3 makes conformance depend on every `log.md` following "the structure in
§9". The date-form MUST was a condition already; "newest first" now has force
from §11.3 if order counts as structure, and the gap `Policy.logOrdering`
represents moves from "no keyword" to "is order structure". Same two readings,
same field. The title and bullet shape §11.3 arguably binds are not modelled.

## Log frontmatter is unaddressed

§8 says index files contain no frontmatter. §9 says nothing about `log.md`
frontmatter at all. The asymmetry is noted here and not logged: the question
for upstream is thin, and §3.1's MUST NOT covers a concept-shaped `log.md` by
the same argument `Okf.V0_2.Index` makes for `index.md`.

## What else is not modelled

The `# Directory Update Log` title and the bullet shape of entries are
indicative. The bold leading word is "a convention, not a requirement" by the
text's own words. The MAY on placement is permission. §9's `YYYY-MM-DD` was
untouched by the timestamp change the first `docs/findings.md` entry records.
-/

namespace Okf.V0_2

/-- Split a character list at newlines. -/
def splitLines : List Char → List (List Char)
  | [] => [[]]
  | '\n' :: rest => [] :: splitLines rest
  | c :: rest =>
    match splitLines rest with
    | [] => [[c]]
    | line :: lines => (c :: line) :: lines

/-- The text after `## ` on each line that begins with it: the line-based
reading of §9's "date headings" the module docstring describes. -/
def Body.dateHeadings (b : Body) : List String :=
  (splitLines b.toList).filterMap fun line =>
    if "## ".toList.isPrefixOf line then some (String.mk (line.drop 3)) else none

/-- §9's `YYYY-MM-DD` form, as shape. -/
def isIsoDate (s : String) : Bool :=
  match s.toList with
  | [y₁, y₂, y₃, y₄, '-', m₁, m₂, '-', d₁, d₂] =>
    [y₁, y₂, y₃, y₄, m₁, m₂, d₁, d₂].all Char.isDigit
  | _ => false

/-- §9: "Date headings MUST use ISO 8601 `YYYY-MM-DD` form". -/
def Document.logDatesIso (d : Document) : Bool :=
  d.body.dateHeadings.all isIsoDate

/-- The fourth clause: every log's date headings have the form. -/
def Bundle.logDatesIso (b : Bundle) : Bool :=
  b.logs.all fun e => e.2.logDatesIso

/-- The `Prop` reading of `Bundle.logDatesIso`. -/
def Bundle.LogDatesIso (b : Bundle) : Prop :=
  ∀ e ∈ b.logs, e.2.logDatesIso = true

theorem Bundle.logDatesIso_iff (b : Bundle) :
    b.logDatesIso = true ↔ b.LogDatesIso := by
  simp [Bundle.logDatesIso, Bundle.LogDatesIso]

/-- Each element is no greater than the one before it. -/
def isNonIncreasing : List String → Bool
  | a :: b :: rest => if a < b then false else isNonIncreasing (b :: rest)
  | _ => true

/-- The strict reading of "newest first": date headings in non-increasing
order. Whether it binds is `Policy.logOrdering`. -/
def Document.logNewestFirst (d : Document) : Bool :=
  isNonIncreasing d.body.dateHeadings

/-- The strict reading over the bundle's logs. -/
def Bundle.logNewestFirst (b : Bundle) : Bool :=
  b.logs.all fun e => e.2.logNewestFirst

/-- The `Prop` reading of `Bundle.logNewestFirst`. -/
def Bundle.LogNewestFirst (b : Bundle) : Prop :=
  ∀ e ∈ b.logs, e.2.logNewestFirst = true

theorem Bundle.logNewestFirst_iff (b : Bundle) :
    b.logNewestFirst = true ↔ b.LogNewestFirst := by
  simp [Bundle.logNewestFirst, Bundle.LogNewestFirst]

end Okf.V0_2
