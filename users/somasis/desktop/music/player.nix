{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };

  scrobblers = [
    "Elisa"
    "fooyin"
  ];
in
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      config.services.playerctld.package
      music-discord-rpc
      fooyin
    ];

  age.secrets.rescrobbled-env.file = "${self}/secrets/rescrobbled-env.age";

  # Elisa is my music player of choice. I use it to play music from ~/audio/library.
  programs.elisa = {
    enable = true;

    package = pkgs.kdePackages.elisa.override {
      withVLC = false;
    };

    appearance = {
      showNowPlayingBackground = true;
      showProgressOnTaskBar = true;

      defaultView = "allAlbums";
      defaultFilesViewPath = config.xdg.userDirs.music;

      # Elisa doesn't currently attempt to split the genre tags
      # in any way (I use '; ' as a separator), so this looks
      # kinda silly.
      # embeddedView = "genres";
    };

    indexer = {
      paths = [ config.xdg.userDirs.music ];
      scanAtStartup = true;
      ratingsStyle = "stars";
    };
    player = {
      playAtStartup = false;
      useAbsolutePlaylistPaths = false;
    };
  };

  # TODO contribute the settings needed to add these to `programs.elisa`.
  programs.plasma.configFile.elisarc.Views = {
    # Sort the Albums view in descending order
    SortOrderPreferences.value = "Album==DescendingOrder";

    # albums: sort by year (latest first); tracks: in alphabetical order by title
    SortRolePreferences.value = "Album==YearRole,Track==TitleRole";

    # albums: grid; files: list; genres: list
    ViewStylePreferences.value = "Album==GridStyle,FileName==ListStyle,Genre==ListStyle";
  };

  services = {
    # I use playerctld rather than Plasma's built-in media controller.
    playerctld.enable = true;
    mpris-proxy.enable = true;

    rescrobbled = {
      enable = true;
      settings.player-whitelist = scrobblers;
    };
  };

  persist = with config.lib.somasis; {
    directories = [
      (xdgDataDir "elisa")
      (xdgConfigDir "fooyin")
      (xdgDataDir "fooyin")
    ];

    # ~/etc/kde.org is already preserved by plasma.nix, because
    # KDE programs create so many little files in this directory,
    # it's just easier that way without having to make the
    # persistence more strict.
    # files = [
    #   (config.lib.somasis.xdgConfigDir "kde.org/elisa.conf")
    # ];

    # Don't forget to log in to Last.FM by running `rescrobbled` manually
    # in a terminal.
    files = [
      (xdgConfigDir "rescrobbled/session")
    ];
  };

  cache = with config.lib.somasis; {
    directories = [
      (xdgCacheDir "music-discord-rpc")
      (xdgCacheDir "fooyin")
    ];
  };

  systemd.user = {
    services.rescrobbled = {
      Unit.After = [ "agenix.service" ];
      Service.EnvironmentFile = config.age.secrets.rescrobbled-env.path;
    };

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

      # Only allow Elisa's now-playing to be broadcast over Discord Rich Presence.
      allowlist = scrobblers;

      disable_musicbrainz_cover = false;
    };
  };

}
