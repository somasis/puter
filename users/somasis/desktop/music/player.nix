{
  config,
  lib,
  pkgs,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };
in
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      config.services.playerctld.package
      music-discord-rpc
      feishin
    ];

  # Elisa is my music player of choice. I use it to play music from ~/audio/library.
  services = {
    # I use playerctld rather than Plasma's built-in media controller.
    playerctld.enable = true;
    mpris-proxy.enable = true;
  };

  persist = with config.lib.somasis; {
    directories = [
      (xdgConfigDir "feishin")
    ];
  };

  cache = with config.lib.somasis; {
    directories = [
      (xdgCacheDir "music-discord-rpc")
    ];
  };

  systemd.user = {
    targets.graphical-session.Unit.Wants = [
      "music-discord-rpc.service"
    ];

    services.music-discord-rpc = {
      Unit = {
        Description = pkgs.music-discord-rpc.meta.description;
        After = [ "network.target" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        ExecStart = lib.getExe pkgs.music-discord-rpc;
      };
    };
  };

  xdg.configFile = {
    "music-discord-rpc/config.yaml".source = yamlFormat.generate "music-discord-rpc-config.yaml" {
      interval = 10;
      button = [
        "yt"
        "listenbrainz"
      ];

      listenbrainz_name = "Somasis";

      only_when_playing = true;

      small_image = "player";

      # Only allow Feishin's now-playing to be broadcast over Discord Rich Presence.
      allowlist = [ "Feishin" ];

      disable_musicbrainz_cover = false;
    };
  };

}
