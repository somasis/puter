{
  config,
  pkgs,
  ...
}:
let
  inherit (config.lib.somasis) xdgConfigDir xdgCacheDir xdgDataDir;
in
{
  imports = [
    ./manage.nix
    ./player.nix
  ];

  persist = {
    directories = [
      {
        method = "symlink";
        directory = "audio";
      }

      {
        method = "symlink";
        directory = xdgConfigDir "audacity";
      }
    ];

    files = [
      (xdgConfigDir "tageditor.ini")
    ];
  };

  cache.directories = [
    {
      method = "symlink";
      directory = xdgCacheDir "audacity";
    }
    {
      method = "symlink";
      directory = xdgDataDir "audacity";
    }
  ];

  xdg.userDirs.music = "${config.home.homeDirectory}/audio/library";

  home.packages = [
    pkgs.ffmpeg-full
    pkgs.opusTools
    pkgs.flac
    pkgs.audacity
  ];
}
