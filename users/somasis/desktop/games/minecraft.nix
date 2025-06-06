{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.prismlauncher
    (config.osConfig.programs.java.package or pkgs.jre)
  ];

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "PrismLauncher";
    }
  ];

  # TODO use NixMinecraft?
  # programs.minecraft = {
  #   shared = {
  #     username = "somasis";
  #   };
  # };
}
