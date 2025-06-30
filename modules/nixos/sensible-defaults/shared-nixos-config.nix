{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
{
  imports = with inputs; [
    agenix.nixosModules.default
    nixos-cli.nixosModules.nixos-cli
  ];

  system.nixos.tags = [ "puter" ];

  # Set the automatic upgrade timer to use this flake's canonical location.
  system.autoUpgrade.flake = lib.mkDefault "github:somasis/puter";

  environment = {
    # Link the complete flake into /etc/nixos.
    # TODO Is there some better way to do this while also including the
    # complete Git repository used?
    etc."nixos".source = self.outPath;

    sessionVariables.NIXOS_CONFIG = config.system.autoUpgrade.flake;
    systemPackages = with pkgs; [
      nix-output-monitor
      nvd
    ];
  };

  services.nixos-cli = {
    enable = true;
    prebuildOptionCache = false;
    config = {
      use_nvd = true;
      apply = {
        imply_impure_with_tag = true;
        use_git_commit_msg = true;
        use_nom = true;
      };
    };
  };

  nix.settings = {
    extra-substituters = [ "https://watersucks.cachix.org" ];
    extra-trusted-public-keys = [
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
    ];
  };
}
