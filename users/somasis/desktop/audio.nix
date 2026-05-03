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

  xdg.autostart.entries = [
    (
      (pkgs.makeDesktopItem {
        name = "easyeffects";
        icon = "com.github.wwmm.easyeffects";
        desktopName = "Easy Effects";
        exec = "${pkgs.easyeffects}/bin/easyeffects --hide-window --service-mode";
      })
      + "/share/applications/easyeffects.desktop"
    )
  ];
}
