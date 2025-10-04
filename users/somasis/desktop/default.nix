{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    # keep-sorted start by_regex=['^./.*[^(\.nix)]$', '.*\.nix$']
    ./browser
    ./chat
    ./documents
    ./games
    ./music
    ./audio.nix
    ./diary.nix
    ./email.nix
    ./feeds.nix
    ./file-manager.nix
    ./konsole.nix
    ./ledger.nix
    ./mess.nix
    ./notes.nix
    ./notifications.nix
    ./phone.nix
    ./photo.nix
    ./plasma.nix
    ./radio.nix
    ./syncplay.nix
    ./syncthing.nix
    ./torrent.nix
    ./video.nix
    ./wine.nix
    ./www.nix
    # keep-sorted end
  ];

  home = {
    extraOutputsToInstall = [
      "doc"
      "devdoc"
      "man"
    ];

    packages =
      with pkgs;
      with kdePackages;
      [
        # keep-sorted start
        bc
        ffmpeg-full
        kcharselect
        hyperfine
        okteta
        zenity
        # keep-sorted end
      ];

    file = {
      ".face".source = inputs.avatarSomasis;
      ".face.png".source = inputs.avatarSomasis;
      ".face.icon".source = inputs.avatarSomasis;
    };
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
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "containers";
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
    {
      method = "bindfs";
      directory = config.lib.somasis.xdgDataDir "icons";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "containers";
    }
  ];

  # ~/share/direnv contains the allowlist of repositories.
  sync.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "direnv";
    }
  ];

  xdg.autostart.enable = true;
}
