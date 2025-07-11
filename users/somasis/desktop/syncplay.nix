{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs) syncplay;

  mkList = list: "[" + (lib.concatStringsSep "," (map (x: ''"${x}"'') list)) + "]";

  mpv = "${config.programs.mpv.package}/bin/mpv";

  syncplayINI = lib.generators.toINI { } {
    general.checkforupdatesautomatically = false;

    client_settings = {
      name = config.home.username;
      playerpath = mpv;

      # time synchronization
      dontslowdownwithme = false;
      fastforwardondesync = true;
      fastforwardthreshold = 5.0;
      rewindondesync = true;
      rewindthreshold = 4.0;
      slowdownthreshold = 1.5;
      slowondesync = false;

      # playback
      pauseonleave = true;
      unpauseaction = "IfOthersReady";

      # playlist
      sharedplaylistenabled = true;
      readyatstart = true;

      autoplayminusers = -1.0;
      autoplayrequiresamefilenames = true;

      filenameprivacymode = "SendRaw";
      filesizeprivacymode = "SendRaw";
      loopatendofplaylist = false;
      loopsinglefiles = false;

      onlyswitchtotrusteddomains = false;
      # trusteddomains = mkList [
      #   "drive.google.com"
      #   "instagram.com"
      #   "vimeo.com"
      #   "tumblr.com"
      #   "twitter.com"
      #   "youtube.com"
      #   "youtu.be"
      #   "x.com"
      # ];

      mediasearchdirectories = mkList [
        config.xdg.userDirs.download
        "${config.home.homeDirectory}/mess/current"
        "${config.xdg.userDirs.videos}/anime"
        "${config.xdg.userDirs.videos}/film"
        "${config.xdg.userDirs.videos}/tv"
        "${config.home.homeDirectory}/mnt/seedbox/files/video/anime"
        "${config.home.homeDirectory}/mnt/seedbox/files/video/film"
        "${config.home.homeDirectory}/mnt/seedbox/files/video/tv"
        "${config.home.homeDirectory}/shared/kylie"
        "${config.home.homeDirectory}/shared/cassie"
        "${config.home.homeDirectory}/shared/violet"
      ];

      room = "anime";
      roomlist = mkList [
        "anime"
        "jonesing"
        "pones"
        "wifes"
      ];
    };

    client_settings.forceguiprompt = true;
    gui = {
      alerttimeout = 5.0;
      chatbottommargin = 30.0;
      chatdirectinput = true;
      chatinputenabled = true;
      chatinputfontcolor = "#ffff00";
      chatinputfontfamily = "monospace";
      chatinputfontunderline = false;
      chatinputfontweight = 50.0;
      chatinputposition = "Top";
      chatinputrelativefontsize = 24.0;
      chatleftmargin = 20.0;
      chatmaxlines = 7.0;
      chatmoveosd = true;
      chatosdmargin = 110.0;
      chatoutputenabled = true;
      chatoutputfontfamily = "monospace";
      chatoutputfontunderline = false;
      chatoutputfontweight = 50.0;
      chatoutputmode = "Scrolling";
      chatoutputrelativefontsize = 24.0;
      chattimeout = 7.0;
      chattopmargin = 25.0;
      notificationtimeout = 3.0;
      showdifferentroomosd = false;
      showdurationnotification = true;
      shownoncontrollerosd = false;
      showosd = true;
      showosdwarnings = true;
      showsameroomosd = true;
      showslowdownosd = true;
    };
  };

  secret-syncplay = pkgs.writeShellApplication {
    name = "secret-syncplay";
    runtimeInputs = [
      config.programs.password-store.package
      pkgs.coreutils
    ];

    text = ''
      umask 0077

      : "''${XDG_CONFIG_HOME:=$HOME/.config}"
      : "''${XDG_RUNTIME_DIR:=/run/user/$(id -un)}"
      runtime="''${XDG_RUNTIME_DIR}/secret-syncplay"

      hostname="$1"; shift
      port="$1"; shift

      pass=$(pass "syncplay/$hostname") || exit $?

      [ -d "$runtime" ] || mkdir -m 700 "$runtime"
      cat > "$runtime"/syncplay.ini <<EOF
      ${syncplayINI}
      [server_data]
      host = $hostname
      port = $port
      password = $pass
      EOF

      ln -sf "$runtime"/syncplay.ini "$XDG_CONFIG_HOME"/syncplay.ini
    '';
  };
in
{
  home.packages = [
    syncplay
    secret-syncplay
  ];

  persist = {
    directories = [ (config.lib.somasis.xdgConfigDir "Syncplay") ];
    files = [ (config.lib.somasis.xdgConfigDir "syncplay.ini") ];
  };

  # xdg.configFile = {
  #   "syncplay.ini".force = true;
  #   "Syncplay/MainWindow.conf".text = lib.generators.toINI { } {
  #     MainWindow = {
  #       autoplayChecked = false;
  #       autoplayMinUsers = 3;
  #       showAutoPlayButton = true;
  #       showPlaybackButtons = false;
  #     };
  #   };

  #   "Syncplay/MoreSettings.conf".text = lib.generators.toINI { } {
  #     MoreSettings.ShowMoreSettings = true;
  #   };

  #   "Syncplay/PlayerList.conf".text = lib.generators.toINI { } {
  #     PlayerList.PlayerList = mpv;
  #   };
  # };

  # systemd.user.services.secret-syncplay = {
  #   Unit = {
  #     Description = "Authenticate `syncplay` using `pass`";
  #     PartOf = [ "graphical-session.target" ];

  #     After = [ "gpg-agent.service" ];
  #   };
  #   Install.WantedBy = [ "graphical-session.target" ];

  #   Service = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;

  #     ExecStart = [ "${secret-syncplay}/bin/secret-syncplay journcy.net 8999" ];
  #     ExecStop = [ "${pkgs.coreutils}/bin/rm -rf %t/secret-syncplay" ];
  #   };
  # };
}
