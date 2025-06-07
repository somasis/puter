{
  config,
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

  systemd.user.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";

  programs.plasma = {
    workspace = {
      lookAndFeel = "org.kde.breezetwilight.desktop";

      theme = "breeze-dark";
      colorScheme = "SomasisLight";

      windowDecorations = {
        library = "org.kde.breeze";
        theme = "Breeze";
      };

      splashScreen.theme = "None";
    };

    configFile.kdeglobals.General.AccentColor = config.lib.somasis.colors.kde config.theme.colors.accent;
  };

  services.darkman = {
    enable = true;

    lightModeScripts = {
      kde-color-scheme = ''
        set -x
        plasma-apply-colorscheme SomasisLight
        plasma-apply-colorscheme -a ${lib.escapeShellArg (colors.hex config.theme.colors.accent)}
      '';
      kde-gtk-theme = ''
        set -x
        dbus-send --session --dest=org.kde.GtkConfig --type=method_call /GtkConfig org.kde.GtkConfig.setGtkTheme "string:Breeze-gtk"
      '';
    };

    darkModeScripts = {
      kde-color-scheme = ''
        set -x
        plasma-apply-colorscheme SomasisDark
        plasma-apply-colorscheme -a ${lib.escapeShellArg (colors.hex config.theme.colors.brightAccent)}
      '';
      kde-gtk-theme = ''
        set -x
        dbus-send --session --dest=org.kde.GtkConfig --type=method_call /GtkConfig org.kde.GtkConfig.setGtkTheme "string:Breeze-dark-gtk"
      '';
    };

    settings = {
      usegeoclue = true;
    };
  };

  log.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "darkman";
    }
  ];
}
