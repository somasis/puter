{ config
, pkgs
, lib
, inputs
, osConfig
, ...
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

  makeCssFontFamily = familyName: fontList: ''
    @font-face {
        font-family: "${familyName}";
        src: ${
          lib.pipe fontList [
            (map (font: "local(\"${font}\")"))
            (lib.concatStringsSep ",")
          ]
        };
    }
  '';
in
{
  home.packages = [ caprine ];

  persist.directories = [ (config.lib.somasis.xdgConfigDir caprineWindowClassName) ];

  systemd.user.tmpfiles.rules = [
    "C ${config.xdg.configHome}/${caprineWindowClassName}/config.json - - - 0 ${caprineConfigFile}"
  ];

  xdg.configFile."${caprineWindowClassName}/custom.css".text = ''
    ${makeCssFontFamily "system-ui" osConfig.fonts.fontconfig.defaultFonts.sansSerif}
    ${makeCssFontFamily "-apple-system" osConfig.fonts.fontconfig.defaultFonts.sansSerif}
    ${makeCssFontFamily "BlinkMacSystemFont" osConfig.fonts.fontconfig.defaultFonts.sansSerif}
    ${makeCssFontFamily "emoji" osConfig.fonts.fontconfig.defaultFonts.emoji}
    ${makeCssFontFamily "sans-serif" osConfig.fonts.fontconfig.defaultFonts.sansSerif}
    ${makeCssFontFamily "serif" osConfig.fonts.fontconfig.defaultFonts.serif}
    ${makeCssFontFamily "monospace" osConfig.fonts.fontconfig.defaultFonts.monospace}
    ${makeCssFontFamily "ui-sans-serif" osConfig.fonts.fontconfig.defaultFonts.sansSerif}
    ${makeCssFontFamily "ui-serif" osConfig.fonts.fontconfig.defaultFonts.serif}
    ${makeCssFontFamily "ui-monospace" osConfig.fonts.fontconfig.defaultFonts.monospace}

    body,
    button,
    input,
    label,
    select,
    td,
    textarea {
        font-family: ui-sans-serif, sans-serif !important;
    }

    pre,
    code {
        font-family: ui-monospace, monospace !important;
    }
  '';
}
