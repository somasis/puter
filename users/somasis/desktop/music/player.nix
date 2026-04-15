{
  config,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      config.services.playerctld.package
      feishin
    ];

  # Elisa is my music player of choice. I use it to play music from ~/audio/library.
  services = {
    # I use playerctld rather than Plasma's built-in media controller.
    playerctld.enable = true;
    mpris-proxy.enable = true;
  };

  persist = with config.lib.somasis; {
    directories = [
      (xdgConfigDir "feishin")
    ];
  };
}
