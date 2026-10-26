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

/-- The spec's open choices, as of §4. -/
structure Policy where
  /-- §4.1 describes value types for its five named keys with no keyword
  attached (`docs/findings.md`, 2026-10-26). Whether a concept violating one is
  non-conformant. -/
  fieldTypes : Force
  deriving DecidableEq, Repr

end Okf.V0_2
