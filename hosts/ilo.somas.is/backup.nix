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
      "/persist"
      "/persist/home/kylie"
    ];
    exclude = [
      "*cache*"
      "*/Steam/steamapps/*"

      "/persist/home/kylie/audio/library"
      "/persist/home/kylie/audio/source"
      "/persist/home/kylie/doc/vault"
      "/persist/home/kylie/video/anime"
      "/persist/home/kylie/video/film"
      "/persist/home/kylie/video/tv"
    ];

    extraBackupArgs = [
      "--one-file-system"
      "--iexclude=*cache*"
      "--exclude-if-present=.stfolder"
      "--exclude-caches"
    ];
  };
}
