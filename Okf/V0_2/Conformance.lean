import Okf.V0_2.Structure
import Okf.V0_2.Document
import Okf.V0_2.Provenance
import Okf.V0_2.Actors
import Okf.V0_2.Index
import Okf.V0_2.Log
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

§5's snippets are combined into one frontmatter below, with a `type` added
since none of them has one and §4.1 requires it; the second copy writes
`verified` as the bare mapping §5.2's MAY permits.

Most separating bundles are invented. Every example in §4 and §5 is well-typed
and fully keyed, so the text offers no concept with a scalar `tags`, a `status`
outside its three values, or a `verified` event without `by`. The exception is
§7: §5.1's `author: team:ga4-docs` is a fourth actor scheme, so the §5 bundle
itself separates two readings of `actorForm` and both readings of
`actorFields`, and is rejected outright under `threeForms` with `withAuthor`.
That is the scenario `docs/scope-and-stance.md` named before any Lean existed.
-/

namespace Okf.V0_2

/-- A bundle conforms under policy `p`. -/
def conformant (p : Policy) (b : Bundle) : Bool :=
  b.allHaveType
    && b.sourcesHaveResource
    && b.generatedHasBy
    && (match p.fieldTypes with
        | .required => b.statedTypesHold && b.provenanceTypesHold
        | .convention => true)
    && (match p.verifiedEntryKeys with
        | .required => b.verifiedEntriesKeyed
        | .convention => true)
    && b.byActors p.actorForm
    && (match p.actorFields with
        | .withAuthor => b.authorActors p.actorForm
        | .listedOnly => true)
    && (match p.indexFrontmatter with
        | .required => b.indexFrontmatterClean
        | .convention => true)
    && b.logDatesIso
    && (match p.logOrdering with
        | .required => b.logNewestFirst
        | .convention => true)

/-- The `Prop` reading of `conformant`. -/
def Conformant (p : Policy) (b : Bundle) : Prop :=
  b.AllHaveType ∧ b.SourcesHaveResource ∧ b.GeneratedHasBy
    ∧ (p.fieldTypes = .required → b.StatedTypesHold ∧ b.ProvenanceTypesHold)
    ∧ (p.verifiedEntryKeys = .required → b.VerifiedEntriesKeyed)
    ∧ b.ByActors p.actorForm
    ∧ (p.actorFields = .withAuthor → b.AuthorActors p.actorForm)
    ∧ (p.indexFrontmatter = .required → b.IndexFrontmatterClean)
    ∧ b.LogDatesIso
    ∧ (p.logOrdering = .required → b.LogNewestFirst)

theorem conformant_iff (p : Policy) (b : Bundle) :
    conformant p b = true ↔ Conformant p b := by
  obtain ⟨ft, vk, af, afs, ifm, lo⟩ := p
  cases ft <;> cases vk <;> cases af <;> cases afs <;> cases ifm <;> cases lo <;>
    simp [conformant, Conformant, ← Bundle.allHaveType_iff, ← Bundle.sourcesHaveResource_iff,
      ← Bundle.generatedHasBy_iff, ← Bundle.statedTypesHold_iff,
      ← Bundle.provenanceTypesHold_iff, ← Bundle.verifiedEntriesKeyed_iff,
      ← Bundle.byActors_iff, ← Bundle.authorActors_iff,
      ← Bundle.indexFrontmatterClean_iff, ← Bundle.logDatesIso_iff,
      ← Bundle.logNewestFirst_iff, and_assoc]

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

/-- §5.1 and §5.2's events, as written. -/
def ga4Source : Value :=
  .map [ ("id", .scalar "ga4-schema"),
         ("resource", .scalar "https://developers.google.com/analytics/bigquery/export-schema"),
         ("title", .scalar "GA4 BigQuery Export schema"),
         ("author", .scalar "team:ga4-docs"),
         ("usage_count", .scalar "5000"),
         ("last_modified", .scalar "2026-05-30T00:00:00Z") ]

def humanVerification : Value :=
  .map [("by", .scalar "human:ahormati"), ("at", .scalar "2026-06-25T09:00:00Z")]

def nightlyVerification : Value :=
  .map [("by", .scalar "process:finance-nightly"), ("at", .scalar "2026-06-26T02:00:00Z")]

/-- §5's snippets as one frontmatter, `type` added. `verified` is the §5.2
list. -/
def section5Frontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "Reference"),
     ("sources", .seq [ga4Source]),
     ("usage_window", .map [("from", .scalar "2026-06-01T00:00:00Z"),
                            ("to", .scalar "2026-06-30T00:00:00Z")]),
     ("generated", .map [("by", .scalar "reference_agent/gemini-2.5-pro"),
                         ("at", .scalar "2026-06-20T22:53:05Z")]),
     ("verified", .seq [humanVerification, nightlyVerification]),
     ("status", .scalar "stable"),
     ("stale_after", .scalar "2026-09-23T00:00:00Z") ],
   by simp⟩

/-- The same, with `verified` as the bare mapping §5.2's MAY permits. -/
def section5BareVerifiedFrontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "Reference"),
     ("generated", .map [("by", .scalar "reference_agent/gemini-2.5-pro"),
                         ("at", .scalar "2026-06-20T22:53:05Z")]),
     ("verified", humanVerification) ],
   by simp⟩

/-- The §5 snippets as one bundle, at invented paths. -/
def section5Examples : Bundle :=
  ⟨[ (["ga4", "events.md"], ⟨section5Frontmatter, ""⟩),
     (["ga4", "sessions.md"], ⟨section5BareVerifiedFrontmatter, ""⟩) ],
   by simp⟩

/-- §4.3 and §4.4 conform, whatever the policy. -/
theorem section4Examples_conformant (p : Policy) : conformant p section4Examples = true := by
  obtain ⟨ft, vk, af, afs, ifm, lo⟩ := p
  cases ft <;> cases vk <;> cases af <;> cases afs <;> cases ifm <;> cases lo <;> decide

/-- §4.1: "a concept carrying just `type` is fully conformant". -/
theorem typeOnly_conformant (p : Policy) : conformant p typeOnly = true := by
  obtain ⟨ft, vk, af, afs, ifm, lo⟩ := p
  cases ft <;> cases vk <;> cases af <;> cases afs <;> cases ifm <;> cases lo <;> decide

/-- §5's snippets conform under every policy but one. -/
theorem section5Examples_conformant (p : Policy)
    (h : ¬ (p.actorForm = .threeForms ∧ p.actorFields = .withAuthor)) :
    conformant p section5Examples = true := by
  obtain ⟨ft, vk, af, afs, ifm, lo⟩ := p
  cases ft <;> cases vk <;> cases af <;> cases afs <;> cases ifm <;> cases lo <;>
    first
    | decide
    | exact absurd ⟨rfl, rfl⟩ h

/-- The one policy that rejects §5's snippets: §7's three forms, reaching
`author` as §5.1 says they do, meet `author: team:ga4-docs`. The spec's own
example fails the spec's own rule under that reading. -/
theorem section5Examples_rejected :
    conformant ⟨.convention, .convention, .threeForms, .withAuthor, .convention, .convention⟩ section5Examples = false := by
  decide

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
    conformant ⟨.required, .convention, .unconstrained, .listedOnly, .convention, .convention⟩ scalarTags
      ≠ conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .convention⟩ scalarTags := by
  decide

/-- A concept whose `status` is none of §5.4's three values. -/
def unknownStatus : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"), ("status", .scalar "retired")], by simp⟩, ""⟩)],
   by simp⟩

/-- §5.4 lists three values for `status` with no keyword attached, so
`Policy.fieldTypes` separates on §5 as it does on §4.1. Finding:
`docs/findings.md`, 2026-10-26, "§5 states shapes and an enumeration without
force". -/
theorem fieldTypes_separates_on_status :
    conformant ⟨.required, .convention, .unconstrained, .listedOnly, .convention, .convention⟩ unknownStatus
      ≠ conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .convention⟩ unknownStatus := by
  decide

/-- A concept whose one `verified` event has `at` and no `by`. -/
def verifiedWithoutBy : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"),
        ("verified", .seq [.map [("at", .scalar "2026-06-25T09:00:00Z")]])], by simp⟩, ""⟩)],
   by simp⟩

/-- §5.2 marks `generated.by` REQUIRED and nothing within a `verified` event.
`verifiedWithoutBy` conforms if the event's keys are a description and not if
they bind, so `Policy.verifiedEntryKeys` is a choice the spec left open.
Finding: `docs/findings.md`, 2026-10-26, "§5.2 marks nothing within a
`verified` event". -/
theorem verifiedEntryKeys_separates :
    conformant ⟨.required, .required, .unconstrained, .listedOnly, .convention, .convention⟩ verifiedWithoutBy
      ≠ conformant ⟨.required, .convention, .unconstrained, .listedOnly, .convention, .convention⟩ verifiedWithoutBy := by
  decide

/-- §7 lists three actor forms with no keyword, and §5.1's own example writes
`author: team:ga4-docs`. Read as `author`-reaching, the three forms reject it
and the open `<scheme>:<id>` reading admits it. The witness is the spec's text.
Finding: `docs/findings.md`, 2026-10-26, "§7's actor forms carry no force, and
§5.1 uses a fourth". -/
theorem actorForm_separates :
    conformant ⟨.convention, .convention, .threeForms, .withAuthor, .convention, .convention⟩ section5Examples
      ≠ conformant ⟨.convention, .convention, .schemeOrSlash, .withAuthor, .convention, .convention⟩ section5Examples := by
  decide

/-- A concept generated by `bob`: no scheme, no slash. -/
def bareNameActor : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"),
        ("generated", .map [("by", .scalar "bob")])], by simp⟩, ""⟩)],
   by simp⟩

/-- The open reading still constrains: `bob` separates it from reading the
convention as description. Same finding as `actorForm_separates`. -/
theorem actorForm_separates_unconstrained :
    conformant ⟨.convention, .convention, .schemeOrSlash, .listedOnly, .convention, .convention⟩ bareNameActor
      ≠ conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .convention⟩ bareNameActor := by
  decide

/-- §7 names `generated.by` and `verified[].by`; §5.1 says `author` is in the
convention too. Under the three forms, the §5 bundle conforms if §7 stops at
its own list and not if it reaches `author`. The witness is the spec's text.
Finding: `docs/findings.md`, 2026-10-26, "§7 and §5.1 disagree on whether
`author` is an actor field". -/
theorem actorFields_separates :
    conformant ⟨.convention, .convention, .threeForms, .listedOnly, .convention, .convention⟩ section5Examples
      ≠ conformant ⟨.convention, .convention, .threeForms, .withAuthor, .convention, .convention⟩ section5Examples := by
  decide

/-- A root `index.md` carrying `okf_version`, the exception §8 names, beside
one concept. -/
def rootIndexWithVersion : Bundle :=
  ⟨[ (["index.md"], ⟨⟨[("okf_version", .scalar "0.2")], by simp⟩, "# Contents\n"⟩),
     (["concept.md"], ⟨⟨[("type", .scalar "Reference")], by simp⟩, ""⟩) ],
   by simp⟩

/-- An `index.md` carrying `title:`. -/
def indexWithTitle : Bundle :=
  ⟨[(["index.md"], ⟨⟨[("title", .scalar "Contents")], by simp⟩, ""⟩)], by simp⟩

/-- An `index.md` one directory down carrying `okf_version`, which §8 allows at
the root only. -/
def nestedIndexWithVersion : Bundle :=
  ⟨[(["a", "index.md"], ⟨⟨[("okf_version", .scalar "0.2")], by simp⟩, ""⟩)], by simp⟩

/-- §8 says index files contain no frontmatter, in the indicative. Read as
binding, `title:` on an index fails; read as description, it passes. Finding:
`docs/findings.md`, 2026-10-26, "§8 says index files contain no frontmatter,
without force". -/
theorem indexFrontmatter_separates :
    conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .required, .convention⟩ indexWithTitle
      ≠ conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .convention⟩
          indexWithTitle := by
  decide

/-- The exception is root-only: `okf_version` one level down separates the same
two readings. -/
theorem indexFrontmatter_separates_on_depth :
    conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .required, .convention⟩
        nestedIndexWithVersion
      ≠ conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .convention⟩
          nestedIndexWithVersion := by
  decide

/-- A log whose two dates are in ascending order. -/
def ascendingLog : Bundle :=
  ⟨[(["log.md"], ⟨Frontmatter.empty, "## 2026-05-15\n* **Creation**: x.\n\n## 2026-05-22\n* **Update**: y.\n"⟩)],
   by simp⟩

/-- §9 says "newest first" in the indicative. Read as binding, an ascending log
fails; read as description, it passes. Finding: `docs/findings.md`,
2026-10-26, "§9 says newest first without force". -/
theorem logOrdering_separates :
    conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .required⟩
        ascendingLog
      ≠ conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .convention⟩
          ascendingLog := by
  decide

end Gaps

/-- §9's own log, as written. -/
def section9Log : Bundle :=
  ⟨[(["log.md"], ⟨Frontmatter.empty,
      "# Directory Update Log\n\n" ++
      "## 2026-05-22\n" ++
      "* **Update**: Added a BigQuery table reference for [Customer Metrics](/tables/customer-metrics.md).\n" ++
      "* **Creation**: Established the [Dataplex Playbook](/playbooks/dataplex.md).\n\n" ++
      "## 2026-05-15\n" ++
      "* **Initialization**: Created foundational directory structure.\n"⟩)],
   by simp⟩

/-- §9's own log conforms under every policy. The body is long enough that
evaluating it once per policy is too slow, so the two log predicates are
evaluated once each and the concept clauses are discharged by the bundle having
no concepts. -/
theorem section9Log_conformant (p : Policy) : conformant p section9Log = true := by
  have hDates : section9Log.logDatesIso = true := by decide +kernel
  have hOrder : section9Log.logNewestFirst = true := by decide +kernel
  have hConcepts : section9Log.concepts = [] := rfl
  have hIndexes : section9Log.indexes = [] := rfl
  obtain ⟨ft, vk, af, afs, ifm, lo⟩ := p
  cases ft <;> cases vk <;> cases af <;> cases afs <;> cases ifm <;> cases lo <;>
    simp [conformant, hDates, hOrder, hConcepts, hIndexes, Bundle.allHaveType,
      Bundle.sourcesHaveResource, Bundle.generatedHasBy, Bundle.statedTypesHold,
      Bundle.provenanceTypesHold, Bundle.verifiedEntriesKeyed, Bundle.byActors,
      Bundle.authorActors, Bundle.indexFrontmatterClean]

/-- A log with a `MM/DD/YYYY` heading. -/
def slashDateLog : Bundle :=
  ⟨[(["log.md"], ⟨Frontmatter.empty, "## 05/22/2026\n* **Update**: x.\n"⟩)], by simp⟩

/-- §9's MUST: the slash date fails under every policy. -/
theorem slashDateLog_rejected (p : Policy) : conformant p slashDateLog = false := by
  obtain ⟨ft, vk, af, afs, ifm, lo⟩ := p
  cases ft <;> cases vk <;> cases af <;> cases afs <;> cases ifm <;> cases lo <;> decide

/-- §8's own exception conforms under every policy. -/
theorem rootIndexWithVersion_conformant (p : Policy) :
    conformant p Gaps.rootIndexWithVersion = true := by
  obtain ⟨ft, vk, af, afs, ifm, lo⟩ := p
  cases ft <;> cases vk <;> cases af <;> cases afs <;> cases ifm <;> cases lo <;> decide

end Okf.V0_2
