# Contributing to okf-model

This repo formalizes a specification it does not own. That shapes everything
below: the point is to describe OKF exactly as written, including where it is
inconsistent, and to be able to prove that description.

Read [`docs/scope-and-stance.md`](docs/scope-and-stance.md) first.

## The one decision every change turns on

For any clause you are modelling: **did the spec decide this, or not?**

- **Decided** — model it directly. The definition is the spec's sentence, in
  Lean.
- **Not decided** — do not choose. Add a field to `Policy`, give it a constructor
  per defensible reading, and prove the readings separate on a concrete bundle —
  ideally one the spec itself prints. Then write the `docs/findings.md` entry.

"Not decided" includes three shapes worth naming, because all three have already
turned up in `okf-tools`: normative prose that contradicts a worked example; a
constraint stated without marking its normative force (is it a MUST or a
convention?); and a distinction the text relies on but gives no syntax for.

Resolving one of these in Lean would be **driving OKF**. It is the failure mode
this repo is built to avoid, and it always arrives disguised as being helpful.

## Development setup

```sh
nix develop                 # or let direnv load it on cd
./scripts/lean-check.sh     # lake build + a sorry check
```

With direnv, create the untracked local shim once per clone:

```sh
printf 'source_env .envrc.shared\n' > .envrc
direnv allow
```

The dev shell provides `elan`, which provides the `lake`/`lean` shims that read
`lean-toolchain`.

## Dependency management — Lake's, not Nix's

Worth stating plainly, because the sibling repos differ and the wrong assumption
is easy to make:

- **`okf-tools` builds Rust hermetically in Nix** — deps vendored from
  `Cargo.lock`, no network — so its `nix flake check` genuinely compiles and
  tests everything.
- **This repo does not do the equivalent for Lean.** The flake supplies `elan`
  and the hygiene tooling *around* Lean; `elan` fetches the pinned compiler and
  `lake` fetches Batteries over the network, per `lean-toolchain` and
  `lake-manifest.json`. Reproducible **by pin**, not hermetic.

Accepted deliberately. Hermeticity would mean nixpkgs' `lean4` — which is
**4.30.0**, not the 4.32.0 chosen for Pacioli parity — so it costs an overlay or
`lean4-nix` plus a vendored Batteries, and dropping `elan` breaks the `lake serve`
path the VS Code and Helix tooling expects. With no Mathlib the fetch is small
and a source build of Batteries is cheap. Revisit only if CI fetch flakiness
actually bites.

**No Mathlib**, likewise deliberate: the v0.2 structural fragment is strings,
lists, paths and finite maps. The rationale is recorded in `lakefile.toml`.

## What the checks enforce

CI is one job, **`check`**, with two steps:

1. `nix flake check -L` — nixfmt, deadnix, statix, markdownlint (80 columns),
   check-yaml, whitespace/EOF. Exactly the local pre-commit set, so CI and the
   dev shell agree.
2. `nix develop --command ./scripts/lean-check.sh` — `lake build` plus the
   `sorry` check, outside the Nix sandbox where the network is available.

Two steps because they cannot be one command: a Nix build sandbox has no network,
so `nix flake check` cannot build Lean here. A check that passed without
type-checking anything would be worse than no check.

The job is named `check`, not `nix flake check` as the sibling repos are,
precisely because it is more than that. **The ruleset requires this job by its
display name — renaming the job silently breaks the requirement.**

There is no `.lean` autoformatter: Lean has no mature rustfmt-equivalent, so
layout is convention-guided. TOML is formatted by `taplo`.

## House style

- Prose and comments wrap at **80 columns**; emphasis style is consistent within
  each file.
- A theorem that witnesses a spec gap names the section in its docstring, and the
  `docs/findings.md` entry names the theorem.
- Quote the spec where the exact words are load-bearing, and cite the section.
  Paraphrase drifts, and the drift is invisible.

## Contributing a change

Small, deliberate steps aimed at a clear model rather than at coverage. Prefer
the change that makes the model easier to read against the spec.

Before opening (or un-drafting) a PR:

- `./scripts/lean-check.sh` is green, and no `sorry` remains in anything
  load-bearing.
- New `Policy` fields, if any, have both a separation theorem and a
  `docs/findings.md` entry.
- Anything read from the spec was read **at the pinned SHA**.

`main` is PR-only — no direct pushes, `check` required, squash only — but with
**no merge queue and no required review**. With two contributors those were
ceremony rather than safety, so a green PR lands the ordinary way:

```sh
gh pr merge --squash --delete-branch
git up          # or: git remote update -p && git merge --ff-only @{u}
```

CODEOWNERS still requests the owner's review on every PR, which informs without
blocking. This is worth revisiting the moment anyone outside the two
contributors starts sending changes: the review requirement and the queue are
the tools for that case, and both are one edit to
`.github/rulesets/main.json` away.

## Findings go no further than this repo by default

`docs/findings.md` is a local record. Taking any of it to the OKF working group
is a separate, per-item decision by the owner — and when it happens it goes in
their house style: short plain sentences, no section headers, no hard wrapping,
the Lean witness linked rather than pasted.
