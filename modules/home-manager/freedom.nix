{ lib, osConfig, ... }:
{
  imports = [ ../freedom.nix ];

  config.nixpkgs.allowUnfreePackages = lib.mkIf (
    osConfig.nixpkgs ? allowUnfreePackages
  ) osConfig.nixpkgs.allowUnfreePackages;
}
