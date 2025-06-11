{
  config,
  lib,
  ...
}:
{
  console.colors =
    with config.home-manager.users.somasis.theme.colors;
    map (lib.removePrefix "#") [
      color0
      color1
      color2
      color3
      color4
      color5
      color6
      color7
      color8
      color9
      color10
      color11
      color12
      color13
      color14
      color15
    ];

  # Only create two virtual terminals, one for Xorg and one for getty.
  services.logind.extraConfig = lib.generators.toKeyValue { } {
    NAutoVTs = 2;
  };

  # Show the system journal on tty12.
  services.journald.console = "/dev/tty12";
}
