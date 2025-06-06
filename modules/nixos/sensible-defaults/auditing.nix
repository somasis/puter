{
  pkgs,
  ...
}:
{
  log.directories = [
    {
      directory = "/var/log/audit";
      mode = "0700";
    }
  ];

  # Enable auditing, which can be useful for seeing what's
  # actually going on elsewhere in the system sometimes.
  security = {
    audit.enable = true;
    auditd.enable = true;
  };

  # Keep uptime statistics.
  services.uptimed.enable = true;
  persist.directories = [ "/var/lib/uptimed" ];

  environment.systemPackages = with pkgs; [
    ssh-audit
    nix-inspect
    nmap
  ];

  # Send notifications about ZFS scrubs, resilvers, etc.
  services.zfs.zed.settings = {
    ZED_NTFY_TOPIC = "aebien8Kee3dohXa";
    ZED_NOTIFY_VERBOSE = true;
  };
}
