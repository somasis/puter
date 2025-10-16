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

  persist = {
    directories = [
      (config.lib.somasis.xdgCacheDir "KDE/neochat")
      (config.lib.somasis.xdgDataDir "KDE/neochat")
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "KDE/neochat.conf")
      (config.lib.somasis.xdgConfigDir "kunifiedpush-org.kde.neochat")
      (config.lib.somasis.xdgConfigDir "neochatrc")
    ];
  };

  # Required to build packages like pkgs.kdePackages.neochat, due to its
  # dependency on libolm, which is deprecated...
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
