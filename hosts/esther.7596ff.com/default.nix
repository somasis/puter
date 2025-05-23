{ config
, lib
, pkgs
, self
, modulesPath
, ...
}:
{
  imports = with self; with inputs; [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixosModules.sensible-defaults

    ./audio.nix
    ./backups.nix
    ./cassie.nix
    ./desktop.nix
    ./filesystems.nix
    ./gaming.nix
    ./git.nix
    ./networking.nix
    ./nix.nix
    ./ntfy.nix
    ./samba.nix
    ./somasis.nix
    ./users.nix
  ];

  meta.type = "workstation";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.11";

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];

    loader = {
      systemd-boot = {
        enable = true;
        editor = false;

        # Include Memtest86+, so we have some memory diagnostics
        memtest86.enable = true;
      };

      timeout = 5;

      efi.canTouchEfiVariables = true;
    };
  };

  persist = {
    directories = [
      "/var/lib/systemd"
      {
        directory = "/var/lib/private";
        mode = "0700";
      }
    ];
  };

  log = {
    directories = [
      {
        directory = "/var/log/journal";
        user = "root";
        group = "systemd-journal";
        mode = "2755";
      }
    ];

    files = [
      "/etc/machine-id"
      "/var/log/btmp"
      "/var/log/lastlog"
      "/var/log/wtmp"
    ];
  };

  home-manager = {
    verbose = true;

    users = {
      cassie = import "${self}/users/cassie/esther.nix";
      somasis = {
        imports = [
          "${self}/users/somasis"
          "${self}/users/somasis/desktop"
        ];
      };
    };
  };

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

  environment.systemPackages = [
    pkgs.htop
    pkgs.tmux
    pkgs.kakoune
    pkgs.neovim
  ]
  ++ lib.unique (lib.mapAttrsToList (_: x: x) (lib.filterAttrs (_: lib.isDerivation) pkgs.nixos-artwork.wallpapers))
  ;

  environment.pathsToLink = [ "/share/wallpapers" "/share/backgrounds" ];
}
