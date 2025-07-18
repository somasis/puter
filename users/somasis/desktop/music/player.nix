{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      config.services.playerctld.package
      mpris-scrobbler
    ];

  # Elisa is my music player of choice. I use it to play music from ~/audio/library.
  # Metadata from Elisa is propagated to beets using `~/bin/elisa-to-beets`,
  # which is only ran manually right now.
  programs.elisa = {
    enable = true;
    appearance = {
      showNowPlayingBackground = true;
      showProgressOnTaskBar = true;
      embeddedView = "genres";
      defaultView = "allAlbums";
      defaultFilesViewPath = config.xdg.userDirs.music;
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

  services = {
    playerctld.enable = true;
    mpris-proxy.enable = true;
  };

  persist = {
    directories = [
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "elisa";
      }

      (config.lib.somasis.xdgConfigDir "mpris-scrobbler")
      (config.lib.somasis.xdgDataDir "mpris-scrobbler")
    ];

    # ~/etc/kde.org is already preserved by plasma.nix, because
    # KDE programs create so many little files in this directory,
    # it's just easier that way without having to make the
    # persistence more strict.
    # files = [
    #   (config.lib.somasis.xdgConfigDir "kde.org/elisa.conf")
    # ];
  };

  systemd.user.targets.graphical-session.Unit.Wants = [ "mpris-scrobbler.service" ];

  xdg.configFile."mpris-scrobbler/config".text =
    lib.generators.toINIWithGlobalSection { listsAsDuplicateKeys = true; }
      {
        globalSection.ignore = [
          "playerctld"
          "kdeconnect"
          "mpv"
          "chromium"
          "qutebrowser"
          "firefox"
        ];
      };
}
