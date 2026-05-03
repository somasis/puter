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

  data.directories = with config.lib.somasis; [
    (xdgConfigDir "pulse")
    (xdgCacheDir "easyeffects")
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
