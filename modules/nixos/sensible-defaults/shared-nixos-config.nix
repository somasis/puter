{
  lib,
  inputs,
  self,
  ...
}:
{
  imports = with inputs; [ agenix.nixosModules.default ];

  system.nixos.tags = [ "puter" ];

  # Set the automatic upgrade timer to use this flake's canonical location.
  system.autoUpgrade.flake = lib.mkDefault "github:somasis/puter";

  # Link the complete flake into /etc/nixos.
  # TODO Is there some better way to do this while also including the
  # complete Git repository used?
  environment.etc."nixos".source = self.outPath;
}
