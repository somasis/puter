{ pkgs
, lib
, ...
}:
{
  imports = [
    ./audio.nix
    # ./display.nix
    ./bluetooth.nix
    ./brightness.nix
    ./ddcci.nix
    ./fingerprint.nix
    ./phone.nix
    ./networking.nix
    ./print.nix
    ./scan.nix
    ./sensors.nix
    ./touchpad.nix
  ];

  hardware.enableRedistributableFirmware = true;
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
    };

    kernelModules = [
      "kvm-intel"
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];
  };

  # Keep system firmware up to date.
  # TODO: Framework still doesn't have their updates in LVFS properly,
  #       <https://knowledgebase.frame.work/en_us/framework-laptop-bios-releases-S1dMQt6F#:~:text=Updating%20via%20LVFS%20is%20available%20in%20the%20testing%20channel>
  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
    uefiCapsuleSettings.DisableCapsuleUpdateOnDisk = true;
  };

  services.usbguard = {
    enable = true;
    package = pkgs.usbguard;
    IPCAllowedGroups = [ "wheel" ];
  };

  environment.systemPackages = [
    pkgs.framework-tool
  ];

  persist.directories = [ "/var/lib/fwupd" ];
  cache.directories = [
    "/var/cache/fwupd"
    {
      directory = "/var/lib/usbguard";
      mode = "0775";
      user = "root";
      group = "wheel";
    }
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

  # Fix watchdog delaying reboot
  # https://wiki.archlinux.org/title/Framework_Laptop#ACPI
  systemd.watchdog.rebootTime = "0";
}
