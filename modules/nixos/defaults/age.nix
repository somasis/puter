{
  sources,
  lib,
  pkgs,
  config,
  ...
}:
let
  agePkg = (pkgs.age.withPlugins (p: [ p.age-plugin-tpm ])).overrideAttrs (oldAttrs: {
    meta = (oldAttrs.meta or { }) // {
      mainProgram = "age";
    };
  });
in
{
  imports = [
    "${sources.agenix}/modules/age.nix"
  ];

  options.services.age-keygen.enable = lib.mkOption {
    default = true;
    description = ''
      Whether to enable age-keygen, a service which automatically
      generates age format keys at /etc/age, preferring to create
      TPM2-backed keys (using age-plugin-tpm) if available.
    '';
  };

  config = lib.mkIf config.services.age-keygen.enable {
    age = {
      # <https://github.com/ryantm/agenix/issues/237#issuecomment-2813581111>
      ageBin = lib.getExe agePkg;
      identityPaths = [
        "/etc/age/identity"
      ];
    };

    environment.systemPackages = [
      agePkg
    ];

    systemd.services = {
      age-tpm-keygen = {
        unitConfig = {
          Description = "Automatically generate an age(1) identity for %H, using TPM if available";

          Before = [ "age-keygen.service" ];
          Conflicts = [ "age-keygen.service" ];

          # Only attempt execution if machine has TPM2,
          ConditionSecurity = "tpm2";

          # and if additionally there are no existing keys.
          ConditionPathExists = "!/etc/age/identity";
        };
        wantedBy = [ "default.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = [ "${pkgs.coreutils}/bin/mkdir -p /etc/age" ];
          ExecStart = [
            "${pkgs.age-plugin-tpm}/bin/age-plugin-tpm --generate -o /etc/age/identity"
            "${pkgs.age-plugin-tpm}/bin/age-plugin-tpm -y /etc/age/identity -o /etc/age/recipient"
            "${pkgs.coreutils}/bin/chmod go+r /etc/age/recipient"
          ];
        };
      };

      age-keygen = {
        unitConfig = {
          Description = "Automatically generate an age(1) identity for %H";
          After = [ "age-tpm-keygen.service" ];
          Conflicts = [ "age-tpm-keygen.service" ];
          ConditionPathExistsGlob = "!/etc/age/identity";
        };
        wantedBy = [ "default.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = [ "${pkgs.coreutils}/bin/mkdir -p /etc/age" ];
          ExecStart = [
            "${agePkg}/bin/age-keygen -o /etc/age/identity"
            "${agePkg}/bin/age-keygen -y -o /etc/age/recipient /etc/age/identity"
            "${pkgs.coreutils}/bin/chmod go+r /etc/age/recipient"
          ];
        };
      };
    };

    home-manager.sharedModules = [
      {
        age.package = agePkg;
      }
    ];
  };
}
