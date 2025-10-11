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
    (config.lib.somasis.xdgConfigDir "jamesdsp")
  ];

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
}
