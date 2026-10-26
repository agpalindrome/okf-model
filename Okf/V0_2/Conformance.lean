import Okf.V0_2.Structure
import Okf.V0_2.Document
import Okf.V0_2.Provenance
import Okf.V0_2.Actors
import Okf.V0_2.Index
import Okf.V0_2.Log
import Okf.V0_2.Computation
import Okf.V0_2.Footnotes
import Okf.V0_2.Policy

/-!
# Conformance — the clauses assembled

`conformant p b` is the conjunction of every clause modelled so far, with each
`Policy` field choosing between the readings of the gap it names. It is
assembled here, apart from the clause modules, so that a section adds its
clause in its own module and this one grows by a line.

Each `Force` field enters through `Force.gate`, so that a theorem about every
policy is `simp` with each predicate evaluated once, and needs no case split:
nine fields give 1152 policies, which the earlier `cases` then `decide` pattern
did not survive. The three-valued fields, `actorForm` and `inlineComp`, are
parameters of their predicates and are discharged by `cases` on that one field.

Two kinds of theorem live beside the predicate. The spec's own examples, encoded
as values, conform under every policy, or under every policy but the one the
text itself contradicts: a model that rejected the text's own examples silently
would be reading something the text did not write. And for each `Policy` field,
`Gaps` holds the separation theorem: a bundle on which two values of the field
disagree, so the gap is observable and not a field with no effect.

## Where the witnesses come from

§4.3 and §4.4 give two frontmatters and two bodies but no paths, so the paths
below are invented from the links the examples make: §4.4 links "the orders
table" at `/tables/orders.md`, which fits §4.3's `Customer Orders`; nothing
names §4.4's own path. §4.1 states its third witness in prose: "a concept
carrying just `type` is fully conformant". §5's snippets are combined into one
frontmatter with a `type` added, since none of them has one and §4.1 requires
it. §9's log, §10.2's Attested Computation and §10.4's Metric are as written,
at invented paths.

Most separating bundles are invented. Two are the spec's own text. §5.1's
`author: team:ga4-docs` is a fourth actor scheme, so the §5 bundle separates
two readings of `actorForm` and both of `actorFields`, and is rejected under
`threeForms` with `withAuthor`. §10.2's example indents its computation, so it
separates `fencedOnly` from `fencedOrIndented` and is rejected under
`fencedOnly`. Both are the scenario `docs/scope-and-stance.md` named before any
Lean existed: a rule in one section rejecting the example in another. §8's own
root `okf_version` is the third: §11.2 read literally rejects it.

## §11, read against this predicate

§11 defines "conformant" by three conditions: every non-reserved `.md` file has
a parseable frontmatter block, every block has a non-empty `type`, and every
reserved file follows §8 and §9. Then: producers "SHOULD follow §5 through
§10", and consumers "SHOULD treat all other constraints as soft guidance".

That is not how §5 and §10 read themselves. §5.1 says `resource` is REQUIRED
within a `sources` entry, §5.2 that `generated.by` is REQUIRED, §10.2 that
`runtime` is REQUIRED for the type. Under §11 those are guidance a conformant
bundle may violate; under their own sections they are conditions. So
`Policy.familyClauses` gates clauses three, four and five together. Under §11.3
the §9 date-form MUST stays unconditional, since it is "the structure in §9".

§11.2 says "every frontmatter block". §8 permits a root `index.md` whose only
key is `okf_version`. Read literally, §11.2 rejects §8's own permitted form;
read as scoped by §11.1's "non-reserved", it does not. `Policy.typeScope`
holds that choice, and clause two takes it as a parameter.

§11.1 is parse-side: "parseable" is below the trust boundary, and post-parse
the model cannot tell a missing block from an empty one. §11.2 fails both, so
nothing is lost. §11's consumer rules, three in the middle block and five in
the last, bind consumers and are not modelled, as throughout. Two of the five,
"broken cross-links" and "missing `index.md` files", confirm the §6 and §3
readings.
-/

namespace Okf.V0_2

/-- A bundle conforms under policy `p`. -/
def conformant (p : Policy) (b : Bundle) : Bool :=
  b.typedBlocks p.typeScope
    && p.familyClauses.gate (b.sourcesHaveResource && b.generatedHasBy && b.attestedHaveRuntime)
    && b.logDatesIso
    && p.fieldTypes.gate (b.statedTypesHold && b.provenanceTypesHold && b.computationTypesHold
          && b.indexTypesHold)
    && p.verifiedEntryKeys.gate b.verifiedEntriesKeyed
    && b.byActors p.actorForm
    && p.actorFields.gate (b.authorActors p.actorForm)
    && p.indexFrontmatter.gate b.indexFrontmatterClean
    && p.logOrdering.gate b.logNewestFirst
    && p.contractFields.gate b.contractsComplete
    && b.computationsProvided p.inlineComp
    && p.footnoteLabels.gate b.footnotesJoined

/-- The `Prop` reading of `conformant`. -/
def Conformant (p : Policy) (b : Bundle) : Prop :=
  b.TypedBlocks p.typeScope
    ∧ (p.familyClauses = .required →
        b.SourcesHaveResource ∧ b.GeneratedHasBy ∧ b.AttestedHaveRuntime)
    ∧ b.LogDatesIso
    ∧ (p.fieldTypes = .required →
        b.StatedTypesHold ∧ b.ProvenanceTypesHold ∧ b.ComputationTypesHold ∧ b.IndexTypesHold)
    ∧ (p.verifiedEntryKeys = .required → b.VerifiedEntriesKeyed)
    ∧ b.ByActors p.actorForm
    ∧ (p.actorFields = .withAuthor → b.AuthorActors p.actorForm)
    ∧ (p.indexFrontmatter = .required → b.IndexFrontmatterClean)
    ∧ (p.logOrdering = .required → b.LogNewestFirst)
    ∧ (p.contractFields = .required → b.ContractsComplete)
    ∧ b.ComputationsProvided p.inlineComp
    ∧ (p.footnoteLabels = .required → b.FootnotesJoined)

theorem conformant_iff (p : Policy) (b : Bundle) :
    conformant p b = true ↔ Conformant p b := by
  simp only [conformant, Conformant, Bool.and_eq_true, Force.gate_eq_true_iff,
    ActorFields.gate_eq_true_iff, Bundle.typedBlocks_iff, Bundle.sourcesHaveResource_iff,
    Bundle.generatedHasBy_iff, Bundle.attestedHaveRuntime_iff, Bundle.logDatesIso_iff,
    Bundle.statedTypesHold_iff, Bundle.provenanceTypesHold_iff, Bundle.computationTypesHold_iff,
    Bundle.indexTypesHold_iff,
    Bundle.verifiedEntriesKeyed_iff, Bundle.byActors_iff, Bundle.authorActors_iff,
    Bundle.indexFrontmatterClean_iff, Bundle.logNewestFirst_iff, Bundle.contractsComplete_iff,
    Bundle.computationsProvided_iff, Bundle.footnotesJoined_iff, and_assoc]

/-! ## §4's examples -/

/-- A one-key frontmatter, for the witnesses below. -/
private def fm1 (k : String) (v : Value) : Frontmatter := ⟨[(k, v)], by simp⟩

/-- §4.3's frontmatter, as written. `generated` is a §5 family. -/
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

/-! ## §5's snippets -/

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

/-! ## §9's log -/

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

/-- A log with a `MM/DD/YYYY` heading. -/
def slashDateLog : Bundle :=
  ⟨[(["log.md"], ⟨Frontmatter.empty, "## 05/22/2026\n* **Update**: x.\n"⟩)], by simp⟩

/-! ## §10's examples -/

/-- §10.2's Attested Computation frontmatter, as written. -/
def revenueComputationFrontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "Attested Computation"),
     ("title", .scalar "Revenue for fiscal year"),
     ("description", .scalar "Recognized revenue for a fiscal year, per Finance's definition."),
     ("status", .scalar "stable"),
     ("runtime", .scalar "bigquery"),
     ("parameters", .seq [.map [("name", .scalar "year"), ("type", .scalar "integer"),
                                ("required", .scalar "true")]]),
     ("executor", .map [("resource", .scalar "references/skills/run-on-bq.md"),
                        ("receipt", .seq [.scalar "job_id", .scalar "executed_sql",
                                          .scalar "result"])]),
     ("attester", .map [("resource", .scalar "references/attesters/revenue.py")]),
     ("generated", .map [("by", .scalar "reference_agent/gemini-2.5-pro"),
                         ("at", .scalar "2026-06-20T22:53:05Z")]),
     ("verified", humanVerification),
     ("stale_after", .scalar "2026-09-23T00:00:00Z"),
     ("sources", .seq [.map [("id", .scalar "rev-policy"),
                             ("resource", .scalar "https://wiki.acme/finance/revenue-recognition"),
                             ("title", .scalar "Revenue recognition policy")]]) ],
   by simp⟩

/-- §10.2's body, as written: an indented block, not a fence, and a footnote
joined to `rev-policy`. -/
def revenueComputationBody : Body :=
  "# Computation\n\n" ++
  "    SELECT SUM(amount) AS revenue\n" ++
  "    FROM finance.recognized_revenue\n" ++
  "    WHERE fiscal_year = @year\n\n" ++
  "The computation binds only the declared `parameters`, per the recognition\n" ++
  "policy.[^rev-policy]\n\n" ++
  "[^rev-policy]: Revenue recognition policy\n"

/-- §10.4's Metric, as written. -/
def revenueMetricFrontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "Metric"),
     ("title", .scalar "Revenue"),
     ("description", .scalar "Recognized revenue for a fiscal year."),
     ("tags", .seq [.scalar "finance", .scalar "revenue"]),
     ("status", .scalar "stable"),
     ("generated", .map [("by", .scalar "reference_agent/gemini-2.5-pro"),
                         ("at", .scalar "2026-06-20T22:53:05Z")]) ],
   by simp⟩

def revenueMetricBody : Body :=
  "# Definition\n\n" ++
  "Recognized revenue sums `amount` over rows booked to the fiscal year,\n" ++
  "computed by [the revenue computation](../computations/revenue.md).\n"

/-- §10.2 and §10.4 as one bundle, at the paths §10.4's link implies. -/
def section10Examples : Bundle :=
  ⟨[ (["computations", "revenue.md"], ⟨revenueComputationFrontmatter, revenueComputationBody⟩),
     (["metrics", "revenue.md"], ⟨revenueMetricFrontmatter, revenueMetricBody⟩) ],
   by simp⟩

/-! ## The examples conform -/

/-- Everything `conformant` checks that does not depend on the policy, plus
every `Force`-gated predicate, holds of `b`. With these, `simp` closes
`conformant p b = true` for any `p`. -/
structure AllClausesHold (b : Bundle) : Prop where
  typedBlocks : ∀ scope, b.typedBlocks scope = true
  sourcesHaveResource : b.sourcesHaveResource = true
  generatedHasBy : b.generatedHasBy = true
  attestedHaveRuntime : b.attestedHaveRuntime = true
  logDatesIso : b.logDatesIso = true
  statedTypesHold : b.statedTypesHold = true
  provenanceTypesHold : b.provenanceTypesHold = true
  computationTypesHold : b.computationTypesHold = true
  indexTypesHold : b.indexTypesHold = true
  verifiedEntriesKeyed : b.verifiedEntriesKeyed = true
  byActors : ∀ form, b.byActors form = true
  authorActors : ∀ form, b.authorActors form = true
  indexFrontmatterClean : b.indexFrontmatterClean = true
  logNewestFirst : b.logNewestFirst = true
  contractsComplete : b.contractsComplete = true
  computationsProvided : ∀ form, b.computationsProvided form = true
  footnotesJoined : b.footnotesJoined = true

theorem conformant_of_allClausesHold {b : Bundle} (h : AllClausesHold b) (p : Policy) :
    conformant p b = true := by
  simp [conformant, h.typedBlocks, h.sourcesHaveResource, h.generatedHasBy,
    h.attestedHaveRuntime, h.logDatesIso, h.statedTypesHold, h.provenanceTypesHold,
    h.computationTypesHold, h.indexTypesHold, h.verifiedEntriesKeyed, h.byActors, h.authorActors,
    h.indexFrontmatterClean, h.logNewestFirst, h.contractsComplete, h.computationsProvided,
    h.footnotesJoined]

/-- §4.3 and §4.4 conform, whatever the policy. -/
theorem section4Examples_conformant (p : Policy) : conformant p section4Examples = true :=
  conformant_of_allClausesHold
    { typedBlocks := by intro s; cases s <;> decide, sourcesHaveResource := by decide, generatedHasBy := by decide,
      attestedHaveRuntime := by decide, logDatesIso := by decide,
      statedTypesHold := by decide, provenanceTypesHold := by decide,
      computationTypesHold := by decide, indexTypesHold := by decide,
      verifiedEntriesKeyed := by decide,
      byActors := by intro f; cases f <;> decide, authorActors := by intro f; cases f <;> decide,
      indexFrontmatterClean := by decide, logNewestFirst := by decide,
      contractsComplete := by decide, computationsProvided := by intro f; cases f <;> decide,
      footnotesJoined := by decide +kernel } p

/-- §4.1: "a concept carrying just `type` is fully conformant". -/
theorem typeOnly_conformant (p : Policy) : conformant p typeOnly = true :=
  conformant_of_allClausesHold
    { typedBlocks := by intro s; cases s <;> decide, sourcesHaveResource := by decide, generatedHasBy := by decide,
      attestedHaveRuntime := by decide, logDatesIso := by decide,
      statedTypesHold := by decide, provenanceTypesHold := by decide,
      computationTypesHold := by decide, indexTypesHold := by decide,
      verifiedEntriesKeyed := by decide,
      byActors := by intro f; cases f <;> decide, authorActors := by intro f; cases f <;> decide,
      indexFrontmatterClean := by decide, logNewestFirst := by decide,
      contractsComplete := by decide, computationsProvided := by intro f; cases f <;> decide,
      footnotesJoined := by decide } p

/-- §5's snippets conform under every policy but one. -/
theorem section5Examples_conformant (p : Policy)
    (h : ¬ (p.actorForm = .threeForms ∧ p.actorFields = .withAuthor)) :
    conformant p section5Examples = true := by
  have hBy : ∀ form, section5Examples.byActors form = true := by intro f; cases f <;> decide
  have hAuthorOpen : section5Examples.authorActors .schemeOrSlash = true := by decide
  have hAuthorAny : section5Examples.authorActors .unconstrained = true := by decide
  have hComp : ∀ form, section5Examples.computationsProvided form = true := by
    intro f; cases f <;> decide
  have hTyped : ∀ scope, section5Examples.typedBlocks scope = true := by
    intro sc; cases sc <;> decide
  have hRest :
      section5Examples.sourcesHaveResource = true
        ∧ section5Examples.generatedHasBy = true ∧ section5Examples.attestedHaveRuntime = true
        ∧ section5Examples.logDatesIso = true ∧ section5Examples.statedTypesHold = true
        ∧ section5Examples.provenanceTypesHold = true
        ∧ section5Examples.computationTypesHold = true
        ∧ section5Examples.indexTypesHold = true
        ∧ section5Examples.verifiedEntriesKeyed = true
        ∧ section5Examples.indexFrontmatterClean = true
        ∧ section5Examples.logNewestFirst = true ∧ section5Examples.contractsComplete = true
        ∧ section5Examples.footnotesJoined = true := by decide
  obtain ⟨ft, vk, af, afs, ifm, lo, cf, ic, fl, fc, ts⟩ := p
  cases af <;> cases afs <;>
    first
    | exact absurd ⟨rfl, rfl⟩ h
    | simp [conformant, hBy, hAuthorOpen, hAuthorAny, hComp, hRest, hTyped, ActorFields.gate]

/-- The one policy that rejects §5's snippets: §7's three forms, reaching
`author` as §5.1 says they do, meet `author: team:ga4-docs`. The spec's own
example fails the spec's own rule under that reading. -/
theorem section5Examples_rejected :
    conformant ⟨.convention, .convention, .threeForms, .withAuthor, .convention, .convention,
      .convention, .unconstrained, .convention, .required, .conceptsOnly⟩ section5Examples = false := by
  decide

/-- §9's own log conforms under every policy. Its body is long enough that the
two log predicates are evaluated by the kernel once each. -/
theorem section9Log_conformant (p : Policy) : conformant p section9Log = true := by
  have hDates : section9Log.logDatesIso = true := by decide +kernel
  have hOrder : section9Log.logNewestFirst = true := by decide +kernel
  have hConcepts : section9Log.concepts = [] := rfl
  have hIndexes : section9Log.indexes = [] := rfl
  have hTyped : ∀ scope, section9Log.typedBlocks scope = true := by
    intro sc; cases sc <;> decide +kernel
  simp [conformant, hDates, hOrder, hConcepts, hIndexes, hTyped,
    Bundle.sourcesHaveResource, Bundle.generatedHasBy, Bundle.attestedHaveRuntime,
    Bundle.statedTypesHold, Bundle.provenanceTypesHold, Bundle.computationTypesHold,
    Bundle.indexTypesHold, Bundle.verifiedEntriesKeyed, Bundle.byActors, Bundle.authorActors,
    Bundle.indexFrontmatterClean, Bundle.contractsComplete, Bundle.computationsProvided,
    Bundle.footnotesJoined]

/-- §9's MUST: the slash date fails under every policy. -/
theorem slashDateLog_rejected (p : Policy) : conformant p slashDateLog = false := by
  have h : slashDateLog.logDatesIso = false := by decide
  simp [conformant, h]

/-- §10.2 and §10.4 conform under every policy but one. The body predicates are
evaluated by the kernel once each. -/
theorem section10Examples_conformant (p : Policy) (h : p.inlineComp ≠ .fencedOnly) :
    conformant p section10Examples = true := by
  have hFootnotes : section10Examples.footnotesJoined = true := by decide +kernel
  have hCompIndented : section10Examples.computationsProvided .fencedOrIndented = true := by
    decide +kernel
  have hCompAny : section10Examples.computationsProvided .unconstrained = true := by decide
  have hBy : ∀ form, section10Examples.byActors form = true := by intro f; cases f <;> decide
  have hAuthor : ∀ form, section10Examples.authorActors form = true := by
    intro f; cases f <;> decide
  have hTyped : ∀ scope, section10Examples.typedBlocks scope = true := by
    intro sc; cases sc <;> decide
  have hRest :
      section10Examples.sourcesHaveResource = true
        ∧ section10Examples.generatedHasBy = true
        ∧ section10Examples.attestedHaveRuntime = true
        ∧ section10Examples.logDatesIso = true ∧ section10Examples.statedTypesHold = true
        ∧ section10Examples.provenanceTypesHold = true
        ∧ section10Examples.computationTypesHold = true
        ∧ section10Examples.indexTypesHold = true
        ∧ section10Examples.verifiedEntriesKeyed = true
        ∧ section10Examples.indexFrontmatterClean = true
        ∧ section10Examples.logNewestFirst = true
        ∧ section10Examples.contractsComplete = true := by decide
  obtain ⟨ft, vk, af, afs, ifm, lo, cf, ic, fl, fc, ts⟩ := p
  cases ic with
  | fencedOnly => exact absurd rfl h
  | fencedOrIndented => simp [conformant, hFootnotes, hCompIndented, hBy, hAuthor, hRest, hTyped]
  | unconstrained => simp [conformant, hFootnotes, hCompAny, hBy, hAuthor, hRest, hTyped]

/-- The one reading that rejects §10.2's example: §10.3's "single fenced code
block", met by the example's indented block and absent `computation` key. The
spec's own example fails the spec's own rule under that reading. -/
theorem section10Examples_rejected :
    conformant ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .convention,
      .convention, .fencedOnly, .convention, .required, .conceptsOnly⟩ section10Examples = false := by
  have h : section10Examples.computationsProvided .fencedOnly = false := by decide +kernel
  simp [conformant, h]

/-! ## Separations -/

namespace Gaps

/-- A policy that waives every `Force` field and constrains nothing. -/
def lax : Policy :=
  ⟨.convention, .convention, .unconstrained, .listedOnly, .convention, .convention,
    .convention, .unconstrained, .convention, .convention, .conceptsOnly⟩

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
    conformant { lax with fieldTypes := .required } scalarTags
      ≠ conformant lax scalarTags := by
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
    conformant { lax with fieldTypes := .required } unknownStatus
      ≠ conformant lax unknownStatus := by
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
    conformant { lax with verifiedEntryKeys := .required } verifiedWithoutBy
      ≠ conformant lax verifiedWithoutBy := by
  decide

/-- §7 lists three actor forms with no keyword, and §5.1's own example writes
`author: team:ga4-docs`. Read as `author`-reaching, the three forms reject it
and the open `<scheme>:<id>` reading admits it. The witness is the spec's text.
Finding: `docs/findings.md`, 2026-10-26, "§7's actor forms carry no force, and
§5.1 uses a fourth". -/
theorem actorForm_separates :
    conformant { lax with actorForm := .threeForms, actorFields := .withAuthor } section5Examples
      ≠ conformant { lax with actorForm := .schemeOrSlash, actorFields := .withAuthor }
          section5Examples := by
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
    conformant { lax with actorForm := .schemeOrSlash } bareNameActor
      ≠ conformant lax bareNameActor := by
  decide

/-- §7 names `generated.by` and `verified[].by`; §5.1 says `author` is in the
convention too. Under the three forms, the §5 bundle conforms if §7 stops at
its own list and not if it reaches `author`. The witness is the spec's text.
Finding: `docs/findings.md`, 2026-10-26, "§7 and §5.1 disagree on whether
`author` is an actor field". -/
theorem actorFields_separates :
    conformant { lax with actorForm := .threeForms } section5Examples
      ≠ conformant { lax with actorForm := .threeForms, actorFields := .withAuthor }
          section5Examples := by
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

/-- A root `index.md` whose `okf_version` is not `<major>.<minor>`. -/
def wordyVersion : Bundle :=
  ⟨[(["index.md"], ⟨⟨[("okf_version", .scalar "two")], by simp⟩, ""⟩)], by simp⟩

/-- §12 says revisions are versioned `<major>.<minor>` with no keyword on the
value's form, so `Policy.fieldTypes` separates on §12 as on §4.1 and §5. Same
findings as `fieldTypes_separates`. -/
theorem fieldTypes_separates_on_version :
    conformant { lax with fieldTypes := .required } wordyVersion
      ≠ conformant lax wordyVersion := by
  decide

/-- §8 says index files contain no frontmatter, in the indicative. Read as
binding, `title:` on an index fails; read as description, it passes. Finding:
`docs/findings.md`, 2026-10-26, "§8 says index files contain no frontmatter,
without force". -/
theorem indexFrontmatter_separates :
    conformant { lax with indexFrontmatter := .required } indexWithTitle
      ≠ conformant lax indexWithTitle := by
  decide

/-- The exception is root-only: `okf_version` one level down separates the same
two readings. -/
theorem indexFrontmatter_separates_on_depth :
    conformant { lax with indexFrontmatter := .required } nestedIndexWithVersion
      ≠ conformant lax nestedIndexWithVersion := by
  decide

/-- A log whose two dates are in ascending order. -/
def ascendingLog : Bundle :=
  ⟨[(["log.md"], ⟨Frontmatter.empty, "## 2026-05-15\n* **Creation**: x.\n\n## 2026-05-22\n* **Update**: y.\n"⟩)],
   by simp⟩

/-- §9 says "newest first" in the indicative. Read as binding, an ascending log
fails; read as description, it passes. Finding: `docs/findings.md`,
2026-10-26, "§9 says newest first without force". -/
theorem logOrdering_separates :
    conformant { lax with logOrdering := .required } ascendingLog
      ≠ conformant lax ascendingLog := by
  decide

/-- An Attested Computation with `runtime` and a `computation` path, and no
`executor` or `attester`. -/
def bareComputation : Bundle :=
  ⟨[(["c.md"],
     ⟨⟨[("type", .scalar "Attested Computation"), ("runtime", .scalar "bigquery"),
        ("computation", .scalar "references/computations/lib/revenue.sql")], by simp⟩, ""⟩)],
   by simp⟩

/-- §10.2 marks `runtime` REQUIRED, `computation` Optional, and `executor` and
`attester` neither. Read as required, `bareComputation` fails; read as
description, it passes. Finding: `docs/findings.md`, 2026-10-26, "§10.2 marks
`executor` and `attester` neither required nor optional". -/
theorem contractFields_separates :
    conformant { lax with contractFields := .required } bareComputation
      ≠ conformant lax bareComputation := by
  decide

/-- §10.3 says "a single fenced code block" and §10.2's own example indents
its computation. Under the fence-only reading the example fails; admitting the
indented block, it passes. The witness is the spec's text. Finding:
`docs/findings.md`, 2026-10-26, "§10.3 says fenced, and §10.2's example is
indented". -/
theorem inlineComp_separates :
    conformant { lax with inlineComp := .fencedOnly } section10Examples
      ≠ conformant { lax with inlineComp := .fencedOrIndented } section10Examples := by
  have h1 : section10Examples.computationsProvided .fencedOnly = false := by decide +kernel
  have h2 : section10Examples.computationsProvided .fencedOrIndented = true := by decide +kernel
  have hFootnotes : section10Examples.footnotesJoined = true := by decide +kernel
  have hBy : ∀ form, section10Examples.byActors form = true := by intro f; cases f <;> decide
  have hTyped : ∀ scope, section10Examples.typedBlocks scope = true := by
    intro sc; cases sc <;> decide
  have hRest :
      section10Examples.sourcesHaveResource = true
        ∧ section10Examples.generatedHasBy = true
        ∧ section10Examples.attestedHaveRuntime = true
        ∧ section10Examples.logDatesIso = true := by decide
  simp [conformant, lax, h1, h2, hFootnotes, hBy, hRest, hTyped, Force.gate, ActorFields.gate]

/-- "Provide the computation in one of two ways" still constrains when read as
binding: `bareComputation` has the key and no body, which passes, and the same
concept with neither fails. -/
def computationless : Bundle :=
  ⟨[(["c.md"],
     ⟨⟨[("type", .scalar "Attested Computation"), ("runtime", .scalar "bigquery")], by simp⟩,
      ""⟩)],
   by simp⟩

/-- The sentence, read as binding, separates from reading it as description.
Same finding as `inlineComp_separates`. -/
theorem inlineComp_separates_unconstrained :
    conformant { lax with inlineComp := .fencedOrIndented } computationless
      ≠ conformant lax computationless := by
  decide

/-- A concept with a footnote definition no `sources[].id` names. -/
def orphanFootnote : Bundle :=
  ⟨[(["c.md"],
     ⟨⟨[("type", .scalar "Reference")], by simp⟩,
      "A claim.[^nowhere]\n\n[^nowhere]: Nothing in sources.\n"⟩)],
   by simp⟩

/-- §5.1 keys footnotes to `sources[].id` with no keyword. Read as binding, an
orphan definition fails; read as description, it passes. Finding:
`docs/findings.md`, 2026-10-26, "§5.1 keys footnotes to `sources[].id` without
force". -/
theorem footnoteLabels_separates :
    conformant { lax with footnoteLabels := .required } orphanFootnote
      ≠ conformant lax orphanFootnote := by
  decide

/-- A concept whose `generated` has `at` and no `by`. -/
def generatedWithoutBy : Bundle :=
  ⟨[(["concept.md"],
     ⟨⟨[("type", .scalar "Reference"),
        ("generated", .map [("at", .scalar "2026-06-20T22:53:05Z")])], by simp⟩, ""⟩)],
   by simp⟩

/-- §5.2 says `generated.by` is REQUIRED; §11 lists three conditions, not that
one, and says producers SHOULD follow §5 through §10. Under §11 the concept
conforms; under §5.2 it does not. Finding: `docs/findings.md`, 2026-10-26,
"§11 defines conformance without the REQUIREDs of §5 and §10". -/
theorem familyClauses_separates :
    conformant { lax with familyClauses := .required } generatedWithoutBy
      ≠ conformant lax generatedWithoutBy := by
  decide

/-- §11.2 says "every frontmatter block contains a non-empty `type`"; §8
permits a root `index.md` whose only key is `okf_version`. Read literally,
§11.2 rejects §8's own form; scoped to non-reserved files, it does not. The
witness is the spec's text. Finding: `docs/findings.md`, 2026-10-26, "§11.2
read literally rejects §8's root `okf_version`". -/
theorem typeScope_separates :
    conformant { lax with typeScope := .everyBlock } rootIndexWithVersion
      ≠ conformant lax rootIndexWithVersion := by
  decide

end Gaps

/-- §8's own exception conforms under every policy that scopes §11.2 to
concepts. -/
theorem rootIndexWithVersion_conformant (p : Policy) (h : p.typeScope = .conceptsOnly) :
    conformant p Gaps.rootIndexWithVersion = true := by
  have hTyped : Gaps.rootIndexWithVersion.typedBlocks .conceptsOnly = true := by decide
  have hBy : ∀ form, Gaps.rootIndexWithVersion.byActors form = true := by
    intro f; cases f <;> decide
  have hAuthor : ∀ form, Gaps.rootIndexWithVersion.authorActors form = true := by
    intro f; cases f <;> decide
  have hComp : ∀ form, Gaps.rootIndexWithVersion.computationsProvided form = true := by
    intro f; cases f <;> decide
  have hRest :
      Gaps.rootIndexWithVersion.sourcesHaveResource = true
        ∧ Gaps.rootIndexWithVersion.generatedHasBy = true
        ∧ Gaps.rootIndexWithVersion.attestedHaveRuntime = true
        ∧ Gaps.rootIndexWithVersion.logDatesIso = true
        ∧ Gaps.rootIndexWithVersion.statedTypesHold = true
        ∧ Gaps.rootIndexWithVersion.provenanceTypesHold = true
        ∧ Gaps.rootIndexWithVersion.computationTypesHold = true
        ∧ Gaps.rootIndexWithVersion.indexTypesHold = true
        ∧ Gaps.rootIndexWithVersion.verifiedEntriesKeyed = true
        ∧ Gaps.rootIndexWithVersion.indexFrontmatterClean = true
        ∧ Gaps.rootIndexWithVersion.logNewestFirst = true
        ∧ Gaps.rootIndexWithVersion.contractsComplete = true
        ∧ Gaps.rootIndexWithVersion.footnotesJoined = true := by decide
  obtain ⟨ft, vk, af, afs, ifm, lo, cf, ic, fl, fc, ts⟩ := p
  cases ts with
  | conceptsOnly => simp [conformant, hTyped, hBy, hAuthor, hComp, hRest]
  | everyBlock => simp at h

/-- The one reading that rejects §8's own exception: §11.2 taken as every
block. The spec's §8 permission fails the spec's §11.2 under that reading. -/
theorem rootIndexWithVersion_rejected :
    conformant { Gaps.lax with typeScope := .everyBlock } Gaps.rootIndexWithVersion = false := by
  decide

end Okf.V0_2
