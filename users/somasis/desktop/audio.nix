{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    jamesdsp
    ponymix
  ];

  cache.directories = [
    (config.lib.somasis.xdgConfigDir "pulse")
    (config.lib.somasis.xdgCacheDir "jamesdsp")
  ];

  persist.directories = [
    {
      method = "bindfs";
      directory = config.lib.somasis.xdgConfigDir "jamesdsp";
    }
  ];

  sync = {
    directories = [
      {
        method = "symlink";
        directory = config.lib.somasis.xdgConfigDir "jamesdsp/irs";
      }
      {
        method = "symlink";
        directory = config.lib.somasis.xdgConfigDir "jamesdsp/liveprog";
      }
      {
        method = "symlink";
        directory = config.lib.somasis.xdgConfigDir "jamesdsp/presets";
      }
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "jamesdsp/application.conf")
    ];
  };

  xdg.autostart.entries = [
    (
      (pkgs.makeDesktopItem {
        name = "jdsp-gui";
        icon = "jamesdsp";
        desktopName = "JamesDSP (tray)";
        exec = "${pkgs.jamesdsp}/bin/jamesdsp --tray";
      })
      + "/share/applications/jdsp-gui.desktop"
    )
  ];

  services.easyeffects.enable = true;
}
