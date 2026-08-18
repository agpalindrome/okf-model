{
  description = "okf-model — descriptive Lean 4 formalization of the Open Knowledge Format (OKF)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, git-hooks, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Hygiene only: Nix formatting/lint, markdown, YAML, and whitespace.
      #
      # The Lean gate is deliberately NOT here. `elan` fetches the pinned
      # compiler and `lake` fetches Batteries over the network, which a Nix build
      # sandbox forbids — so `nix flake check` cannot build Lean under this
      # arrangement, and pretending otherwise would give a check that passes
      # without type-checking anything. CI runs `scripts/lean-check.sh` as a
      # second step of the same job instead (`.github/workflows/ci.yml`), where
      # the network is available. See CONTRIBUTING, "What the checks enforce".
      hooksFor =
        system:
        git-hooks.lib.${system}.run {
          src = ./.;
          # `prek` rather than the default `pkgs.pre-commit`, for the shape of
          # the hook each one installs into `.git/hooks/`.
          #
          # That file is generated and untracked, so it cannot be fixed by
          # editing it. `pre-commit`'s template writes a `/nix/store` path as
          # its shebang *and* execs a second one, neither guarded — and while
          # git-hooks.nix roots the hook *entries* by making
          # `.pre-commit-config.yaml` an indirect GC root, nothing roots the
          # driver or that bash. They survive only as long as the untracked
          # `.direnv` profile happens to hold them, and when a collection takes
          # the shebang the failure names nothing useful: git reports `cannot
          # exec '.git/hooks/pre-commit': No such file or directory` about a
          # file that is present and executable, because what is missing is the
          # interpreter on its first line (measured 2026-08-12). `prek` pins its
          # path too, but takes `#!/bin/sh` and guards the pin with a test that
          # falls back to `PATH` — where the dev shell already supplies it.
          #
          # Upstream recommends the switch (git-hooks.nix README), the option is
          # first-class, and `usingPrek` gates only the unused `priority` field.
          #
          # That guard is upstream's and untracked here, so `hook-fallback`
          # below is what notices if a prek release drops it.
          package = nixpkgs.legacyPackages.${system}.prek;
          hooks = {
            # `nixfmt` (not `nixfmt-rfc-style`): as of nixpkgs 25.11 the RFC 166
            # formatter *is* `pkgs.nixfmt`, and the old alias warns on eval.
            nixfmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            check-merge-conflicts.enable = true;
            check-added-large-files.enable = true;
            trim-trailing-whitespace.enable = true;
            end-of-file-fixer.enable = true;
            check-yaml.enable = true;
            markdownlint = {
              enable = true;
              settings.configuration = {
                MD013 = {
                  # line length — prose wraps at 80 for terminal review; tables
                  # and code blocks (ASCII trees) can't reflow, so exempt them.
                  line_length = 80;
                  tables = false;
                  code_blocks = false;
                };
                MD033 = false; # inline HTML
                MD036 = false; # emphasis-as-heading — prose uses emphasis stylistically
                MD040 = false; # fenced code language not required (ASCII trees)
                MD025.front_matter_title = ""; # don't treat YAML front-matter title as an H1
              };
            };
          };
        };

      # What `prek` bought above is one property of a file this repo neither
      # tracks nor owns: the generated hook guards its pinned store path and
      # falls back to `PATH`. A prek release that dropped the guard would leave
      # this repo green and silently back to the failure #3 reports, which is
      # why the property is checked rather than assumed. The check installs the
      # real hook and takes its pinned path away; `scripts/check-hook-fallback.sh`
      # carries the reasoning and the failure messages.
      hookFallbackFor =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.runCommandLocal "hook-fallback"
          {
            nativeBuildInputs = [
              pkgs.git
              pkgs.prek
            ];
          }
          ''
            ${pkgs.bash}/bin/bash ${./scripts/check-hook-fallback.sh}
            touch $out
          '';
    in
    {
      checks = forAllSystems (system: {
        pre-commit = hooksFor system;
        hook-fallback = hookFallbackFor system;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          hooks = hooksFor system;
        in
        {
          default = pkgs.mkShell {
            # Retire the hooks the previous driver left behind, in any clone
            # that predates the `prek` switch above.
            #
            # Switching drivers is not enough on its own, and the reason is not
            # visible from either tool's docs. `prek install` refuses to discard
            # a hook it did not write: it moves it to `<hook>.legacy` and then
            # runs it too, so the pinned shebang stays on the commit path.
            # `prek uninstall` puts it back — and git-hooks.nix uninstalls every
            # hook type before it installs, so each reinstall resurrects the
            # pinned file rather than converging away from it (measured
            # 2026-08-12 against prek 0.4.4 in a scratch repo).
            #
            # Deleting it after the install breaks that cycle: the next entry
            # finds nothing to restore and installs clean. The generator marker
            # is what makes this safe to do unasked — it matches only a file
            # `pre-commit` wrote, never a hand-written hook someone parked here.
            shellHook = hooks.shellHook + ''
              if hooks_dir=$(${pkgs.git}/bin/git rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
                for legacy in "$hooks_dir"/hooks/*.legacy; do
                  if [ -f "$legacy" ] && ${pkgs.gnugrep}/bin/grep -q '^# File generated by pre-commit:' "$legacy"; then
                    echo 1>&2 "okf-model: removing stale pre-commit hook $legacy (see flake.nix)"
                    rm -f "$legacy"
                  fi
                done
              fi
            '';
            buildInputs = hooks.enabledPackages ++ [
              # `elan` is Lean's official toolchain multiplexer: the flake
              # provides the `elan` binary, and `elan` provides `lake`/`lean`
              # shims that read `lean-toolchain` and fetch the pinned Lean into
              # ~/.elan. This is what both the VS Code Lean4 extension and
              # Helix's `lake serve` expect. Lean's own dependencies are pinned
              # by `lean-toolchain` + `lake-manifest.json`, not by this flake.
              pkgs.elan
              # `taplo` formats `lakefile.toml`.
              pkgs.taplo
            ];
          };
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [
            pkgs.nixfmt
            pkgs.findutils
          ];
          text = ''
            find . -name '*.nix' -not -path './.git/*' -print0 | xargs -0 nixfmt
          '';
        }
      );
    };
}
