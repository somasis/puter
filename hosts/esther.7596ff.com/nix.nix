{ config
, self
, ...
}:
{
  age.secrets.esther-nix-serve-key = {
    file = "${self}/secrets/nix-serve-esther.7596ff.com-2024-07-06.key.age";
    owner = "root";
    mode = "400";
  };

  services.nix-serve = {
    enable = true;
    openFirewall = true;
    secretKeyFile = config.age.secrets.esther-nix-serve-key.path;
  };

  nix = {
    # NOTE(somasis) Helpful for debugging build errors
    settings.log-lines = 1000;

    # NOTE(somasis) Garbage collect the store every week
    #               (remove derivations that are no longer used
    #               by any other derivations)
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 28d";
    };

    # NOTE(somasis) Flakes are used as they are more in line with
    #               Nix's declarative philosophy than channels.
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # NOTE(somasis) Minimize resource usage as much as possible
    # "idle" means that the kernel will always let other processes
    # have priority over `nix` builds, when allocating resources.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

    settings.max-jobs = 24; # how many different builds should be allowed to run at once
    settings.cores = 8; # number of concurrent tasks should be ran during one build (these so misnamed!)

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

    # Allow for building over ssh.
    settings.trusted-users = [ "nix-ssh" ];

    # Sign built packages with a key;
    # corresponds to the "esther.7596ff.com:EBIlWcAE7fxSHKVsXig9eu6BfrLtDZI6ekLH9hlLANA="
    settings.secret-key-files = [ config.services.nix-serve.secretKeyFile ];

    # What using this looks like on other machines:
    # {
    #   nix = {
    #     # This allows for using it as a substituter (as in, you can use it
    #     # for downloading packages from, rather than cache.nixos.org, or
    #     # having to build them locally if they exist on another Nix store).
    #     settings.extra-substituters = [ "ssh://nix-ssh@esther.7596ff.com" ];
    #     settings.extra-trusted-public-keys = [ "esther.7596ff.com-2024-07-06:o2RYdGw81MDdCKd21cgW2mA7sE2o8YaYvVwMHISRFnw=" ];
    #
    #     distributedBuilds = true;
    #     buildMachines = [{
    #       hostName = "esther.7596ff.com";
    #
    #       system = "x86_64-linux";
    #       maxJobs = 4;
    #
    #       protocol = "ssh";
    #       sshUser = "nix-ssh";
    #       sshKey = "${config.users.users.root.home}/.ssh/id_ed25519";
    #
    #       # This is a base64 encoded ssh public key:
    #       # $ ssh-keyscan -q esther.7596ff.com | cut -d' ' -f2- | head -n1 | base64 -w0
    #       publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1Ydk9HdkRKb1NYa0wwbDV4dWVlSG1ZbzFGalVkUzFUaTc3ZDRLdGVTeUUK";
    #
    #       # This list is from running:
    #       # $ nix eval /etc/nixos#nixosConfigurations.esther.config.nix.settings.system-features
    #       supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    #     }];
    #   };
    # }
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    # Use `nix-index` for finding unknown commands. It's faster and it supports
    # flakes. Additionally, we use the `nix-index-database` which provides an
    # up-to-date database of the contents of nixpkgs' packages.
    command-not-found.enable = false;
    nix-index.enable = true;

    # See <https://github.com/nix-community/comma>
    nix-index-database.comma.enable = true;
  };
}
