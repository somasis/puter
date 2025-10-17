{
  sources,
  self,
  config,
  ...
}:
{
  imports = with sources; [
    "${agenix}/modules/age-home.nix"
    "${plasma-manager}/modules"

    # keep-sorted start
    ./age.nix
    ./commands
    ./editor
    ./git
    ./less.nix
    ./locale.nix
    ./man.nix
    ./monitor.nix
    ./pass.nix
    ./rclone.nix
    ./shell
    ./ssh.nix
    ./syncthing.nix
    ./theme
    ./tmux.nix
    ./xdg.nix
    # keep-sorted end
  ];

  cache = {
    defaultDirectoryMethod = "symlink";
    allowOther = true;
  };

  persist = {
    defaultDirectoryMethod = "symlink";
    allowOther = true;

    directories = [
      "src"
      (config.lib.somasis.xdgDataDir "nix")
    ];
  };

  sync = {
    # defaultDirectoryMethod = "symlink";
    allowOther = true;
  };

  nixpkgs = {
    overlays = [
      self.overlay
      self.overlays.nixpkgsVersions
    ];
    config.allowUnfree = true;
  };

  systemd.user.startServices = true;

  services.home-manager.autoExpire.enable = true;

  home.stateVersion = "24.11";
}
