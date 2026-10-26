/-!
# §2 Terminology — the carriers

The types the model works over. §2 states no MUST, SHOULD or MAY, so nothing
here is a clause; the job of this module is to fix carriers precisely enough
that the later sections have something to constrain. Every definition here was
provisional until the last section was read; this docstring describes the
carriers as they stand after §13, and keeps the history below.

## What the carriers are

A `Bundle` is a finite map from `Path` to `Document`, where a `Document` is
the frontmatter-and-body pair every markdown file in the tree is. Which kind of
file a document is, a concept or one of §3.1's reserved files, follows from its
path: `Okf.V0_2.Structure` defines `Bundle.concepts`, `Bundle.indexes` and
`Bundle.logs` as filters, and a clause about concepts quantifies over
`concepts`. `Concept` is kept as an abbreviation for the §2 term.

A `Frontmatter` is a finite map from key to `Value`, where `Value` is YAML's
three node kinds with every scalar carried as its text. A `Body` is a `String`,
read line by line where a later section states a rule over it (§9, §10, and
§5.1's footnotes), and never parsed as markdown.

## Maps, not trees; proved, not structural

`Bundle` is a map rather than an inductive tree of directories. §2 gives us
paths, "Concept ID: the path of the concept's file within the bundle", and
asserts a bundle is "hierarchical" without saying what that means. A tree
constructor would have to answer what the text does not: whether an empty
directory exists, whether a directory is a thing in its own right, whether a
name may repeat at a level. Only files are ever mentioned, and §3 added no
rule over a directory as a thing.

The same argument made `Frontmatter` a map. A record with a `type : String`
field would make a concept missing `type` unrepresentable, and the one MUST of
§4.1 would then hold by construction where nothing could observe it.

Structure in a type is an axiom: it holds by construction, no value can fail
it, and nothing can observe it. A lemma is a claim: it names its hypotheses,
and a later section that contradicts it breaks a proof where we can see it.
Concretely, a tree makes "every concept sits under exactly one root" true by
construction, and that is a thing §2 leaves open (see `docs/pinned-revision.md`
on upstream PR #232). What the type forbids, no `Policy` field can reopen, so
building it in would erase a live gap rather than represent it.

The price is real. The map admits values no directory could produce, an empty
path among them. Those become conditions we state rather than impossibilities,
and each one is a place to ask whether the spec speaks. A tree encoding
isomorphic to this map would be equally faithful and would buy nothing but
different traversals; if one is ever wanted, the obligation is to state the
isomorphism, not to reopen this argument.

## Commitments, recorded

Four things the carriers assume that the text does not state, each recorded
rather than defended:

- Keying `Bundle` on `Path` makes two documents at one path unrepresentable.
  §2's "the path of the concept's file" and the filesystem both give us that.
- Keying `Frontmatter` on `String` makes two values under one key
  unrepresentable. YAML's own mapping rules give us that, and a parser enforces
  it before the model sees anything.
- A `Value` scalar is its text. YAML resolves `42` to an integer and `"42"` to
  a string, the spec never names a YAML schema, and modelling that resolution
  is parse work below the trust boundary. So `type: 42` and `type: "42"` are
  one value here, and if the spec ever cares about the difference, this is
  where the model cannot see it.
- A file with no frontmatter block and a file with an empty one are the same
  `Frontmatter`. §11.1's "contains a parseable YAML frontmatter block" is
  parse-side, and §11.2 fails both anyway.

## Where §2's fifteen terms landed

Every term was provisional until the section that gives it content was read.
None of the ten §2 deferred became a type: an empty type would have asserted a
shape the text had not given, and when the text did give one it was always a
shape over `Value`, which the predicates read in place.

| §2 term | Where it landed |
| --- | --- |
| Knowledge Bundle | `Bundle` |
| Concept | `Document` at an unreserved path; `Concept` the abbreviation |
| Concept ID | `conceptId`, derived; no later section states a rule over it |
| Frontmatter | `Frontmatter` |
| Body | `Body`, a `String` read by lines where a rule needs it |
| Link | nothing: §6 binds no bundle, `Okf.V0_2.Links` |
| Source, Provenance | `sources` entries as `Value`s, `Okf.V0_2.Provenance` |
| Credibility signal | scalar fields of a source, under `fieldTypes` |
| Actor | predicates over a scalar, `Okf.V0_2.Actors` |
| Trust tier | a consumer derivation, not modelled (§5.3, stance) |
| Attested Computation | `Document.isAttestedComputation`, `Okf.V0_2.Computation` |
| Executor, Attester | mapping shapes, under `fieldTypes` |
| Receipt | "not stored in the bundle" by §2's own words; nothing |

## History

Three revisions, each the expected case under `docs/scope-and-stance.md` rather
than a defect. At §4, `Frontmatter` went from an empty structure to the map
above, when §4.1 gave it keys. At §8, `Bundle` went from a map to `Concept` to
a map to `Document`, when §8 gave `index.md` content and §3.1's "all other
`.md` files are concept documents" said how to tell files apart; the §3 clause
forbidding a concept at a reserved path went with it, and `Okf.V0_2.Structure`
says why. At §11, nothing here moved, but the clause over `type` became
non-empty and took a scope.
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
file can be a concept, which no section settles (`docs/findings.md`,
2026-10-26). Carried because §2 defines it; no clause in §3 through §13 reads
a concept ID, and §11 speaks of files. -/
def conceptId (p : Path) : Option Path :=
  match p.reverse with
  | [] => none
  | last :: rest =>
    if last.endsWith ".md" then
      some ((last.dropEnd 3).toString :: rest).reverse
    else
      none

end Okf.V0_2
