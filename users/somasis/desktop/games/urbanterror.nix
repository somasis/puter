{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.urbanterror
  ];

  sync.directories = [
    {
      directory = config.lib.somasis.xdgConfigDir "urbanterror";
      method = "symlink";
    }
  ];

  home.file.".q3a".source =
    config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/urbanterror";

  # xdg.configFile."urbanterror/q3ut4/download" = {
  #   directory = true;
  #   source = pkgs.buildEnv {
  #     name = "urbanterror-downloads";
  #     paths = [
  #       # <http://www.dswp.de/old/wiki/doku.php/tutorials:urban_terror:all-funstuff-ever>
  #       (pkgs.fetchurl {
  #         url = "http://maps.dswp.de/q3ut4/zzzallfunstuffever.pk3";
  #         hash = "sha256-wdCJ6IHseTB3XvdabiguZ07IRWaAjP2+v86IS3cnIao=";
  #       })
  #       (pkgs.fetchurl {
  #         url = "http://www.mhermann.net/q3ut4/ut4_happyfunstuffroom.pk3";
  #         hash = "sha256-khtHWjqQKLLttajWfYIcfz9Fu5Rx3BjxrS91Ru4B8Lc=";
  #       })
  #     ];
  #   };
  # };
}
