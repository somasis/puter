{ config, pkgs, ... }:
{
  home.packages = [ pkgs.qownnotes ];

  persist.directories = [
    (config.lib.somasis.xdgConfigDir "PBE") # contains QOwnNotes.conf
    (config.lib.somasis.xdgDataDir "PBE/QOwnNotes")
  ];

  cache.directories = [
    (config.lib.somasis.xdgCacheDir "PBE/QOwnNotes")
  ];
}
