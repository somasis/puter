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

  data.directories = [
    (config.lib.somasis.xdgDataDir "PrismLauncher")
  ];

  # TODO use NixMinecraft?
  # programs.minecraft = {
  #   shared = {
  #     username = "somasis";
  #   };
  # };
}
