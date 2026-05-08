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
    ./radio.nix
  ];

  data = {
    directories = [
      "audio"

      (xdgConfigDir "audacity")
      (xdgCacheDir "audacity")
      (xdgDataDir "audacity")
    ];

    files = [
      (xdgConfigDir "tageditor.ini")
    ];
  };

  xdg.userDirs.music = "${config.home.homeDirectory}/audio/library";

  home.packages = with pkgs; [
    audacity
    ffmpeg-full
    flac
    opus-tools
  ];
}
