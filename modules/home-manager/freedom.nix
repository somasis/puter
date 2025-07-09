{ osConfig, ... }:
{
  imports = [ ../freedom.nix ];

  config.nixpkgs.allowUnfreePackages = osConfig.nixpkgs.allowUnfreePackages;
}
