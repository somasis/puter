{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.zoom-us
    # (pkgs.wrapCommand {
    #   name = "zoom-us";

    #   package = pkgs.zoom-us;
    #   wrappers = [
    #     {
    #       command = "/bin/zoom";
    #       setEnvironment.XDG_SESSION_TYPE = "X11";
    #     }
    #   ];
    # })
  ];

  data = {
    directories = [ ".zoom" ];
    files = [
      (config.lib.somasis.xdgConfigDir "zoomus.conf")
      (config.lib.somasis.xdgConfigDir "zoom.conf")
    ];
  };
}
