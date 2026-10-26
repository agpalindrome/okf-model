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

## Where okf-graph was not at its own point

Five behaviours of 0.8.0 were not readings of the text and did not enter the
record; `conformant okfGraphPolicy` judged each the other way, and the theorems
below witness the difference on a bundle. Three were `Defect`s on bundles the
model accepts: a scheme with a character outside ASCII letters, digits, `_` and
`-`; a `human:` prefix in another case; and an actor with both separators,
which okf-graph split at the slash first and the model at either. Two were
acceptances of bundles the model rejects: a `Computation` heading at a level
other than one, and a heading behind leading whitespace. Filed as
okf-tools#147 (2026-10-26) and taken in okf-tools#148 (squash `3623e16`; its
branch head `e6d6f1b` is not in that history): the character set and the
slash-first split are dropped, since no text stood behind them even as
reports; a miscased `human:` is CONCEPT-17, a `Report`; and the heading
matcher is level one only, read as CommonMark reads an ATX heading. The
witnesses stay as the record of what the point says.

One witness was wrong by three spaces. The filing put one space before
`# Computation` and called the model's rejection a reading of §10.3. CommonMark
reads up to three spaces as the same heading, and the model's exact-line match
is an approximation, which `Okf.V0_2.Computation` now says. The witness stands
at four spaces, which CommonMark makes a code block, so no dialect reads it as
a heading.

A sixth difference came back in the same reply. okf-graph 0.8.0 ended the
section at the next heading of any level and the model at the next level-one
heading, so a subheading inside the section was CONCEPT-11 there and conformant
here. Markdown defines no section structure, so `Okf.V0_2.Computation` records
the model's extent as a pick, and `levelTwoSubheading` witnesses it. okf-graph
took the model's extent in okf-tools#149 (`12dda79`), so the witness now draws
nothing there either.

okf-graph 0.9.0 (okf-tools#150, `b8324ed`, on crates.io 2026-10-26) is the
first release carrying okf-tools#148 and okf-tools#149, so the first release at
its own point on every witness here. Each witness names 0.8.0 as the version it
was read against, and 0.9.0 as where it was taken.
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

/-! ## Where okf-graph was not at its own point

Each bundle below is one okf-graph 0.8.0 was read to judge the other way. -/

/-- A concept generated by `Human:ahormati`: a `<scheme>:<id>` whose scheme is
a miscased `human`. okf-graph 0.8.0: CONCEPT-5, a `Defect` (`bundle.rs:930`);
CONCEPT-17, a `Report`, from okf-tools#148. -/
def miscasedHumanActor : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"),
        ("generated", .map [("by", .scalar "Human:ahormati")])], by simp⟩, ""⟩)],
   by simp⟩

/-- A concept generated by `a.b:x`: a scheme with a `.`. okf-graph 0.8.0:
CONCEPT-5, a `Defect` (`bundle.rs:996`); dropped in okf-tools#148. -/
def dottedSchemeActor : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"),
        ("generated", .map [("by", .scalar "a.b:x")])], by simp⟩, ""⟩)],
   by simp⟩

/-- A concept generated by `team:x/`: a `<scheme>:<id>` whose id ends in a
slash. okf-graph 0.8.0 split at the slash first and found an empty version:
CONCEPT-5, a `Defect` (`bundle.rs:996`); dropped in okf-tools#148. -/
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
okf-graph 0.8.0 accepted a heading at any level (`concept.rs:547`); level one
only from okf-tools#148. -/
def levelTwoComputation : Bundle :=
  ⟨[(["c.md"],
     ⟨⟨[("type", .scalar "Attested Computation"), ("runtime", .scalar "bigquery")], by simp⟩,
      "## Computation\n\n    SELECT 1\n"⟩)],
   by simp⟩

/-- The same behind four spaces, which CommonMark makes an indented code block
and no dialect reads as a heading. okf-graph 0.8.0 trimmed any leading
whitespace; from okf-tools#148 one to three spaces stay the heading there, the
case the model's exact-line match takes no side on. -/
def indentedHeadingComputation : Bundle :=
  ⟨[(["c.md"],
     ⟨⟨[("type", .scalar "Attested Computation"), ("runtime", .scalar "bigquery")], by simp⟩,
      "    # Computation\n\n    SELECT 1\n"⟩)],
   by simp⟩

/-- §10.3 says `# Computation`, so neither provides its computation either way
and both fail at okf-graph's own point. -/
theorem headingAcceptances_rejected_okfGraph :
    conformant okfGraphPolicy levelTwoComputation = false
      ∧ conformant okfGraphPolicy indentedHeadingComputation = false := by
  decide

/-- A `## Notes` subheading inside the `# Computation` section, with the block
below it. The model's section runs to the next level-one heading, so the block
is inside. okf-graph 0.8.0 ended the section at any heading and found it empty,
CONCEPT-11 (`has_empty_computation_section`, `concept.rs`); from okf-tools#149
it runs to the next level-one heading too. -/
def levelTwoSubheading : Bundle :=
  ⟨[(["c.md"],
     ⟨⟨[("type", .scalar "Attested Computation"), ("runtime", .scalar "bigquery")], by simp⟩,
      "# Computation\n\n## Notes\n\n    SELECT 1\n"⟩)],
   by simp⟩

/-- The subheading stays inside the section, so the bundle conforms at
okf-graph's own point. -/
theorem subheadingSection_conformant_okfGraph :
    conformant okfGraphPolicy levelTwoSubheading = true := by
  decide

end Okf.V0_2
