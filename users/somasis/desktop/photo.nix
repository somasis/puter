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

  data = {
    directories = [
      (xdgConfigDir "GIMP")

      # NOTE G'MIC seems to recreate the directory if it is a symlink?
      (xdgConfigDir "gmic")

      (xdgConfigDir "darktable")
      (xdgConfigDir "inkscape")

      (xdgDataDir "krita")

      (xdgDataDir "koko")
      (xdgConfigDir "GREYC") # Used by gmic.
      (xdgCacheDir "optimize")

      (xdgCacheDir "gimp")
      (xdgCacheDir "gmic")

      (xdgCacheDir "darktable")
      (xdgCacheDir "koko")
    ];

    files = [
      (xdgConfigDir "kritarc")
      (xdgConfigDir "kritadisplayrc")
      (xdgConfigDir "kritashortcutsrc")
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
}
