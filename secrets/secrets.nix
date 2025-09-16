# deadnix: skip
# This file is *not* used by the NixOS configuration,
# it is only used by the `agenix` command line tool.
let
  flake = import ../default.nix;
in
with flake.inputs;
with flake.inputs.nixpkgs;
let
  recipients = {
    ilo = "age1tpm1qtfwxktsqmuw363sjalejf80qasph0dzawu38rs8h9ah5fqsc0zekwu5ev8";
    somasis.ilo = "age1tpm1qd0gxkaj69v6s44khyfrdkqry4tvs3gm0rjl6m74fmys37q0dfk3szkxadd";
  };
in
with recipients;
builtins.mapAttrs (n: v: v // { armor = true; }) {
  # Before committing any modifications to the list of recipients for
  # any file listed here, run `agenix -r` in the development environment.
  "rclone-fastmail-pass.age".publicKeys = [ somasis.ilo ];
  "rclone-nextcloud-pass.age".publicKeys = [ somasis.ilo ];
  "rclone-whatbox-http-url.age".publicKeys = [ somasis.ilo ];
  "rclone-whatbox-pass.age".publicKeys = [ somasis.ilo ];
  "rclone-vault-password.age".publicKeys = [ somasis.ilo ];
  "rclone-vault-password2.age".publicKeys = [ somasis.ilo ];

  # Used by host, not by a specific user on the host.
  "ntfy-token-ilo.somas.is.age".publicKeys = [
    ilo
    somasis.ilo
  ];
  "restic-ilo.age".publicKeys = [
    ilo
    somasis.ilo
  ];
  "restic-rclone-whatbox.age".publicKeys = [
    ilo
    somasis.ilo
  ];
}
