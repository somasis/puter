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
  cassie = lib.fileContents keys-github-cassie;
  somasis = lib.fileContents keys-github-somasis;

  # Sourced from /etc/ssh/ssh_host_ed25519_key, or ~root/.ssh/id25519.pub
  # on the corresponding machine, which is generated after first boot.
  # This will need to be updated if/when new machines are added.
  esther = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXvOGvDJoSXkL0l5xueeHmYo1FjUdS1Ti77d4KteSyE generated 2024-07-02";
  ilo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICt+E12KtLbvV4T7oLgs8gY3DHWN6yaWaks/U/Ci4fc9 ilo.somas.is_20230125";
  machines = [ esther ilo ];
in
{
  # Before committing any modifications to the list of recipients for
  # any file listed here, run `agenix -r <file name exactly as listed here>`
  # in the `nix develop` environment.
  "cassie-beets-musicbrainz-password.age".publicKeys = [ somasis cassie esther ];
  "cassie-transmission.json.age".publicKeys = [ somasis cassie esther ];
  "cassie-openvpn-galileo.ovpn.age".publicKeys = [ somasis cassie esther ];

  "cassie-htpasswd-media.age".publicKeys = [ somasis cassie esther ];
  "cassie-htpasswd-zotero.age".publicKeys = [ somasis cassie esther ];

  "somasis-htpasswd-hledger-web.age".publicKeys = [ somasis esther ];
  "somasis-htpasswd-scooper.age".publicKeys = [ somasis esther ];

  "somasis-rclone-fastmail-pass.age".publicKeys = [ somasis ] ++ machines;
  "somasis-rclone-nextcloud-pass.age".publicKeys = [ somasis ] ++ machines;

  # These are machine-specific, and should only be shared with the machines in question
  "nix-serve-esther.7596ff.com-2024-07-06.key.age".publicKeys = [ somasis cassie esther ];
}
