# deadnix: skip
# This file is *not* used by the NixOS configuration,
# it is only used by the `agenix` command line tool.
let
  recipients = {
    ilo = "age1tag1qtfwxktsqmuw363sjalejf80qasph0dzawu38rs8h9ah5fqsc0zek479y76";
    majuna = "age1wzn2fqm39eqgzyspdlvh3knwzfjxnvhqmftz8wmyfm9r0gwwu98qwrjcs8";
    somasis.ilo = "age1tag1qd0gxkaj69v6s44khyfrdkqry4tvs3gm0rjl6m74fmys37q0dfk3se5hqls";
  };

  secrets = with recipients; {
    # Before committing any modifications to the list of recipients for
    # any file listed here, run `agenix -r` in the development environment.
    "rclone-fastmail-pass.age".publicKeys = [ somasis.ilo ];
    "rclone-nextcloud-pass.age".publicKeys = [ somasis.ilo ];
    "rclone-whatbox-http-url.age".publicKeys = [ somasis.ilo ];
    "rclone-whatbox-ilo-pass.age".publicKeys = [ somasis.ilo ];
    "rclone-vault-password.age".publicKeys = [ somasis.ilo ];
    "rclone-vault-password2.age".publicKeys = [ somasis.ilo ];
    "rescrobbled-env.age".publicKeys = [ somasis.ilo ];

    # Used by host, not by a specific user on the host.
    "ntfy-token-ilo.somas.is.age".publicKeys = [
      ilo
      somasis.ilo
    ];
    "ntfy-token-majuna.age".publicKeys = [
      majuna
      somasis.ilo
    ];
    "restic-ilo.somas.is.age".publicKeys = [
      ilo
      somasis.ilo
    ];
    "restic-rclone-whatbox.age".publicKeys = [
      ilo
      somasis.ilo
    ];
  };
in
builtins.listToAttrs (
  builtins.attrValues (
    builtins.mapAttrs (name: value: {
      name = "secrets/${name}";
      value = value // {
        armor = true;
      };
    }) secrets
  )
)
