{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) options types;
  inherit (options) mkEnableOption mkOption;
  inherit (config.lib.nixos) escapeSystemdPath;

  rcloneCfg = config.programs.rclone;
  rclonePkg = rcloneCfg.package;
  rcloneExe = lib.getExe rclonePkg;

  rcloneFlagToEnvVar =
    flag:
    assert (lib.hasPrefix "--" flag);
    let
      flagParts = lib.pipe flag [
        (lib.removePrefix "--")
        (lib.splitString "=")
      ];
    in
    "RCLONE_"
    + (lib.pipe (builtins.head flagParts) [
      (lib.replaceStrings [ "-" ] [ "_" ])
      lib.toUpper
    ])
    + (
      if (lib.drop 1 flagParts) != [ ] then "=${lib.concatStrings (lib.drop 1 flagParts)}" else "=true"
    );
in
{
  options.services.rclone = {
    enable = mkEnableOption "Enable rclone mount services";

    mounts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, config, ... }:
          {
            options = {
              remote = mkOption {
                type = types.nonEmptyStr;
                description = "Remote to mount. Remote must exist in `programs.rclone.remotes`.";
                default = null;
                example = "seedbox";
              };

              what = mkOption {
                type = types.str;
                description = "Path on remote to mount";
                default = "";
                example = "/mnt/raid";
              };

              where =
                let
                  remoteSettings = rcloneCfg.remotes."${config.remote}";
                in
                mkOption {
                  type = types.nonEmptyStr;
                  description = "Local path to mount remote path";
                  default = "${config.home.homeDirectory}/mnt/${remoteSettings.type}/${name}";
                  defaultText = options.literalExpression "\${config.home.homeDirectory}/mnt/<mount remote type>/<mount name>";
                  example = options.literalExpression "\${config.home.homeDirectory}/mnt/seedbox";
                };

              options = mkOption {
                type = with types; listOf str;
                description = ''
                  Options for `rclone mount` and the mount services *only*.
                  See `rclone mount --help` for details.
                '';
                default = [ ];
                example = [ "vfs-cache-max-size=1G" ];
              };

              linger = mkOption {
                type = with types; either nonEmptyStr ints.nonnegative;
                description = ''
                  How long the mount should be kept around after its last use.
                  See systemd.automount(7) "TimeoutIdleSec=" for details.
                '';
                default = "5min 20s";
                example = 0;
              };
            };
          }
        )
      );

      description = "Set of mounts to create";

      default = { };
      example = {
        seedbox = {
          remote = "seedbox";
          what = "/mnt/raid";
          where = options.literalExpression "\${config.home.homeDirectory}/mnt/seedbox";
          options = [ "vfs-cache-max-size=1G" ];
        };
      };
    };
  };

  config = {
    systemd.user = lib.mkIf (config.services.rclone.enable && config.services.rclone.mounts != { }) (
      lib.foldr
        (
          mount: units:
          let
            unitPath = escapeSystemdPath mount.where;
            unitDescription = "Mount ${mount.remote}:${mount.what} at ${mount.where}";

          in
          # rclone recommends using
          # > You should not run two copies of rclone using the same VFS cache with
          # > the same or overlapping remotes if using `--vfs-cache-mode > off`.
          # > This can potentially cause data corruption if you do. You can work
          # > around this by giving each rclone its own cache hierarchy with
          # > `--cache-dir`. You don't need to worry about this if the remotes in
          # > use don't overlap.
          # rcloneCache = "${config.xdg.cacheHome}/rclone/
          lib.recursiveUpdate units {
            services.${unitPath} = {
              Unit = {
                Description = unitDescription;
                PartOf = [ "rclone.target" ];
                # Upholds = [ "${unitPath}.mount" ];
              };
              Install.WantedBy = [
                "rclone.target"
                # "${unitPath}.mount"
              ];

              Service = {
                Type = "notify";

                SyslogIdentifier = "rclone-${mount.what}-${mount.where}";

                Environment =
                  [
                    "RCLONE_CONFIG=%E/rclone/rclone.conf"
                    "RCLONE_CACHE_DIR=%C/rclone"
                    ''"WHERE=${mount.where}"''
                    ''"WHAT=${mount.remote}:${mount.what}"''
                  ]
                  ++ lib.optionals (mount.options != [ ]) (
                    map (flag: ''"${rcloneFlagToEnvVar "--${flag}"}"'') mount.options
                  );

                # <https://rclone.org/commands/rclone_mount/#systemd>
                # > Note that systemd runs mount units without any environment variables
                # > including `PATH` or `HOME`. This means that tilde (`~`) expansion will
                # > not work and you should provide `--config` and `--cache-dir` explicitly
                # > as absolute paths via rclone arguments.
                ExecStartPre = [
                  # ensure the configuration is there; `rclone config touch` seems to cause a race condition!
                  "${rcloneExe} config dump"

                  ''${pkgs.coreutils}/bin/mkdir -p ''${WHERE}''
                ];

                ExecStart = [ ''${rcloneExe} mount ''${WHAT} ''${WHERE}'' ];
                ExecStopPost = [ ''-${pkgs.coreutils}/bin/rmdir ''${WHERE}'' ];

                StandardOutput = "null";
              };
            };

            # mounts.${unitPath} = {
            #   Unit = {
            #     Description = unitDescription;
            #     BindsTo = [ "${unitPath}.service" ];
            #     After = [ "${unitPath}.service" ];
            #   };

            #   Install.WantedBy = [ "mounts.target" "rclone.target" ];

            #   Mount = {
            #     Type = "rclone";
            #     What = "${mount.remote}:${mount.what}";
            #     Where = mount.where;
            #     # Options = lib.concatStringsSep "," ([ "rw" "_netdev" "args2env" ]);

            #     # Necessary for `afuse` to work.
            #     # LazyUnmount = true;
            #   };
            # };

            # BUG These don't properly function right now...
            #     not sure how userspace automounts ever would have worked.
            # automounts.${unitPath} = {
            #   Unit.Description = unitDescription;
            #   Unit.PartOf = [ "rclone.target" ];
            #   Install.WantedBy = [ "rclone.target" ];

            #   Automount.Where = mount.where;
            #   Automount.TimeoutIdleSec = mount.linger;
            # };

            # services."afuse-${unitPath}" = {
            #   Unit.Description = "Automount for ${mount.remote}:${mount.what} at ${mount.where}";
            #   Install.WantedBy = [ "rclone.target" ];

            #   Service = {
            #     Type = "simple";
            #     ExecStart = lib.singleton ''
            #       ${pkgs.afuse}/bin/afuse \
            #           -o mount_template="${pkgs.systemd}/bin/systemctl --user start ${unitPath}.mount" \
            #           -o unmount_template="${pkgs.systemd}/bin/systemctl --user stop ${userPath}.mount"
            #     '';
            #   };
            # };
          }
        )
        {
          targets.rclone = {
            Unit.Description = "All rclone mounts";
            Install.WantedBy = [ "default.target" ];
          };
        }
        (lib.mapAttrsToList (n: v: v) config.services.rclone.mounts)
    );
  };
}
