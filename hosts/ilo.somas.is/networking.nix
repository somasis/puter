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

    hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.fqdnOrHostName);

    firewall.checkReversePath = "loose";

    useDHCP = false;

    # Necessary for Syncthing.
    firewall.allowedTCPPorts = [
      22000
      27385
    ];
    firewall.allowedUDPPorts = [
      22000
      27385
    ];

    # Necessary for KDE Connect
    firewall.allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    firewall.allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];

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
  systemd.extraConfig = ''
    DefaultIPAccounting=true
  '';

  # NOTE: systemd-resolved actually breaks `hostname -f`!
  # services.resolved = {
  #   enable = true;
  #   dnssec = "false"; # slow as fuck and often broken
  # };

  # services.dnsmasq = {
  #   enable = true;
  #   settings = {
  #     listen-address = [ "::1,127.0.0.1" ];
  #     cache-size = 10000;
  #   };
  # };

  services.tor = {
    enable = false;
    client = {
      enable = false;
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
