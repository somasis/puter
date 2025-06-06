{
  pkgs,
  config,
  ...
}:
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      dolphin
      filelight
    ];

  sync.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "kio/servicemenus";
    }
  ];

  dconf.settings = {
    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
      date-format = "with-time";
      show-hidden = true;
      show-size-column = true;
      show-type-column = true;
      sort-directories-first = true;
      startup-mode = "cwd";
      type-format = "mime";
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "with-time";
      show-hidden = true;
      sort-directories-first = true;
      type-format = "mime";
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; with kdePackages; [ xdg-desktop-portal-kde ];
    configPackages = with pkgs; with kdePackages; [ xdg-desktop-portal-kde ];
  };
}
