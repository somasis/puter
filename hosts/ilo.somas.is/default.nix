{
  self,
  sources,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = with sources; [
    self.nixosModules.defaults
    self.nixosModules.npins
    self.nixosModules.impermanence

    "${nixos-hardware}/framework/13-inch/12th-gen-intel"

    ./audio.nix
    ./backup.nix
    ./bluetooth.nix
    ./boot.nix
    ./console.nix
    ./desktop.nix
    ./documentation.nix
    ./filesystems.nix
    ./fingerprint.nix
    ./fonts.nix
    ./games.nix
    ./hardware-configuration.nix
    ./locale.nix
    ./networking.nix
    ./phone.nix
    ./power.nix
    ./print.nix
    ./scan.nix
    ./security.nix
    ./sensors.nix
    ./touchpad.nix
    ./users.nix
    ./wine.nix
  ];

  meta.type = "laptop";
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.systems.examples.gnu64;
  };

  system = {
    stateVersion = "25.05";
    autoUpgrade.enable = false;
  };

  persist = {
    hideMounts = true;
    directories = [
      "/var/lib/systemd"

      {
        directory = "/var/log/journal";
        user = "root";
        group = "systemd-journal";
        mode = "2755";
      }
    ];

    files = [
      "/var/log/btmp"
      "/var/log/wtmp"
      "/etc/machine-id"
    ];
  };

  cache.hideMounts = true;

  programs.nano.enable = false;

  environment.systemPackages = with pkgs; [
    extrace
    framework-tool
    git
  ];

  # VDPAU, VAAPI, etc. is handled by <nixos-hardware/common/gpu/intel>,
  # which is imported by <nixos-hardware/framework>.
  hardware.graphics = {
    enable32Bit = true;

    extraPackages = [
      # Enable OpenCL functionality for the Intel integrated graphics.
      pkgs.intel-compute-runtime
    ];
  };

  environment.pathsToLink =
    lib.optional config.programs.bash.completion.enable "/share/bash-completion"
    ++ lib.optionals config.xdg.portal.enable [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

  # Keep system firmware up to date.
  services.fwupd = {
    enable = true;
    uefiCapsuleSettings.DisableCapsuleUpdateOnDisk = true;
  };

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
