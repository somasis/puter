{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  news.display = "silent";

  home.packages = [
    pkgs.kdePackages.kasts
  ];

  persist = {
    files = [
      (config.lib.somasis.xdgConfigDir "kastsrc")

      # Already handled by ~/etc/KDE in plasma.nix
      (config.lib.somasis.xdgConfigDir "KDE/kasts.conf")
    ];

    directories = [
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "KDE/Kasts";
      }
    ];
  };

  programs.qutebrowser = {
    aliases.news-add = "open -rt https://nxc.journcy.net/apps/news/#?subscribe_to={url}";
    keyBindings.normal.zr = "news-add";
  };
}
