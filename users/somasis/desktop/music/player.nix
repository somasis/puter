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
  # Metadata from Elisa is propagated to beets using `~/bin/beets-sync-ratings-elisa`,
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
      ratingsStyle = "favourites";
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

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "elisa";
    }

    (config.lib.somasis.xdgConfigDir "mpris-scrobbler")
    (config.lib.somasis.xdgDataDir "mpris-scrobbler")
  ];

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
