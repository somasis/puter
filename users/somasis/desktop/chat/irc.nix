{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      figlet
      toilet
      konversation
    ];

  xdg.autostart.entries = [
    "${pkgs.kdePackages.konversation}/share/applications/org.kde.konversation.desktop"
  ];

  persist = {
    directories = [
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "konversation";
      }
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "konversationrc")
      (config.lib.somasis.xdgConfigDir "konversation-${osConfig.networking.fqdnOrHostName}.pem")
      (config.lib.somasis.xdgConfigDir "konversation.kmessagebox")
    ];
  };
}
