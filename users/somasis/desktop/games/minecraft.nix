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
    (config.lib.somasis.xdgDataDir "PrismLauncher")
  ];

  # TODO use NixMinecraft?
  # programs.minecraft = {
  #   shared = {
  #     username = "somasis";
  #   };
  # };
}
