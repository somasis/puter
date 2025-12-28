# Populate the system environment with information about the configuration
# from npins and its assorted infrastructure.
{
  self ? null,
  sources,
  nixpkgs ? (throw "The nixpkgs npins source used by this configuration needs to be provided"),
  pkgs,
  lib ? pkgs.lib,
  ...
}:
let
  # Ensure the system's nixpkgs source is named "nixpkgs", so that
  # <nixpkgs> and `nixpkgs#...` refer to the same thing that they
  # usually do when using Flakes and channels system-wide.
  sources' =
    # Required since lockfile ver. 5.
    (builtins.removeAttrs sources [ "__functor" ]) // {
      inherit nixpkgs;
    };
in
{
  environment = {
    systemPackages = [ pkgs.npins ];
    etc.npins.source = pkgs.linkFarm "npins-sources" (
      lib.mapAttrsToList (name: src: {
        inherit name;
        path = src.outPath;
      }) sources'
    );
  };

  system = {
    nixos = {
      revision =
        with builtins;
        with lib;
        trivial.revisionWithDefault (
          replaceStrings [ "nixos-" "nixpkgs-" ] [ "" "" ] (baseNameOf (dirOf nixpkgs.url))
        );

      versionSuffix = ".${lib.trivial.versionSuffix}";
    };

    configurationRevision =
      with builtins;
      with lib;
      let
        git = "${self.outPath}/.git";
      in
      # NOTE: this differs from version info calculation in Flakes,
      # because it doesn't tell us when the Git repo is dirty or not.
      if pathExists git then commitIdFromGitRepo git else null;
  };

  # Disable all points of dependency pulling other than npins.
  nix = {
    channel.enable = false;

    # Set $NIX_PATH to our sources in /etc/npins.
    nixPath = lib.mkForce (lib.mapAttrsToList (n: _: "${n}=/etc/npins/${n}") sources');

    # Translate npins sources to Flakes in the system registry.
    registry = lib.mkForce (
      lib.mapAttrs (n: v: {
        to = {
          type = "path";
          path = v.outPath;
        };
      }) sources'
    );
  };

  meta.maintainers = with lib.maintainers; [ somasis ];
}
