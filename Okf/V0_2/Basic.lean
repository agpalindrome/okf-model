/-!
# §2 Terminology — the carriers

The types §2 gives us, and nothing more. §2 states no MUST, SHOULD or MAY, so
there is nothing here to prove yet; its job is to fix carriers precisely enough
that a later section has something to constrain.

## Bundles are maps, not trees

A `Bundle` is a finite map from path to `Concept`, deliberately not an
inductive tree of directories.

§2 gives us paths — "Concept ID: the path of the concept's file within the
bundle" — and asserts a bundle is "hierarchical" without saying what that
means. A tree constructor would have to answer what the text does not: whether
an empty directory exists, whether a directory is a thing in its own right,
whether a name may repeat at a level. Only files are ever mentioned.

So hierarchy is a relation over paths, proved, rather than a shape built into
the type.

### Why proved rather than structural

Structure in a type is an axiom: it holds by construction, no value can fail
it, and nothing can observe it. A lemma is a claim: it names its hypotheses,
and a later section that contradicts it breaks a proof where we can see it.

Concretely, a tree makes "every concept sits under exactly one root" true by
construction — and that is the thing §2 leaves open (see
`docs/pinned-revision.md` on upstream PR #232). What the type forbids, no
`Policy` field can reopen, so building it in would erase a live gap rather
than represent it.

The price is real. The map admits values no directory could produce, an empty
path among them. Those become conditions we state rather than impossibilities,
and each one is a place to ask whether the spec speaks.

The map is not assumption-free: keying on `Path` makes two concepts at one
path unrepresentable. §2's "the path of the concept's file" and the
filesystem both give us that, so it is recorded rather than defended — but it
is a commitment, not a neutrality.

A tree encoding *isomorphic* to this map would be equally faithful, and would
buy nothing but different traversals. If one is ever wanted, the obligation is
to state the isomorphism, not to reopen this argument.

## What §2's fifteen terms become here

**Carried** — Knowledge Bundle, Concept, Frontmatter, Body, plus `Path`, which
§2 uses without naming.

**Derived** — Concept ID, a function of a path rather than a field. Carried, it
could disagree with the path it is supposed to be, and an invariant would be
needed to forbid that; derived, the disagreement is unrepresentable.

**Deferred** — the remaining ten, which §2 names and then hands off: Link and
Source and Provenance, whose content is a markdown link and a frontmatter field
§2 does not give us; Credibility signal (§5.1), Actor (§7), Trust tier (§5.3),
Attested Computation (§10), Executor (§10.2), Receipt (§10), Attester (§10.2).

They get no stub types. An empty type would assert that the thing exists and
has the shape we guessed, which is more than §2 says.
-/

namespace Okf.V0_2

/-- A location within a bundle: a file's path segments, relative to the bundle
root.

Segments rather than a `String`, because §2 fixes no separator; picking one
here would be picking for the spec. -/
abbrev Path := List String

/-- The YAML metadata block at the top of a concept document.

Empty on purpose. §2 says a frontmatter block exists and is YAML; it names not
one field, so the model has nothing to record. §4.1 is where fields arrive, and
this structure is where they land. -/
structure Frontmatter where
  deriving DecidableEq, Repr

/-- Everything in the concept document after the frontmatter.

Text, because that is all §2 makes it. §6 gives links a meaning, which may
force a structured body later; extracting them from text is the parse step
`docs/scope-and-stance.md` puts below the trust boundary. -/
abbrev Body := String

/-- A single unit of knowledge: one markdown document, split into its two
parts.

The split is an input to the model, not something it performs. A `Bundle`
is post-parse — reaching it from a directory of markdown is exactly the work
`docs/scope-and-stance.md` declines to verify. -/
structure Concept where
  frontmatter : Frontmatter
  body : Body
  deriving DecidableEq, Repr

/-- A self-contained collection of concept documents; the unit of distribution.

The `uniquePaths` field is the commitment the module docstring records, made
visible rather than hidden inside a map type: it is what makes this a map and
not a list of pairs. -/
structure Bundle where
  entries : List (Path × Concept)
  uniquePaths : (entries.map Prod.fst).Nodup

/-- A concept's identity: its path with the `.md` suffix removed.

`Option` because §2's definition presupposes a path ending in `.md` and does
not say what a file failing that is. Answering — by stripping when present and
passing the path through otherwise — would be deciding whether a non-markdown
file can be a concept, which §2 leaves to §3. -/
def conceptId (p : Path) : Option Path :=
  match p.reverse with
  | [] => none
  | last :: rest =>
    if last.endsWith ".md" then
      some ((last.dropEnd 3).toString :: rest).reverse
    else
      none

end Okf.V0_2
