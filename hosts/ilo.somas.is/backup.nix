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
      "/persist/home/somasis"
    ];
    exclude = [
      "*cache*"
      "*/Steam/steamapps/*"

      "/persist/home/somasis/audio/library"
      "/persist/home/somasis/audio/source"
      "/persist/home/somasis/doc/vault"
      "/persist/home/somasis/video/anime"
      "/persist/home/somasis/video/film"
      "/persist/home/somasis/video/tv"
    ];

    extraBackupArgs = [
      "--one-file-system"
      "--iexclude=*cache*"
      "--exclude-if-present=.stfolder"
      "--exclude-caches"
    ];
  };
}
