import Okf.V0_2.Provenance
import Okf.V0_2.Policy

/-!
# §7 Actor convention — two gaps, and the spec's own example as witness

§7 is six lines: two fields "use a single actor convention", three forms, and
one MUST. The model reads two gaps in it, and the second is the one
`docs/scope-and-stance.md` named before any Lean was written: a §7 rule that
rejects the spec's own §5.1 example.

## The forms carry no keyword

"Use a single actor convention" is indicative, and §5.1's example writes
`author: team:ga4-docs`, a fourth scheme. Three readings are live: the three
forms bind; any `<scheme>:<id>` or `<producer>/<version>` is fine, which is
what upstream's own example needs; nothing binds beyond being a scalar.
`Policy.actorForm` holds the choice. It is a separate field from `fieldTypes`
because this is string content, not node kind, and because it has three
readings where `Force` has two. `docs/findings.md`, 2026-10-26, "§7's actor
forms carry no force, and §5.1 uses a fourth".

## Which fields §7 reaches

§7 names `generated.by` and `verified[].by`. §5.1 says `author` is "in the
actor convention (§7)". §7's own list omits it. `Policy.actorFields` holds the
choice, and it is what makes the §5.1 snippet a witness: under `threeForms`
with `withAuthor`, it is non-conformant (`Okf.V0_2.section5Examples_rejected`).
`docs/findings.md`, 2026-10-26, "§7 and §5.1 disagree on whether `author` is
an actor field".

## The MUST the model cannot carry

Producers MUST write `human:` for "hand-authored or human-confirmed content".
Whether content was hand-authored is a fact about the world, not about the
bundle, so no predicate over a `Bundle` decides it. It is the first bundle-side
MUST the model records and does not model, and it is recorded here rather than
silently dropped.

## Grammar commitments

`human:a/b` has a prefix and a slash. The predicate checks prefixes first,
which is how §5.3 reads the string. Placeholders are not checked for
emptiness: `human:` alone passes `threeForms`, as an empty path segment passes
§3. Under a constraining form a non-scalar `by` fails, since a mapping is not
an actor string in any reading; under `unconstrained` nothing is checked, and
the scalar question stays with `fieldTypes`.
-/

namespace Okf.V0_2

/-- `s` begins with `prefix`, on the character lists so that `decide` can
evaluate it. -/
def strPrefix (pre s : String) : Bool :=
  pre.toList.isPrefixOf s.toList

/-- `s` contains the character `c`, on the character list for the same reason. -/
def strHas (c : Char) (s : String) : Bool :=
  s.toList.contains c

/-- §7's three forms: a `human:` or `process:` prefix, or a `/`. -/
def isThreeFormActor (s : String) : Bool :=
  strPrefix "human:" s || strPrefix "process:" s || strHas '/' s

/-- The open reading: any `<scheme>:<id>` or `<producer>/<version>`. -/
def isSchemeOrSlashActor (s : String) : Bool :=
  strHas ':' s || strHas '/' s

/-- Which values a reading admits as an actor. -/
def ActorForm.accepts : ActorForm → Value → Bool
  | .unconstrained, _ => true
  | .threeForms, .scalar s => isThreeFormActor s
  | .schemeOrSlash, .scalar s => isSchemeOrSlashActor s
  | _, _ => false

/-- The two fields §7 names, `generated.by` and every `verified[].by`, each
admitted by `ok` when present. -/
def Frontmatter.byActors (f : Frontmatter) (ok : Value → Bool) : Bool :=
  f.keyHolds "generated" (fun g => g.keyHolds "by" ok)
    && f.keyHolds "verified" (fun v => v.verifiedEvents.all fun e => e.keyHolds "by" ok)

/-- Every `sources[].author`, admitted by `ok` when present. -/
def Frontmatter.authorActors (f : Frontmatter) (ok : Value → Bool) : Bool :=
  f.keyHolds "sources" fun v => v.items.all fun e => e.keyHolds "author" ok

/-- §7 over the bundle, for the fields §7 names, under reading `form`. -/
def Bundle.byActors (b : Bundle) (form : ActorForm) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.byActors form.accepts

/-- The `Prop` reading of `Bundle.byActors`. -/
def Bundle.ByActors (b : Bundle) (form : ActorForm) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.byActors form.accepts = true

theorem Bundle.byActors_iff (b : Bundle) (form : ActorForm) :
    b.byActors form = true ↔ b.ByActors form := by
  simp [Bundle.byActors, Bundle.ByActors]

/-- §7 over the bundle, for `author`, under reading `form`. Whether it applies
is `Policy.actorFields`. -/
def Bundle.authorActors (b : Bundle) (form : ActorForm) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.authorActors form.accepts

/-- The `Prop` reading of `Bundle.authorActors`. -/
def Bundle.AuthorActors (b : Bundle) (form : ActorForm) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.authorActors form.accepts = true

theorem Bundle.authorActors_iff (b : Bundle) (form : ActorForm) :
    b.authorActors form = true ↔ b.AuthorActors form := by
  simp [Bundle.authorActors, Bundle.AuthorActors]

end Okf.V0_2
