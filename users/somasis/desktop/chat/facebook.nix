{
  config,
  pkgs,
  ...
}:
let

  caprine = pkgs.caprine-bin;
  caprineWindowClassName = "Caprine";

  caprineConfig = {
    autoUpdate = false;

    autoHideMenuBar = true;
    emojiStyle = "native";
    theme = "dark";

    autoplayVideos = false;
    notificationMessagePreview = true;

    showTrayIcon = true;
    keepMeSignedIn = true;
    launchMinimized = true;
    quitOnWindowClose = false;

    showMessageButtons = true;
    spellCheckLanguages = [ "en-US" ];
  };

  caprineConfigFile = (pkgs.formats.json { }).generate "caprine-config.json" caprineConfig;
in
{
  home.packages = [ caprine ];

  persist.directories = [ (config.lib.somasis.xdgConfigDir "Caprine") ];

  systemd.user.tmpfiles.rules = [
    "C ${config.xdg.configHome}/${caprineWindowClassName}/config.json - - - 0 ${caprineConfigFile}"
  ];
}
