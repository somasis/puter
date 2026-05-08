{
  config,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      okular
    ];

  data = with config.lib.somasis; {
    directories = [
      (xdgDataDir "okular")
    ];

    files = [
      (xdgConfigDir "okularpartrc")
      (xdgConfigDir "okularrc")
    ];
  };
}
