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

  # Sourced from /etc/ssh/ssh_host_ed25519_key, or ~root/.ssh/id25519.pub
  # on the corresponding machine, which is generated after first boot.
  # This will need to be updated if/when new machines are added.
  machines = {
    esther = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXvOGvDJoSXkL0l5xueeHmYo1FjUdS1Ti77d4KteSyE generated 2024-07-02";
    ilo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICt+E12KtLbvV4T7oLgs8gY3DHWN6yaWaks/U/Ci4fc9 generated 2023-01-25";
  };

  users = {
    cassie = {
      default = lib.fileContents keys-github-cassie;
    };

    somasis = {
      default = lib.fileContents keys-github-somasis;
      ilo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkmjWLpicEaQOkM7FAv5bctmZjV5GjISYW7re0oknLU somasis@ilo.somas.is_20220603";
      esther = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwx+D9HPPjg0H6rSLUaXiEOQzF9W4LlX3HRgyD+4eis somasis@esther.7596ff.com_20250221";
    };
  };
in
with users;
{
  # Before committing any modifications to the list of recipients for
  # any file listed here, run `agenix -r` in the development environment.
  "cassie-beets-musicbrainz-password.age".publicKeys = [
    somasis.esther
    cassie.default
    machines.esther
  ];
  "cassie-transmission.json.age".publicKeys = [
    somasis.esther
    cassie.default
    machines.esther
  ];
  "cassie-openvpn-galileo.ovpn.age".publicKeys = [
    somasis.esther
    cassie.default
    machines.esther
  ];

  "cassie-htpasswd-media.age".publicKeys = [
    somasis.esther
    cassie.default
    machines.esther
  ];
  "cassie-htpasswd-zotero.age".publicKeys = [
    somasis.esther
    cassie.default
    machines.esther
  ];

  "somasis-htpasswd-hledger-web.age".publicKeys = [
    somasis.default
    machines.esther
  ];
  "somasis-htpasswd-scooper.age".publicKeys = [
    somasis.default
    machines.esther
  ];

  "somasis-rclone-fastmail-pass.age".publicKeys = [
    somasis.esther
    somasis.ilo
  ];
  "somasis-rclone-nextcloud-pass.age".publicKeys = [
    somasis.esther
    somasis.ilo
  ];

  # These are machine-specific, and should only be shared with the machines in question
  "esther.7596ff.com/initrd_ssh_host_ed25519_key.age".publicKeys = [
    somasis.esther
    machines.esther
  ];
  "esther.7596ff.com/nix-serve-2024-07-06.key.age".publicKeys = [
    somasis.esther
    machines.esther
  ];
}
