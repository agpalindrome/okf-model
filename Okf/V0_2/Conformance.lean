import Okf.V0_2.Structure
import Okf.V0_2.Document
import Okf.V0_2.Policy

/-!
# Conformance — the clauses assembled

`conformant p b` is the conjunction of every clause modelled so far, with each
`Policy` field choosing between the readings of the gap it names. It is
assembled here, apart from the clause modules, so that a section adds its
clause in its own module and this one grows by a line.

Two kinds of theorem live beside it. The spec's own examples, encoded as
values, conform under every policy: a model that rejected the text's own
examples would be reading something the text did not write. And for each
`Policy` field, `Gaps` holds the separation theorem: a bundle on which the two
values of the field disagree, so the gap is observable and not a field with no
effect.

## Where the witnesses come from

§4.3 and §4.4 give two frontmatters and two bodies but no paths, so the paths
below are invented from the links the examples make: §4.4 links "the orders
table" at `/tables/orders.md`, which fits §4.3's `Customer Orders`; nothing
names §4.4's own path. §4.1 states its third witness in prose: "a concept
carrying just `type` is fully conformant".

The separating bundle for `fieldTypes` is invented. Every example in §4 is
well-typed, so the text offers no concept with a scalar `tags`.
-/

namespace Okf.V0_2

/-- A bundle conforms under policy `p`. -/
def conformant (p : Policy) (b : Bundle) : Bool :=
  b.noReservedConcepts
    && b.allHaveType
    && (match p.fieldTypes with
        | .required => b.statedTypesHold
        | .convention => true)

/-- The `Prop` reading of `conformant`. -/
def Conformant (p : Policy) (b : Bundle) : Prop :=
  b.NoReservedConcepts ∧ b.AllHaveType ∧ (p.fieldTypes = .required → b.StatedTypesHold)

theorem conformant_iff (p : Policy) (b : Bundle) :
    conformant p b = true ↔ Conformant p b := by
  obtain ⟨ft⟩ := p
  cases ft <;>
    simp [conformant, Conformant, ← Bundle.noReservedConcepts_iff,
      ← Bundle.allHaveType_iff, ← Bundle.statedTypesHold_iff, and_assoc]

/-- A one-key frontmatter, for the witnesses below. -/
private def fm1 (k : String) (v : Value) : Frontmatter := ⟨[(k, v)], by simp⟩

/-- §4.3's frontmatter, as written. `generated` is a §5 family and is held as
an extension key until §5 is read. -/
def customerOrdersFrontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "BigQuery Table"),
     ("title", .scalar "Customer Orders"),
     ("description", .scalar "One row per completed customer order across all channels."),
     ("resource", .scalar "https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders"),
     ("tags", .seq [.scalar "sales", .scalar "orders", .scalar "revenue"]),
     ("generated", .map [("by", .scalar "reference_agent/gemini-2.5-pro"),
                         ("at", .scalar "2026-05-28T14:30:00Z")]) ],
   by simp⟩

/-- §4.3's body, as written. -/
def customerOrdersBody : Body :=
  "# Schema\n\n" ++
  "| Column        | Type      | Description                              |\n" ++
  "|---------------|-----------|------------------------------------------|\n" ++
  "| `order_id`    | STRING    | Globally unique order identifier.        |\n" ++
  "| `customer_id` | STRING    | Foreign key into [customers](/tables/customers.md). |\n" ++
  "| `total_usd`   | NUMERIC   | Order total in US dollars.               |\n" ++
  "| `placed_at`   | TIMESTAMP | When the customer submitted the order.   |\n\n" ++
  "# Joins\n\n" ++
  "Joined with [customers](/tables/customers.md) on `customer_id`.\n"

/-- §4.4's frontmatter, as written. -/
def freshnessPlaybookFrontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "Playbook"),
     ("title", .scalar "Incident response: data freshness alert"),
     ("description", .scalar "Steps to triage a freshness alert on the orders pipeline."),
     ("tags", .seq [.scalar "oncall", .scalar "incident"]),
     ("generated", .map [("by", .scalar "human:ahormati"),
                         ("at", .scalar "2026-04-12T09:00:00Z")]) ],
   by simp⟩

/-- §4.4's body, as written. -/
def freshnessPlaybookBody : Body :=
  "# Trigger\n\n" ++
  "A freshness alert fires when `orders` lags more than 30 minutes behind its\n" ++
  "expected SLA. See the [orders table](/tables/orders.md).\n\n" ++
  "# Steps\n\n" ++
  "1. Check the [ingestion job dashboard](https://example.com/dash).\n" ++
  "2. ...\n"

/-- The two §4 examples as one bundle, at the invented paths the module
docstring explains. -/
def section4Examples : Bundle :=
  ⟨[ (["tables", "orders.md"], ⟨customerOrdersFrontmatter, customerOrdersBody⟩),
     (["playbooks", "freshness-alert.md"], ⟨freshnessPlaybookFrontmatter, freshnessPlaybookBody⟩) ],
   by simp⟩

/-- §4.1's prose theorem: a concept carrying just `type`. -/
def typeOnly : Bundle :=
  ⟨[(["concept.md"], ⟨fm1 "type" (.scalar "Reference"), ""⟩)], by simp⟩

/-- §4.3 and §4.4 conform, whatever the policy. -/
theorem section4Examples_conformant (p : Policy) : conformant p section4Examples = true := by
  obtain ⟨ft⟩ := p
  cases ft <;> decide

/-- §4.1: "a concept carrying just `type` is fully conformant". -/
theorem typeOnly_conformant (p : Policy) : conformant p typeOnly = true := by
  obtain ⟨ft⟩ := p
  cases ft <;> decide

namespace Gaps

/-- A concept whose `tags` is a scalar where §4.1 describes a list. -/
def scalarTags : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"), ("tags", .scalar "sales")], by simp⟩, ""⟩)],
   by simp⟩

/-- §4.1 states value types for its keys with no RFC 2119 keyword attached.
`scalarTags` conforms if they are conventions and not if they bind, so
`Policy.fieldTypes` is a choice the spec left open and the model does not make.
Finding: `docs/findings.md`, 2026-10-26, "§4.1 states value types without
saying whether they bind". -/
theorem fieldTypes_separates :
    conformant ⟨.required⟩ scalarTags ≠ conformant ⟨.convention⟩ scalarTags := by
  decide

end Gaps

end Okf.V0_2
