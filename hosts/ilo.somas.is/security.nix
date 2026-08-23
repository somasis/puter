{
  sources,
  modulesPath,
  pkgs,
  lib,
  ...
}:
let
  lanzaboote = import sources.lanzaboote {
    inherit pkgs;
    inherit (pkgs) system;
  };
in
{
  imports = [
    lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = with pkgs; [
    sbctl
    tpm2-tss
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

    # $ mkpasswd -m sha-512 -s
    initrd.systemd.emergencyAccess = "$6$wdbNitvg5GyxAnQQ$bjXTIGMdmPIE0MciSAzQcLZfX0nhH72Q5PkPabB74eJkMM6mzJsR1eiG2kXjKx38dSh2swkIyeQyGdXFhqrHZ1";
  };

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  programs.yubikey-manager.enable = true;
  services.pcscd.enable = true;
}
