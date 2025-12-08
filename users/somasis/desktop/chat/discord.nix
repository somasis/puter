{
  config,
  pkgs,
  lib,
  ...
}:
let
  mkIcon =
    icon:
    pkgs.runCommand "discord-tray.png" { inherit icon; } ''
      ${pkgs.librsvg}/bin/rsvg-convert \
          --width 128 \
          --height 128 \
          --keep-aspect-ratio \
          --output "$out" \
          "$icon"
    '';

  json = lib.generators.toJSON { };
in
{
  home.packages = [
    pkgs.discordchatexporter-cli
    pkgs.equibop
  ];

  xdg.autostart.entries = [
    (
      pkgs.makeDesktopItem {
        name = "equibop";
        desktopName = "Equibop";
        icon = "discord";
        exec = "/usr/bin/env equibop --start-minimized";
      }
      + "/share/applications/equibop.desktop"
    )
  ];

  cache = {
    directories = [
      (config.lib.somasis.xdgConfigDir "equibop/sessionData")
    ];
  };

  persist = {
    directories = [
      (config.lib.somasis.xdgConfigDir "equibop/settings")
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "equibop/state.json")
    ];
  };

  xdg.configFile = {
    "equibop/settings.json".text = json {
      discordBranch = "stable";

      disableMinSize = true;
      disableSmoothScroll = false;
      enableMenu = false;
      hardwareVideoAcceleration = true;
      spellCheckLanguages = [
        "en-US"
        "tok"
        "en"
      ];

      arRPC = true;

      enableSplashScreen = true;
      splashAnimationPath =
        # Use an empty splash GIF.
        pkgs.runCommandLocal "empty.gif" {
          b64 = "R0lGODlhAQABAIABAAAAACEmLSH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";
        } ''base64 -d <<<"$b64" > $out'';

      staticTitle = false;

      tray = true;
      minimizeToTray = true;
      clickTrayToShowHide = true;

      trayColorType = "custom";
      trayColor = lib.replaceStrings [ "#" ] [ "" ] config.theme.colors.accent;
      trayAutoFill = "black";

      trayIdleOverride = true;
      trayDeafenedOverride = true;
      trayMainOverride = true;
      trayMutedOverride = true;
      traySpeakingOverride = true;
    };

    "equibop/TrayIcons/deafened.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24@2x/panel/discord-tray-deafened.svg";
    "equibop/TrayIcons/icon.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24@2x/panel/discord-tray.svg";
    "equibop/TrayIcons/idle.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24@2x/panel/discord-tray-connected.svg";
    "equibop/TrayIcons/muted.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24@2x/panel/discord-tray-muted.svg";
    "equibop/TrayIcons/speaking.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24@2x/panel/discord-tray-speaking.svg";

    # "equibop/settings/quickCss.css".source = ./discord.css;

    # "equibop/settings/settings.json".text = json {
    #   disableMinSize = false;
    #   notifications = {
    #     useNative = "always";
    #     missed = true;
    #     logLimit = 0;
    #   };

    #   useQuickCss = true;
    #   winCtrlQ = false;
    #   winNativeTitleBar = false;

    #   plugins = {
    #     AlwaysTrust = {
    #       enabled = true;
    #       domain = true;
    #       file = true;
    #     };
    #     Anammox = {
    #       enabled = true;
    #       billing = false;
    #       dms = true;
    #       emojiList = true;
    #       gift = true;
    #     };
    #     BetterBlockedUsers = {
    #       enabled = true;
    #       hideBlockedWarning = false;
    #       showUnblockConfirmationEverywhere = false;
    #     };
    #     BetterGifAltText.enabled = true;
    #     BetterGifPicker.enabled = true;
    #     BetterPlusReacts.enabled = true;
    #     BetterSessions = {
    #       enabled = true;
    #       backgroundCheck = true;
    #       checkInterval = 30;
    #     };
    #     BetterSettings = {
    #       enabled = true;
    #       disableFade = true;
    #       eagerLoad = true;
    #       organizeMenu = true;
    #     };
    #     BlurNSFW = {
    #       enabled = true;
    #       blurAllChannels = false;
    #       blurAmount = 15;
    #     };
    #     CallTimer = {
    #       enabled = true;
    #       format = "human";
    #     };
    #     ClearURLs.enabled = true;
    #     ConsoleJanitor.enabled = true;
    #     CrashHandler = {
    #       enabled = true;
    #       attemptToNavigateToHome = true;
    #       attemptToPreventCrashes = true;
    #     };
    #     DontRoundMyTimestamps.enabled = true;
    #     Downloadify = {
    #       enabled = true;
    #       defaultDirectory = config.xdg.userDirs.download;
    #     };
    #     FixImagesQuality.enabled = true;
    #     ForceOwnerCrown.enabled = true;
    #     FrequentQuickSwitcher.enabled = true;
    #     FriendsSince.enabled = true;
    #     FullSearchContext.enabled = true;
    #     FullUserInChatbox.enabled = true;
    #     FullVCPFP.enabled = true;
    #     GameActivityToggle = {
    #       enabled = true;
    #       oldIcon = false;
    #     };
    #     GuildPickerDumper.enabled = true;
    #     HomeTyping.enabled = true;
    #     ImageFilename = {
    #       enabled = true;
    #       showFullUrl = false;
    #     };
    #     IrcColors = {
    #       enabled = true;
    #       applyColorOnlyInDms = true;
    #       applyColorOnlyToUsersWithoutColor = true;
    #       lightness = 65;
    #       memberListColors = true;
    #     };
    #     LimitMiddleClickPaste = {
    #       enabled = true;
    #       limitTo = "direct";
    #       reenableDelay = 500;
    #     };
    #     MentionAvatars = {
    #       enabled = true;
    #       showAtSymbol = true;
    #     };
    #     NSFWGateBypass.enabled = true;
    #     NoDevtoolsWarning.enabled = true;
    #     NoF1.enabled = true;
    #     NoModalAnimation.enabled = true;
    #     NoTrack.disableAnalytics = true;
    #     NoUnblockToJump.enabled = true;
    #     NormalizeMessageLinks.enabled = true;
    #     PinIcon.enabled = true;
    #     ReactErrorDecoder.enabled = true;
    #     ReplaceGoogleSearch = {
    #       enabled = true;
    #       customEngineName = "DuckDuckGo";
    #       customEngineURL = "https://duckduckgo.com/?q=";
    #     };
    #     SearchFix.enabled = true;
    #     ServerSearch.enabled = true;
    #     Settings.settingsLocation = "aboveActivity";
    #     ShikiCodeblocks.enabled = true;
    #     ShowAllMessageButtons = {
    #       enabled = true;
    #       noShiftDelete = false;
    #       noShiftPin = false;
    #     };
    #     ShowConnections = {
    #       enabled = true;
    #       iconSize = 32;
    #       iconSpacing = 1;
    #     };
    #     SilentMessageToggle = {
    #       enabled = true;
    #       autoDisable = true;
    #       persistState = "none";
    #     };
    #     SortFriends = {
    #       enabled = true;
    #       showDates = true;
    #     };
    #     TextReplace = {
    #       enabled = true;
    #       regexRules = [ ];
    #       stringRules = [
    #         {
    #           find = "https://x.com";
    #           onlyIfIncludes = "/status/";
    #           replace = "https://fxtwitter.com";
    #           scope = "myMessages";
    #         }
    #         {
    #           find = "https://twitter.com";
    #           onlyIfIncludes = "/status/";
    #           replace = "https://fxtwitter.com";
    #           scope = "myMessages";
    #         }
    #       ];
    #     };
    #     ThemeAttributes.enabled = true;
    #     Title = {
    #       enabled = true;
    #       title = "Discord";
    #     };
    #     UnreadCountBadge = {
    #       enabled = true;
    #       notificationCountLimit = false;
    #       replaceWhiteDot = false;
    #       showOnMutedChannels = false;
    #     };
    #     UserVoiceShow = {
    #       enabled = true;
    #       showInMemberList = true;
    #       showInMessages = true;
    #       showInUserProfileModal = true;
    #     };
    #     ValidReply.enabled = true;
    #     ValidUser.enabled = true;
    #     ViewIcons = {
    #       enabled = true;
    #       format = "webp";
    #       imgSize = "1024";
    #     };
    #     VoiceChatDoubleClick.enabled = true;
    #     WebKeybinds.enabled = true;
    #     WebScreenShareFixes.enabled = true;
    #     YoutubeAdblock.enabled = true;
    #   };
    # };
  };
}
