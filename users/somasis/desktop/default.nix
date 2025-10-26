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
        hyperfine
        josm
        kcharselect
        okteta
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

  cache.directories = [
    (config.lib.somasis.xdgCacheDir "borg")
    (config.lib.somasis.xdgCacheDir "mesa_shader_cache")
    (config.lib.somasis.xdgCacheDir "mesa_shader_cache_db")
    (config.lib.somasis.xdgCacheDir "containers")
    (config.lib.somasis.xdgCacheDir "JOSM")
  ];

  persist = {
    directories = [
      (config.lib.somasis.xdgDataDir "containers")
      (config.lib.somasis.xdgConfigDir "JOSM")
      (config.lib.somasis.xdgDataDir "JOSM")
      (config.lib.somasis.relativeToHome config.xdg.userDirs.documents)
      {
        method = "bindfs";
        directory = config.lib.somasis.xdgDataDir "applications";
      }
      {
        method = "bindfs";
        directory = config.lib.somasis.xdgDataDir "icons";
      }
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "oktetarc")
    ];
  };

  xdg.autostart.enable = true;
}
