import Okf.V0_2.Basic

/-!
# The policy record — one field per gap

`docs/scope-and-stance.md`: conformance is parameterised over a record whose
fields are exactly the spec's open choices, and adding a field is how a gap
enters the model. This module is that record and nothing else, so that the
list of gaps the model represents can be read in one place.

A field is added when a section is read and found to leave something open; it
is never added in advance. Each field's docstring names the section and the
`docs/findings.md` entry, and `Okf.V0_2.Gaps` holds the theorem that the two
values separate.

A field is also added, or widened, when a reader of the text is found to hold
a reading none of the existing values express, provided the text supports it.
`Okf.V0_2.OkfGraph` is the first such reader: okf-graph is based on this model,
so its behaviour has to be a point in this record, and where it was not, the
record grew (okf-tools#145, 2026-10-26). A reading the text does not support
does not enter here; it is okf-graph's to drop.
-/

namespace Okf.V0_2

/-- Whether a constraint the spec states without an RFC 2119 keyword binds.
`required` reads it as a MUST; `convention` reads it as description. -/
inductive Force where
  | required
  | convention
  deriving DecidableEq, Repr

/-- Whether a constraint under a `Force` field counts: `required` checks it,
`convention` waives it. `conformant` is written with this so that a theorem
about every policy needs no case split. -/
def Force.gate : Force → Bool → Bool
  | .required, b => b
  | .convention, _ => true

@[simp] theorem Force.gate_true (f : Force) : f.gate true = true := by
  cases f <;> rfl

theorem Force.gate_eq_true_iff (f : Force) (b : Bool) :
    f.gate b = true ↔ (f = .required → b = true) := by
  cases f <;> simp [Force.gate]

/-- Which keys a `verified` event must carry. `byAndAt` is §5.2's "each with
`by` and `at`" read as binding; `byOnly` binds the key §5.3 computes on and
leaves `at` as description; `convention` binds neither. -/
inductive VerifiedKeys where
  | byAndAt
  | byOnly
  | convention
  deriving DecidableEq, Repr

/-- The readings of §7's actor convention. `threeForms` is the text's list;
`schemeOrSlash` admits any `<scheme>:<id>`, which the spec's own §5.1 example
needs; `unconstrained` reads the convention as description. -/
inductive ActorForm where
  | threeForms
  | schemeOrSlash
  | unconstrained
  deriving DecidableEq, Repr

/-- Which fields §7 reaches. `listedOnly` is §7's own list, `generated.by` and
`verified[].by`; `withAuthor` adds `sources[].author`, which §5.1 says is "in
the actor convention (§7)" and §7 does not name. -/
inductive ActorFields where
  | listedOnly
  | withAuthor
  deriving DecidableEq, Repr

/-- Whether `actorForm` reaches `author`, as a gate. -/
def ActorFields.gate : ActorFields → Bool → Bool
  | .withAuthor, b => b
  | .listedOnly, _ => true

@[simp] theorem ActorFields.gate_true (a : ActorFields) : a.gate true = true := by
  cases a <;> rfl

theorem ActorFields.gate_eq_true_iff (a : ActorFields) (b : Bool) :
    a.gate b = true ↔ (a = .withAuthor → b = true) := by
  cases a <;> simp [ActorFields.gate]

/-- Which frontmatter blocks §11.2's "every frontmatter block contains a
non-empty `type`" reaches. `conceptsOnly` scopes it by §11.1's "non-reserved";
`everyBlock` reads it literally, which rejects §8's root `okf_version`. -/
inductive TypeScope where
  | conceptsOnly
  | everyBlock
  deriving DecidableEq, Repr

/-- The readings of §10.3's inline computation. `fencedOnly` is the text, "a
single fenced code block"; `fencedOrIndented` also admits the indented block
§10.2's own example uses; `anySection` counts a `# Computation` section that
holds anything at all, so "one of two ways" binds and the block's style is
description; `unconstrained` reads the whole sentence as description. -/
inductive InlineCompForm where
  | fencedOnly
  | fencedOrIndented
  | anySection
  | unconstrained
  deriving DecidableEq, Repr

/-- The spec's open choices, after the full text and one reader of it. -/
structure Policy where
  /-- §4.1 describes value types for its five named keys, §5 the shapes of
  its families, §10.2 the shapes of a computation's keys and §12 the version
  string's form, with no keyword attached (`docs/findings.md`, 2026-10-26).
  Whether a value violating any of them is non-conformant. This is the
  whole-description reading; the next two fields are the narrower readings a
  reader can hold apart from it. -/
  fieldTypes : Force
  /-- §5.1's REQUIRED is "within an entry" of `sources`, §5.2's is "within
  `generated`", and `verified` is "a list of verification events" or one bare
  mapping: each clause presupposes a carrier of the described kind. Whether a
  family whose carrier is some other kind fails. The first pass passed it
  vacuously and sent the kind to `fieldTypes`, and recorded that as a pick;
  okf-graph fails it while holding the leaf shapes as conventions
  (okf-tools#145), which the clauses' wording supports, so it is a field. -/
  familyShapes : Force
  /-- §5.4 lists three `status` values with no keyword attached
  (`docs/findings.md`, 2026-10-26). Whether a fourth is non-conformant.
  Separate from `fieldTypes` on the precedent `verifiedEntryKeys` set: §5.4's
  default and its three definitions compute on the value, so a reader can hold
  the shape descriptions as conventions and this enumeration as binding.
  okf-graph is that reader (okf-tools#145). -/
  statusEnum : Force
  /-- §5.2 marks `generated.by` REQUIRED and marks nothing within a `verified`
  event, which §5.3 then computes on (`docs/findings.md`, 2026-10-26). Which of
  `by` and `at` an event must carry. Three-valued because §5.3 computes on `by`
  and nothing computes on `at`, so a reader can bind the one and not the other
  (okf-tools#145). -/
  verifiedEntryKeys : VerifiedKeys
  /-- §7 lists three actor forms with no keyword attached, and §5.1's own
  example uses a fourth scheme (`docs/findings.md`, 2026-10-26). Which actor
  strings a `by` field, and under `actorFields` an `author`, may hold. -/
  actorForm : ActorForm
  /-- §7 names two fields; §5.1 says `author` is in the convention too
  (`docs/findings.md`, 2026-10-26). Whether `actorForm` reaches `author`. -/
  actorFields : ActorFields
  /-- §8 says "index files contain no frontmatter", excepting `okf_version` at
  the root, with no keyword attached; §11.3 binds "the structure in §8"
  (`docs/findings.md`, 2026-10-26). Whether that sentence is structure, so that
  an index file with other frontmatter is non-conformant. -/
  indexFrontmatter : Force
  /-- §9 describes a log as "date-grouped entries, newest first", with the MUST
  on the date form and no keyword on the order; §11.3 binds "the structure in
  §9" (`docs/findings.md`, 2026-10-26). Whether order is structure, so that a
  log whose date headings are out of order is non-conformant. The field
  `docs/scope-and-stance.md` sketched by name. -/
  logOrdering : Force
  /-- §10.2 marks `runtime` REQUIRED and `computation` Optional, and marks
  `executor` and `attester` neither way (`docs/findings.md`, 2026-10-26).
  Whether an Attested Computation without both is non-conformant. -/
  contractFields : Force
  /-- §10.3 says the inline computation is "a single fenced code block" and
  §10.2's example indents it; "provide the computation in one of two ways" has
  no keyword (`docs/findings.md`, 2026-10-26). The second field
  `docs/scope-and-stance.md` sketched by name. -/
  inlineComp : InlineCompForm
  /-- §5.1 says a claim is attributed by a footnote "whose label is a
  `sources[].id`", with no keyword (`docs/findings.md`, 2026-10-26). Whether a
  footnote definition with no matching `id` is non-conformant. -/
  footnoteLabels : Force
  /-- §11 defines conformance by three conditions and says producers "SHOULD
  follow §5 through §10", while §5.1, §5.2 and §10.2 say REQUIRED
  (`docs/findings.md`, 2026-10-26). Whether those REQUIREDs are conformance
  conditions or producer guidance. -/
  familyClauses : Force
  /-- §11.2 says "every frontmatter block"; §8 permits a root `index.md` with
  `okf_version` and no `type`, and §12 calls that root block "the only place
  frontmatter is permitted in an `index.md`" (`docs/findings.md`, 2026-10-26).
  Which blocks §11.2 reaches. -/
  typeScope : TypeScope
  deriving DecidableEq, Repr

end Okf.V0_2
