{ self
, inputs
, config
, lib
, pkgs
, osConfig
, ...
}:
{
  imports =
    with self;
    with inputs;
    with self.homeManagerModules;
    [
      plasma-manager.homeManagerModules.plasma-manager

      ./commands
      ./editor
      ./git
      ./modules
      ./shell
      ./theme

      ./less.nix
      ./locale.nix
      ./man.nix
      ./monitor.nix
      ./pass.nix
      ./skim.nix
      ./ssh.nix
      ./syncthing.nix
      ./text-manipulation.nix
      ./tmux.nix
      ./xdg.nix
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
        method = "bindfs"; # NOTE (FIXME?) bindfs has to be used because Nix doesn't want to access it if it's a symlink...
        directory = "src";
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
