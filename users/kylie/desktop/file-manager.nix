{
  pkgs,
  config,
  self,
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

  xdg.dataFile."kio/servicemenus" = {
    source = "${self}/share/kio/servicemenus";
    recursive = true;
  };

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
