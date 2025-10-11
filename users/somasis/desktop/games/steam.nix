{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  inherit (osConfig.programs) steam;
in
assert steam.enable;
{
  persist.directories = [
    ".steam"
    (config.lib.somasis.xdgDataDir "Steam")

    ".WorldOfGoo"
    (config.lib.somasis.xdgDataDir "Celeste")
    ".paradoxlauncher"

    (config.lib.somasis.xdgConfigDir "r2modman")
    (config.lib.somasis.xdgConfigDir "r2modmanPlus-local")
  ];

  home.packages = [ pkgs.r2modman ];

  xdg.autostart.entries = [
    (
      pkgs.makeDesktopItem {
        name = "steam";
        desktopName = "Steam (silent)";
        exec = "steam -silent";
        icon = "steam";
      }
      + "/share/applications/steam.desktop"
    )
  ];
}
