{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.prismlauncher
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
