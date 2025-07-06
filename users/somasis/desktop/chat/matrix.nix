{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.kdePackages.neochat
  ];

  persist = {
    # ~/share/KDE is already handled by plasma.nix
    # directories = [
    #   {
    #     method = "symlink";
    #     directory = config.lib.somasis.xdgDataDir "KDE/neochat";
    #   }
    # ];
    files = [ (config.lib.somasis.xdgConfigDir "neochatrc") ];
  };

  # Required to build packages like pkgs.kdePackages.neochat, due to its dependency
  # on libolm, which is deprecated...
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
