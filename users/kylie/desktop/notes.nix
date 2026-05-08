{ config, pkgs, ... }:
{
  home.packages = [ pkgs.qownnotes ];

  data.directories = [
    (config.lib.somasis.xdgConfigDir "PBE") # contains QOwnNotes.conf
    (config.lib.somasis.xdgDataDir "PBE/QOwnNotes")
    (config.lib.somasis.xdgCacheDir "PBE/QOwnNotes")
  ];
}
