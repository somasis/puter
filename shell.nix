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

    pkgs.apacheHttpd # for `htpasswd`
    pkgs.nix-update
    pkgs.npins
    pkgs.replace-secret

    (pkgs.writeShellApplication {
      name = "nixos";
      text = ''
        exec nixos-rebuild -f . -A nixosConfigurations."$HOSTNAME" "$@"
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
