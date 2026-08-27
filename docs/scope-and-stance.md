# Scope and stance

What this repo is for, what it certifies, and what it deliberately does not do.
Written 2026-07-31, before any Lean was written, from [okf-tools#69][i69].

[i69]: https://github.com/ojhermann-org/okf-tools/issues/69

## Position in the stack

`okf > okf-graph > okf-normative > applications`. This repo sits **upstream of
the tooling**, as the object both `okf-tools` crates are read against — not as a
member of that workspace. A workspace member would invert the dependency: the
tool would own its own spec.

Its versions track **OKF revisions**, on OKF's cadence, not `okf-tools`
releases.

## Stance: descriptive, not prescriptive

The model mirrors what the text gives us. It does not drive OKF, does not
"improve" it, and does not resolve its gaps. **Both the normative prose and the
worked examples count as source** — a spec whose §7 rule rejects its own §5.1
example has told us something, and the model's job is to say so precisely rather
than to pick a winner.

So the model and `okf-graph` may legitimately disagree, and that is not a bug in
either. `okf-graph` must decide something to run — it accepts `team:` actors
permissively. The model testifies that the standard itself did not decide.

### How a gap is represented

Conformance is **parameterized over an explicit policy record whose fields are
exactly the spec's open choices**:

```lean
structure Policy where
  actorForm   : ActorForm      -- §7 strict-three vs. ⟨scheme⟩:⟨id⟩
  inlineComp  : InlineCompForm -- §10.3 fenced-only vs. fenced-or-indented
  scopeMarker : ScopeRule      -- §5.1/§6.2 scope descriptor vs. path
  logOrdering : Force          -- §9 "newest first" — required, or convention
  -- one field per gap; adding a field is how a new gap enters the model
```

Two theorem shapes carry the stance, and every gap gets both where it can:

- **Separation** — the gap is observable:
  `∃ b, conformant p₁ b ≠ conformant p₂ b`.
- **Witness from the spec's own text** — the separating bundle is *the spec's
  example*, not one we invented.

`okf-graph`'s actual behaviour is then a named value, `okfGraphPolicy`, so its
permissiveness is auditable in one place instead of inferred from `if`
statements — the "enumerable rather than implicit" property the okf-stack board
asks of the graph layer.

**Rejected: three-valued conformance** (`yes` / `no` / `undetermined`). It looks
like the honest encoding and is not. It bakes a judgment about *which* clauses
are undetermined into the return type of the predicate, so the model's opinion
becomes invisible rather than explicit; and it costs decidability, which the
fixtures need. Parameterization keeps the model opinion-free *and* executable.
Recorded because it is the obvious first idea.

## What is certified — and the trust boundary

**Certified.** For an abstract `Bundle` value, a Lean theorem naming exactly
which clause it satisfies or violates, under a named `Policy`. Conformance is a
`Bool`-valued function paired with its `Prop` and a bridging lemma
(`conformant_iff`), rather than a `Prop` discharged by `decide` — the `Bool` side
is what executes on fixtures without elaborator blowup on large structures.

**Not certified, and never to be claimed:**

- **Nothing about `okf-graph`.** No theorem here says the Rust checker is
  correct. The fixtures are a **cross-check**, not a proof.
- **Bytes on disk.** Emitting a fixture goes through a Lean *serializer*, and
  `okf-tools` reads it back through *its own* parser. Both are unverified glue.
  A `parse (render b) = some b` round-trip theorem would shrink the trusted glue
  to one side; it would not eliminate it.
- **Abstraction fidelity.** The map from a directory of markdown to a `Bundle`
  (YAML frontmatter, link extraction) is where `okf-graph` does most of its real
  work, and this repo does not verify it. The model's reach begins *after* that
  abstraction.

This is the same discipline `okf-tools` states about fidelity: say what the gate
actually is, rather than implying more.

## How the modelling proceeds

**Down the document, section by section, revising as we go.** A pass reads one
section of the pinned `SPEC.md`, models what that section's own text supports,
and stops there. Nothing commits in advance to a list of sections, or to an
order other than the spec's own.

Revision is the expected case rather than the exception. §2 defines `Actor` and
`Receipt` in a line each and leaves their content to §7 and §10, so a model of
§2 written before those sections is *meant* to be reopened once they are read.
A definition here is provisional until every section constraining it has been
read.

Read against the pinned revision in [`pinned-revision.md`](pinned-revision.md) —
note that §3.2 / §11 have an in-flight upstream PR.

**Out of scope, deliberately:** the normative / semantic layer (that is
`okf-normative`'s, and modelling it here would invert the same dependency this
repo exists to keep straight); undecided items such as §5.3 trust-tier ownership
([okf-tools#62][i62]); and anything requiring domain knowledge.

[i62]: https://github.com/ojhermann-org/okf-tools/issues/62

## Two purposes, unequally weighted

1. **Reference for `okf-tools`** — made concrete, so it cannot decay to
   prose-only cross-reference, via conformance fixtures the model emits (a clean
   bundle plus one per violation class) which `okf-tools` tests against. This is
   the purpose carrying the repo.
2. **Feedback to the OKF group** — the formalization pass surfaces
   contradictions and under-specification; each becomes a dated, revision-pinned
   entry in [`findings.md`](findings.md). **Which findings get filed is the
   owner's call**, every time.

Purpose 2 is currently **unproven**: the three issues raised upstream on
2026-07-26 have sat with no response. That is a reason to let findings accumulate
as a dated local record rather than to build around an assumption that filing is
imminent — not a reason to change scope.

## Non-goals

- No checker. This repo does not compete with `okf-graph`, does not read a real
  bundle off disk, and never validates for a user.
- No normative layer, no colouring, no seam.
- No resolution of a spec gap, however obvious the fix looks. Adopting a
  resolution is driving OKF.
- No claim that anything in `okf-tools` is verified.
- No release cadence tied to `okf-tools`.

## Open, deliberately

- The fixture bridge to `okf-tools` — its direction, its format, and whether it
  is built at all.
- Whether a round-trip theorem is worth its cost.
- Whether inter-revision theorems (§13 "changes from") are worth stating — the
  layout keeps them possible; nothing commits to writing them.
- Hermetic Lean in Nix — see [CONTRIBUTING](../CONTRIBUTING.md); revisit only if
  CI fetch flakiness actually bites.
