{
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
        hyperfine
        josm
        kcharselect
        okteta
        qemu
        quickemu
        zenity
        # keep-sorted end
      ];

    # file = {
    #   ".face".source = inputs.avatarSomasis;
    #   ".face.png".source = inputs.avatarSomasis;
    #   ".face.icon".source = inputs.avatarSomasis;
    # };
  };

  services.tunnels.enable = true;

  cache.directories = with config.lib.somasis; [
    (xdgCacheDir "borg")
    (xdgCacheDir "mesa_shader_cache")
    (xdgCacheDir "mesa_shader_cache_db")
    (xdgCacheDir "containers")
    (xdgCacheDir "JOSM")
  ];

  persist = with config.lib.somasis; {
    directories = [
      (xdgDataDir "containers")
      (xdgConfigDir "JOSM")
      (xdgDataDir "JOSM")
      (relativeToHome config.xdg.userDirs.documents)
      {
        method = "bindfs";
        directory = xdgDataDir "applications";
      }
      {
        method = "bindfs";
        directory = xdgDataDir "icons";
      }
    ];

    files = [
      (xdgConfigDir "oktetarc")
    ];
  };

  xdg.autostart.enable = true;
}
