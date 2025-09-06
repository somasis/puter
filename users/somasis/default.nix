{
  self,
  config,
  inputs,
  lib,
  osConfig,
  ...
}:
{
  imports =
    with self;
    with inputs;
    with self.homeManagerModules;
    [
      agenix.homeManagerModules.default
      plasma-manager.homeModules.plasma-manager

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
      ./skim.nix
      ./ssh.nix
      ./syncthing.nix
      ./theme
      ./tmux.nix
      ./xdg.nix
      # keep-sorted end
    ];

  cache = {
    # defaultDirectoryMethod = "symlink";
    allowOther = true;
  };

  log = {
    # defaultDirectoryMethod = "symlink";
    allowOther = true;
  };

  persist = {
    # defaultDirectoryMethod = "symlink";
    allowOther = true;

    directories = [
      {
        method = "symlink";
        directory = "src";
      }
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "nix";
      }
    ];
  };

  sync = {
    # defaultDirectoryMethod = "symlink";
    allowOther = true;
  };

  nixpkgs.overlays =
    (osConfig.nixpkgs.overlays or [ ])
    ++ (lib.mapAttrsToList (_: v: v) (lib.filterAttrs (n: _: n != "default") self.overlays));

  systemd.user.startServices = true;

  services.home-manager.autoExpire.enable = true;

  home.stateVersion = "24.11";
}
