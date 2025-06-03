{ config, pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;

    # Necessary for gamepad support (or at least, the 8BitDo controller I have).
    package = pkgs.bluez5-experimental;

    # Report headphones' battery level to UPower
    # <https://wiki.archlinux.org/title/Bluetooth#Enabling_experimental_features>
    settings.General = {
      Name = config.networking.fqdnOrHostName;
      Experimental = config.services.upower.enable;
      KernelExperimental = config.services.upower.enable;
    };
  };

  boot.initrd.systemd.storePaths = [
    config.hardware.bluetooth.package
    pkgs.networkmanager
  ];

  persist.directories = [ "/var/lib/bluetooth" ];
}
