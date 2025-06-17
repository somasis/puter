{
  config,
  pkgs,
  ...
}:
{
  programs.gamemode = {
    enable = true;

    settings = {
      general = {
        renice = "19";
        inhibit_screensaver = "0";
      };

      custom = {
        start = "${pkgs.systemd}/bin/systemctl --user start game.target";
        stop = "${pkgs.systemd}/bin/systemctl --user stop game.target";
      };
    };
  };

  programs.steam.enable = true;

  systemd.user.targets.game = {
    description = "Gaming mode (ensure system utilizes lower resources than normal)";

    after = [ "gamemoded.service" ];
    wants = [ "gamemoded.service" ];
  };

  # RetroArch joysticks and stuff
  services.udev.packages = [ pkgs.game-devices-udev-rules ];
  hardware.uinput.enable = true;
}
