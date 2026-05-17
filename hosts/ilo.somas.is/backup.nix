{
  config,
  self,
  ...
}:
{
  age.secrets = {
    restic.file = "${self}/secrets/restic-${config.networking.fqdnOrHostName}.age";
    restic-rclone-whatbox.file = "${self}/secrets/restic-rclone-whatbox.age";
  };

  services.restic.backups.ilo = {
    repository = "rclone:whatbox:backups/restic/ilo";
    passwordFile = config.age.secrets.restic.path;
    rcloneConfigFile = config.age.secrets.restic-rclone-whatbox.path;
    initialize = true;

    pruneOpts = [
      "--keep-within 1h"
      "--keep-within-hourly 12h"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
      "--keep-yearly 1"
      "--repack-cacheable-only"
    ];

    timerConfig.OnCalendar = [
      "*:0/15:00" # every 15 minutes
      "hourly"
      "daily"
      "weekly"
      "monthly"
    ];

    paths = [
      "/data"
      "/data/home/kylie"
    ];
    exclude = [
      "*/Steam/steamapps/*"

      "/data/home/kylie/var/cache/rclone/*"
      "/data/home/kylie/audio/library"
      "/data/home/kylie/audio/source"
      "/data/home/kylie/doc/vault"
      "/data/home/kylie/video/anime"
      "/data/home/kylie/video/film"
      "/data/home/kylie/video/tv"
    ];

    extraBackupArgs = [
      "--one-file-system"
      "--exclude-caches"
    ];
  };
}
