{
  sources ? (import ./npins),

  pkgs ? (import sources.nixpkgs { }),
  lib ? pkgs.lib,

  git-hooks ? (import ./git-hooks.nix),
  treefmt-nix ? (import sources.treefmt-nix),
  agenix ? (import sources.agenix { inherit pkgs; }),
}:
let
  agenixPkg = agenix.agenix;
  treefmtPkg = treefmt-nix.mkWrapper pkgs ./treefmt.nix;
in
pkgs.mkShell {
  # Construct NIX_PATH from npins sources.
  NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: v: "${n}=${v.outPath}") sources);

  shellHook = git-hooks.shellHook + ''
    export NIXOS_CONFIG="$PWD"
  '';

  buildInputs =
    git-hooks.enabledPackages
    ++ (with pkgs; [
      # for secrets management (see also: `./secrets.nix`)
      agenixPkg
      treefmtPkg

      act
      apacheHttpd # for `htpasswd`
      cachix
      nix-update
      npins
      replace-secret

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

          edo nixos-rebuild \
              --log-format bar-with-logs \
              --sudo \
              -f . \
              -A nixosConfigurations."$HOSTNAME" \
              "$@"
              # |& nom --json
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
