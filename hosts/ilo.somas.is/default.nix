{ self
, inputs
, lib
, config
, pkgs
, ...
}:
{
  imports = with self; with inputs; [
    nixosModules.sensible-defaults

    nixosHardware.nixosModules.framework-12th-gen-intel
    ./hardware

    ./backup.nix
    ./boot.nix
    ./console.nix
    ./desktop.nix
    ./documentation.nix
    ./filesystems.nix
    ./fonts.nix
    ./games.nix
    ./locale.nix
    ./nix.nix
    ./power.nix
    ./security.nix
    ./users.nix
    ./wine.nix
  ];

  meta.type = "laptop";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";

  persist.hideMounts = true;

  cache = {
    hideMounts = true;

    directories = [
      "/var/lib/systemd/timers"
      "/var/lib/systemd/backlight"
      "/var/lib/systemd/linger"
    ];
    files = [ "/var/lib/systemd/random-seed" ];
  };

  log = {
    hideMounts = true;

    directories = [
      "/var/lib/systemd/catalog"
      "/var/lib/systemd/coredump"
      {
        directory = "/var/log/journal";
        user = "root";
        group = "systemd-journal";
        mode = "2755";
      }
    ];
    files = [
      "/var/log/btmp"
      "/var/log/lastlog"
      "/var/log/wtmp"
      "/etc/machine-id"
    ];
  };

  programs.command-not-found.enable = false;
  programs.nano.enable = false;
  programs.partition-manager.enable = true;

  environment.systemPackages = with pkgs; [
    extrace
    git
  ];

  security.wrappers.extrace = {
    source = "${pkgs.extrace}/bin/extrace";
    capabilities = "cap_net_admin+ep";
    owner = "root";
    group = "root";
  };

  environment.pathsToLink =
    lib.optional config.programs.bash.completion.enable "/share/bash-completion"
    ++ lib.optionals config.xdg.portal.enable [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

  home-manager = {
    verbose = true;

    users.somasis =
      { pkgs, ... }:
      {
        imports = [
          ../../users/somasis
          ../../users/somasis/desktop
        ];
      };
  };
}
