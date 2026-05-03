{
  pkgs,
  config,
  ...
}:
{
  home.packages = [
    pkgs.syncplay
  ];

  data = with config.lib.somasis; {
    directories = [ (xdgConfigDir "Syncplay") ];
    files = [ (xdgConfigDir "syncplay.ini") ];
  };
}
