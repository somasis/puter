# Populate the system environment with information about the configuration
# from npins and its assorted infrastructure.
{
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
  sources' = sources // {
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

  system.nixos = rec {
    revision =
      with builtins;
      if elem ".git-revision" (attrNames (readDir nixpkgs)) then
        (substring 0 10 (readFile "${nixpkgs}/.git-revision"))
      else
        nixpkgs.revision
          or (replaceStrings [ "nixos-" "nixpkgs-" ] [ "" "" ] (baseNameOf (dirOf nixpkgs.url)));

    versionSuffix =
      with builtins;
      if elem ".version-suffix" (attrNames (readDir nixpkgs)) then
        ".${readFile "${nixpkgs}/.version-suffix"}"
      else
        ".${revision}";
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
