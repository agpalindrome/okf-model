#!/usr/bin/env bash
# Lint authored prose against the vendored house-style rules (`.vale.ini`,
# `.vale/styles`). Run it from the root of a checkout — the dev shell provides
# the pinned `vale`, and the flake's `prose` pre-commit hook runs this same
# file, so a local run and CI cannot diverge.
#
# The rules are the word-level half of the owner's prose.md. They are vendored
# by `~/.claude/scripts/sync-vale.sh` rather than referenced: a machine-global
# styles directory is invisible to CI, and a `vale sync` package needs a public
# host that the private source repo cannot be. `sync-vale.sh --check .` reports
# drift against the source.
#
# Three decisions this encodes, from agpalindrome/claude#21:
#
#   1. Errors block, warnings do not. That needs no flag — vale's exit code is
#      errors-only whatever `MinAlertLevel` chooses to print.
#   2. `--no-global` is required. Without it vale merges a machine-global styles
#      directory on top of the vendored one, which is how a local run comes to
#      disagree with CI while both look correctly configured.
#   3. An empty file list is a failure, not a pass. `vale` with no path argument
#      lints stdin, finds nothing, and exits 0 — a green check over no prose at
#      all. That hole shipped into the source repo's own CI once. Here the list
#      is discovered rather than handed in, so a broken discovery is the only
#      way it can empty, and it stops rather than passing.
#
# Discovery is `find`, not `git ls-files`: `nix flake check` runs this against a
# copy of the source tree that has no `.git` in it.
set -euo pipefail

if [ ! -f .vale.ini ]; then
  echo "prose-check: no .vale.ini here — run this from the repo root" >&2
  exit 1
fi

# A working tree carries markdown belonging to dependencies and to the direnv
# profile. The Nix source copy has already dropped those, so this prune matters
# only for the local run — which is exactly the run that must agree with CI.
files=()
while IFS= read -r -d '' f; do
  files+=("$f")
done < <(
  find . \
    \( -name .git -o -name .lake -o -name .direnv \
    -o -name result -o -name 'result-*' \) -prune \
    -o -type f -name '*.md' -print0
)

if [ "${#files[@]}" -eq 0 ]; then
  echo "prose-check: no markdown found — the discovery is broken, not the repo" >&2
  exit 1
fi

echo "==> $(vale --version) over ${#files[@]} file(s)"
exec vale --no-global --config .vale.ini "${files[@]}"
