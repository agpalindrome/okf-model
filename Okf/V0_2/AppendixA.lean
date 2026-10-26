import Okf.V0_2.Conformance

/-!
# Appendix A — the worked example as the capstone witness

Appendix A says it exercises every family, and it does: a `Metric` with a bare
`verified` and a joined footnote, and two Attested Computations with
parameters, executors, attesters, sources, a usage window and footnotes. Both
`docs/scope-and-stance.md` and this repo count worked examples as source, so
the three documents the appendix shows are encoded here as written, at the
paths its tree gives.

The tree also lists `references/skills/run-on-bq.md`, `run-dbt.md`,
`references/attesters/sql-equality.py` and `dbt-binding.py`, with no content.
The two `.md` files are omitted because the model cannot encode a document the
text does not show. The two `.py` files are the §3 finding's question live in
the text's own example, and the carrier cannot hold them.

## What the appendix proves

It conforms under every policy except the two readings the text already
contradicts: §7's three actor forms reaching `author`, because
`author: team:finance-fpa` is the fourth scheme §5.1's example used; and
§10.3's fence only, because both computations are indented as §10.2's example
was. The two self-rejections recur in the text's largest example.

The appendix's v0.1 form, with `timestamp` and a `# Citations` list, conforms
under every policy. §13 says a v0.1 bundle is "consumable"; this is stronger,
and the text does not say it.
-/

namespace Okf.V0_2

/-- `metrics/income-statement.md`, as written. -/
def incomeStatementFrontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "Metric"),
     ("title", .scalar "Income statement (fiscal year)"),
     ("description", .scalar "Headline income-statement figures for a fiscal year."),
     ("tags", .seq [.scalar "finance", .scalar "income-statement"]),
     ("status", .scalar "stable"),
     ("generated", .map [("by", .scalar "reference_agent/gemini-2.5-pro"),
                         ("at", .scalar "2026-06-20T22:53:05Z")]),
     ("verified", .map [("by", .scalar "human:ahormati"), ("at", .scalar "2026-06-25T09:00:00Z")]),
     ("stale_after", .scalar "2026-12-31T00:00:00Z"),
     ("sources", .seq [.map [("id", .scalar "fpa-handbook"),
                             ("resource", .scalar "https://wiki.acme/finance/fpa-handbook"),
                             ("title", .scalar "FP&A reporting handbook")]]) ],
   by simp⟩

def incomeStatementBody : Body :=
  "# Definition\n" ++
  "The income statement reports [revenue](../computations/revenue.md) and\n" ++
  "[gross profit](../computations/profit.md) for a fiscal year, per the FP&A\n" ++
  "reporting handbook.[^fpa-handbook] Each figure is produced by a sanctioned,\n" ++
  "attestable computation; this concept only narrates them.\n\n" ++
  "[^fpa-handbook]: FP&A reporting handbook\n"

/-- `computations/revenue.md`, as written. -/
def appendixRevenueFrontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "Attested Computation"),
     ("title", .scalar "Revenue for fiscal year"),
     ("description", .scalar "Recognized revenue for a fiscal year, per Finance's definition."),
     ("tags", .seq [.scalar "finance", .scalar "revenue"]),
     ("status", .scalar "stable"),
     ("runtime", .scalar "bigquery"),
     ("parameters", .seq [.map [("name", .scalar "year"), ("type", .scalar "integer"),
                                ("required", .scalar "true")]]),
     ("executor", .map [("resource", .scalar "references/skills/run-on-bq.md"),
                        ("receipt", .seq [.scalar "job_id", .scalar "executed_sql",
                                          .scalar "result"])]),
     ("attester", .map [("resource", .scalar "references/attesters/sql-equality.py")]),
     ("generated", .map [("by", .scalar "reference_agent/gemini-2.5-pro"),
                         ("at", .scalar "2026-06-28T14:00:00Z")]),
     ("verified", .map [("by", .scalar "human:ahormati"), ("at", .scalar "2026-06-25T09:00:00Z")]),
     ("stale_after", .scalar "2026-12-31T00:00:00Z"),
     ("sources", .seq [
        .map [("id", .scalar "rev-policy"),
              ("resource", .scalar "https://wiki.acme/finance/revenue-recognition"),
              ("title", .scalar "Revenue recognition policy"),
              ("author", .scalar "team:finance-fpa"),
              ("last_modified", .scalar "2026-04-02T00:00:00Z")],
        .map [("id", .scalar "exec-rev-dash"),
              ("resource", .scalar "dashboards/exec-revenue"),
              ("title", .scalar "Executive revenue dashboard"),
              ("author", .scalar "team:finance-fpa"),
              ("usage_count", .scalar "5000"),
              ("last_modified", .scalar "2026-06-18T00:00:00Z")] ]),
     ("usage_window", .map [("from", .scalar "2026-06-01T00:00:00Z"),
                            ("to", .scalar "2026-06-30T00:00:00Z")]) ],
   by simp⟩

def appendixRevenueBody : Body :=
  "# Computation\n\n" ++
  "    SELECT SUM(amount) AS revenue\n" ++
  "    FROM finance.recognized_revenue\n" ++
  "    WHERE fiscal_year = @year\n\n" ++
  "Recognized revenue per the recognition policy,[^rev-policy] corroborated by\n" ++
  "the executive revenue dashboard.[^exec-rev-dash]\n\n" ++
  "[^rev-policy]: Revenue recognition policy\n" ++
  "[^exec-rev-dash]: Executive revenue dashboard\n"

/-- `computations/profit.md`, as written. -/
def appendixProfitFrontmatter : Frontmatter :=
  ⟨[ ("type", .scalar "Attested Computation"),
     ("title", .scalar "Gross profit for fiscal year"),
     ("description", .scalar "Gross profit by segment for a fiscal year, per the cost-allocation standard."),
     ("tags", .seq [.scalar "finance", .scalar "profit"]),
     ("status", .scalar "stable"),
     ("runtime", .scalar "dbt"),
     ("parameters", .seq [
        .map [("name", .scalar "year"), ("type", .scalar "integer"), ("required", .scalar "true")],
        .map [("name", .scalar "segment"), ("type", .scalar "string"),
              ("required", .scalar "true")] ]),
     ("executor", .map [("resource", .scalar "references/skills/run-dbt.md"),
                        ("receipt", .seq [.scalar "run_id", .scalar "compiled_sql",
                                          .scalar "result"])]),
     ("attester", .map [("resource", .scalar "references/attesters/dbt-binding.py")]),
     ("generated", .map [("by", .scalar "reference_agent/gemini-2.5-pro"),
                         ("at", .scalar "2026-06-14T14:00:00Z")]),
     ("verified", .map [("by", .scalar "process:finance-nightly"),
                        ("at", .scalar "2026-06-12T08:00:00Z")]),
     ("stale_after", .scalar "2026-06-15T00:00:00Z"),
     ("sources", .seq [.map [("id", .scalar "cost-alloc"),
                             ("resource", .scalar "https://wiki.acme/finance/cost-allocation"),
                             ("title", .scalar "Cost allocation standard")]]) ],
   by simp⟩

def appendixProfitBody : Body :=
  "# Computation\n\n" ++
  "    SELECT gross_profit\n" ++
  "    FROM {{ ref('fct_income_statement') }}\n" ++
  "    WHERE fiscal_year = {{ var('year') }}\n" ++
  "      AND segment = {{ var('segment') }}\n\n" ++
  "Gross profit by segment per the cost-allocation standard.[^cost-alloc]\n\n" ++
  "[^cost-alloc]: Cost allocation standard\n"

/-- Appendix A's v0.2 bundle: the three documents it shows, at its paths. -/
def appendixA : Bundle :=
  ⟨[ (["metrics", "income-statement.md"], ⟨incomeStatementFrontmatter, incomeStatementBody⟩),
     (["computations", "revenue.md"], ⟨appendixRevenueFrontmatter, appendixRevenueBody⟩),
     (["computations", "profit.md"], ⟨appendixProfitFrontmatter, appendixProfitBody⟩) ],
   by simp⟩

/-! The facts about `appendixA` that `appendixA_conformant` assembles, each as
its own declaration so that each has its own heartbeat budget: the three bodies
and frontmatters are large enough that one `by` block holding them all times
out. -/

theorem appendixA_typedBlocks (scope : TypeScope) : appendixA.typedBlocks scope = true := by
  cases scope <;> decide

theorem appendixA_byActors (form : ActorForm) : appendixA.byActors form = true := by
  cases form <;> decide

theorem appendixA_authorActors_open : appendixA.authorActors .schemeOrSlash = true := by decide

theorem appendixA_authorActors_any : appendixA.authorActors .unconstrained = true := by decide

theorem appendixA_computations_indented :
    appendixA.computationsProvided .fencedOrIndented = true := by
  decide +kernel

theorem appendixA_computations_any : appendixA.computationsProvided .unconstrained = true := by
  decide

theorem appendixA_footnotes : appendixA.footnotesJoined = true := by decide +kernel

theorem appendixA_familyClauses :
    appendixA.sourcesHaveResource = true ∧ appendixA.generatedHasBy = true
      ∧ appendixA.attestedHaveRuntime = true := by
  decide

theorem appendixA_shapes :
    appendixA.statedTypesHold = true ∧ appendixA.provenanceTypesHold = true
      ∧ appendixA.computationTypesHold = true ∧ appendixA.indexTypesHold = true := by
  decide +kernel

theorem appendixA_rest :
    appendixA.logDatesIso = true ∧ appendixA.verifiedEntriesKeyed = true
      ∧ appendixA.indexFrontmatterClean = true ∧ appendixA.logNewestFirst = true
      ∧ appendixA.contractsComplete = true := by
  decide

/-- Appendix A conforms under every policy but the two readings the text itself
contradicts. -/
theorem appendixA_conformant (p : Policy)
    (hActor : ¬ (p.actorForm = .threeForms ∧ p.actorFields = .withAuthor))
    (hFence : p.inlineComp ≠ .fencedOnly) :
    conformant p appendixA = true := by
  obtain ⟨ft, vk, af, afs, ifm, lo, cf, ic, fl, fc, ts⟩ := p
  cases af <;> cases afs <;> cases ic <;>
    first
    | exact absurd ⟨rfl, rfl⟩ hActor
    | exact absurd rfl hFence
    | simp [conformant, appendixA_typedBlocks, appendixA_byActors, appendixA_authorActors_open,
        appendixA_authorActors_any, appendixA_computations_indented, appendixA_computations_any,
        appendixA_footnotes, appendixA_familyClauses, appendixA_shapes, appendixA_rest,
        ActorFields.gate]

/-- The first reading that rejects Appendix A: §7's three forms reaching
`author`, meeting `author: team:finance-fpa`. -/
theorem appendixA_rejected_actor :
    conformant { Gaps.lax with actorForm := .threeForms, actorFields := .withAuthor } appendixA
      = false := by
  have h : appendixA.authorActors .threeForms = false := by decide
  simp [conformant, Gaps.lax, h, ActorFields.gate]

/-- The second: §10.3's fence only, meeting two indented computations. -/
theorem appendixA_rejected_fence :
    conformant { Gaps.lax with inlineComp := .fencedOnly } appendixA = false := by
  have h : appendixA.computationsProvided .fencedOnly = false := by decide +kernel
  simp [conformant, Gaps.lax, h]

/-- Appendix A's v0.1 form, as written: `timestamp`, and a `# Citations` list in
the body. -/
def appendixAv01 : Bundle :=
  ⟨[(["income-statement.md"],
     ⟨⟨[ ("type", .scalar "Metric"),
         ("title", .scalar "Income statement (fiscal year)"),
         ("description", .scalar "Headline income-statement figures for a fiscal year."),
         ("tags", .seq [.scalar "finance", .scalar "income-statement"]),
         ("timestamp", .scalar "2026-05-28T22:53:05+00:00") ], by simp⟩,
      "# Definition\n" ++
      "The income statement reports revenue and gross profit for a fiscal year.\n\n" ++
      "# Revenue\n" ++
      "Recognized revenue sums `amount` over rows booked to the fiscal year:\n\n" ++
      "    SELECT SUM(amount) AS revenue\n" ++
      "    FROM finance.recognized_revenue\n" ++
      "    WHERE fiscal_year = <year>\n\n" ++
      "# Gross profit\n" ++
      "Gross profit by segment, per the cost-allocation standard:\n\n" ++
      "    SELECT gross_profit FROM fct_income_statement\n" ++
      "    WHERE fiscal_year = <year> AND segment = <segment>\n\n" ++
      "# Citations\n" ++
      "- https://wiki.acme/finance/fpa-handbook\n" ++
      "- https://wiki.acme/finance/revenue-recognition\n" ++
      "- https://wiki.acme/finance/cost-allocation\n"⟩)],
   by simp⟩

/-- The v0.1 form conforms to v0.2 under every policy: `timestamp` is an
extension key and no clause reads `# Citations`. Stronger than §13's
"consumable", and stated nowhere in the text. -/
theorem appendixAv01_conformant (p : Policy) : conformant p appendixAv01 = true :=
  conformant_of_allClausesHold
    { typedBlocks := by intro s; cases s <;> decide, sourcesHaveResource := by decide,
      generatedHasBy := by decide, attestedHaveRuntime := by decide, logDatesIso := by decide,
      statedTypesHold := by decide, provenanceTypesHold := by decide,
      computationTypesHold := by decide, indexTypesHold := by decide,
      verifiedEntriesKeyed := by decide,
      byActors := by intro f; cases f <;> decide, authorActors := by intro f; cases f <;> decide,
      indexFrontmatterClean := by decide, logNewestFirst := by decide,
      contractsComplete := by decide, computationsProvided := by intro f; cases f <;> decide,
      footnotesJoined := by decide +kernel } p

end Okf.V0_2
