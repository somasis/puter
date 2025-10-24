let
  sources = import ./npins;

  pkgs = import sources.nixpkgs { };
  lib = pkgs.lib;

  git-hooks = import ./git-hooks.nix;
  inherit (import sources.agenix { inherit pkgs; }) agenix;
  treefmt = import ./treefmt.nix;
in
pkgs.mkShell {
  # Construct NIX_PATH from npins sources.
  NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: v: "${n}=${v.outPath}") sources);

  shellHook = git-hooks.shellHook + ''
    export NIXOS_CONFIG="$PWD"
  '';

  buildInputs = git-hooks.enabledPackages ++ [
    # for secrets management (see also: `./secrets/secrets.nix`)
    agenix

    treefmt

    pkgs.act
    pkgs.apacheHttpd # for `htpasswd`
    pkgs.cachix
    pkgs.nix-update
    pkgs.npins
    pkgs.replace-secret

    (pkgs.writeShellApplication {
      name = "nixos";
      runtimeInputs = [
        pkgs.nixos-rebuild
        # pkgs.nix-output-monitor
      ];
      text = ''
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

    (pkgs.writeShellApplication {
      name = "npins-update-commit";
      runtimeInputs = [ pkgs.npins ];
      text = ''
        PS3='$ '

        set -euo pipefail
        set -x

        npins update "$@"
        git commit -m 'npins: update' npins/
      '';
    })
  ];
}
