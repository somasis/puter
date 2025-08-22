{
  config,
  self,
  ...
}:
{
  # services.borgbackup.jobs.persist = defaults // {
  #   repo = repoEsther;
  # };

  # systemd = {
  #   timers."borgbackup-job-esther".wants = [ "network-online.target" ];
  #   services."borgbackup-job-esther" = {
  #     unitConfig.ConditionACPower = true;
  #     serviceConfig.Nice = 19;
  #   };
  # };

  # environment.systemPackages =
  #   let
  #     borgJobs = builtins.attrNames config.services.borgbackup.jobs;
  #     defaultArgs = lib.cli.toGNUCommandLineShell { } {
  #       progress = true;
  #       verbose = true;
  #       lock-wait = 600;
  #     };
  #   in
  #   [
  #     (pkgs.borg-takeout.override {
  #       borgConfig = config.services.borgbackup.jobs.persist;
  #     })
  #   ]
  #   ++ (lib.optional (builtins.length borgJobs == 1) (
  #     pkgs.writeShellScriptBin "borg" ''
  #       exec borg-job-${lib.escapeShellArg (builtins.elemAt borgJobs 0)} ${defaultArgs} "$@"
  #     ''
  #   ));

  cache.directories = [
    # {
    #   directory = "/root/.cache/borg";
    #   mode = "0770";
    # }
    {
      directory = "/var/cache/restic-backups-ilo";
      mode = "0770";
    }
  ];

  age.secrets = {
    restic-ilo.file = "${self}/secrets/restic-ilo.age";
    restic-rclone-whatbox.file = "${self}/secrets/restic-rclone-whatbox.age";
  };

  services.restic.backups.ilo = {
    repository = "rclone:whatbox:backups/restic/ilo";
    passwordFile = config.age.secrets.restic-ilo.path;
    rcloneConfigFile = config.age.secrets.restic-rclone-whatbox.path;
    initialize = true;

    paths = [
      "/persist"
      "/persist/home/somasis"
    ];
    exclude = [ "*cache*" ];

    extraBackupArgs = [
      "--one-file-system"
      ''--iexclude=*cache*''
      "--exclude-if-present=.stfolder"
      "--exclude-caches"
    ];
  };
}
