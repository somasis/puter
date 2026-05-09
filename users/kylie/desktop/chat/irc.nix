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

  data = {
    directories = [
      (config.lib.somasis.xdgDataDir "konversation")
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "konversationrc")
      (config.lib.somasis.xdgConfigDir "konversation-${osConfig.networking.fqdnOrHostName}.pem")
      (config.lib.somasis.xdgConfigDir "konversation.kmessagebox")
    ];
  };
}
