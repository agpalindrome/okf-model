import Okf.V0_2.Document
import Okf.V0_2.Policy

/-!
# §5 Provenance, trust, and lifecycle — two conditional clauses and a gap

§5 is where keys become required under a condition: `resource` within a
`sources` entry, `by` within `generated`. It also marks nothing within a
`verified` event, which §5.3 then computes on. Three families of frontmatter,
two clauses, one new `Policy` field, and the existing `fieldTypes` field
widened to §5's shapes.

Both clauses are gated. §11 defines conformance by three conditions, neither
of these among them, and says producers "SHOULD follow §5 through §10"; under
§11 these REQUIREDs are guidance. `Policy.familyClauses` holds the choice, and
`Okf.V0_2.Conformance` says more.

## Entries of a value that is not what §5 describes

Both clauses quantify over entries: of `sources`, and of `verified`. When the
key holds something with no entries, a scalar say, the clause has nothing to
check and passes vacuously. The first pass sent the value's shape to
`Policy.fieldTypes` and recorded the other reading, a shapeless value failing
the REQUIRED clause, as a pick not taken. okf-graph takes it, for `sources`,
`generated` and `verified`, while holding the leaf shapes inside them as
conventions (okf-tools#145), and the clauses' own wording, "within an entry",
"within `generated`", presupposes a carrier of the described kind. So the
reading is a field, `Policy.familyShapes`, with `Frontmatter.familyShapesHold`
its strict side: `sources` a list of mappings, `generated` a mapping,
`verified` a list of mappings or one. An entry that is not a mapping has no
keys, so it fails the REQUIRED clause under either reading of the carrier.

§5.2's MAY lets a single verifier be written as a bare mapping, so
`Value.verifiedEvents` counts a mapping as one event.

## The gap: `verified` events have no REQUIRED

`generated.by` is "REQUIRED within `generated`". A `verified` event is "each
with `by` (an actor) and `at` (an ISO 8601 datetime)", with nothing marked, and
§5.3 derives the trust tier from `by`. So `verified: [{ at: … }]` conforms on
the text and has no tier. `Policy.verifiedEntryKeys` is the choice; it is
separate from `fieldTypes` because a reader can hold value descriptions as
conventions and still treat `by` as required, since §5.3 computes on it. The
same argument separates `by` from `at`: nothing computes on `at`, so a reader
can bind the one key and not the other, and okf-graph does (okf-tools#145).
Hence three values, `VerifiedKeys.holds` carrying each.
`docs/findings.md`, 2026-10-26, "§5.2 marks nothing within a `verified` event".

## Shapes stated without force, again

§5 describes `sources` as a list of mappings with scalar fields,
`usage_window` and `generated` as mappings, `verified` as a list of mappings or
one bare mapping, `status` as one of `draft`, `stable`, `deprecated`, and every
timestamp as a datetime. No keyword attaches. `Frontmatter.provenanceTypesHold`
is the whole-description reading, under the same `fieldTypes` field as §4.1,
the same editorial habit. Two narrower readings sit beside it since
okf-tools#145. The `status` enumeration is `Policy.statusEnum`, through
`Frontmatter.statusValid`: §5.4's default and its three definitions compute on
the value, which is the ground `verifiedEntryKeys` already stands on. The
carriers' kinds are `Policy.familyShapes`, above. The strict `fieldTypes`
reading still covers the carriers, so it implies the narrower field; the
separations in `Okf.V0_2.Gaps` hold each with the others waived. ISO 8601
syntax, the "explicit UTC offset" the §5 preamble asks for, and URI syntax are
not checked: all three are parse work below the trust boundary, and a scalar
reaches the model as its text.

## Derived values, listed and not modelled

Three things §5 defines are functions a consumer computes from frontmatter:
the trust tier (§5.3: no `verified` is unverified, non-`human:` actors only is
machine-confirmed, any `human:` actor is human-reviewed), the `status` default
(§5.4: absent is `stable`), and staleness (§5.5: `now >= stale_after`).
`docs/scope-and-stance.md` puts §5.3 tier ownership out of scope by name; the
other two are the same kind of thing, and the third depends on the clock. None
is a clause and none is defined here. The tier is a pure function the text
defines fully, so this is a decision, recorded, not an impossibility.

## The footnote join, modelled at §10

§5.1 attributes a claim with a markdown footnote whose label is a
`sources[].id`, and says `id` SHOULD be present when the body cites the source.
Both need a `Body` that can be read. §6 did not force one; §9 set a line-based
precedent; §10.2's example demonstrates the join. It is modelled in
`Okf.V0_2.Footnotes` under `Policy.footnoteLabels`.

## What §5 binds consumers to

Consumers SHOULD read `usage_count` as liveness and trend, MAY recurse into a
source that is itself a concept, MUST treat a bare `verified` mapping as a
one-element list, MUST NOT reject a concept with no trust frontmatter, derive
tiers, and apply the `status` default. As in §4, listed and not modelled.

## `author: team:ga4-docs`, read at §7

§5.1's example writes an actor in none of the three conventions §2 names.
Nothing here reads `author`; `Okf.V0_2.Actors` does, and that example became
the witness from the text for two §7 gaps, with Appendix A repeating it twice.
-/

namespace Okf.V0_2

/-- The value under `key` in a mapping node. A node that is not a mapping has
no keys. -/
def Value.get? : Value → String → Option Value
  | .map entries, key => entries.lookup key
  | _, _ => none

/-- Whether a mapping node carries `key`. -/
def Value.hasKey (v : Value) (key : String) : Bool :=
  (v.get? key).isSome

/-- `Frontmatter.keyHolds`, for a mapping node. -/
def Value.keyHolds (v : Value) (key : String) (ok : Value → Bool) : Bool :=
  match v.get? key with
  | some w => ok w
  | none => true

/-- The entries of a sequence; anything else has none. The module docstring
says why that is the reading. -/
def Value.items : Value → List Value
  | .seq items => items
  | _ => []

/-- The events under `verified`: the items of a sequence, or the one bare
mapping §5.2's MAY permits. -/
def Value.verifiedEvents : Value → List Value
  | .seq items => items
  | v@(.map _) => [v]
  | _ => []

/-- §5.1: `resource` is "REQUIRED within an entry" of `sources`. -/
def Frontmatter.sourcesHaveResource (f : Frontmatter) : Bool :=
  f.keyHolds "sources" fun v => v.items.all fun e => e.hasKey "resource"

/-- §5.1's clause: every `sources` entry in the bundle carries `resource`.
Gated by `Policy.familyClauses`. -/
def Bundle.sourcesHaveResource (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.sourcesHaveResource

/-- The `Prop` reading of `Bundle.sourcesHaveResource`. -/
def Bundle.SourcesHaveResource (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.sourcesHaveResource = true

theorem Bundle.sourcesHaveResource_iff (b : Bundle) :
    b.sourcesHaveResource = true ↔ b.SourcesHaveResource := by
  simp [Bundle.sourcesHaveResource, Bundle.SourcesHaveResource]

/-- §5.2: `generated.by` is "REQUIRED within `generated`". -/
def Frontmatter.generatedHasBy (f : Frontmatter) : Bool :=
  f.keyHolds "generated" fun v => v.hasKey "by"

/-- §5.2's clause: every `generated` in the bundle carries `by`. Gated by
`Policy.familyClauses`. -/
def Bundle.generatedHasBy (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.generatedHasBy

/-- The `Prop` reading of `Bundle.generatedHasBy`. -/
def Bundle.GeneratedHasBy (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.generatedHasBy = true

theorem Bundle.generatedHasBy_iff (b : Bundle) :
    b.generatedHasBy = true ↔ b.GeneratedHasBy := by
  simp [Bundle.generatedHasBy, Bundle.GeneratedHasBy]

/-- Which keys reading `k` asks of one `verified` event. -/
def VerifiedKeys.holds : VerifiedKeys → Value → Bool
  | .byAndAt, e => e.hasKey "by" && e.hasKey "at"
  | .byOnly, e => e.hasKey "by"
  | .convention, _ => true

/-- §5.2's "each with `by` and `at`" under reading `k`, over every `verified`
event. -/
def Frontmatter.verifiedEntriesKeyed (f : Frontmatter) (k : VerifiedKeys) : Bool :=
  f.keyHolds "verified" fun v => v.verifiedEvents.all k.holds

/-- The reading over a whole bundle. -/
def Bundle.verifiedEntriesKeyed (b : Bundle) (k : VerifiedKeys) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.verifiedEntriesKeyed k

/-- The `Prop` reading of `Bundle.verifiedEntriesKeyed`. -/
def Bundle.VerifiedEntriesKeyed (b : Bundle) (k : VerifiedKeys) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.verifiedEntriesKeyed k = true

theorem Bundle.verifiedEntriesKeyed_iff (b : Bundle) (k : VerifiedKeys) :
    b.verifiedEntriesKeyed k = true ↔ b.VerifiedEntriesKeyed k := by
  simp [Bundle.verifiedEntriesKeyed, Bundle.VerifiedEntriesKeyed]

/-- The description reading asks nothing, as `Force.gate_true` says of a waived
`Force`. -/
@[simp] theorem VerifiedKeys.holds_convention (e : Value) :
    VerifiedKeys.convention.holds e = true := rfl

@[simp] theorem Frontmatter.verifiedEntriesKeyed_convention (f : Frontmatter) :
    f.verifiedEntriesKeyed .convention = true := by
  simp only [Frontmatter.verifiedEntriesKeyed, Frontmatter.keyHolds]
  split <;> simp

@[simp] theorem Bundle.verifiedEntriesKeyed_convention (b : Bundle) :
    b.verifiedEntriesKeyed .convention = true := by
  simp [Bundle.verifiedEntriesKeyed]

/-- A mapping node. -/
def Value.isMap : Value → Bool
  | .map _ => true
  | _ => false

/-- A sequence whose items are all mappings: a family's "list of entries". -/
def Value.isSeqOfMaps : Value → Bool
  | .seq items => items.all Value.isMap
  | _ => false

/-- The strict reading of `Policy.familyShapes`: each §5 family's carrier is
the kind its clause presupposes. -/
def Frontmatter.familyShapesHold (f : Frontmatter) : Bool :=
  f.keyHolds "sources" Value.isSeqOfMaps
    && f.keyHolds "generated" Value.isMap
    && f.keyHolds "verified" fun v => v.isSeqOfMaps || v.isMap

/-- The strict reading over a whole bundle. -/
def Bundle.familyShapesHold (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.familyShapesHold

/-- The `Prop` reading of `Bundle.familyShapesHold`. -/
def Bundle.FamilyShapesHold (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.familyShapesHold = true

theorem Bundle.familyShapesHold_iff (b : Bundle) :
    b.familyShapesHold = true ↔ b.FamilyShapesHold := by
  simp [Bundle.familyShapesHold, Bundle.FamilyShapesHold]

/-- §5.1's `usage_window`: a mapping with scalar `from` and `to`. -/
def Value.isUsageWindow (v : Value) : Bool :=
  v.isMap && v.keyHolds "from" Value.isScalar && v.keyHolds "to" Value.isScalar

/-- A `sources` entry as §5.1 describes it: a mapping whose named fields are
scalars, with an optional `usage_window` of its own. -/
def Value.isSourceEntry (v : Value) : Bool :=
  v.isMap
    && v.keyHolds "resource" Value.isScalar
    && v.keyHolds "id" Value.isScalar
    && v.keyHolds "title" Value.isScalar
    && v.keyHolds "author" Value.isScalar
    && v.keyHolds "usage_count" Value.isScalar
    && v.keyHolds "last_modified" Value.isScalar
    && v.keyHolds "usage_window" Value.isUsageWindow

/-- A `generated` or `verified` event: a mapping with scalar `by` and `at`. -/
def Value.isEvent (v : Value) : Bool :=
  v.isMap && v.keyHolds "by" Value.isScalar && v.keyHolds "at" Value.isScalar

/-- §5.4's three values. -/
def Value.isStatus : Value → Bool
  | .scalar s => s == "draft" || s == "stable" || s == "deprecated"
  | _ => false

/-- The strict reading of `Policy.statusEnum`: `status`, when present, is one
of the three. -/
def Frontmatter.statusValid (f : Frontmatter) : Bool :=
  f.keyHolds "status" Value.isStatus

/-- The strict reading over a whole bundle. -/
def Bundle.statusValid (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.statusValid

/-- The `Prop` reading of `Bundle.statusValid`. -/
def Bundle.StatusValid (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.statusValid = true

theorem Bundle.statusValid_iff (b : Bundle) :
    b.statusValid = true ↔ b.StatusValid := by
  simp [Bundle.statusValid, Bundle.StatusValid]

/-- The strict reading of §5's shape descriptions, for the keys it names,
`status` apart, which is `Frontmatter.statusValid`. Whether this reading binds
is `Policy.fieldTypes`, shared with §4.1. -/
def Frontmatter.provenanceTypesHold (f : Frontmatter) : Bool :=
  f.keyHolds "sources" (fun v => match v with
      | .seq items => items.all Value.isSourceEntry
      | _ => false)
    && f.keyHolds "usage_window" Value.isUsageWindow
    && f.keyHolds "generated" Value.isEvent
    && f.keyHolds "verified" (fun v => match v with
      | .seq items => items.all Value.isEvent
      | .map _ => v.isEvent
      | _ => false)
    && f.keyHolds "stale_after" Value.isScalar

/-- The strict reading over a whole bundle. -/
def Bundle.provenanceTypesHold (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.provenanceTypesHold

/-- The `Prop` reading of `Bundle.provenanceTypesHold`. -/
def Bundle.ProvenanceTypesHold (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.provenanceTypesHold = true

theorem Bundle.provenanceTypesHold_iff (b : Bundle) :
    b.provenanceTypesHold = true ↔ b.ProvenanceTypesHold := by
  simp [Bundle.provenanceTypesHold, Bundle.ProvenanceTypesHold]

end Okf.V0_2
