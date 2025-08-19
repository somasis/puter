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
    somasis = {
      ilo = "age1tpm1qtfwxktsqmuw363sjalejf80qasph0dzawu38rs8h9ah5fqsc0zekwu5ev8";
    };
  };
in
with recipients;
{
  # Before committing any modifications to the list of recipients for
  # any file listed here, run `agenix -r` in the development environment.
  "somasis-rclone-fastmail-pass.age".publicKeys = [ somasis.ilo ];
  "somasis-rclone-nextcloud-pass.age".publicKeys = [ somasis.ilo ];
  "somasis-rclone-whatbox-http-url.age".publicKeys = [ somasis.ilo ];
  "somasis-rclone-whatbox-pass.age".publicKeys = [ somasis.ilo ];
  "somasis-restic-ilo.age".publicKeys = [ somasis.ilo ];
  "somasis-restic-rclone-whatbox.age".publicKeys = [ somasis.ilo ];
}
