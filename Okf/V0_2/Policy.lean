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

/-- The spec's open choices, as of §7. -/
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
  deriving DecidableEq, Repr

end Okf.V0_2
