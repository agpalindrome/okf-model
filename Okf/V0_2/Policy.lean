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

/-- The readings of §10.3's inline computation. `fencedOnly` is the text, "a
single fenced code block"; `fencedOrIndented` also admits the indented block
§10.2's own example uses; `unconstrained` reads "provide the computation in
one of two ways" as description. -/
inductive InlineCompForm where
  | fencedOnly
  | fencedOrIndented
  | unconstrained
  deriving DecidableEq, Repr

/-- The spec's open choices, as of §10. -/
structure Policy where
  /-- §4.1 describes value types for its five named keys, and §5 describes the
  shapes of its families and the three values of `status`, with no keyword
  attached (`docs/findings.md`, 2026-10-26, two entries). Whether a concept
  violating one is non-conformant. One field for both sections: the same
  editorial habit, and a second field would separate nothing new. -/
  fieldTypes : Force
  /-- §5.2 marks `generated.by` REQUIRED and marks nothing within a `verified`
  event, which §5.3 then computes on (`docs/findings.md`, 2026-10-26). Whether
  an event without `by` and `at` is non-conformant. -/
  verifiedEntryKeys : Force
  /-- §7 lists three actor forms with no keyword attached, and §5.1's own
  example uses a fourth scheme (`docs/findings.md`, 2026-10-26). Which actor
  strings a `by` field, and under `actorFields` an `author`, may hold. -/
  actorForm : ActorForm
  /-- §7 names two fields; §5.1 says `author` is in the convention too
  (`docs/findings.md`, 2026-10-26). Whether `actorForm` reaches `author`. -/
  actorFields : ActorFields
  /-- §8 says "index files contain no frontmatter", excepting `okf_version` at
  the root, with no keyword attached (`docs/findings.md`, 2026-10-26). Whether
  an index file with other frontmatter is non-conformant. -/
  indexFrontmatter : Force
  /-- §9 describes a log as "date-grouped entries, newest first", with the MUST
  on the date form and no keyword on the order (`docs/findings.md`,
  2026-10-26). Whether a log whose date headings are out of order is
  non-conformant. The field `docs/scope-and-stance.md` sketched by name. -/
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
  deriving DecidableEq, Repr

end Okf.V0_2
