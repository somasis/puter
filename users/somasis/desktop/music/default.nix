{
  config,
  ...
}:
{
  imports = [
    ./manage
    ./player.nix
    ./production.nix
  ];

  persist.directories = [
    {
      method = "symlink";
      directory = "audio";
    }
  ];
  xdg.userDirs.music = "${config.home.homeDirectory}/audio/library";
}
