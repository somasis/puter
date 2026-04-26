{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    browsing = true;
  };

  # Necessary for discovering printers on the network.
  # CUPS doesn't use systemd-resolved for discovery.
  # <https://github.com/apple/cups/issues/5452>
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeText "restart-avahi" ''
        if [ "$2" = "up" ]; then
            ${pkgs.systemd}/bin/systemctl try-restart avahi-daemon.service
        fi
      '';
    }
  ];

  # this seems to fix some discovery issues for me?
  # systemd.services.cups-browsed = {
  #   wants = [ "cups.service" ];
  #   after = [ "cups.service" ];
  # };
}
