{ config
, pkgs
, lib
, ...
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
      music = lib.mkDefault "/var/empty";
      pictures = lib.mkDefault "${config.home.homeDirectory}/pictures";
      publicShare = lib.mkDefault "/var/empty";
      videos = lib.mkDefault "${config.home.homeDirectory}/videos";
    };
  };

  # Force replacing mimeapps.list, since it might have been changed
  # during system runtime (and thus de-symlinked).
  # <https://github.com/nix-community/home-manager/issues/4199#issuecomment-1620657055>
  xdg.configFile."mimeapps.list".force = true;

  home = {
    # Necessary so dconf and rclone things don't mess activation up...
    activation.setXdgDirs =
      lib.hm.dag.entryBefore [ "writeBoundary" "installPackages" "dconfSettings" ]
        ''
          if ! [ -L ~/.config ] && [ -d ~/.config ]; then run mv ~/.config ~/.config.bak; fi
          run ln -Tsf ${lib.escapeShellArg config.xdg.configHome} ~/.config
          if ! [ -L ~/.cache ] && [ -d ~/.cache ]; then run mv ~/.cache ~/.cache.bak; fi
          run ln -Tsf ${lib.escapeShellArg config.xdg.cacheHome} ~/.cache
          run mkdir -p ~/.local
          if ! [ -L ~/.local/share ] && [ -d ~/.local/share ]; then run mv ~/.local/share ~/.local/share.bak; fi
          run ln -Tsf ${lib.escapeShellArg config.xdg.dataHome} ~/.local/share
          if ! [ -L ~/.local/state ] && [ -d ~/.local/state ]; then run mv ~/.local/state ~/.local/state.bak; fi
          run ln -Tsf ${lib.escapeShellArg config.xdg.stateHome} ~/.local/state
        '';

    preferXdgDirectories = true;

    packages = [
      (pkgs.writeShellScriptBin "open" ''
        exec xdg-open "$@"
      '')
    ];
  };

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
