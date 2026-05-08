{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tremotesf ];

  data.directories = [
    (config.lib.somasis.xdgConfigDir "tremotesf")
  ];
}
