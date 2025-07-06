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
}
