{
  config,
  pkgs,
  lib,
  ...
}:
{
  networking = {
    hostName = "ilo";
    domain = "somas.is";

    useDHCP = false;

    firewall = {
      checkReversePath = "loose";

      allowedTCPPorts = [
        22000 # Syncthing
        27385 # Syncthing

        2234 # SoulSeek (Nicotine+, specifically)
      ];

      allowedUDPPorts = [
        22000 # Syncthing
        27385 # Syncthing
      ];

      allowedTCPPortRanges = [
        {
          # KDE Connect
          from = 1714;
          to = 1764;
        }
      ];

      allowedUDPPortRanges = [
        {
          # KDE Connect
          from = 1714;
          to = 1764;
        }
      ];
    };

    networkmanager = {
      enable = true;

      ethernet.macAddress = "stable";
      wifi = {
        macAddress = "random";
        powersave = true;
      };

      dns = "dnsmasq";

      plugins = [
        pkgs.networkmanager-openvpn
      ];
    };
  };

  persist.directories = [ "/etc/NetworkManager/system-connections" ];
  cache.directories = [ "/var/lib/NetworkManager" ];

  # TODO: Track net usage by services
  #       Currently cannot by used for user services...
  systemd.settings.Manager.DefaultIPAccounting = true;

  services.tor = {
    enable = true;
    client = {
      enable = true;
      dns.enable = true;
    };

    settings = {
      HardwareAccel = 1;
      SafeLogging = 1;
      ControlPort = 9051;
    };
  };

  powerManagement.resumeCommands = lib.mkIf config.services.tor.enable ''
    ${config.systemd.package}/bin/systemctl try-restart tor.service
  '';
}
