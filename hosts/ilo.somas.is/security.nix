{
  sources,
  modulesPath,
  pkgs,
  lib,
  ...
}:
let
  importFlake = src: (import sources.flake-compat { inherit src; }).defaultNix;
in
{
  imports = [
    "${modulesPath}/profiles/hardened.nix"
    (importFlake sources.lanzaboote).nixosModules.lanzaboote
  ];

  persist.directories = [
    "/var/lib/sbctl"
  ];

  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot = {
    # Always automatically recover from kernel panics by rebooting in 60 seconds
    kernelParams = [ "panic=60" ];

    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        autoReboot = true;
      };
    };
  };

  security = {
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

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

  # Remove when Chrome stops crashing
  environment.memoryAllocator.provider = "libc";
}
