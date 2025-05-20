{ config
, pkgs
, lib
, osConfig
, ...
}:
let
  inherit (osConfig.programs) steam;
in
assert steam.enable;
{
  persist.directories = [
    {
      method = "symlink";
      directory = ".steam";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "Steam";
    }

    {
      method = "symlink";
      directory = ".WorldOfGoo";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "Celeste";
    }
    {
      method = "symlink";
      directory = ".paradoxlauncher";
    }

    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "r2modman";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "r2modmanPlus-local";
    }
  ];

  home.packages = [
    pkgs.steamcmd
    pkgs.r2modman
  ];
}
