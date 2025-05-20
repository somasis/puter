{ config
, lib
, pkgs
, ...
}:
{
  home.packages = with pkgs; [
    papirus-icon-theme
    hackneyed
  ];

  home.pointerCursor = {
    name = "Hackneyed";
    package = pkgs.hackneyed;
    size = 24;

    x11.enable = true;
    gtk.enable = true;
  };

  gtk.iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };

  programs.plasma.workspace = {
    iconTheme = "Papirus-Dark";
    cursor = {
      size = 24;
      theme = "Hackneyed";
    };
  };
}
