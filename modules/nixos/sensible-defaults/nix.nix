{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    # Install git by default to ease development from a clean system.
    git.enable = true;

    # direnv is used for the flake's development environment;
    # this ensures that it is activated by the shell automatically.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  environment = {
    systemPackages = lib.optional config.programs.bash.completion.enable pkgs.nix-bash-completions;

    sessionVariables.FLAKE = config.system.autoUpgrade.flake;
  };

  # System should automatically upgrade according to the canonical version
  # of the flake repository.
  system.autoUpgrade = {
    enable = lib.mkDefault (config.system.autoUpgrade.flake != null);

    # Allow automatic reboots only if it is not a user-interfacing
    # machine, and it is between 2am and 5:30am. Check for updates
    # every day at 5pm.
    dates = "17:00";
    allowReboot = !config.meta.desktop;
    rebootWindow = {
      lower = "02:00";
      upper = "05:30";
    };
  };

  # Use Lix <https://lix.systems/add-to-config/>.
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-update
        ;
    })
  ];

  nix = {
    package = pkgs.lixPackageSets.stable.lix;

    registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;

    # NOTE(somasis) Garbage collect the store every week
    #               (remove derivations that are no longer used
    #               by any other derivations)
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 28d";
    };

    settings = {
      use-xdg-base-directories = true;

      # NOTE(somasis) More log by default makes it easier to for debug build errors.
      log-lines = 1000;

      # Automatically optimize the Nix store as possible, equivalent to
      # `nix-store --optimize` but does it automatically with little performance impact.
      auto-optimise-store = true;

      # Perform automatic garbage collection when free space drops below 512 MB,
      # attempting to collect garbage until there is 1 GB free.
      min-free = 1024000000; # 512 MB
      max-free = 1024000000; # 1 GB

      extra-substituters = [
        # Use binary cache for nonfree packages
        "https://nixpkgs-unfree.cachix.org"

        # Used by various nix-community projects, which are referenced in flake.nix.
        "https://nix-community.cachix.org"

        # treefmt-nix
        "https://numtide.cachix.org"

        # lanzaboote
        "https://lanzaboote.cachix.org"
      ];

      trusted-public-keys = [
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      ];

      # Potentially reduce build times being constrained by internet speed
      # by having remote builders get dependencies themselves where possible.
      builders-use-substitutes = true;

      # Allow building from source if binary substitution fails
      fallback = true;

      # Shorten the download timeout to 15 seconds, as it defaults to 300 seconds.
      stalled-download-timeout = 15;

      # NOTE(somasis) Flakes are used as they are more in line with
      #               Nix's declarative philosophy than channels.
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [ "@wheel" ];
    };

    # NOTE(somasis) Minimize resource usage as much as possible.
    # "idle" means that the kernel will always let other processes
    # have priority over `nix` builds, when allocating resources.
    daemonCPUSchedPolicy = lib.mkIf config.meta.desktop "idle";
    daemonIOSchedClass = lib.mkIf config.meta.desktop "idle";
  };
}
