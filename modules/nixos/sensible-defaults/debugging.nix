{
  config,
  pkgs,
  ...
}:
{
  # Keep uptime statistics.
  services.uptimed.enable = true;
  persist.directories = [ "/var/lib/uptimed" ];

  # services.nixseparatedebuginfod.enable = true;
  # cache.directories = [ "/var/cache/nixseparatedebuginfod" ];

  # Add some additional tools for monitoring the system's resources.
  programs = {
    bandwhich.enable = true;
    htop.enable = true;
    iotop.enable = true;
    tcpdump.enable = true;
  };
}
