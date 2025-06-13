{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.lib.somasis) relativeToHome;
in
{
  xdg = {
    enable = true;

    mimeApps.enable = true;

    configHome = "${config.home.homeDirectory}/etc";
    dataHome = "${config.home.homeDirectory}/share";
    cacheHome = "${config.home.homeDirectory}/var/cache";
    stateHome = "${config.home.homeDirectory}/var/lib";

    userDirs = {
      enable = true;
      createDirectories = false;

      templates = "/var/empty";

      desktop = lib.mkDefault "${config.home.homeDirectory}/desktop";
      documents = lib.mkDefault "${config.home.homeDirectory}/doc";
      download = lib.mkDefault "${config.home.homeDirectory}/downloads";
      music = lib.mkDefault "${config.home.homeDirectory}/audio/library";
      pictures = lib.mkDefault "${config.home.homeDirectory}/pictures";
      publicShare = lib.mkDefault "/var/empty";
      videos = lib.mkDefault "${config.home.homeDirectory}/videos";
    };

    autostart.enable = true;

    # Force replacing mimeapps.list, since it might have been changed
    # during system runtime (and thus de-symlinked). I usually only want
    # MIME overrides to persist for a session anyway; anything permanent
    # would be added to this configuration, so this works out well for
    # keeping that mostly-persistent.
    # <https://github.com/nix-community/home-manager/issues/4199#issuecomment-1620657055>
    configFile."mimeapps.list".force = true;
  };

  home = {
    # Necessary so dconf and rclone things don't mess activation up...
    activation.setXdgDirs =
      lib.hm.dag.entryBefore [ "writeBoundary" "installPackages" "dconfSettings" "reloadSystemd" ]
        ''
          if ! [ -L ~/.config ] && [ -d ~/.config ]; then run mv ~/.config ~/.config.bak; fi
          run ln -Tsf ${lib.escapeShellArg config.xdg.configHome} ~/.config
          if ! [ -L ~/.cache ] && [ -d ~/.cache ]; then run mv ~/.cache ~/.cache.bak; fi
          run ln -Tsf ${lib.escapeShellArg config.xdg.cacheHome} ~/.cache
        '';

    preferXdgDirectories = true;

    packages = [
      (pkgs.writeShellScriptBin "open" ''
        exec xdg-open "$@"
      '')
    ];
  };

  log.directories = [
    # > $XDG_STATE_HOME contains state data that should persist between (application) restarts,
    # > but that is not important or portable enough to the user that it should be stored in
    # > $XDG_DATA_HOME.
    # <https://specifications.freedesktop.org/basedir-spec/latest/#variables>
    # (config.lib.somasis.relativeToHome config.xdg.stateHome)
    {
      method = "bindfs";
      directory = "var/lib";
    }
  ];

  persist.directories = [
    {
      method = "symlink";
      directory = relativeToHome config.xdg.userDirs.pictures;
    }
    {
      method = "symlink";
      directory = relativeToHome config.xdg.userDirs.videos;
    }
  ];
}
