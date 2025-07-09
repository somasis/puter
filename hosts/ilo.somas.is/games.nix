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

  nixpkgs.allowUnfreePackages = [
    "steam"
  ];

  # RetroArch joysticks and stuff
  services = {
    joycond.enable = true;
    udev.packages = [ pkgs.game-devices-udev-rules ];
  };

  hardware.uinput.enable = true;
}
