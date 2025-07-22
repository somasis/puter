{ config, pkgs, ... }:
{
  home.packages = [ pkgs.qownnotes ];
  sync.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "PBE"; # contains QOwnNotes.conf
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "PBE/QOwnNotes";
    }
  ];

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "PBE/QOwnNotes";
    }
  ];
}
