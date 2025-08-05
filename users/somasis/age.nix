{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.age
    pkgs.age-plugin-tpm
  ];

  age.identityPaths = [
    "${config.xdg.configHome}/age/identity.tpm"
  ];

  systemd.user.services = {
    age-tpm-keygen = {
      Unit = {
        Description = "Automatically generate an age(1) identity for $USER, using TPM if available";

        Before = [ "age-keygen.service" ];
        Conflicts = [ "age-keygen.service" ];

        # Only attempt execution if machine has TPM2,
        ConditionSecurity = "tpm2";

        # and if additionally there are no existing TPM-generated keys.
        ConditionPathExists = "!%E/age/identity.tpm";
      };
      Install.WantedBy = [ "default.target" ];

      Service = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.age-plugin-tpm}/bin/age-plugin-tpm --generate -o %E/age/identity.tpm"
          "${pkgs.age-plugin-tpm}/bin/age-plugin-tpm -y %E/age/identity.tpm -o %E/age/recipient"
        ];
      };
    };

    age-keygen = {
      Unit = {
        Description = "Automatically generate an age(1) identity for $USER";
        Conflicts = [ "age-tpm-keygen.service" ];
        ConditionSecurity = "!tpm2";
        ConditionPathExistsGlob = "!%E/age/identity.tpm";
      };
      Install.WantedBy = [ "default.target" ];

      Service = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.age}/bin/age-keygen -o %C/age/identity"
          "${pkgs.age}/bin/age-keygen -y -o %C/age/recipient %C/age/identity"
        ];
      };
    };
  };
}
