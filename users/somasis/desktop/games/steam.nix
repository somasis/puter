{
  config,
  pkgs,
  osConfig,
  lib,
  ...
}:
lib.mkIf osConfig.programs.steam.enable {
  persist.directories = with config.lib.somasis; [
    ".steam"
    (xdgDataDir "Steam")
    (xdgDataDir "vulkan")

    ".WorldOfGoo"
    ".paradoxlauncher"
    (xdgDataDir "Celeste")
    (xdgDataDir "SHENZHEN IO")

    (xdgConfigDir "r2modman")
    (xdgConfigDir "r2modmanPlus-local")
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
