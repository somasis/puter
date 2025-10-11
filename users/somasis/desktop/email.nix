{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.thunderbird-esr ];
  persist.directories = [
    (config.lib.somasis.xdgCacheDir "thunderbird")
    ".thunderbird"
  ];
}
