{
  self,
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports =
    with self;
    with inputs;
    [
      nixosModules.sensible-defaults
      nixosModules.freedom
      nixos-hardware.nixosModules.framework-12th-gen-intel

      lix-module.nixosModules.default

      ./audio.nix
      ./backup.nix
      ./bluetooth.nix
      ./boot.nix
      ./brightness.nix
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
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";

  persist = {
    hideMounts = true;
    directories = [ "/var/lib/systemd" ];
  };

  cache.hideMounts = true;

  log = {
    hideMounts = true;

    directories = [
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

  programs = {
    command-not-found.enable = false;
    nano.enable = false;
  };

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

  # nix = {
  #   distributedBuilds = true;
  #   buildMachines = [
  #     {
  #       hostName = "esther.7596ff.com";
  #       sshUser = "somasis";
  #       protocol = "ssh-ng";
  #       system = "x86_64-linux";
  #       speedFactor = 2;
  #     }
  #   ];
  # };

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
