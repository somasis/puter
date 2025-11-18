{ config, lib, ... }:
{
  services.self-deploy = {
    enable = lib.mkDefault true;
    startAt = lib.mkDefault "weekly";
    repository = lib.mkDefault "https://github.com/somasis/puter.git";
    branch = lib.mkDefault "main";
    nixAttribute = lib.mkDefault "nixosConfigurations.${config.networking.hostName}";
  };
}
