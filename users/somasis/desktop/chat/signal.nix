{
  config,
  pkgs,
  # lib,
  ...
}:
# let
#   inherit (lib)
#     mapAttrs'
#     nameValuePair
#     ;

#   inherit (config.lib.somasis)
#     camelCaseToKebabCase
#     ;
# in
{
  home.packages = [ pkgs.signal-desktop ];

  persist.directories = [ (config.lib.somasis.xdgConfigDir "Signal") ];

  xdg.autostart.entries = [
    (
      pkgs.makeDesktopItem {
        desktopName = "Signal";
        name = "signal";
        icon = "signal-desktop";

        # Force usage of libsecret instead of kwallet, which it defaults to when
        # XDG_CURRENT_DESKTOP=KDE, for some reason...
        exec = "/usr/bin/env signal-desktop --password-store=gnome-libsecret --start-in-tray";
      }
      + "/share/applications/signal.desktop"
    )
  ];

  # xdg.configFile."Signal/ephemeral.json".text = lib.generators.toJSON { } (
  #   mapAttrs' (n: v: nameValuePair (camelCaseToKebabCase n) v) {
  #     systemTraySetting = "MinimizeToAndStartInSystemTray";
  #     shownTrayNotice = true;

  #     themeSetting = "system";

  #     window = mapAttrs' (n: v: nameValuePair (camelCaseToKebabCase n) v) {
  #       autoHideMenuBar = true;
  #     };

  #     spellCheck = true;
  #   }
  # );
}
