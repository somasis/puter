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

  persist = with config.lib.somasis; {
    directories = [
      (xdgCacheDir "cinny")
      (xdgDataDir "cinny")
    ];
  };
}
