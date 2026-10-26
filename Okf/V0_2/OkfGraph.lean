import Okf.V0_2.AppendixA

/-!
# okf-graph's point of the record

okf-graph is based on this model: its conformance predicate is `conformant` at
one point of `Policy`, and this module names the point. The values were read
from okf-graph 0.8.0 at okf-tools `d9006dd` and reported on okf-tools#145
(2026-10-26), each with the file and line it was read from; the citations below
are those. Nothing here verifies the Rust. The record is the claim, and the
theorems say what the model does at that point, which a test on okf-graph's
side can then be held against.

## The mapping

okf-graph gives a rule one of three outcomes: silent, a `Report`, which prints
and passes the bundle, and a `Defect`, which fails it. A `Force` asks whether a
clause binds conformance, so `Defect` is `required` and both `Report` and
silent are `convention`. Which rules are which is `Rule::severity` in
`crates/okf-graph/src/finding.rs`. A consumer may promote a `Report` with
`--deny`; this is the default run.

## Where the record grew to hold the point

Four fields could not express okf-graph's reading as the record stood after the
first pass, and the text supported each reading, so the record grew rather than
the reading being forced onto a neighbour: `statusEnum` and `familyShapes` out
of `fieldTypes`, `byOnly` in `verifiedEntryKeys`, `anySection` in
`inlineComp`, and non-empty placeholders in `actorForm`'s constraining values.
Each module's docstring carries the argument from the text.

## Where okf-graph is not at its own point

Five behaviours are not readings of the text and did not enter the record. In
each, okf-graph differs from `conformant okfGraphPolicy`, and the theorems
below witness the difference on a bundle. Three are `Defect`s on bundles the
model accepts: a scheme with a character outside ASCII letters, digits, `_` and
`-`; a `human:` prefix in another case; and an actor with both separators,
which okf-graph splits at the slash first and the model at either. Two are
acceptances of bundles the model rejects: a `Computation` heading at a level
other than one, and a heading with leading whitespace. The first three are
okf-graph's to demote to `Report`; the last two are its to tighten. Both lists
are okf-tools' to act on, and this module only states them.
-/

namespace Okf.V0_2

/-- okf-graph 0.8.0's reading of each field, from okf-tools#145.

- `fieldTypes := .convention`: `parameters` shape is CONCEPT-9, a `Report`
  (`bundle.rs:828`); an unknown `okf_version` is INDEX-3, a `Report`; `tags`,
  `title` and `description` shapes are silent (`concept.rs:125`).
- `familyShapes := .required`: a `sources` that is not a list of mappings is
  CONCEPT-6 (`bundle.rs:725`), a `verified` that is not is CONCEPT-16
  (`bundle.rs:667`), a `generated` that is not a mapping is CONCEPT-4
  (`bundle.rs:648`), all `Defect`.
- `statusEnum := .required`: CONCEPT-3, a `Defect` (`bundle.rs:633`).
- `verifiedEntryKeys := .byOnly`: no `by` is CONCEPT-16, a `Defect`
  (`bundle.rs:678`); `at` is checked for form only when present
  (`bundle.rs:692`).
- `actorForm := .schemeOrSlash`: `is_actor` (`bundle.rs:996`).
- `actorFields := .withAuthor`: `sources[].author` goes through the same
  `actor_finding` (`bundle.rs:747`).
- `indexFrontmatter := .required`: INDEX-1, a `Defect` (`bundle.rs:408`,
  `index.rs:29`).
- `logOrdering := .convention`: LOG-2, a `Report` (`bundle.rs:458`).
- `contractFields := .convention`: absent `executor` and `attester` are silent;
  CONCEPT-10 fires on one present and incomplete, a `Report` (`bundle.rs:858`).
- `inlineComp := .anySection`: `has_computation_section` keys on the heading
  (`concept.rs:547`); both and neither are CONCEPT-8, an empty section
  CONCEPT-11, all `Defect` (`bundle.rs:800`, `bundle.rs:816`).
- `footnoteLabels := .convention`: the link scanner skips `[^id]:` and nothing
  joins it (`links.rs:251`).
- `familyClauses := .required`: CONCEPT-4, CONCEPT-6 and CONCEPT-7, all
  `Defect` (`bundle.rs:648`, `bundle.rs:734`, `bundle.rs:778`).
- `typeScope := .conceptsOnly`: CONCEPT-2 runs over concepts (`bundle.rs:623`),
  and the root `index.md` goes to `index::check_frontmatter` (`index.rs:29`). -/
def okfGraphPolicy : Policy :=
  { fieldTypes := .convention
    familyShapes := .required
    statusEnum := .required
    verifiedEntryKeys := .byOnly
    actorForm := .schemeOrSlash
    actorFields := .withAuthor
    indexFrontmatter := .required
    logOrdering := .convention
    contractFields := .convention
    inlineComp := .anySection
    footnoteLabels := .convention
    familyClauses := .required
    typeScope := .conceptsOnly }

/-! ## What the point accepts -/

/-- Appendix A conforms at okf-graph's point. okf-tools#146 measured okf-graph
accepting the appendix as written, with no defect, and this is the model
agreeing from the other side. -/
theorem appendixA_conformant_okfGraph : conformant okfGraphPolicy appendixA = true :=
  appendixA_conformant okfGraphPolicy (by decide) (by decide)

/-- The spec's own examples, at the same point. -/
theorem specExamples_conformant_okfGraph :
    conformant okfGraphPolicy section4Examples = true
      ∧ conformant okfGraphPolicy typeOnly = true
      ∧ conformant okfGraphPolicy section5Examples = true
      ∧ conformant okfGraphPolicy section9Log = true
      ∧ conformant okfGraphPolicy section10Examples = true
      ∧ conformant okfGraphPolicy Gaps.rootIndexWithVersion = true :=
  ⟨section4Examples_conformant _, typeOnly_conformant _,
    section5Examples_conformant _ (by decide), section9Log_conformant _,
    section10Examples_conformant _ (by decide), rootIndexWithVersion_conformant _ rfl⟩

/-- The three readings that grew the record, each at the point: a `verified`
event with `by` and no `at` passes, a fourth `status` fails, a scalar `sources`
fails, a prose `# Computation` section passes. -/
theorem grownReadings_at_okfGraph :
    conformant okfGraphPolicy Gaps.verifiedWithoutAt = true
      ∧ conformant okfGraphPolicy Gaps.verifiedWithoutBy = false
      ∧ conformant okfGraphPolicy Gaps.unknownStatus = false
      ∧ conformant okfGraphPolicy Gaps.scalarSources = false
      ∧ conformant okfGraphPolicy Gaps.proseComputation = true := by
  decide

/-! ## Where okf-graph is not at its own point

Each bundle below is one okf-graph was read to judge the other way. -/

/-- A concept generated by `Human:ahormati`: a `<scheme>:<id>` whose scheme is
a miscased `human`. okf-graph: CONCEPT-5, a `Defect` (`bundle.rs:930`). -/
def miscasedHumanActor : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"),
        ("generated", .map [("by", .scalar "Human:ahormati")])], by simp⟩, ""⟩)],
   by simp⟩

/-- A concept generated by `a.b:x`: a scheme with a `.`. okf-graph: CONCEPT-5, a
`Defect` (`bundle.rs:996`). -/
def dottedSchemeActor : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"),
        ("generated", .map [("by", .scalar "a.b:x")])], by simp⟩, ""⟩)],
   by simp⟩

/-- A concept generated by `team:x/`: a `<scheme>:<id>` whose id ends in a
slash. okf-graph splits at the slash first and finds an empty version:
CONCEPT-5, a `Defect` (`bundle.rs:996`). -/
def trailingSlashActor : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"),
        ("generated", .map [("by", .scalar "team:x/")])], by simp⟩, ""⟩)],
   by simp⟩

/-- §7 names no character set for a scheme and §5.3 makes a miscased prefix a
non-`human:` actor, so all three conform at okf-graph's own point. -/
theorem actorDefects_conformant_okfGraph :
    conformant okfGraphPolicy miscasedHumanActor = true
      ∧ conformant okfGraphPolicy dottedSchemeActor = true
      ∧ conformant okfGraphPolicy trailingSlashActor = true := by
  decide

/-- An Attested Computation whose computation sits under `## Computation`.
okf-graph accepts a heading at any level (`concept.rs:547`). -/
def levelTwoComputation : Bundle :=
  ⟨[(["c.md"],
     ⟨⟨[("type", .scalar "Attested Computation"), ("runtime", .scalar "bigquery")], by simp⟩,
      "## Computation\n\n    SELECT 1\n"⟩)],
   by simp⟩

/-- The same under ` # Computation`, with a leading space. okf-graph trims it. -/
def indentedHeadingComputation : Bundle :=
  ⟨[(["c.md"],
     ⟨⟨[("type", .scalar "Attested Computation"), ("runtime", .scalar "bigquery")], by simp⟩,
      " # Computation\n\n    SELECT 1\n"⟩)],
   by simp⟩

/-- §10.3 says `# Computation`, so neither provides its computation either way
and both fail at okf-graph's own point. -/
theorem headingAcceptances_rejected_okfGraph :
    conformant okfGraphPolicy levelTwoComputation = false
      ∧ conformant okfGraphPolicy indentedHeadingComputation = false := by
  decide

end Okf.V0_2
