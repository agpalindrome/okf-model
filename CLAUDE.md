# okf-model — repo guide for Claude

A **descriptive** Lean 4 formalization of the [OKF][spec] standard, one model
per OKF revision. Read [`docs/scope-and-stance.md`](docs/scope-and-stance.md)
first — it carries the stance, the trust boundary, and the roadmap, and this
file only adds what an agent needs on top of it.

[spec]: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md

## The one rule this repo turns on

**The model describes; it does not decide.** Where the spec is contradictory or
silent, represent the gap — add a field to `Policy` and prove the readings
separate — rather than picking the reading that seems right. Picking is driving
OKF, which is the one thing this repo exists not to do.

The pressure to resolve is strongest exactly where the gap is most annoying, so
the failure mode looks like helpfulness. If you find yourself writing "the spec
clearly means X", that is the signal to add a `Policy` field instead.

`okf-graph` differing from this model is **expected**, not a defect in either. It
must decide something to run; the model must not.

## Read against the pin, never against `main`

Every module and every finding is read against the exact `okf/SPEC.md` commit in
[`docs/pinned-revision.md`](docs/pinned-revision.md) — **not** the upstream
default branch, which is edited in place under an unchanged version string. If
you fetch the spec to check a clause, fetch it at the pinned SHA. Re-pinning is
deliberate work with its own checklist in that file.

## Build and verify

- `nix develop` (direnv auto-loads it) provides `elan`; `elan` provides the
  `lake`/`lean` shims that read `lean-toolchain`.
- The gate is **`./scripts/lean-check.sh`** — `lake build` plus a `sorry` check.
  Run it before committing. A `sorry` matters more here than in an ordinary Lean
  project: under a separation theorem it would make the repo publish a finding
  about the spec that nothing has proved.
- **CI is the `check` job** — `nix flake check -L` for hygiene, then
  `scripts/lean-check.sh`. Two steps because they cannot be one: `elan`/`lake`
  fetch over the network, which the Nix sandbox forbids. **The required status
  check matches the job's display name — renaming the job silently breaks it.**
- **Repo settings as code:** `scripts/settings.sh --check` diffs the ruleset
  (`.github/rulesets/main.json`) and the About block against live GitHub;
  `--apply` writes them. Owner-run, never wired into CI.
- **Docs lint at 80 columns**, and emphasis style must be consistent within each
  file (MD049 infers it from the first use — this file is asterisk).
- **Prose lints against vale** — `./scripts/prose-check.sh`, also wired as the
  `prose` pre-commit hook and so covered by `nix flake check`. Errors block,
  warnings do not. The rules in `.vale.ini` and `.vale/styles` are **vendored**
  from `~/.claude/vale`: fix a rule there and re-sync, never here. CONTRIBUTING,
  "`prose`, and the rules it enforces", carries the rest.

## Comments and prose

Comments enhance the code; they do not narrate it. This repo argues for its
designs in prose, which is easy to mistake for licence to write a lot — it is
not.

- Keep the reasoning a reader **cannot recover** from the Lean or the spec: why
  a `Policy` field exists, what the spec text actually says, what reading was
  rejected and why.
- Cut restatement of the spec where the definition already carries it, and
  narration of what a proof plainly does.
- A theorem that witnesses a gap should name the spec section in its docstring,
  and the corresponding `docs/findings.md` entry should name the theorem. If
  those two ever disagree, the finding is the one that is wrong.

## Landing changes

- `main` is **PR-only**: no direct pushes, `check` required, squash only. But
  **no merge queue and no required review** — with two contributors those were
  ceremony. So land a PR the ordinary way, `gh pr merge --squash
  --delete-branch`, once CI is green, then `git up`.
- **This is deliberately unlike `pacioli` and `okf-tools`**, the closest
  siblings, where a required owner review means an owner-authored PR needs
  `scripts/merge.sh` and an explicit per-PR ask. That script does **not** exist
  here and should not be reintroduced: it is a ruleset-bypass tool, and there is
  no longer a gate for it to bypass. Don't carry those repos' merge discipline
  over by pattern-matching.
- CODEOWNERS still auto-requests the owner's review on every PR. It informs;
  it no longer blocks.
- Revisit if anyone outside the two contributors starts sending changes — that
  is what the review requirement and the queue were for.
- Repo-level and org-level GitHub settings changes are **seat-only** — spawn a
  `~/github-settings`-seated sub-agent rather than running `gh` here.

## Deletion & creation

- A **new module** is added to `Okf.lean` in dependency order, inside the
  revision namespace it belongs to (`Okf.V0_2`, …). Revisions live side by side;
  a new declared version means a new namespace, not an edit in place.
- Do **not** delete or weaken a **separation theorem** or a `Policy` field
  without a stated reason. Each one is the evidence behind a published finding;
  removing it silently retracts a claim made to the OKF group.
- Do **not** edit `docs/pinned-revision.md`'s SHA as maintenance. Re-pinning
  follows the checklist in that file, and closes findings rather than deleting
  them.
- Treat the **pinned** files as sensitive — `lean-toolchain`,
  `lake-manifest.json`, `flake.lock`, and vale's version in `flake.nix`. Don't
  change them casually.
- Do **not** hand-edit `.vale.ini` or `.vale/styles/**`. They are vendored;
  `~/.claude/scripts/sync-vale.sh --check .` reports the drift an edit creates,
  and the fix belongs upstream in `~/.claude`.
- Do **not** add a checker, a bundle loader for real user input, a normative /
  colouring layer, or Mathlib, without going through the owner. The first three
  belong to `okf-tools`; the fourth was a deliberate choice recorded in
  `lakefile.toml`.
- Do **not** file anything upstream. Findings accumulate in `docs/findings.md`;
  taking one to the OKF group is the owner's call, every time.
