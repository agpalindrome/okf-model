#!/usr/bin/env bash
# Local Lean quality gate for okf-model — the checks run before a change to the
# model is considered done, and the same script CI runs as its `lean` step. Run
# it from inside the dev shell (direnv loads it automatically; otherwise
# `nix develop --command scripts/lean-check.sh`).
#
# What it checks, and why these and not others:
#
#   1. `lake build` — the Lean type-checker is the primary linter. A clean build
#      means every proof is accepted by the kernel and Lean's built-in linters
#      (unused variables, deprecations, …) are satisfied. `lakefile.toml` turns
#      off auto-bound implicits, so signatures can't drift silently either.
#
#   2. sorry-freeness — Lean emits `declaration uses 'sorry'` for any proof that
#      is still a hole. It matters more here than in an ordinary Lean project:
#      a `sorry` under a separation theorem would make this repo publish a
#      finding about the OKF spec that nothing has actually proved. During
#      interactive proving `sorry` is a fine scaffold — this gate is for "done".
#
# There is deliberately no `.lean` autoformatter step: Lean has no mature
# rustfmt-equivalent yet, so layout is convention-guided rather than
# machine-enforced. TOML (`lakefile.toml`) is formatted by `taplo`, and
# Nix/Markdown by the flake's pre-commit hooks.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> lake build"
# Keep lake's own exit status: a missing `lake` prints "command not found",
# which the "error:" grep below does not match.
if build_log="$(lake build 2>&1)"; then build_status=0; else build_status=$?; fi
# Filter the benign macOS linker version warnings (libuv built against a newer
# SDK than the target floor) so real diagnostics stand out.
build_log="$(printf '%s\n' "$build_log" | grep -v 'ld64.lld: warning' || true)"
echo "$build_log"

if [ "$build_status" -ne 0 ]; then
  echo "FAIL: lake build exited $build_status." >&2
  exit 1
fi

if printf '%s\n' "$build_log" | grep -q "error:"; then
  echo "FAIL: lake build reported errors." >&2
  exit 1
fi

echo "==> sorry check"
if printf '%s\n' "$build_log" | grep -qE "uses '(sorry|sorryAx)'"; then
  echo "FAIL: the build reports a proof still using 'sorry'." >&2
  exit 1
fi

echo "OK: build is clean and sorry-free."
