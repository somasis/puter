{
  config,
  pkgs,
  lib,
  inputs,
  osConfig,
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

  # discord =
  #   if config.programs.nixcord.discord.enable then
  #     config.programs.nixcord.discord.package.override
  #       {
  #         withVencord = config.programs.nixcord.discord.vencord.enable;
  #         withOpenASAR = config.programs.nixcord.discord.openASAR.enable;
  #       }
  #   else
  #     null
  # ;
in
{
  # imports = [ inputs.nixcord.homeManagerModules.nixcord ];

  # programs.nixcord = {
  #   enable = true;

  #   discord.enable = true;
  #   # vesktop = {
  #   #   enable = true;

  #   #   # settings = {
  #   #   #   arRPC = "on";
  #   #   #   checkUpdates = false;
  #   #   #   clickTrayToShowHide = true;
  #   #   #   disableSmoothScroll = true;
  #   #   #   discordBranch = "stable";
  #   #   #   minimizeToTray = "on";
  #   #   #   splashTheme = true;
  #   #   # };
  #   #   # state.firstLaunch = false;
  #   # };

  #   quickCss = lib.fileContents discord-css;
  #   config = {
  #     useQuickCss = true;
  #     enableReactDevtools = true;

  #     plugins = {
  #       # Global
  #       roleColorEverywhere = { enable = true; chatMentions = true; memberList = true; reactorsList = true; voiceUsers = true; };

  #       # Conversation view
  #       blurNSFW.enable = true;
  #       dontRoundMyTimestamps.enable = true;
  #       fixCodeblockGap.enable = true;
  #       keepCurrentChannel.enable = true;
  #       mentionAvatars.enable = true;
  #       messageClickActions = { enable = true; requireModifier = false; };
  #       messageLatency = { enable = true; showMillis = false; };
  #       messageLinkEmbeds = { enable = true; automodEmbeds = "prefer"; };
  #       messageLogger = {
  #         enable = true;
  #         collapseDeleted = false;
  #         ignoreBots = true;
  #         ignoreSelf = true;
  #       };
  #       noUnblockToJump.enable = true;
  #       nsfwGateBypass.enable = true;
  #       quickReply.enable = true;
  #       revealAllSpoilers.enable = true;
  #       sendTimestamps = { enable = true; replaceMessageContents = true; };
  #       showAllMessageButtons.enable = true;
  #       silentMessageToggle = { enable = true; autoDisable = true; persistState = false; };
  #       fixYoutubeEmbeds.enable = true;
  #       youtubeAdblock.enable = true;

  #       validReply.enable = true;
  #       validUser.enable = true;

  #       # Servers
  #       serverInfo.enable = true;

  #       # Emoji/sticker/GIF picker
  #       betterGifAltText.enable = true;
  #       betterGifPicker.enable = true;
  #       gifPaste.enable = true;
  #       stickerPaste.enable = true;

  #       # Calls
  #       callTimer = { enable = true; format = "human"; };
  #       disableCallIdle.enable = true;

  #       clearURLs.enable = true;

  #       copyEmojiMarkdown = { enable = true; copyUnicode = true; };
  #       copyUserURLs.enable = true;
  #       emoteCloner.enable = true;
  #       friendsSince.enable = true;

  #       # Channel list
  #       typingIndicator = {
  #         enable = true;
  #         includeBlockedUsers = false;
  #         includeMutedChannels = false;
  #       };
  #       voiceChatDoubleClick.enable = true;

  #       # Member list
  #       colorSighted.enable = true;
  #       forceOwnerCrown.enable = true;
  #       # platformIndicators.enable = true;
  #       typingTweaks = { enable = true; alternativeFormatting = false; };

  #       # Search
  #       fullSearchContext.enable = true;

  #       # Friends list / profile view
  #       implicitRelationships = { enable = true; sortByAffinity = true; };
  #       mutualGroupDMs.enable = true;
  #       noPendingCount = {
  #         enable = true;
  #         hideFriendRequestsCount = false;
  #         # hideMessageRequestsCount = false;
  #         hidePremiumOffersCount = true;
  #       };
  #       showConnections = {
  #         enable = true;
  #         iconSize = 32;
  #         iconSpacing = "cozy";
  #       };
  #       sortFriendRequests = { enable = true; showDates = true; };
  #       userVoiceShow.enable = true;
  #       viewIcons.enable = true;

  #       # Links
  #       alwaysTrust = { enable = true; file = true; };
  #       textReplace.enable = true;
  #       normalizeMessageLinks.enable = true;
  #       # noCanaryMessageLinks = { enable = true; alwaysUseDiscordHost = true; linkPrefix = ""; };

  #       # Miscellaneous
  #       betterSettings.enable = true;
  #       consoleJanitor.enable = true;
  #       crashHandler.attemptToNavigateToHome = true;
  #       experiments = { enable = true; toolbarDevMenu = true; };
  #       noDevtoolsWarning.enable = true;
  #       noF1.enable = true;
  #       noMosaic = {
  #         enable = true;
  #         # mediaLayoutType = "static";
  #       };
  #       noOnboardingDelay.enable = true;
  #       noTrack = { enable = true; disableAnalytics = true; };
  #       noTypingAnimation.enable = true;
  #       reactErrorDecoder.enable = true;
  #       replyTimestamp.enable = true;
  #       settings = { enable = true; settingsLocation = "aboveActivity"; };
  #       themeAttributes.enable = true;
  #     };
  #   };

  #   vencordConfig.plugins.fixImagesQuality.enable = true;
  #   vesktopConfig.plugins = {
  #     webKeybinds.enable = true;
  #     webRichPresence.enable = true;
  #     webScreenShareFixes.enable = true;
  #   };
  # };

  # xdg.configFile = let json = lib.generators.toJSON { }; in
  # # Discord
  #   {
  #     "${discordWindowClassName}/settings.json".text = json ({
  #       SKIP_HOST_UPDATE = true;
  #       DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
  #       trayBalloonShown = true;
  #     } // lib.optionalAttrs (discordArgs ? withOpenASAR && discordArgs.withOpenASAR) {
  #       openasar = {
  #         setup = true;
  #         quickstart = true;
  #       };
  #     } // lib.optionalAttrs ((discordArgs ? withOpenASAR && discordArgs.withOpenASAR) && (!(discordArgs ? withVencord) || !discordArgs.withVencord)) {
  #       css = lib.fileContents discord-css;
  #     });
  #   } // lib.optionalAttrs (discord.pname == "legcord") {
  #     "${discordWindowClassName}/storage/lang.json".text = json { lang = "en-US"; };

  #     # this makes things break
  #     "${discordWindowClassName}/storage/settings.json".text = json {
  #       doneSetup = true;
  #       multiInstance = false;

  #       alternativePaste = false;
  #       disableAutogain = false;

  #       channel = "canary";
  #       automaticPatches = true;

  #       legcordCSP = true;
  #       mods = "vencord";
  #       inviteWebsocket = true;
  #       spellcheck = true;

  #       skipSplash = true;
  #       startMinimized = true;
  #       minimizeToTray = true;
  #       windowStyle = "native";
  #       mobileMode = false;

  #       tray = true;
  #       trayIcon = "dsc-tray";
  #       dynamicIcon = true;

  #       performanceMode = "vaapi";

  #       useLegacyCapturer = true;
  #     };

  #     "${discordWindowClassName}/themes/theme".source = discord-theme;
  #   }
  #   // lib.optionalAttrs (discordArgs ? withVencord && discordArgs.withVencord) {
  #     "Vencord/themes/theme".source = discord-theme;
  #     # "Vencord/settings/quickCss.css".source = discord-css;
  #   }
  #   # // {
  #   #   "discord/tray.png".source = mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/panel/discord-tray.svg";
  #   #   "discord/tray-unread.png".source = mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/panel/discord-tray-unread.svg";
  #   #   "discord/tray-connected.png".source = mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/panel/discord-tray-connected.svg";
  #   #   "discord/tray-deafened.png".source = mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/panel/discord-tray-deafened.svg";
  #   #   "discord/tray-muted.png".source = mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/panel/discord-tray-muted.svg";
  #   #   "discord/tray-speaking.png".source = mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/panel/discord-tray-speaking.svg";
  #   # }
  # ;

  home.packages = [
    pkgs.discordchatexporter-cli
    pkgs.equibop
  ];

  cache = {
    directories = [
      (config.lib.somasis.xdgConfigDir "equibop/sessionData")
    ];
  };

  sync = {
    directories = [
      (config.lib.somasis.xdgConfigDir "equibop/themes")
      (config.lib.somasis.xdgConfigDir "equibop/settings")
      (config.lib.somasis.xdgConfigDir "equibop/TrayIcons")
      (config.lib.somasis.xdgConfigDir "equibop/MessageLoggerData")
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "equibop/settings.json")
      (config.lib.somasis.xdgConfigDir "equibop/state.json")
    ];
  };

  xdg.configFile = {
    "equibop/TrayIcons/deafened_nixos.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/32x32@2x/panel/discord-tray-deafened.svg";
    "equibop/TrayIcons/icon_nixos.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/32x32@2x/panel/discord-tray.svg";
    # "equibop/TrayIcons/unread.png".source = mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/32x32@2x/panel/discord-tray-unread.svg";
    "equibop/TrayIcons/idle_nixos.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/32x32@2x/panel/discord-tray-connected.svg";
    "equibop/TrayIcons/muted_nixos.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/32x32@2x/panel/discord-tray-muted.svg";
    "equibop/TrayIcons/speaking_nixos.png".source =
      mkIcon "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/32x32@2x/panel/discord-tray-speaking.svg";
  };
}
