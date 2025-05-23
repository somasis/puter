{ config
, lib
, pkgs
, ...
}:
let
  jsonFormat = pkgs.formats.json { };
  radiotrayConfig = {
    bookmarks = "${config.xdg.dataHome}/radiotray-ng/bookmarks.json";

    notifications = true;
    notifications-verbose = false;

    split-title = true;
    track-info-copy = true;

    volume-level = 50;
  };

  libraries = "${config.home.homeDirectory}/audio/libraries";
in
{
  home.packages =
    with pkgs;
    with libsForQt5;
    with kdePackages;
    [
      config.services.playerctld.package
      radiotray-ng
      mpris-scrobbler
    ];

  programs.elisa = {
    enable = true;
    appearance = {
      showNowPlayingBackground = false;
      showProgressOnTaskBar = true;
      embeddedView = "genres";
      defaultView = "recentlyPlayed";
      defaultFilesViewPath = libraries;
    };
    indexer = {
      paths = [ libraries ];
      scanAtStartup = true;
      ratingsStyle = "favourites";
    };
    player = {
      playAtStartup = false;
      # minimiseToSystemTray = true;
      useAbsolutePlaylistPaths = false;
    };
  };

  services.playerctld.enable = true;
  services.mpris-proxy.enable = true;

  sync.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "fooyin";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "fooyin";
    }

    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "audacious";
    }

    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "radiotray-ng";
    }
  ];

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "elisa";
    }
    (config.lib.somasis.xdgConfigDir "radiotray-ng")

    (config.lib.somasis.xdgConfigDir "mpris-scrobbler")
    (config.lib.somasis.xdgDataDir "mpris-scrobbler")
  ];

  systemd.user.targets.graphical-session.Unit.Wants = [ "mpris-scrobbler.service" ];

  home.activation.merge-radiotray-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! [[ -v DRY_RUN ]]; then
        config_path=${lib.escapeShellArg config.xdg.configHome}/radiotray-ng/radiotray-ng.json
        default_config=${lib.escapeShellArg (jsonFormat.generate "radiotray-ng.json" radiotrayConfig)}

        if ! [[ -s "$config_path" ]]; then
            touch "$config_path"
            printf '{}' > "$config_path"
        fi

        merged_config=$(${pkgs.jq}/bin/jq -s '.[0] // .[1]' "$default_config" "$config_path")

        printf '%s' "$merged_config" > "$config_path"
    fi
  '';

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
