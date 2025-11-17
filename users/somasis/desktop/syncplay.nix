{
  pkgs,
  config,
  ...
}:
{
  home.packages = [
    pkgs.syncplay
  ];

  persist = with config.lib.somasis; {
    directories = [ (xdgConfigDir "Syncplay") ];
    files = [ (xdgConfigDir "syncplay.ini") ];
  };
}
