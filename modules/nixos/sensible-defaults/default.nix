{
  config,
  lib,
  self,
  pkgs,
  inputs,
  nixpkgs,
  ...
}:
{
  imports =
    with self;
    with inputs;
    [
      impermanence.nixosModules.impermanence
      nix-index-database.nixosModules.nix-index

      home-manager.nixosModules.default

      nixosModules.lib
      nixosModules.meta
      nixosModules.impermanence

      ./auditing.nix
      ./boot.nix
      ./debugging.nix
      ./documentation.nix
      ./nix.nix
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
      "tok/UTF-8" # toki pona
    ];
    console.earlySetup = true;

    # Keep system firmware up to date.
    # TODO: Framework still doesn't have their updates in LVFS properly,
    #       <https://knowledgebase.frame.work/en_us/framework-laptop-bios-releases-S1dMQt6F#:~:text=Updating%20via%20LVFS%20is%20available%20in%20the%20testing%20channel>
    services.fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];
      uefiCapsuleSettings.DisableCapsuleUpdateOnDisk = true;
    };

    persist.directories = [ "/var/lib/fwupd" ];
    cache.directories = [ "/var/cache/fwupd" ];

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

    systemd = {
      # Fix watchdog delaying reboot
      # https://wiki.archlinux.org/title/Framework_Laptop#ACPI
      watchdog.rebootTime = "0";

      # Only do garbage collection if not on battery,
      # and limit resource usage priorities.
      services.nix-gc = {
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

      sharedModules =
        with self;
        with inputs;
        [
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
