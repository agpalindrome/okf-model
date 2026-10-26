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
