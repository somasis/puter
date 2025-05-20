{ pkgs, config, ... }:
{
  environment.systemPackages = [ pkgs.borgbackup ];
  # TODO(somasis) bobo I don't have this working yet
  # services.borgbackup = {
  #   jobs.system = {
  #     doInit = false;
  #     repo = "/mnt/raid/backup";
  #
  #     paths = [ "/persist" "/log" ];
  #
  #     # Don't try to backup mountpoints
  #     extraCreateArgs = [ "--one-file-system" ];
  #
  #     encryption.mode = "none";
  #
  #     persistentTimer = true;
  #
  #     prune.keep = {
  #       daily = 7;
  #       weekly = 4;
  #       monthly = -1;
  #     };
  #   };
  # };

  services.smartd = {
    enable = true;
    notifications.systembus-notify.enable = true;
  };
}
