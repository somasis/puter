{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    easyeffects
    ponymix
  ];

  cache.directories = with config.lib.somasis; [
    (xdgConfigDir "pulse")
    (xdgCacheDir "easyeffects")
  ];

  persist.directories = with config.lib.somasis; [
    (xdgConfigDir "easyeffects")
    (xdgDataDir "easyeffects")
  ];

  # xdg.autostart.entries = [
  #   (
  #     (pkgs.makeDesktopItem {
  #       name = "jdsp-gui";
  #       icon = "jamesdsp";
  #       desktopName = "JamesDSP (tray)";
  #       exec = "${pkgs.jamesdsp}/bin/jamesdsp --tray";
  #     })
  #     + "/share/applications/jdsp-gui.desktop"
  #   )
  # ];
}
