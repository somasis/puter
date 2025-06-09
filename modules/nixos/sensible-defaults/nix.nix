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
    shellAliases.nixos = ''nixos-rebuild --use-remote-sudo --flake "$FLAKE"'';
  };

  # System should automatically upgrade according to the canonical version
  # of the flake repository.
  system.autoUpgrade = {
    enable = config.system.autoUpgrade.flake != null;

    # Allow automatic reboots only if it is not a user-interfacing machine,
    # and it is between 2am and 6am.
    dates = "Sat 02:00"; # a time which no sane person would be awake
    allowReboot = !config.meta.desktop;
    rebootWindow = {
      lower = "02:00";
      upper = "06:00";
    };

    flags =
      lib.concatMap
        (x: [
          "--update-input"
          x
        ])
        [
          "nixpkgs"
          "nixpkgsStable"
          "nixpkgsUnstable"
          "homeManager"
          "homeManagerStable"
          "homeManagerUnstable"
        ]
      ++ [ "--commit-lock-file" ];
  };

  nix = {
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

      substituters = lib.mkMerge [
        # Add each build machine as a substituter
        (map (m: "${m.protocol}://${m.sshUser}@${m.hostName}") config.nix.buildMachines)

        [
          # Use binary cache for nonfree packages
          "https://nixpkgs-unfree.cachix.org"
          "https://nix-community.cachix.org"
          "https://numtide.cachix.org"
          "https://lanzaboote.cachix.org"
        ]
      ];

      trusted-public-keys = lib.mkAfter [
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
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

        # Test out content-addressed derivations, since they are built and seem
        # to have few bugs by this point, but still are not default. The feature
        # is worth testing out since it could improve disk space usage.
        "ca-derivations"
      ];

      trusted-users = [ "@wheel" ];
    };

    # NOTE(somasis) Minimize resource usage as much as possible.
    # "idle" means that the kernel will always let other processes
    # have priority over `nix` builds, when allocating resources.
    daemonCPUSchedPolicy = lib.mkIf config.meta.desktop "idle";
    daemonIOSchedClass = lib.mkIf config.meta.desktop "idle";

    # NOTE(somasis) Serve the store over ssh so it can be a substituter
    #               and remote builder for remote machines.
    sshServe = {
      enable = true;
      write = true;

      # Filter out all users that are not in the "nixos" group
      # and that are allowed to use nix-daemon. Then, get all
      # their lists of authorized ssh keys, and flatten the
      # combined list, so that they can access the nix store
      # with any of their authorized ssh keys.
      keys = config.lib.somasis.sshKeysForGroups [
        "wheel"
        "nixos"
      ];
    };
  };
}
