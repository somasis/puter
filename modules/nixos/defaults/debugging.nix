{
  config,
  pkgs,
  ...
}:
{
  # Keep uptime statistics.
  services.uptimed.enable = true;
  persist.directories = [ "/var/lib/uptimed" ];

  # Add some additional tools for monitoring the system's resources.
  programs = {
    bandwhich.enable = true;
    htop.enable = true;
    iotop.enable = true;
    tcpdump.enable = true;
    wireshark = {
      enable = true;

      # Defaults to -cli, which doesn't have the Qt interface.
      package = if config.meta.type == "server" then pkgs.wireshark-cli else pkgs.wireshark;

      dumpcap.enable = true;
      usbmon.enable = true;
    };
  };

  # extrace(1) is a tool for showing programs executed by a given program.
  security.wrappers.extrace = {
    source = "${pkgs.extrace}/bin/extrace";
    capabilities = "cap_net_admin+ep";
    owner = "root";
    group = "root";
  };

  # TODO I think this will make DrKonqi work?
  services.nixseparatedebuginfod2 = {
    enable = true;
    substituters = [ "local:" ] ++ config.nix.settings.substituters;
  };
}
