{
  pkgs,
  lib,
  config,
  osConfig,
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

  xdg.userDirs.music = "${config.home.homeDirectory}/audio/library";

  # Workaround a bug when two users are running beets at once
  home.shellAliases.beet = ''TMPDIR="$XDG_RUNTIME_DIR" beet'';


  # programs.qutebrowser.searchEngines."!beets" = "file:///${beets.doc}/share/doc/beets-${beets.version}/html/search.html?q={}";
}
