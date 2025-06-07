{
  self,
  config,
  lib,
  osConfig,
  ...
}:
let
  bigCacheOptions = {
    vfs-cache-max-size = "16G";
    vfs-cache-max-age = "1d";
    vfs-cache-mode = "full";
    vfs-read-ahead = "128Mi";
    vfs-fast-fingerprint = true;
    vfs-cache-poll-interval = "10m";
    vfs-refresh = true;
    dir-cache-time = "1d";
  };

  streamingCacheOptions = {
    vfs-fast-fingerprint = true;
    vfs-read-ahead = "128Mi";
    vfs-read-chunk-size = "4Mi";
    vfs-read-chunk-size-limit = "25Mi";
    vfs-read-chunk-streams = "16";
  };
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
            key_use_agent = true;

            copy_is_hardlink = true;
          };

      whatbox-webdav = {
        config = {
          type = "webdav";
          url = "https://webdav.quietzebra.box.ca";
          user = "somasis";
        };
        secrets.pass = config.age.secrets.rclone-whatbox-webdav-pass.path;
      };

      whatbox-sftp.config = {
        type = "sftp";
        host = "ariel.whatbox.ca";
        user = "somasis";
        key_use_agent = true;
      };

      whatbox = {
        config = {
          type = "union";
          upstreams = "whatbox-sftp:files/ whatbox-webdav:";
        };

        mounts = {
          "audio/library" = {
            enable = true;
            mountPoint = config.xdg.userDirs.music;
            options = bigCacheOptions // streamingCacheOptions;
          };

          "video/anime" = {
            enable = true;
            mountPoint = "${config.xdg.userDirs.videos}/anime";
            options = bigCacheOptions // streamingCacheOptions;
          };

          "video/film" = {
            enable = true;
            mountPoint = "${config.xdg.userDirs.videos}/film";
            options = bigCacheOptions // streamingCacheOptions;
          };

          "video/tv" = {
            enable = true;
            mountPoint = "${config.xdg.userDirs.videos}/tv";
            options = bigCacheOptions // streamingCacheOptions;
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
            options = streamingCacheOptions;
          };

          "cassie/media/music/flac2" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/audio/library-cassie";
            options = bigCacheOptions // streamingCacheOptions;
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
