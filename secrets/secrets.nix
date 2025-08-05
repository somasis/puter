# deadnix: skip
# This file is *not* used by the NixOS configuration,
# it is only used by the `agenix` command line tool.
let
  flake = import ../default.nix;
in
with flake.inputs;
with flake.inputs.nixpkgs;
let
  # Use publicly-available SSH keys from https://github.com/<user>.keys

  users = {
    somasis = {
      default = lib.fileContents keys-github-somasis;
      ilo = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFIbzmSphq2OTrMGV8TIgpF8zKzQW7Lp7yHFd/I9Esy9fcqXzXtTtFAn2rN/QWwmPXDi5+Icg09GfKAdcUxS+UM= somasis@ilo_tpm";
    };
  };
in
with users;
{
  # Before committing any modifications to the list of recipients for
  # any file listed here, run `agenix -r` in the development environment.
  "somasis-rclone-whatbox-http-url.age".publicKeys = [
    somasis.ilo
  ];

  "somasis-rclone-whatbox-pass.age".publicKeys = [
    somasis.ilo
  ];

  "somasis-rclone-fastmail-pass.age".publicKeys = [
    somasis.ilo
  ];

  "somasis-rclone-nextcloud-pass.age".publicKeys = [
    somasis.ilo
  ];
}
