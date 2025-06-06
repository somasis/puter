{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tremotesf ];
  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "tremotesf";
    }
  ];
}
