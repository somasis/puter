{
  sources ? (import ./npins),

  nixpkgs ? sources.nixpkgs,
  pkgs ? (import nixpkgs { }),

  lib ? pkgs.lib,

  agenix ? sources.agenix,
  treefmt-nix ? sources.treefmt-nix,
  flake-compat ? sources.flake-compat,
  git-hooks ? sources.git-hooks,

  ...
}@args:
let
  agenixPkg = (import agenix { inherit pkgs; }).agenix;
  treefmtPkg = (import treefmt-nix).mkWrapper pkgs ./treefmt.nix;
  gitHooksPkg = (import git-hooks).run (import ./git-hooks.nix args);
in
pkgs.mkShell {
  # Construct NIX_PATH from npins sources.
  NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: v: "${n}=${v.outPath}") sources);

  inherit (gitHooksPkg) shellHook;

  buildInputs =
    gitHooksPkg.enabledPackages
    ++ (with pkgs; [
      # for secrets management (see also: `./secrets.nix`)
      agenixPkg
      treefmtPkg

      act
      apacheHttpd # for `htpasswd`; used by some secrets
      cachix
      nix-update
      npins

      (writeShellApplication {
        name = "nixos";
        runtimeInputs = [
          pkgs.nixos-rebuild
          # pkgs.nix-output-monitor
        ];
        text = ''
          set -euo pipefail

          edo() {
              local arg string
              string=
              for arg; do
                  if [[ ''${arg@Q} == "'$arg'" ]] && ! [[ ''${arg} =~ [[:blank:]] ]]; then
                      string+="''${string:+ }$arg"
                  else
                      string+="''${string:+ }''${arg@Q}"
                  fi
              done

              printf '$ %s\n' "''${string}" >&2
              # alt: printf '$ %s\n' "$(condquote "$@")" >&2

              "$@"
          }

          if command -v nom >/dev/null 2>&1; then
              use_nom=true
          else
              use_nom=false
          fi

          update=false
          for arg; do
              case "$arg" in
                  --nom) use_nom=true; shift ;;
                  --no-nom) use_nom=false; shift ;;
                  --update) update=true; shift ;;
                  --log-format) use_nom=false ;;
                  repl|edit|list-generations) use_nom=false ;;
              esac
          done

          nixos_rebuild_args=(
              --no-flake
          )

          if [[ "$update" == true ]]; then
              npins-update-commit || exit 1
          fi

          if [[ "$use_nom" == true ]]; then
              nixos_rebuild_args+=(
                  --log-format internal-json
              )
          else
              nixos_rebuild_args+=(
                  --log-format multiline-with-logs
              )
          fi

          nixos_rebuild_args+=(
              --sudo \
              -f . \
              -A nixosConfigurations."$HOSTNAME" \
              "$@"
          )

          if [[ "$use_nom" == true ]]; then
              edo nixos-rebuild "''${nixos_rebuild_args[@]}" |& nom --json
          else
              edo nixos-rebuild "''${nixos_rebuild_args[@]}"
          fi
        '';
      })

      (writeShellApplication {
        name = "npins-update-commit";
        runtimeInputs = [ pkgs.npins ];
        text = ''
          set -euo pipefail

          edo() {
              local arg string
              string=
              for arg; do
                  if [[ ''${arg@Q} == "'$arg'" ]] && ! [[ ''${arg} =~ [[:blank:]] ]]; then
                      string+="''${string:+ }$arg"
                  else
                      string+="''${string:+ }''${arg@Q}"
                  fi
              done

              printf '$ %s\n' "''${string}" >&2
              # alt: printf '$ %s\n' "$(condquote "$@")" >&2

              "$@"
          }

          edo npins update "$@"
          edo git commit -m 'npins: update' npins/
        '';
      })
    ]);
}
