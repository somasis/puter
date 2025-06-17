{
  config,
  pkgs,
  ...
}:
{
  programs = {
    gamemode = {
      enable = true;

      settings.general = {
        renice = "19";
        inhibit_screensaver = "0";
      };
    };

    steam.enable = true;
  };

  # RetroArch joysticks and stuff
  services.udev.packages = [ pkgs.game-devices-udev-rules ];
  hardware.uinput.enable = true;
}
