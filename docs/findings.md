# Formalization findings

Gaps in the [OKF spec][spec] surfaced by **formalizing** it: contradictions
between the normative prose and the worked examples, constraints stated without
marking their normative force, and places the text is silent. Each entry is
dated, pinned to a SPEC.md SHA, and — where one exists — linked to the Lean
theorem that witnesses it.

The format was established before the first modelling pass so that a finding is
written down when it is found, rather than reconstructed later from
recollection.

[spec]: https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/main/SPEC.md

## The split with okf-tools' friction log

There are two logs, and they are not duplicates. Stated once, so they do not
drift:

- **[`okf-tools/docs/okf-friction.md`][friction]** records friction hit while
  *implementing a checker* — the place where a tool had to decide something to
  run, and what it decided.
- **This log** records gaps found while *formalizing the text* — the place where
  the standard did not decide, established by a proof rather than by an
  implementation choice.

The four entries already in the friction log stay where they are. One that later
acquires a Lean witness gains a **cross-link** from here, not a copy.

[friction]: https://github.com/agpalindrome/okf-tools/blob/main/docs/okf-friction.md

## Entry format

Follow the friction log's shape, plus the two things only this repo can supply:

```markdown
## YYYY-MM-DD — one-line statement of the gap

Pinned: SPEC.md `<sha>` (declared v0.X)
Witness: `Okf.V0_X.Gaps.<theoremName>`

[What the spec says — quoted, with section links.]

**What the model does.** [Which Policy field this becomes, and why the model
does not pick a value for it.]

**The question for upstream.** [One question, answerable by the editors.]

**Raised upstream** / **Not raised upstream** (date, and the reason).
```

## Filing is the owner's call

Every time. A finding is evidence; taking it upstream is a separate decision,
and the default is *not yet*. When something is filed it goes in the working
group's house style — short plain sentences, no section headers, no hard
wrapping — with the Lean witness linked rather than pasted.

## 2026-09-21 — v0.2 changed its timestamp type without a version change

Pinned: SPEC.md `ad30107c` (declared v0.2), against the earlier pin `3fcbb9f8`
(declared v0.2)
Witness: none — no model module exists yet, and this was found by diffing two
pins, not by a proof.

Between the two pins, every timestamp-valued key became "an ISO 8601 datetime
with an explicit UTC offset" (§5 preamble). `stale_after`,
`sources[].last_modified` and `usage_window`'s `from` and `to` were
`YYYY-MM-DD` dates at the earlier pin, and §5.5 and §10.5 now compare
`now >= stale_after` where they compared `today >= stale_after`. The document
still declares version 0.2, and §13, "Changes from v0.1", does not mention the
change.

§12 names two kinds of revision: a minor bump for "backward-compatible
additions" and a major bump for breaking changes such as "renaming required
fields". A change to a field's value type is named by neither, and this one was
made with no bump. A bundle declaring `okf_version: "0.2"` therefore names two
texts that disagree on the type of `stale_after`.

The edit is scoped to frontmatter keys: §9 still requires `log.md` date headings
in `YYYY-MM-DD` form, at both pins.

**What the model does.** Nothing yet. The model is pinned by SHA, so it reads
the datetime text. If a later module has to say what a bundle declaring "0.2"
means, that choice between the two texts is a `Policy` field, not a pick.

**The question for upstream.** Under §12, is changing a field's value type from
a date to a datetime a minor or a major change, and should it have moved the
declared version?

**Not raised upstream** (2026-09-21). Filing is the owner's call.

## 2026-10-26 — §3 does not say what a non-markdown file in the tree is

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: none — `Bundle` holds concept documents only, so the bundle that would
separate the readings is unrepresentable. Widening the carrier to hold files
the text never names was declined as modelling the worry rather than the text.

§3 opens "A bundle is a directory tree of markdown files." §3.1 reserves two
filenames and closes "All other `.md` files are concept documents." §2 defines
a Concept ID as the concept's path "with the `.md` suffix removed". None of the
three says what a regular file without the `.md` suffix is when it sits in the
tree: not part of the bundle, part of it and ignored, or a conformance failure.

The readings separate on a bundle containing one `.txt` beside its concepts:
ignored, it conforms; forbidden, it does not. The in-flight upstream PR on
§3.2 (`docs/pinned-revision.md`) defines a conformance corpus of "regular `.md`
file entries", which would answer the question at a later pin.

**What the model does.** `Okf.V0_2.conceptId` returns `none` for a path not
ending in `.md` rather than passing it through, and `Bundle` cannot hold such a
file. No `Policy` field, for the reason the witness line gives; if the carrier
is ever widened, the two readings become one.

**The question for upstream.** Is a regular file in the tree whose name does
not end in `.md` outside the bundle, inside it and ignored, or a conformance
failure?

**Not raised upstream** (2026-10-26). Filing is the owner's call, and §3.2 may
settle it first.

## 2026-10-26 — §4.1 states value types without saying whether they bind

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.fieldTypes_separates`

§4.1 marks `type` REQUIRED and describes it as "A short string identifying
the kind of concept". Under **Recommended** it describes `title` as a
"Human-readable display name", `description` as "A single sentence",
`resource` as "A URI that uniquely identifies the underlying asset", and `tags`
as "A YAML list of short strings". No RFC 2119 keyword attaches to any of the
five descriptions, and §4.1 closes by saying a concept carrying just `type` is
"fully conformant (§11)", which speaks to presence and not to shape.

So a concept with `tags: sales`, a scalar where a list is described, is
conformant if the descriptions are conventions and not if they are constraints.
Every example in §4 is well-typed, so the separating bundle is invented rather
than the spec's own.

**What the model does.** `Policy.fieldTypes : Force` chooses between the two
readings. `Frontmatter.statedTypesHold` is the strict reading for the five
keys, checking node kind only: scalar for four, a sequence of scalars for
`tags`. "Short", "a single sentence" and URI syntax are not checked, the first
two because nothing can check them and the third because it is parse work
below the trust boundary. The model does not pick a value for the field.

**The question for upstream.** Are the value descriptions in §4.1 normative,
so that a `tags` scalar or a `type` list is non-conformant, or are they
guidance?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §5.2 marks nothing within a `verified` event

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.verifiedEntryKeys_separates`

§5.2 says `generated.by` is "REQUIRED within `generated`". Of `verified` it
says "A list of verification events, each with `by` (an actor) and `at` (an
ISO 8601 datetime)", and marks neither key. §5.3 then derives the trust tier
from whether `verified` has a `human:` actor among its `by` values, and §5.2
says "how recently" is the latest `at`.

So `verified: [{ at: 2026-06-25T09:00:00Z }]` is conformant on the text, and
§5.3 has no answer for it: the event names no actor, so it is neither a
`human:` actor nor a non-`human:` one. The asymmetry with `generated.by`,
marked REQUIRED one paragraph earlier, is the reason to think the omission
may not be deliberate.

**What the model does.** `Policy.verifiedEntryKeys : Force` chooses whether an
event without `by` and `at` is non-conformant. It is a separate field from
`fieldTypes`: a reader can hold the value descriptions as conventions and still
treat `by` as required, because §5.3 computes on it. The strict reading is
`Frontmatter.verifiedEntriesKeyed`, counting a bare mapping as one event as
§5.2's MAY permits. The model does not pick a value.

**The question for upstream.** Are `by` and `at` REQUIRED within a `verified`
event, as `by` is within `generated`?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §5 states shapes and an enumeration without force

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.fieldTypes_separates_on_status`

The same gap as the §4.1 entry above, in the next section. §5 describes
`sources` as a list of entries with scalar fields, `usage_window` and
`generated` as mappings, `verified` as a list of events or one bare mapping,
`status` as `draft | stable | deprecated`, and every timestamp as "an ISO 8601
datetime with an explicit UTC offset". No RFC 2119 keyword attaches to any of
these. The `status` enumeration is the sharpest instance: §5.4 lists three
values in a comment and defines each, and says nothing about a fourth.

**What the model does.** The same `Policy.fieldTypes` field covers §5, through
`Frontmatter.provenanceTypesHold`. One field for both sections because the gap
is one editorial habit, and a second field would separate nothing a reader
could plausibly hold apart. The predicate checks node kinds and the three
`status` values; ISO 8601 syntax and the UTC offset are not checked, as URI
syntax was not, being parse work below the trust boundary.

**The question for upstream.** The §4.1 question, extended: are the shape
descriptions in §5, and the three `status` values, normative?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §7's actor forms carry no force, and §5.1 uses a fourth

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.actorForm_separates`, from the spec's own §5.1 example;
`Okf.V0_2.Gaps.actorForm_separates_unconstrained`, invented

§7 says identity fields "use a single actor convention" and lists three forms:
`<producer>/<version>`, `human:<id>`, `process:<id>`. No RFC 2119 keyword
attaches to the list; the section's one MUST is that producers write `human:`
for hand-authored content, which is a fact about how the content was made and
not about the string. §5.1's example writes `author: team:ga4-docs`, a scheme
none of the three forms names.

So the text supports three readings and uses a fourth form itself. The three
forms bind, and the §5.1 example is wrong where `author` is an actor field. Any
`<scheme>:<id>` or `<producer>/<version>` is admitted, which the example needs.
Or the list is description, and any scalar is an actor.

**What the model does.** `Policy.actorForm : ActorForm` with `threeForms`,
`schemeOrSlash` and `unconstrained`. A separate field from `fieldTypes`, since
this is string content rather than node kind and has three readings rather than
two. Prefixes are checked before the slash, as §5.3 reads the string, and
placeholders are not checked for emptiness. The §7 MUST on `human:` is
recorded in `Okf.V0_2.Actors` as undecidable from a bundle and is not a clause.

**The question for upstream.** Do the three forms in §7 bind, and if so, is
`team:<id>` in §5.1's example an error in the example or a fourth form missing
from §7?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §7 and §5.1 disagree on whether `author` is an actor field

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.actorFields_separates` and
`Okf.V0_2.section5Examples_rejected`, both from the spec's own §5.1 example

§7 opens "Fields that record an identity (`generated.by`, `verified[].by`) use
a single actor convention", naming two fields. §5.1 describes `author` as "Who
or what produced the source, in the actor convention (§7)". §7's own list does
not include it.

The two readings separate on the spec's own text. Under §7's three forms,
§5.1's `author: team:ga4-docs` conforms if §7 stops at its list and fails if it
reaches `author` as §5.1 says. `section5Examples_rejected` is the theorem
`docs/scope-and-stance.md` described before any Lean existed: a spec whose §7
rule rejects its own §5.1 example.

**What the model does.** `Policy.actorFields : ActorFields` with `listedOnly`
and `withAuthor`. It applies whichever `actorForm` is in force to `author` or
not. The model does not pick.

**The question for upstream.** Is `sources[].author` bound by §7, as §5.1 says
and §7's list does not?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §8 says index files contain no frontmatter, without force

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.indexFrontmatter_separates` and
`Okf.V0_2.Gaps.indexFrontmatter_separates_on_depth`, both invented

§8 says "Index files contain no frontmatter, with one exception: a bundle-root
`index.md` MAY carry an `okf_version` key (§12)." The exception carries a MAY;
the rule it excepts carries nothing. §3.1 says the reserved filenames "MUST NOT
be used for concept documents", and frontmatter on an `index.md` is the one way
a consumer can see that a producer did.

So an `index.md` with `title:` in its frontmatter conforms if §8's sentence is
description and not if it binds, and so does an `okf_version` key on an
`index.md` below the root. §8's own text is well-formed, so both witnesses are
invented.

**What the model does.** `Policy.indexFrontmatter : Force`. The strict reading,
`Document.indexFrontmatterClean`, is an empty frontmatter, or at the root one
holding `okf_version` and nothing else. A separate field from `fieldTypes`,
because §3.1's MUST NOT stands behind this rule and a reader can hold it as
binding while holding §4's shape descriptions as conventions. The model does not
pick.

This is also the section that reopened `Bundle`: it now maps paths to
`Document`s and tells concepts from index files by path, as §3.1 says to. The
§3.1 clause that forbade a concept at a reserved path went with it;
`Okf.V0_2.Structure` records why that removes nothing the text decides.

**Revised at §11 (2026-10-26).** §11.3 makes conformance depend on every
`index.md` following "the structure in §8". That gives §8 the force this entry
said it lacked, and moves the gap: whether "contain no frontmatter" is part of
§8's structure, or only the body's sections and bullets are. The field and its
two readings are unchanged.

**The question for upstream.** Is frontmatter on an `index.md`, other than
`okf_version` at the root, a conformance failure?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §9 says newest first without force

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.logOrdering_separates`, invented

§9 says a log's format "is a flat list of date-grouped entries, newest first",
then "Date headings MUST use ISO 8601 `YYYY-MM-DD` form", then that the bold
leading word "is a convention, not a requirement". The section marks one thing
as binding and one as not, and leaves the order between them unmarked. A log
whose dates ascend conforms if "newest first" is description and not if it
binds.

**What the model does.** `Policy.logOrdering : Force`, the field
`docs/scope-and-stance.md` sketched before any Lean existed. The strict
reading, `Document.logNewestFirst`, is non-increasing order of the date
headings compared as strings, which is chronological order whenever the MUST
holds; it admits a repeated date, a pick inside the reading that
`Okf.V0_2.Log` records. The model does not choose.

This is also the first clause that reads a `Body`. The MUST on date form is
modelled with a line-based reading of "date heading", a line opening with two
hashes and a space, which the module docstring states as an approximation of
markdown rather than a parse.

**Revised at §11 (2026-10-26).** §11.3 makes conformance depend on every
`log.md` following "the structure in §9". The gap moves from "no keyword" to
"is order structure"; the field and its two readings are unchanged.

**The question for upstream.** Is "newest first" a requirement on `log.md`,
as the date form is, or a description of the example?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §10.2 marks `executor` and `attester` neither required nor optional

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.contractFields_separates`, invented

§10.2 lists what an Attested Computation concept carries. `runtime` is
"REQUIRED for this type". `computation` is "Optional". `parameters`,
`executor` and `attester` carry neither word. §10.5's informative walk-through
cannot execute without `executor` or attest without `attester`, and §10.1 says
"a single `attester`" describes one computation.

So an Attested Computation with `runtime` and a `computation` path and nothing
else conforms if the unmarked fields are optional and not if the marking of
`runtime` and `computation` was exhaustive and the rest are required.

**What the model does.** `Policy.contractFields : Force`. The strict reading,
`Document.contractComplete`, requires `executor` and `attester` on a concept of
that type. `parameters` is left out of it, because an empty list and an absent
key cannot be told apart in intent and §10.5 runs with none declared; that is a
pick inside the strict reading, recorded in `Okf.V0_2.Computation`.

**The question for upstream.** Are `executor` and `attester` required for an
Attested Computation, as `runtime` is?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §10.3 says fenced, and §10.2's example is indented

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.inlineComp_separates` and
`Okf.V0_2.section10Examples_rejected`, both from the spec's own §10.2 example;
`Okf.V0_2.Gaps.inlineComp_separates_unconstrained`, invented

§10.3 says to "provide the computation in one of two ways": inline, as "a
single fenced code block in the body under `# Computation`", or as a file named
by `computation` with the body fence omitted. The sentence carries no keyword.
§10.2's own example gives its computation under `# Computation` as a block
indented four spaces, with no fence and no `computation` key.

Under the text's own words the example provides its computation neither way.
Under a reading that admits the indented block, which markdown treats as a
code block too, it provides it inline. Under a reading of the sentence as
description, nothing is checked.

**What the model does.** `Policy.inlineComp : InlineCompForm` with
`fencedOnly`, `fencedOrIndented` and `unconstrained`, the second field
`docs/scope-and-stance.md` sketched before any Lean existed. The strict
readings require exactly one of the key and a body block, since "one of two
ways" and "omit the body fence" read as exclusive; "single" is not counted.
The body is read by lines, as `Okf.V0_2.Log` reads it, and
`Okf.V0_2.Computation` records the approximation. `section10Examples_rejected`
is the stance document's scenario a second time: the spec's own example fails
the spec's own rule.

**The question for upstream.** Does an indented code block under
`# Computation` satisfy §10.3, or should the §10.2 example use a fence?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §5.1 keys footnotes to `sources[].id` without force

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.footnoteLabels_separates`, invented; §10.2's example is
the positive case

§5.1 says: "To attribute a specific claim, use a markdown footnote whose label
is a `sources[].id`", and "The footnote label is the join key into `sources`;
consumers resolve attribution through the matching entry". It also says `id`
"SHOULD be present when the body cites the source". No keyword attaches to the
join. §10.2's example demonstrates it, with `[^rev-policy]` and
`id: rev-policy`.

A footnote definition whose label names no `sources[].id` is a claim with no
resolvable attribution. It conforms if the join is description and not if it
binds.

**What the model does.** `Policy.footnoteLabels : Force`. The strict reading,
`Document.footnotesJoined`, requires every footnote definition's label to be
the `id` of some `sources` entry. Definitions are read by lines, a line opening
with `[^`; inline references in prose are not read, and the SHOULD on `id`
presence is not a clause. The entry was parked at §5 and §6 for want of a
readable `Body`, and `Okf.V0_2.Footnotes` records the route.

**The question for upstream.** Is a footnote definition with no matching
`sources[].id` a conformance failure?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §11 defines conformance without the REQUIREDs of §5 and §10

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.familyClauses_separates`, invented

§11 says a bundle "is conformant with OKF v0.2 if" three things hold: every
non-reserved `.md` file has a parseable frontmatter block, every block has a
non-empty `type`, and every reserved file follows §8 and §9. It then says that
when the families are present, "producers SHOULD follow §5 through §10", and
that "consumers SHOULD treat all other constraints as soft guidance".

§5.1 says `resource` is "REQUIRED within an entry". §5.2 says `generated.by`
is "REQUIRED within `generated`". §10.2 says `runtime` is "REQUIRED for this
type". None of the three is among §11's conditions, and §11's SHOULD places all
of §5 through §10 below them. So a concept whose `generated` has no `by`
conforms by §11 and violates §5.2.

**What the model does.** `Policy.familyClauses : Force` gates the three
clauses that come from those REQUIREDs together: §11 is one reading and the
sections' own words the other, and a reader holds one or the other of the whole
set. §9's date-form MUST stays unconditional, because §11.3 binds "the
structure in §9". The model does not pick.

**The question for upstream.** Are the REQUIRED fields of §5.1, §5.2 and §10.2
conformance conditions, or does §11's list define conformance and demote them
to guidance?

**Not raised upstream** (2026-10-26). Filing is the owner's call.

## 2026-10-26 — §11.2 read literally rejects §8's root `okf_version`

Pinned: SPEC.md `ad30107c` (declared v0.2)
Witness: `Okf.V0_2.Gaps.typeScope_separates` and
`Okf.V0_2.rootIndexWithVersion_rejected`, both from §8's own exception

§11.2: "Every frontmatter block contains a non-empty `type` field." §8: "a
bundle-root `index.md` MAY carry an `okf_version` key". A root `index.md` with
`okf_version: "0.2"` has a frontmatter block and no `type`. §11.1 speaks of
"every non-reserved `.md` file", and §11.2 may inherit that scope or may not;
the text does not say.

Read literally, §11.2 rejects the one form §8 permits. Read as scoped by §11.1,
it does not. It is the third time a rule in one section rejects a form another
section gives.

**What the model does.** `Policy.typeScope : TypeScope` with `conceptsOnly`
and `everyBlock`, and clause two takes it as a parameter. Under `everyBlock` a
reserved file with an empty frontmatter passes, since the model cannot tell an
absent block from an empty one and §11.1 is parse-side. §11.2's "non-empty" is
read for any node kind, with the kind left to `fieldTypes`.

**The question for upstream.** Does §11.2 reach a root `index.md` carrying
`okf_version`, or is it scoped to the non-reserved files of §11.1?

**Not raised upstream** (2026-10-26). Filing is the owner's call.
