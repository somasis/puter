{
  pkgs,
  config,
  ...
}:
{
  imports = [
    # keep-sorted start by_regex=['^./.*[^(\.nix)]$', '.*\.nix$']
    ./chat
    ./documents
    ./games
    ./music
    ./audio.nix
    ./browser.nix
    ./diary.nix
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
        fmit
        hyperfine
        josm
        kcharselect
        lingot
        okteta
        organicmaps
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

  data = with config.lib.somasis; {
    directories = [
      (xdgCacheDir "mesa_shader_cache")
      (xdgCacheDir "mesa_shader_cache_db")
      (xdgCacheDir "containers")
      (xdgCacheDir "JOSM")
      (xdgDataDir "containers")
      (xdgConfigDir "OMaps")
      (xdgDataDir "OMaps")
      (xdgConfigDir "JOSM")
      (xdgDataDir "JOSM")
      (xdgDataDir "applications")
      (xdgDataDir "icons")
    ];

    files = [
      (xdgConfigDir "oktetarc")
    ];
  };

  xdg.autostart.enable = true;
}
