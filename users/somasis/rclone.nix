{
  self,
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  inherit (osConfig.networking) hostName;

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
    (config.lib.somasis.xdgCacheDir "vfs")
    (config.lib.somasis.xdgCacheDir "vfsMeta")

    (config.lib.somasis.xdgCacheDir "restic")
  ];

  home = {
    packages = [ pkgs.restic ];
    shellAliases.rclone = "rclone --fast-list --use-mmap --human-readable";
  };

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
          copy_is_hardlink = true;
        };

        whatbox-http = {
          config.type = "http";
          secrets.url = config.age.secrets.rclone-whatbox-http-url.path;
        };

        whatbox-sftp.config = {
          type = "sftp";
          ssh = "${sshExe} whatbox";
        };

        whatbox = {
          config = {
            type = "webdav";
            url = "https://files.box.somas.is";
            vendor = "rclone";
            user = hostName;
          };
          secrets.pass = config.age.secrets."rclone-whatbox-${hostName}-pass".path;

          mounts = {
            "" = {
              enable = true;
              mountPoint = "${config.home.homeDirectory}/mnt/whatbox";
            };

            "audio/library" = {
              enable = true;
              mountPoint = "${config.home.homeDirectory}/audio/library";

              logLevel = "DEBUG";

              options = bigCacheOptions // {
                dir-cache-time = "2m0s";
              };
            };

            "audio/source" = {
              enable = true;
              mountPoint = "${config.home.homeDirectory}/audio/source";

              logLevel = "DEBUG";

              options = bigCacheOptions // {
                dir-cache-time = "2m0s";
              };
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

        vault = {
          config = {
            type = "crypt";
            remote = "whatbox:backups/vault";
            filename_encoding = "base64";
            suffix = "none";
          };
          secrets = {
            password = config.age.secrets.rclone-vault-password.path;
            password2 = config.age.secrets.rclone-vault-password2.path;
          };

          mounts."" = {
            enable = true;
            mountPoint = "${config.xdg.userDirs.documents}/vault";
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
    # keep-sorted start
    "rclone-whatbox-${hostName}-pass".file = "${self}/secrets/rclone-whatbox-${hostName}-pass.age";
    rclone-fastmail-pass.file = "${self}/secrets/rclone-fastmail-pass.age";
    rclone-nextcloud-pass.file = "${self}/secrets/rclone-nextcloud-pass.age";
    rclone-vault-password.file = "${self}/secrets/rclone-vault-password.age";
    rclone-vault-password2.file = "${self}/secrets/rclone-vault-password2.age";
    rclone-whatbox-http-url.file = "${self}/secrets/rclone-whatbox-http-url.age";
    # keep-sorted end
  };
}
