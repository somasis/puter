{
  self,
  config,
  pkgs,
  lib,
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

  home.packages = with pkgs; [
    klassy
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
    lightModeScripts = {
      kde-color-scheme = ''
        plasma-apply-lookandfeel -a somasis.desktop
        plasma-apply-colorscheme -a ${lib.escapeShellArg (colors.hex config.theme.colors.accent)}
      '';
      kde-gtk-theme = ''
        dbus-send --session --dest=org.kde.GtkConfig --type=method_call /GtkConfig org.kde.GtkConfig.setGtkTheme "string:Breeze-gtk"
      '';
    };

    darkModeScripts = {
      kde-color-scheme = ''
        plasma-apply-lookandfeel -a somasisdark.desktop
        plasma-apply-colorscheme -a ${lib.escapeShellArg (colors.hex config.theme.colors.brightAccent)}
      '';
      kde-gtk-theme = ''
        dbus-send --session --dest=org.kde.GtkConfig --type=method_call /GtkConfig org.kde.GtkConfig.setGtkTheme "string:Breeze-dark-gtk"
      '';
    };
  };

  persist.directories = with config.lib.somasis; [
    (xdgConfigDir "klassy")
  ];

  cache.directories = with config.lib.somasis; [
    (xdgCacheDir "darkman")
  ];
}
