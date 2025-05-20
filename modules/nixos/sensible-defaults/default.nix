{ config
, lib
, self
, pkgs
, inputs
, nixpkgs
, ...
}:
{
  imports =
    with self;
    with inputs;
    [
      impermanence.nixosModules.impermanence
      nix-index-database.nixosModules.nix-index

      homeManager.nixosModules.default

      nixosModules.lib
      nixosModules.meta
      nixosModules.impermanence

      ./auditing.nix
      ./debugging.nix
      ./documentation.nix
      ./quirks.nix
      ./security.nix
      ./shared-nixos-config.nix
      ./ssh.nix
      ./users.nix
    ];

  config = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = lib.mapAttrsToList (_: x: x) self.overlays;
    };

    i18n.extraLocales = [
      "de_DE.UTF-8/UTF-8" # German (Germany)
      "es_US.UTF-8/UTF-8" # Spanish (US)
      "tok/UTF-8" # toki pona
      "eo/UTF-8" # esperanto
      "zh_CN.UTF-8/UTF-8" # Chinese (Mainland)
      "ja_JP.UTF-8/UTF-8" # Japanese
      "ga_IE.UTF-8/UTF-8" # Irish
    ];

    # Use a deterministic host ID, generated from the FQDN of the machine.
    networking.hostId = builtins.substring 0 8 (
      builtins.hashString "sha256" config.networking.fqdnOrHostName
    );

    nix.gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "Sun 08:00:00";
      randomizedDelaySec = lib.mkDefault "1h";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    # Only do garbage collection if not on battery,
    # and limit resource usage priorities.
    systemd.services.nix-gc = {
      unitConfig.ConditionACPower = true;
      serviceConfig = {
        Nice = 19;

        CPUWeight = "idle";
        # CPUSchedulingPolicy = "idle";
        # CPUSchedulingPriority = 1;

        IOSchedulingPriority = 7;
        IOSchedulingClass = "idle";
      };
    };

    environment = {
      homeBinInPath = true;
      systemPackages = with pkgs; [
        # Ensure busybox tools are always available
        (busybox.override {
          enableStatic = true;
          enableAppletSymlinks = false;
        })
      ];
    };

    home-manager = {
      backupFileExtension = lib.mkDefault "hm-bak";

      useGlobalPkgs = lib.mkDefault false;
      useUserPackages = true;
      extraSpecialArgs = { inherit self inputs nixpkgs; };

      sharedModules = with self; with inputs; [
        {
          nixpkgs = {
            config.allowUnfree = lib.mkDefault true;
            overlays = lib.mkAfter (lib.mapAttrsToList (_: x: x) self.overlays);
          };
        }

        impermanence.nixosModules.home-manager.impermanence
        nix-index-database.hmModules.nix-index
        homeManagerModules.lib
        homeManagerModules.default
      ];
    };
  };
}
