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

## Frontmatter is a map too (revised at §4)

§2 made `Frontmatter` an empty structure. §4.1 gives it content: YAML key/value
pairs, one key required, four recommended, any other permitted. A record with a
`type : String` field would make a concept missing `type` unrepresentable, and
§4.1's one MUST would then hold by construction where nothing could observe it.
So the same argument as for `Bundle`: a map from key to `Value`, with the
clauses as predicates in `Okf.V0_2.Document`.

Two commitments come with it. Keys are unique, which YAML's own mapping rules
give us and a parser enforces before the model sees anything. And a `Value`
scalar is its text: YAML resolves `42` to an integer and `"42"` to a string,
the spec never names a YAML schema, and modelling that resolution is parse
work below the trust boundary. The price is that `type: 42` and `type: "42"`
are one value here, so if the spec ever cares about the difference, this is
where the model cannot see it.

## A file's kind follows from its path (revised at §8)

§2 made `Bundle` a map from path to `Concept`. §3.1 says reserved filenames
"have defined meaning at any level of the hierarchy" and "all other `.md` files
are concept documents": the filename decides what a file is. §8 then gives
`index.md` content of its own. So the map is from path to `Document`, the
frontmatter-and-body pair every markdown file is, and `Okf.V0_2.Structure`
defines `Bundle.concepts` and `Bundle.indexes` as filters on the path. A clause
about concepts quantifies over `concepts`.

The §3 module once carried a clause forbidding a `Concept` at a reserved path.
It went with this revision; `Okf.V0_2.Structure` says why.
-/

namespace Okf.V0_2

/-- A location within a bundle: a file's path segments, relative to the bundle
root.

Segments rather than a `String`, because §2 fixes no separator; picking one
here would be picking for the spec. -/
abbrev Path := List String

/-- A YAML node as the model sees it after parsing: the three node kinds YAML
defines, with every scalar carried as its text.

The YAML data model is a commitment the module docstring records, not a
reading of the spec, which says "YAML" and no more. -/
inductive Value where
  | scalar (text : String)
  | seq (items : List Value)
  | map (entries : List (String × Value))
  deriving Repr

/-- The YAML metadata block at the top of a concept document, as a map from key
to `Value`.

`uniqueKeys` is YAML's own rule for a mapping, made visible for the same reason
`Bundle.uniquePaths` is. Which keys mean what is §4.1's business and lives in
`Okf.V0_2.Document`; this structure only holds them. -/
structure Frontmatter where
  entries : List (String × Value)
  uniqueKeys : (entries.map Prod.fst).Nodup

/-- The frontmatter with no keys. §4.1 makes it non-conformant, since `type` is
required; it exists as the smallest value the clauses can be checked on. -/
def Frontmatter.empty : Frontmatter := ⟨[], List.nodup_nil⟩

/-- The value under a key, if the key is present. -/
def Frontmatter.get? (f : Frontmatter) (key : String) : Option Value :=
  f.entries.lookup key

/-- No keys at all. Post-parse, a file with no frontmatter block and a file
with an empty one both land here; §11.1's "contains a parseable YAML
frontmatter block" is parse-side, and §11.2 fails both anyway. -/
def Frontmatter.isEmpty (f : Frontmatter) : Bool :=
  f.entries.isEmpty

/-- Everything in the concept document after the frontmatter.

Text, because that is all §2 makes it, and §6, read, states no rule over body
content either (`Okf.V0_2.Links`). A section that does would force structure
here; extracting it from text is the parse step `docs/scope-and-stance.md`
puts below the trust boundary. -/
abbrev Body := String

/-- One markdown file in the bundle, split into its two parts. Which kind of
file it is, a concept or one of §3.1's reserved files, follows from its path
and is not recorded here.

The split is an input to the model, not something it performs. A `Bundle`
is post-parse — reaching it from a directory of markdown is exactly the work
`docs/scope-and-stance.md` declines to verify. -/
structure Document where
  frontmatter : Frontmatter
  body : Body

/-- §2's single unit of knowledge: a `Document` at a path §3.1 does not reserve.
The name is kept for the §2 term; the type carries nothing the path does not,
so the clauses that apply to concepts quantify over `Bundle.concepts`. -/
abbrev Concept := Document

/-- §2's "self-contained, hierarchical collection of knowledge documents"; the
unit of distribution. Every `.md` file in the tree, concepts and §3.1's
reserved files alike; `Okf.V0_2.Structure` tells them apart by path.

The `uniquePaths` field is the commitment the module docstring records, made
visible rather than hidden inside a map type: it is what makes this a map and
not a list of pairs. -/
structure Bundle where
  entries : List (Path × Document)
  uniquePaths : (entries.map Prod.fst).Nodup

/-- A concept's identity: its path with the `.md` suffix removed.

`Option` because §2's definition presupposes a path ending in `.md` and does
not say what a file failing that is. Answering — by stripping when present and
passing the path through otherwise — would be deciding whether a non-markdown
file can be a concept, which neither §2 nor §3 settles (`docs/findings.md`,
2026-10-26). -/
def conceptId (p : Path) : Option Path :=
  match p.reverse with
  | [] => none
  | last :: rest =>
    if last.endsWith ".md" then
      some ((last.dropEnd 3).toString :: rest).reverse
    else
      none

end Okf.V0_2
