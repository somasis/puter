{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.age
    pkgs.age-plugin-tpm
  ];

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "age";
    }
  ];

  age = {
    identityPaths = [ "${config.xdg.configHome}/age/identity" ];

    # Workaround use of "${XDG_RUNTIME_DIR}" in the secrets path.
    # <https://github.com/ryantm/agenix/issues/300>
    # I first ran into this problem with mounts managed by `programs.rclone` failing
    # since the secret file they'd be receiving the path of would be...
    # "${XDG_RUNTIME_DIR}/agenix/file". Which would usually be fine, but it isn't
    # during activation for the home-manager module, because $XDG_RUNTIME_DIR isn't set
    # at the time of use, and in fact it's only ever set explicitly in the activation script...
    secretsDir = "/run/user/${toString osConfig.users.users.${config.home.username}.uid}/agenix";
    secretsMountPoint = "/run/user/${
      toString osConfig.users.users.${config.home.username}.uid
    }/agenix.d";
  };

  systemd.user.services = {
    age-tpm-keygen = {
      Unit = {
        Description = "Automatically generate an age(1) identity for $USER, using TPM if available";

        Before = [ "age-keygen.service" ];
        Conflicts = [ "age-keygen.service" ];

        # Only attempt execution if machine has TPM2,
        ConditionSecurity = "tpm2";

        # and if additionally there are no existing TPM-generated keys.
        ConditionPathExists = "!%E/age/identity";
      };
      Install.WantedBy = [ "default.target" ];

      Service = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.age-plugin-tpm}/bin/age-plugin-tpm --generate -o %E/age/identity"
          "${pkgs.age-plugin-tpm}/bin/age-plugin-tpm -y %E/age/identity -o %E/age/recipient"
        ];
      };
    };

    age-keygen = {
      Unit = {
        Description = "Automatically generate an age(1) identity for $USER";
        After = [ "age-tpm-keygen.service" ];
        Conflicts = [ "age-tpm-keygen.service" ];
        ConditionPathExistsGlob = "!%E/age/identity";
      };
      Install.WantedBy = [ "default.target" ];

      Service = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.age}/bin/age-keygen -o %E/age/identity"
          "${pkgs.age}/bin/age-keygen -y -o %E/age/recipient %E/age/identity"
        ];
      };
    };
  };
}
