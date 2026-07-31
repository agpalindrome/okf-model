# Formalization findings

Gaps in the [OKF spec][spec] surfaced by **formalizing** it: contradictions
between the normative prose and the worked examples, constraints stated without
marking their normative force, and places the text is simply silent. Each entry
is dated, pinned to a SPEC.md SHA, and — where one exists — linked to the Lean
theorem that witnesses it.

**No entries yet.** The format is established here before the first modelling
pass so that a finding is written down when it is found, rather than
reconstructed later from recollection.

[spec]: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md

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

[friction]: https://github.com/ojhermann-org/okf-tools/blob/main/docs/okf-friction.md

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
