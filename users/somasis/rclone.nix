{
  self,
  config,
  lib,
  osConfig,
  ...
}:
let
  bigCacheOptions = {
    vfs-refresh = true;
    vfs-cache-mode = "full";
    vfs-cache-max-size = "4G";
    vfs-cache-max-age = "7d";
    vfs-fast-fingerprint = true;
    write-back-cache = true;
  };

  # structureCacheOptions = {
  #   # With remotes that can fingerprint on their end, these options allow us to
  #   # have faster access of the *structure* of a remote; but this ultimtaely
  #   # requires a high degree of trust in remote fingerprinting, as well as the
  #   # the VFS write cache of the mount being written back often enough.
  #   vfs-refresh = true;
  #   vfs-cache-max-age = "1d";
  #   vfs-fast-fingerprint = true;
  # };
in
{
  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "vfs";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "vfsMeta";
    }
  ];

  home.shellAliases.rclone = "rclone --fast-list --use-mmap --human-readable";

  programs.rclone = {
    enable = true;

    remotes =
      let
        sshExe = lib.getExe (osConfig.programs.ssh.package or config.programs.ssh.package);
      in
      {
        esther.config = {
          type = "sftp";
          ssh = "${sshExe} somasis@esther.7596ff.com";
          # host = "esther.7596ff.com";
          # user = "somasis";
          copy_is_hardlink = true;
        };

        whatbox-http = {
          config.type = "http";
          secrets.url = config.age.secrets.rclone-whatbox-http-url.path;
        };

        whatbox-webdav = {
          config = {
            type = "webdav";
            url = "https://files.box.somas.is";
            user = "somasis";
          };
          secrets.pass = config.age.secrets.rclone-whatbox-webdav-pass.path;
        };

        whatbox-ftp = {
          config = {
            type = "ftp";
            host = "salak.whatbox.ca";
            explicit_tls = true;
            user = "somasis";
          };
          secrets.pass = config.age.secrets.rclone-whatbox-webdav-pass.path;
        };

        whatbox-sftp.config = {
          type = "sftp";
          ssh = "${sshExe} whatbox";
          # host = "salak.whatbox.ca";
          # user = "somasis";
        };

        whatbox = {
          config = {
            type = "union";
            upstreams = ''"whatbox-webdav:" "whatbox-sftp:files/" "whatbox-ftp:files/" "whatbox-http:files/:ro"'';
          };

          mounts = {
            "" = {
              enable = true;
              mountPoint = "${config.home.homeDirectory}/mnt/whatbox";
            };

            "audio/source" = {
              enable = true;
              mountPoint = "${config.home.homeDirectory}/audio/source";
              options = bigCacheOptions;
            };

            "video/anime" = {
              enable = true;
              mountPoint = "${config.xdg.userDirs.videos}/anime";
            };

            "video/film" = {
              enable = true;
              mountPoint = "${config.xdg.userDirs.videos}/film";
            };

            "video/tv" = {
              enable = true;
              mountPoint = "${config.xdg.userDirs.videos}/tv";
            };
          };
        };

        raid = {
          config = {
            type = "alias";
            remote = "esther:/mnt/raid";
          };

          mounts = {
            "" = {
              enable = true;
              mountPoint = "${config.home.homeDirectory}/mnt/raid";
            };
          };
        };

        fastmail = {
          config = rec {
            type = "webdav";
            vendor = "fastmail";
            url = "https://webdav.fastmail.com/${lib.replaceStrings [ "@" ] [ "." ] user}/files";
            user = "kylie@somas.is";
          };
          secrets.pass = config.age.secrets.rclone-fastmail-pass.path;

          mounts."" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/mnt/fastmail";
          };
        };

        nextcloud = {
          config = rec {
            type = "webdav";
            vendor = "nextcloud";
            url = "https://nxc.journcy.net/remote.php/dav/files/${user}";
            user = "somasis";
          };
          secrets.pass = config.age.secrets.rclone-nextcloud-pass.path;
        };
      };
  };

  age.secrets = {
    rclone-fastmail-pass.file = "${self}/secrets/somasis-rclone-fastmail-pass.age";
    rclone-whatbox-http-url.file = "${self}/secrets/somasis-rclone-whatbox-http-url.age";
    rclone-whatbox-webdav-pass.file = "${self}/secrets/somasis-rclone-whatbox-webdav-pass.age";
    rclone-nextcloud-pass.file = "${self}/secrets/somasis-rclone-nextcloud-pass.age";
  };
}
