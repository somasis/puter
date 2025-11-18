{
  self,
  sources,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = with sources; [
    "${home-manager}/nixos"

    self.nixosModules.lib
    self.nixosModules.meta

    ./age.nix
    ./boot.nix
    ./debugging.nix
    ./nix.nix
    ./notifications.nix
    ./quirks.nix
    ./security.nix
    ./self-update.nix
    ./ssh.nix
  ];

  nixpkgs.overlays = [
    self.overlays.default
    self.overlays.nixpkgsVersions
  ];

  console.earlySetup = true;

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
    settings.Manager.RebootWatchdogSec = "0";

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
    # Link the complete repository into /etc/nixos.
    # TODO Is there some better way to do this while also including the
    # complete Git repository used?
    etc.nixos.source = self.outPath;

    homeBinInPath = true;
    systemPackages = with pkgs; [
      # Ensure busybox tools are always available
      (busybox.override {
        enableStatic = true;
        enableAppletSymlinks = false;
      })

      dix
      lix-diff
      nix-output-monitor
      nvd
    ];
  };

  users.users.root = {
    home = "/root";
    createHome = true;
  };

  home-manager = {
    backupFileExtension = lib.mkDefault "hm-bak";

    useGlobalPkgs = lib.mkDefault false;
    useUserPackages = true;
    extraSpecialArgs = { inherit self sources; };

    sharedModules = with sources; [
      "${impermanence}/home-manager.nix"
      self.homeManagerModules.lib
      self.homeManagerModules.default
    ];
  };
}
