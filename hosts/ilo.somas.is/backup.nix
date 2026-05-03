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

    paths = [
      "/data"
      "/data/home/kylie"
    ];
    exclude = [
      "*cache*"
      "*/Steam/steamapps/*"

      "/data/home/kylie/audio/library"
      "/data/home/kylie/audio/source"
      "/data/home/kylie/doc/vault"
      "/data/home/kylie/video/anime"
      "/data/home/kylie/video/film"
      "/data/home/kylie/video/tv"
    ];

    extraBackupArgs = [
      "--one-file-system"
      "--iexclude=*cache*"
      "--exclude-if-present=.stfolder"
      "--exclude-caches"
    ];
  };
}
