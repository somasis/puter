{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tremotesf ];

  persist.directories = [
    (config.lib.somasis.xdgConfigDir "tremotesf")
  ];
}
