{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.cinny-desktop
  ];

  xdg.autostart.entries = [
    "${pkgs.cinny-desktop}/share/applications/Cinny.desktop"
  ];

  data = with config.lib.somasis; {
    directories = [
      (xdgCacheDir "cinny")
      (xdgDataDir "cinny")
    ];
  };
}
