{
  self,
  config,
  ...
}:
let
  inherit (config.lib.somasis) colors;
in
{
  imports = [
    ./colors.nix
    ./fonts.nix
    ./icons.nix
  ];

  systemd.user.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";

  programs.plasma = {
    # See `./share/plasma/look-and-feel/somasis.desktop`
    workspace.lookAndFeel = "somasis.desktop";

    configFile.kdeglobals.General.AccentColor = colors.kde config.theme.colors.accent;
  };

  xdg.dataFile = {
    "plasma/look-and-feel/somasisdark.desktop".source =
      "${self}/share/plasma/look-and-feel/somasisdark.desktop";
    "plasma/look-and-feel/somasis.desktop".source =
      "${self}/share/plasma/look-and-feel/somasis.desktop";
  };

  services.darkman = {
    enable = true;
    settings.usegeoclue = true;
  };

  cache.directories = with config.lib.somasis; [
    (xdgCacheDir "darkman")
  ];
}
