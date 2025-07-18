{
  self,
  config,
  lib,
  osConfig,
  ...
}:
let
  bigCacheOptions = {
    vfs-cache-max-size = "4G";
    vfs-cache-max-age = "7d";
    vfs-cache-mode = "full";
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

    remotes = {
      esther.config =
        if osConfig.networking.fqdnOrHostName == "esther.7596ff.com" then
          { type = "local"; }
        else
          {
            type = "sftp";
            host = "esther.7596ff.com";
            user = "somasis";
            copy_is_hardlink = true;
          };

      # whatbox-webdav = {
      #   config = {
      #     type = "webdav";
      #     url = "https://webdav.box.somas.is";
      #     user = "somasis";
      #   };
      #   secrets.pass = config.age.secrets.rclone-whatbox-webdav-pass.path;
      # };

      # whatbox-sftp.config = {
      #   type = "sftp";
      #   host = "ariel.whatbox.ca";
      #   user = "somasis";
      # };

      whatbox = {
        config = {
          type = "sftp";
          host = "ariel.whatbox.ca";
          user = "somasis";
          # type = "alias";
          # remote = "whatbox-sftp:files/";
          # type = "union";
          # upstreams = "whatbox-sftp:files/ whatbox-webdav:";
        };

        mounts = {
          "files/" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/mnt/whatbox";
          };

          "files/audio/source" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/audio/source";
            options = bigCacheOptions;
          };

          "files/video/anime" = {
            enable = true;
            mountPoint = "${config.xdg.userDirs.videos}/anime";
          };

          "files/video/film" = {
            enable = true;
            mountPoint = "${config.xdg.userDirs.videos}/film";
          };

          "files/video/tv" = {
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
    rclone-whatbox-webdav-pass.file = "${self}/secrets/somasis-rclone-whatbox-webdav-pass.age";
    rclone-nextcloud-pass.file = "${self}/secrets/somasis-rclone-nextcloud-pass.age";
  };
}
