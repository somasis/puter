{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.thunderbird-esr ];
  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "thunderbird";
    }
    {
      method = "symlink";
      directory = ".thunderbird";
    }
  ];
}
