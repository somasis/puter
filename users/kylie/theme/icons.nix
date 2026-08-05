{
  pkgs,
  lib,
  config,
  ...
}:
let
  hackneyed = pkgs.hackneyed.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      defaultAccentColor='#00ffff'
      ${lib.toShellVar "customAccentColor" config.theme.colors.brightAccent}

      defaultAccentColor="''${defaultAccentColor,,}"
      customAccentColor="''${customAccentColor,,}"
      defaultAccentColorUpper="''${defaultAccentColor^^}"
      customAccentColorUpper="''${customAccentColor^^}"

      printf 'changing accent from %s to %s\n' "$defaultAccentColor" "$customAccentColor" >&2

      find -type f -name '*.svg' -exec sed -i \
          -e "s/$defaultAccentColor/$customAccentColor/g" \
          -e "s/$defaultAccentColorUpper/$customAccentColorUpper/g" \
          {} +
    '';
  });
in
{
  home.packages = [
    pkgs.papirus-icon-theme
    hackneyed
  ];

  home.pointerCursor = {
    enable = true;
    name = "Hackneyed";
    package = hackneyed;
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
