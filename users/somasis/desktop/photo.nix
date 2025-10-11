{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config.lib.somasis)
    xdgCacheDir
    xdgConfigDir
    xdgDataDir
    ;
in
{
  home.packages =
    with pkgs;
    with libsForQt5;
    with kdePackages;
    [
      optimize

      (gimp-with-plugins.override {
        plugins = with gimpPlugins; [
          gmic
        ];
      })

      koko

      krita

      darktable
      inkscape
    ];

  sync = {
    directories = [
      (xdgConfigDir "GIMP")

      # NOTE G'MIC seems to recreate the directory if it is a symlink?
      {
        method = "bindfs";
        directory = xdgConfigDir "gmic";
      }

      (xdgConfigDir "darktable")
      (xdgConfigDir "inkscape")

      (xdgDataDir "krita")
    ];

    files = [
      (xdgConfigDir "kritarc")
      (xdgConfigDir "kritadisplayrc")
      (xdgConfigDir "kritashortcutsrc")
    ];
  };

  persist.directories = [
    (xdgDataDir "koko")
  ];

  cache = {
    directories = [
      (xdgCacheDir "gimp")
      (xdgCacheDir "gmic")

      (xdgCacheDir "darktable")
      (xdgCacheDir "gallery-dl")
      (xdgCacheDir "koko")
    ];
    files = [
      (xdgDataDir "krita.log")
      (xdgDataDir "krita-sysinfo.log")
    ];
  };

  xdg.mimeApps = {
    defaultApplications = {
      "image/x-dcraw" = "darktable.desktop";
      "image/tiff" = "darktable.desktop";
    };

    associations.added = lib.genAttrs [ "inkscape.desktop" "gimp.desktop" ] (_: "image/svg+xml");
    associations.removed = lib.genAttrs [ "image/jpeg" "image/png" "image/tiff" ] (
      _: "darktable.desktop"
    );
  };

  programs.gallery-dl = {
    enable = true;

    settings = {
      extractor = {
        base-directory = ".";

        filename =
          (lib.concatStringsSep "-" [
            "{date|created_at!T}"
            "{category}"
            "{author[name]|user[name]|uploader}"
            "{tweet_id|id}"
            "{filename}"
          ])
          + ".{extension}";

        # Use cookies from qutebrowser if available
        cookies = lib.mkIf config.programs.qutebrowser.enable [
          "chromium"
          "${config.xdg.dataHome}/qutebrowser/webengine"
        ];

        postprocessors = [
          {
            name = "exec";
            command = "${lib.getExe pkgs.optimize} -q {}";
            async = true;
          }
        ];

        ytdl = lib.mkIf config.programs.yt-dlp.enable {
          enabled = true;
          module = "yt_dlp";
        };
      };

      downloader = {
        # Don't set mtime on downloaded files (we store it in the name).
        mtime = false;

        # ytdl = lib.mkIf config.programs.yt-dlp.enable {
        #   # config-file = "${config.xdg.configHome}/yt-dlp/config";
        #   forward-cookies = true;
        # };
      };
    };
  };

  programs.qutebrowser =
    let
      gallery-dl = pkgs.writeShellScript "gallery-dl" ''
        exec ${lib.getExe config.programs.gallery-dl.package} -o output.log='{"level": "warning"}' "$@"
      '';
    in
    {
      aliases.gallery-dl = "spawn -m ${gallery-dl}";
      keyBindings.normal = {
        dgd = "gallery-dl -D ${config.xdg.userDirs.download} {url}";
        dgn = "gallery-dl -D ${config.xdg.userDirs.pictures}/nsfw {url}";
        dgw = "gallery-dl -D ${config.xdg.userDirs.pictures}/wallpapers {url}";
      };
    };
}
