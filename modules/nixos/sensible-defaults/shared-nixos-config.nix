{ config
, lib
, pkgs
, inputs
, self
, ...
}:
{
  imports = with inputs; [
    agenix.nixosModules.default
  ];

  environment.systemPackages = [
    pkgs.flakePackages.agenix.default
  ];

  programs.git.enable = true;

  # Link the complete flake into /etc/nixos.
  # TODO Is there some better way to do this while also including the
  # complete Git repository used?
  environment.etc."nixos".source = self.outPath;

  system.nixos.tags = [ "puter" ];

  # direnv is used for the flake's development environment;
  # this ensures that it is activated by the shell automatically.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # `nh` is the preferred way to update the system.
  programs.nh.enable = true;
  # FLAKE is used instead of programs.nh.flake because the NixOS module for it
  # seems to force you to make it a path, instead of a string (which a valid
  # flake reference can be...)
  environment.sessionVariables.FLAKE = config.system.autoUpgrade.flake;

  environment.shellAliases.nixos = ''nixos-rebuild --use-remote-sudo --flake "$FLAKE"'';

  # System should automatically upgrade according to the canonical version
  # of the flake repository.
  system.autoUpgrade = {
    enable = true;
    flake = lib.mkDefault "git+ssh://esther.7596ff.com/~git/nixos.git";
    dates = "07:00";
  };

  nix = rec {
    daemonCPUSchedPolicy = lib.mkIf config.meta.desktop "idle";
    daemonIOSchedClass = lib.mkIf config.meta.desktop "idle";

    registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;

    settings = {
      use-xdg-base-directories = true;

      trusted-users = [ "@wheel" ];

      # Enable flakes by default.
      extra-experimental-features = [
        "flakes"
        "nix-command"
      ];

      extra-substituters =
        # Add each build machine as a substituter
        map (m: "${m.protocol}://${m.sshUser}@${m.hostName}") config.nix.buildMachines ++ [
          # Use binary cache for nonfree packages
          "https://nixpkgs-unfree.cachix.org"
          "https://numtide.cachix.org"
          "https://nix-community.cachix.org"
        ];

      extra-trusted-public-keys = [
        "esther.7596ff.com-2024-07-06:o2RYdGw81MDdCKd21cgW2mA7sE2o8YaYvVwMHISRFnw="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Potentially reduce build times being constrained by internet speed
      # by having remote builders get dependencies themselves where possible.
      builders-use-substitutes = true;
    };
  };
}
