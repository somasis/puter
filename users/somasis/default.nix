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
      plasma-manager.homeManagerModules.plasma-manager

      ./commands
      ./editor
      ./git
      ./shell
      ./theme

      ./less.nix
      ./locale.nix
      ./man.nix
      ./monitor.nix
      ./pass.nix
      ./rclone.nix
      ./skim.nix
      ./ssh.nix
      ./syncthing.nix
      ./text-manipulation.nix
      ./tmux.nix
      ./xdg.nix
    ];

  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

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
      # NOTE (FIXME?) bindfs has to be used because Nix doesn't want to access it if it's a symlink...
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

  nixpkgs = {
    config.allowUnfree = true;
    overlays =
      (osConfig.nixpkgs.overlays or [ ])
      ++ (lib.mapAttrsToList (_: v: v) (lib.filterAttrs (n: _: n != "default") self.overlays));
  };

  systemd.user.startServices = true;

  services.home-manager.autoExpire.enable = true;

  home.sessionVariables.SYSTEMD_PAGER = "cat";

  home.stateVersion = "24.11";
}
