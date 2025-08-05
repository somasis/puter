{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./convert.nix
    ./ripping.nix
    ./tagging.nix
  ];

  home.packages = with pkgs; [
    (beets-unstable.override {
      pluginOverrides.alias = {
        enable = true;
        propagatedBuildInputs = [ beets-alias ];
      };
    })
    rsgain
    unflac
  ];

  sync.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "beets";
    }
  ];

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "beets";
    }
  ];

  xdg.userDirs.music = "${config.home.homeDirectory}/audio/library";

  home = {
    # Workaround a bug when two users are running beets at once
    shellAliases.beet = ''TMPDIR="$XDG_RUNTIME_DIR" beet'';

    # Used by `bin/beet-import-phish`.
    sessionVariables.BEET_IMPORT_PHISH_DOWNLOAD_DIR = "${config.home.homeDirectory}/audio/source/bootleg-phishin";
  };

  xdg.autostart.entries =
    let
      desktopItem = pkgs.makeDesktopItem;
      autostart = "${desktopItem}/share/applications/${desktopItem.desktopName}.desktop";
    in
    [
      (autostart {
        desktopName = "beets-import-to-library-from-slskd-ntfy";
        name = "beets-import-to-library-from-slskd-ntfy";
        exec = "beets-import-to-library-from-slskd-ntfy";
        icon = "media-import-audio-cd";
        comment = "Import new directories via slskd events propagated by slskd-ntfy";
        genericName = "beets-import-to-library slskd helper";
      })
    ];

  # programs.qutebrowser.searchEngines."!beets" = "file:///${beets.doc}/share/doc/beets-${beets.version}/html/search.html?q={}";
}
