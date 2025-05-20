{ config
, pkgs
, ...
}:
let
  kodi = pkgs.kodi.withPackages (
    kodiPackages: with kodiPackages; [
      inputstream-adaptive
      inputstream-ffmpegdirect
      inputstreamhelper
      inputstream-rtmp
      joystick

      sendtokodi
      sponsorblock

      vfs-libarchive
      vfs-sftp

      visualization-fishbmc
      visualization-goom
      visualization-matrix
      visualization-projectm
      visualization-shadertoy
      visualization-spectrum
      visualization-starburst
      visualization-waveform
    ]
  );
in
{
  environment.systemPackages = [ kodi ];

  users = {
    users.tv = {
      isNormalUser = false;
      isSystemUser = true;
      uid = 1100;

      createHome = true;
      home = "/mnt/raid/tv";

      group = "tv";
      extraGroups = [
        "users"
        "audio"
        "input"
        "video"
      ];

      packages = [
        kodi
        pkgs.wmctrl
        pkgs.xdotool
      ];
    };

    users.cassie.extraGroups = [ "tv" ];
    users.somasis.extraGroups = [ "tv" ];

    groups.tv.gid = 1100;
  };

  # here lies kodi
  # services.xserver.displayManager.session = [{
  #   name = "cycle";
  #   manage = "desktop";
  #   start = ''
  #     export LIRC_SOCKET_PATH=/run/lirc/lircd

  #     touch ~/.run
  #     state=$(cat ~/.run || echo kodi)

  #     case "$state" in
  #         # steam)
  #         #     steam-gamescope &
  #         #     waitPID=$!

  #         #     next_state=kodi
  #         #     ;;
  #         kodi|*)
  #             kodi --standalone &
  #             waitPID=$!

  #             next_state=steam
  #             ;;
  #     esac

  #     wait "$waitPID"

  #     case "$?" in
  #         0) echo "$next_state" > ~/.run ;;
  #     esac

  #     exec -- "$0" "$@"
  #   '';
  # }];

  # services.displayManager = {
  #   defaultSession = "cycle";
  #   autoLogin.enable = false;
  #   autoLogin.user = "tv";
  # };

  # networking.firewall = {
  #   allowedTCPPorts = [
  #     8080 # Kodi web server (HTTP remote control)
  #     9090 # Kodi web server (WebSocket remote control)
  #   ];
  #   allowedUDPPorts = [
  #     8080 # Kodi web server (HTTP remote control)
  #     9090 # Kodi web server (WebSocket remove control)
  #     9777 # Kodi EventServer
  #   ];
  # };
}
