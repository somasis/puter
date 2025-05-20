{ config
, pkgs
, lib
, ...
}:
{
  imports = [
    ./default.nix
    ./beets.nix
  ];

  home.username = "cassie";
  home.homeDirectory = "/home/cassie";
  home.stateVersion = "24.11";

  # home.sessionVariables = {
  # };

  programs.bash.enable = true;

  home.packages = with pkgs; [
    kdePackages.konversation
    prismlauncher
    amarok
    kdePackages.kalk
    picard
    rpcs3
    discord
    zotero
    cantata
    kwalletcli
    transmission-remote-gtk
    wl-clipboard
    mpv
    flac
    lame
    mktorrent
    calibre
    qtpass
    supersonic
    mpc
    signal-desktop
  ];

  services.gpg-agent.enable = true;
  services.gpg-agent.pinentryPackage = pkgs.pinentry-all;
  # pkgs.symlinkJoin {
  #   name = "pinentry";
  #   paths = [ pkgs.pinentry-curses pkgs.pinentry-qt ];
  # };

  systemd.user.services.weechat = {
    Unit = {
      After = [ "network.target" ];
    };

    Service = {
      Type = "forking";
      RemainAfterExit = true;
      ExecStart = "${lib.getExe config.programs.tmux.package} -L weechat new -d -s weechat ${lib.getExe pkgs.weechat}";
      ExecStop = "${lib.getExe config.programs.tmux.package} -L weechat kill-session -t weechat";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.discocss = {
    enable = true;
    discordAlias = false;

    css = '''';
  };

  services.syncthing = {
    enable = true;

    extraOptions = [
      "--gui-address=http://0.0.0.0:8977/"
    ];
  };

  xsession = {
    enable = true;
  };

  services.mpd = {
    enable = true;

    musicDirectory = "/mnt/raid/cassie/media/music/flac2";

    network.listenAddress = "localhost";
    network.port = 8960;

    extraConfig = ''
      audio_output {
        type "pulse"
        name "default"
        mixer_type "hardware"
      }
    '';
  };

  services.mpd-discord-rpc = {
    enable = false;

    settings = {
      hosts = [
        "${config.services.mpd.network.listenAddress}:${builtins.toString config.services.mpd.network.port}"
      ];
    };
  };
}
