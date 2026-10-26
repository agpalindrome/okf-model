import Okf.V0_2.Structure

/-!
# §4 Concept documents — the second clause, and the first gap

§4 is where the model's mechanism first gets exercised. It reopens
`Frontmatter` (the revision is in `Okf.V0_2.Basic`), states the second
conformance clause, and states value types for its keys without saying whether
they bind. This module holds the clause and the two readings of those types;
`Okf.V0_2.Policy` holds the field that chooses between them, and
`Okf.V0_2.Conformance` assembles the clauses.

## The clause: `type` is present

§4.1 marks one key REQUIRED, and says in prose that it is "the only
always-required key". The word "always" implies keys required under some
condition, which §4.1 hands to §5 and §10; nothing here presumes their shape.

## The gap: value types stated without force

§4.1 says `type` is "a short string", `tags` "a YAML list of short strings",
`resource` "a URI", `title` and `description` prose. No RFC 2119 keyword
attaches to any of these. A concept with `tags: sales`, a scalar where a list
is described, is conformant if the descriptions are conventions and not if
they are constraints. `docs/findings.md` names this category directly, and the
2026-10-26 entry on §4.1 records this instance.

`Frontmatter.statedTypesHold` is the strict reading, as a predicate. Whether it
counts is `Policy.fieldTypes`, not a choice made here. "Short", "a single
sentence" and URI syntax are not in the predicate: the first two are not
checkable, and the third is parse work below the trust boundary.

## What §4 binds consumers to, and the model does not carry

Five of §4's keywords bind the reader of a bundle rather than the bundle:
consumers MUST tolerate unknown `type` values, MUST NOT reject documents with
unrecognised keys, SHOULD preserve unknown keys when round-tripping, MAY derive
a missing `title` from the filename, and §4.2 says producers SHOULD favour
structural markdown. `docs/scope-and-stance.md` defines conformance over
bundles and says nothing about consumer obligations, so none of these is a
clause. They are listed so that they stay countable; whether a consumer-side
predicate is ever wanted is a question for the stance, not for §4.

## What else is not modelled

UTF-8 and the `---` delimiters are bytes. The four "Recommended" keys are a
heading, not RFC 2119 RECOMMENDED, and §4.1 itself says a concept with only
`type` is fully conformant, so their presence is no clause. §4.2 says there are
no required body sections and its heading conventions are SHOULDs "when
applicable", which is not checkable, so `Body` stays `String`. Footnotes defer
to §5.1. Extensions MAY appear, so an unknown key is nothing to check.
-/

namespace Okf.V0_2

/-- §4.1 REQUIRED: the concept's frontmatter carries a `type` key. Only
presence; what the value is belongs to `Frontmatter.statedTypesHold`. -/
def Document.hasType (d : Document) : Bool :=
  (d.frontmatter.get? "type").isSome

/-- The second clause: every concept in the bundle carries `type`. Over
`Bundle.concepts`: §8's index files have no `type`, and are not concepts. -/
def Bundle.allHaveType (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.hasType

/-- The `Prop` reading of `Bundle.allHaveType`. -/
def Bundle.AllHaveType (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.hasType = true

theorem Bundle.allHaveType_iff (b : Bundle) :
    b.allHaveType = true ↔ b.AllHaveType := by
  simp [Bundle.allHaveType, Bundle.AllHaveType]

/-- A scalar node. -/
def Value.isScalar : Value → Bool
  | .scalar _ => true
  | _ => false

/-- A sequence whose items are all scalars: §4.1's "a YAML list of short
strings". -/
def Value.isSeqOfScalars : Value → Bool
  | .seq items => items.all Value.isScalar
  | _ => false

/-- Whether the value under `key`, if present, satisfies `ok`. An absent key
holds: §4.1 constrains the shape of a value, not whether the key appears. -/
def Frontmatter.keyHolds (f : Frontmatter) (key : String) (ok : Value → Bool) : Bool :=
  match f.get? key with
  | some v => ok v
  | none => true

/-- The strict reading of §4.1's value descriptions, for the five keys it
names: `type`, `title`, `description` and `resource` are scalars, `tags` is a
list of scalars. Whether this reading binds is `Policy.fieldTypes`. -/
def Frontmatter.statedTypesHold (f : Frontmatter) : Bool :=
  f.keyHolds "type" Value.isScalar
    && f.keyHolds "title" Value.isScalar
    && f.keyHolds "description" Value.isScalar
    && f.keyHolds "resource" Value.isScalar
    && f.keyHolds "tags" Value.isSeqOfScalars

/-- The strict reading over a whole bundle. -/
def Bundle.statedTypesHold (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.statedTypesHold

/-- The `Prop` reading of `Bundle.statedTypesHold`. -/
def Bundle.StatedTypesHold (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.statedTypesHold = true

theorem Bundle.statedTypesHold_iff (b : Bundle) :
    b.statedTypesHold = true ↔ b.StatedTypesHold := by
  simp [Bundle.statedTypesHold, Bundle.StatedTypesHold]

end Okf.V0_2
