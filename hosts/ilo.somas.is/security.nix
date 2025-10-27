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
    "/etc/age"
    "/var/lib/sbctl"
  ];

  systemd.services = {
    age-tpm-keygen = {
      unitConfig = {
        Description = "Automatically generate an age(1) identity for %H, using TPM if available";

        Before = [ "age-keygen.service" ];
        Conflicts = [ "age-keygen.service" ];

        # Only attempt execution if machine has TPM2,
        ConditionSecurity = "tpm2";

        # and if additionally there are no existing TPM-generated keys.
        ConditionPathExists = "!%E/age/identity";
      };
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.age-plugin-tpm}/bin/age-plugin-tpm --generate -o %E/age/identity"
          "${pkgs.age-plugin-tpm}/bin/age-plugin-tpm -y %E/age/identity -o %E/age/recipient"
        ];
      };
    };

    age-keygen = {
      unitConfig = {
        Description = "Automatically generate an age(1) identity for %H";
        After = [ "age-tpm-keygen.service" ];
        Conflicts = [ "age-tpm-keygen.service" ];
        ConditionPathExistsGlob = "!%E/age/identity*";
      };
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.age}/bin/age-keygen -o %C/age/identity"
          "${pkgs.age}/bin/age-keygen -y -o %C/age/recipient %C/age/identity"
        ];
      };
    };
  };

  age = {
    # ugly workaround FIXME
    # <https://github.com/ryantm/agenix/issues/237#issuecomment-2813581111>
    ageBin = "PATH=${pkgs.age-plugin-tpm}/bin:$PATH ${pkgs.age}/bin/age";

    identityPaths = [
      "/etc/age/identity"
    ];
  };

  environment.systemPackages = with pkgs; [
    sbctl

    age
    age-plugin-tpm
  ];

  boot = {
    # Always automatically recover from kernel panics by rebooting in 60 seconds
    kernelParams = [ "panic=60" ];

    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
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
