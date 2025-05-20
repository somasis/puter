{ config
, pkgs
, lib
, osConfig
, ...
}:
let
  cacheOptions = [
    "vfs-cache-mode=full"
    "vfs-cache-max-size=2G"

    "vfs-read-ahead=128Mi"
    "buffer-size=8Mi"

    "vfs-fast-fingerprint"
    # "write-back-cache"
  ];
in
{
  persist.directories = [
    {
      method = "bindfs";
      directory = config.lib.somasis.xdgConfigDir "rclone";
    }
  ];
  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "rclone";
    }
  ];

  programs.rclone = {
    enable = true;

    extraOptions =
      [
        "--default-time"
        "1970-01-01T00:00:00Z"
      ]
      ++ [ "--fast-list" ]
      ++ [ "--human-readable" ]
      ++ [ "--use-mmap" ]
      ++ map (flag: "--${flag}") cacheOptions;

    remotes =
      let
        sftp =
          target: extraAttrs:
            assert (lib.isString target && target != "");
            assert (lib.isAttrs extraAttrs);
            let
              targetParts = builtins.match "(.*@)?(.+)" target;

              host = builtins.elemAt targetParts 1;

              sshPkg =
                if lib.isDerivation config.programs.ssh.package then
                  config.programs.ssh.package
                else
                  osConfig.programs.ssh.package or pkgs.openssh;
              sshExe = lib.getExe sshPkg;
            in
            assert (lib.isString host && builtins.stringLength host > 0);
            {
              type = "sftp";

              # key_file = "${config.xdg.configHome}/ssh/id_ed25519";
              # known_hosts_file = config.programs.ssh.userKnownHostsFile;

              # This makes rclone not use its internal ssh library at all,
              # which reduces the potential of ssh-related issues.
              # inherit host user;
              ssh = "${sshExe} ${target}";
            }
            // extraAttrs;

      in
      {
        "somasis@esther.7596ff.com" = sftp "somasis@esther.7596ff.com" { };
        "somasis@ariel.whatbox.ca" = sftp "somasis@ariel.whatbox.ca" { };

        gdrive-personal = {
          type = "drive";
          scope = "drive";
          drive-export-formats = [
            "docx"
            "xlsx"
            "pptx"
            "svg"
          ];
          poll-interval = "1m";
        };

        gphotos-personal = {
          type = "google photos";
          include_archived = true;
        };

        nextcloud = rec {
          type = "webdav";
          url = "https://nxc.journcy.net/remote.php/dav/files/${user}";
          vendor = "nextcloud";
          user = "somasis";
        };

        fastmail = rec {
          type = "webdav";
          url = ''https://webdav.fastmail.com/${lib.replaceStrings [ "@" ] [ "." ] user}/files'';
          vendor = "fastmail";
          user = "kylie@somas.is";
        };

        music-cassie = {
          type = "union";
          upstreams = "/mnt/raid/cassie/media/music/flac2 music-cassie-webdav:";
          action_policy = "epff";
        };

        music-cassie-webdav = {
          type = "webdav";
          url = "https://esther.7596ff.com/media/music/flac2";
          vendor = "other";
        };
      };
  };

  services.rclone =
    let
      vfsCache = [
        "vfs-cache-max-size=256M"
        "vfs-cache-mode=writes"
      ];
    in
    {
      enable = true;

      mounts =
        {
          music-cassie = {
            remote = "music-cassie";
            what = "";
            where = "${config.home.homeDirectory}/audio/library-cassie";
            options = vfsCache ++ [ "cache-dir=${config.xdg.cacheHome}/rclone/vfs-music-cassie" ];
          };

          whatbox = {
            remote = "somasis@ariel.whatbox.ca";
            what = "";
            where = "${config.home.homeDirectory}/mnt/seedbox";
            options = vfsCache ++ [ "cache-dir=${config.xdg.cacheHome}/rclone/vfs-whatbox" ];
          };

          gdrive-personal = {
            remote = "gdrive-personal";
            what = "";
            where = "${config.home.homeDirectory}/mnt/gdrive-personal";

            # options = defaultOptions ++ [ "cache-dir=${config.xdg.cacheHome}/rclone/vfs-${remote}" ];
          };

          gdrive-personal-shared = {
            remote = "gdrive-personal,shared_with_me";
            what = "";
            where = "${config.home.homeDirectory}/mnt/gdrive-personal/shared";

            # options = defaultOptions ++ [ "cache-dir=${config.xdg.cacheHome}/rclone/vfs-${remote}" ];
          };

          gphotos-personal = {
            remote = "gphotos-personal";
            what = "";
            where = "${config.home.homeDirectory}/mnt/gphotos";

            # NOTE rclone says
            # > --vfs-cache-mode writes or full is recommended for this remote as it can't stream
            options = cacheOptions;
          };

          nextcloud = {
            remote = "nextcloud";
            what = "";
            where = "${config.home.homeDirectory}/mnt/nextcloud";
          };

          fastmail = {
            remote = "fastmail";
            what = "";
            where = "${config.home.homeDirectory}/mnt/fastmail";
          };
        }
        // lib.optionalAttrs (osConfig.networking.fqdnOrHostName != "esther.7596ff.com") {
          esther = {
            remote = "somasis@esther.7596ff.com";
            what = "/";
            where = "${config.home.homeDirectory}/mnt/esther.7596ff.com";
            # options = defaultOptions;
          };

          esther-raid = {
            remote = "somasis@esther.7596ff.com";
            what = "/mnt/raid/somasis";
            where = "${config.home.homeDirectory}/mnt/esther.7596ff.com_raid";
            # options = defaultOptions;
          };
        };
    };
}
