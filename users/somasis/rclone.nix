{ self
, config
, pkgs
, lib
, osConfig
, ...
}:
let
  bigCacheOptions = {
    vfs-cache-max-size = "2G";
    vfs-read-ahead = "128Mi";
    buffer-size = "8Mi";
    vfs-fast-fingerprint = true;
  };
in
{
  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "rclone";
    }
  ];

  home.shellAliases.rclone = "rclone --fast-list --use-mmap --human-readable";

  programs.rclone = {
    enable = true;

    remotes =
      let
        mountPoint = x: "${config.home.homeDirectory}/mnt/${x}";

        sftp =
          target: extraAttrs:
            assert (lib.isString target && target != "");
            assert (lib.isAttrs extraAttrs);
            let
              targetParts = builtins.match "(.*@)?(.+)" target;

              host = builtins.elemAt targetParts 1;

              sshExe = lib.getExe (
                if lib.isDerivation config.programs.ssh.package then
                  config.programs.ssh.package
                else
                  osConfig.programs.ssh.package or pkgs.openssh
              );
            in
            assert (lib.isString host && builtins.stringLength host > 0);
            {
              type = "sftp";

              # This makes rclone not use its internal ssh library at all,
              # which reduces the potential of ssh-related issues.
              # inherit host user;
              ssh = "${sshExe} ${target}";

              copy_is_hardlink = true;
            }
            // extraAttrs;
      in
      {
        esther = {
          config =
            if osConfig.networking.fqdnOrHostName == "esther.7596ff.com" then
              { type = "local"; }
            else
              sftp "somasis@esther.7596ff.com" { };

          mounts."" = {
            enable = true;
            mountPoint = mountPoint "esther";
          };
        };

        whatbox = {
          config = sftp "somasis@ariel.whatbox.ca" { };

          mounts."" = {
            enable = true;
            mountPoint = mountPoint "whatbox";
          };
        };

        raid = {
          config = {
            type = "alias";
            remote = "esther:/mnt/raid";
          };

          mounts."" = {
            enable = true;
            mountPoint = mountPoint "raid";
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
            mountPoint = mountPoint "fastmail";
          };
        };

        # gdrive = {
        #   config = {
        #     type = "drive";
        #     scope = "drive";
        #     drive_export_formats = [
        #       "docx"
        #       "xlsx"
        #       "pptx"
        #       "svg"
        #     ];
        #     poll_interval = "1m";
        #   };
        #   secrets.token = config.age.secrets.rclone-gdrive-token.path;
        #
        #   mounts = {
        #     "" = {
        #       enable = true;
        #       mountPoint = mountPoint "gdrive";
        #     };
        #     ",shared_with_me" = {
        #       enable = true;
        #       mountPoint = mountPoint "gdrive-shared";
        #     };
        #   };
        # };

        # gphotos = {
        #   config = {
        #     type = "google photos";
        #     include_archived = true;
        #   };
        #   secrets.token = config.age.secrets.rclone-gphotos-token.path;
        #
        #   mounts."" = {
        #     enable = true;
        #     mountPoint = mountPoint "gphotos";
        #   };
        # };

        nextcloud = {
          config = rec {
            type = "webdav";
            vendor = "nextcloud";
            url = "https://nxc.journcy.net/remote.php/dav/files/${user}";
            user = "somasis";
          };
          secrets.pass = config.age.secrets.rclone-nextcloud-pass.path;

          mounts."" = {
            enable = true;
            mountPoint = mountPoint "nextcloud";
          };
        };

        music-cassie-webdav.config = {
          type = "webdav";
          url = "https://esther.7596ff.com/media/music/flac2";
          vendor = "other";
        };

        music-cassie = {
          config = {
            type = "union";
            upstreams = "raid:cassie/media/music/flac2 music-cassie-webdav:";
            action_policy = "epff";
          };

          mounts."" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/audio/library-cassie";
            options = bigCacheOptions;
          };
        };
      };
  };

  age.secrets = {
    rclone-fastmail-pass.file = "${self}/secrets/somasis-rclone-fastmail-pass.age";
    rclone-nextcloud-pass.file = "${self}/secrets/somasis-rclone-nextcloud-pass.age";
  };
}
