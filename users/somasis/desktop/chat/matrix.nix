{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.kdePackages.neochat
  ];

  xdg.autostart.entries = [
    "${pkgs.kdePackages.neochat}/share/applications/org.kde.neochat.desktop"
  ];

  persist = with config.lib.somasis; {
    directories = [
      (xdgCacheDir "KDE/neochat")
      (xdgDataDir "KDE/neochat")
    ];

    files = [
      (xdgConfigDir "KDE/neochat.conf")
      (xdgConfigDir "kunifiedpush-org.kde.neochat")
      (xdgConfigDir "neochatrc")
    ];
  };

  # Required to build packages like pkgs.kdePackages.neochat, due to its
  # dependency on libolm, which is deprecated...
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
