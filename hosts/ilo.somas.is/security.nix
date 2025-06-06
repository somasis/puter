{
  config,
  pkgs,
  modulesPath,
  lib,
  nixpkgs,
  inputs,
  ...
}:
{
  imports = with inputs; [
    "${modulesPath}/profiles/hardened.nix"
    lanzaboote.nixosModules.lanzaboote
  ];
  persist.directories = [ "/var/lib/sbctl" ];

  environment.systemPackages = [ pkgs.sbctl ];
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Runs into an error due to hardened profile?
  services.ananicy.enable = lib.mkForce false;

  security = {
    # Previously disabled by hardened profile:
    # Needed to fix builds, allegedly?
    # <https://nixos.org/manual/nixos/unstable/#sec-profile-hardened>
    allowUserNamespaces = true;
    unprivilegedUsernsClone = true;

    # Needed because the hardened profile affects it.
    chromiumSuidSandbox.enable = true;

    # Needed for bluetooth and wifi connectivity.
    lockKernelModules = false;
  };

  # Always automatically recover from kernel panics by rebooting in 60 seconds
  boot.kernelParams = [ "panic=60" ];

  # Remove when Chrome stops crashing
  environment.memoryAllocator.provider = "libc";
}
