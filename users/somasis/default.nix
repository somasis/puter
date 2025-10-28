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

    # keep-sorted start by_regex=['^./.*[^(\.nix)]$', '.*\.nix$']
    ./commands
    ./editor
    ./shell
    ./theme
    ./age.nix
    ./git.nix
    ./less.nix
    ./locale.nix
    ./man.nix
    ./monitor.nix
    ./pass.nix
    ./rclone.nix
    ./ssh.nix
    ./syncthing.nix
    ./tmux.nix
    ./xdg.nix
    # keep-sorted end
  ];

  cache = {
    defaultDirectoryMethod = "symlink";
    allowOther = true;

    directories = with config.lib.somasis; [
      (xdgCacheDir "nix")
      (xdgDataDir "nix")
      (xdgDataDir "systemd")
    ];
  };

  persist = {
    defaultDirectoryMethod = "symlink";
    allowOther = true;

    directories = [
      "src"
    ];
  };

  sync = {
    # defaultDirectoryMethod = "symlink";
    allowOther = true;
  };

  nixpkgs = {
    overlays = [
      self.overlays.default
      self.overlays.nixpkgsVersions
    ];
    config.allowUnfree = true;
  };

  systemd.user.startServices = true;

  services.home-manager.autoExpire.enable = true;

  home.stateVersion = "24.11";
}
