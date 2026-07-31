# okf-model

A **descriptive** Lean 4 formalization of the [Open Knowledge Format][spec], one
model per OKF revision, starting with v0.2.

It sits **upstream of the tooling** — `okf > okf-graph > okf-normative >
applications` — as the object the [`okf-tools`][tools] crates are read against,
rather than as a member of that workspace.

[spec]: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md
[tools]: https://github.com/ojhermann-org/okf-tools

## Descriptive, not prescriptive

The model mirrors what the OKF text gives us. It does not drive OKF and does not
"improve" it. Both the normative prose and the worked examples count as source,
and **where the spec is contradictory or silent the model represents the gap
rather than resolving it** — adopting a resolution would be driving.

So this model and `okf-graph` may legitimately differ. `okf-graph` has to decide
something in order to run; the model testifies that the standard itself did not
decide. Gaps are represented by parameterizing conformance over a `Policy` record
whose fields *are* the spec's open choices, and proving the choices observably
separate — witnessed, where possible, by the spec's own examples.

## What it certifies, and what it does not

Read [`docs/scope-and-stance.md`](docs/scope-and-stance.md) before relying on
anything here. In short:

- **Certified:** for an abstract `Bundle` value, a theorem naming exactly which
  clause it satisfies or violates, under a named `Policy`.
- **Not certified:** anything about `okf-graph` — no theorem here says the Rust
  checker is correct; the fixtures are a **cross-check, not a proof**. Nor the
  bytes on disk (serializing and re-parsing a fixture is unverified glue at both
  ends), nor the map from a directory of markdown to a `Bundle`, which is where
  `okf-graph` does most of its real work.

## Status

**Skeleton.** The toolchain is wired and green; no model exists yet. The first
pass covers the v0.2 structural fragment, built in small reviewed increments —
see the roadmap in `docs/scope-and-stance.md`.

The spec revision under study is pinned by **commit SHA**, not by the string
"v0.2": upstream has no tags or releases and edits the text in place. See
[`docs/pinned-revision.md`](docs/pinned-revision.md).

## Build

```sh
nix develop                 # or let direnv load it on cd
./scripts/lean-check.sh     # lake build + a sorry check
```

Lean and Batteries are pinned at **v4.32.0** by `lean-toolchain` and
`lake-manifest.json` — **by Lake, not by the flake**, which supplies `elan` and
the hygiene tooling around Lean. Deliberately no Mathlib. See
[CONTRIBUTING](CONTRIBUTING.md) for why, and for what CI enforces.

## Findings

Formalizing a specification surfaces contradictions and under-specification.
Each becomes a dated, revision-pinned entry in
[`docs/findings.md`](docs/findings.md), linked to the Lean theorem that witnesses
it. Whether any of it goes upstream is a separate decision, taken case by case.

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
