{ inputs
, lib
, pkgs
, config
, osConfig
, ...
}:
{
  imports = [
    ./plasma.nix

    ./browser
    ./games
    ./study

    ./activity.nix
    ./diary.nix
    ./mess.nix
    ./phone.nix
    ./photo.nix
    ./syncplay.nix
    ./syncthing.nix
    ./video.nix
    ./wine.nix
    ./www.nix

    ./terminal.nix

    # ./pim
    # ./anki.nix
    ./chat
    # ./didyouknow.nix
    # ./feeds
    ./ledger.nix
    # ./list.nix
    ./music
    ./torrent.nix

    ./audio.nix
    # ./automount.nix
    # ./clipboard.nix
    # ./display.nix
    ./file-manager.nix
    # ./mouse.nix
    ./notifications.nix
    # ./panel
    # ./power.nix
    # ./screen-brightness.nix
    # ./screen-locker.nix
    # ./screen-temperature.nix
    # ./stw
    # ./wallpaper.nix
    # ./xsession.nix

    # ./dmenu.nix
  ];

  home.extraOutputsToInstall = [
    "doc"
    "devdoc"
    "man"
  ];

  home.packages =
    with pkgs;
    with kdePackages;
    [
      bc
      bmake
      ffmpeg-full
      hyperfine
      zenity
    ];

  home.file = {
    ".face".source = inputs.avatarSomasis;
    ".face.png".source = inputs.avatarSomasis;
    ".face.icon".source = inputs.avatarSomasis;
  };

  services.tunnels.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # Improve default caching settings instead of making a
    # .devenv directory in every Git repository using it.
    # See also the relevant config.(cache|sync).directories entries.
    stdlib = ''
      : "''${XDG_CACHE_HOME:=$HOME/.cache}"
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "$XDG_CACHE_HOME"/direnv/layouts/
              echo -n "$PWD" | sha1sum | cut -d ' ' -f 1
          )}"
      }
    '';
  };

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "borg";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "direnv";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "mesa_shader_cache";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "mesa_shader_cache_db";
    }
  ];

  log.directories = [
    {
      method = "symlink";
      directory = "logs";
    }
  ];

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.relativeToHome config.xdg.userDirs.documents;
    }
    {
      method = "bindfs";
      directory = config.lib.somasis.xdgDataDir "applications";
    }
  ];

  # ~/share/direnv contains the allowlist of repositories.
  sync.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "direnv";
    }
  ];
}
