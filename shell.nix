{
  sources ? (import ./npins),

  nixpkgs ? sources.nixpkgs,
  pkgs ? (import nixpkgs { }),

  lib ? pkgs.lib,

  agenix ? sources.agenix,
  treefmt-nix ? sources.treefmt-nix,
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
  NIX_PATH = lib.concatStringsSep ":" (
    lib.mapAttrsToList (n: v: "${n}=${(v { inherit pkgs; }).outPath}") (
      # Required since lockfile ver. 5.
      builtins.removeAttrs sources [ "__functor" ]
    )
  );

  shellHook = ''
    ${gitHooksPkg.shellHook}
    export PATH="$PWD/bin:''${PATH:+:$PATH}"
  '';

  packages =
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

        runtimeInputs = with pkgs; [
          dix
          jq
          nix-output-monitor
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

          provide_default_attr=true
          update=false
          for arg; do
              case "$arg" in
                  # Arguments not to be passed to nixos-rebuild
                  --nom) use_nom=true; shift ;;
                  --no-nom) use_nom=false; shift ;;
                  --update) update=true; shift ;;

                  # Arguments to be passed through
                  -A) provide_default_attr=false ;;
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
              -f .
          )

          if [[ "$provide_default_attr" == true ]]; then
              nixos_rebuild_args+=( -A nixosConfigurations."$HOSTNAME" )
          fi

          nixos_rebuild_args+=( "$@" )

          system_before=/nix/var/nix/profiles/system-$(nixos-rebuild list-generations --json | jq -r '.[0].generation')-link

          e=0
          if [[ "$use_nom" == true ]]; then
              edo nixos-rebuild "''${nixos_rebuild_args[@]}" |& nom --json || e=$?
          else
              edo nixos-rebuild "''${nixos_rebuild_args[@]}" || e=$?
          fi

          system_after=/nix/var/nix/profiles/system-$(nixos-rebuild list-generations --json | jq -r '.[0].generation')-link

          [[ "$system_before" != "$system_after" ]] && dix "$system_before" "$system_after" >&2

          exit $e
        '';
      })
    ]);
}
