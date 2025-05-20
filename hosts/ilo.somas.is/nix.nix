{ config
, pkgs
, lib
, inputs
, self
, ...
}:
{
  nix.settings = {
    extra-experimental-features = [
      "ca-derivations"
      "auto-allocate-uids"
    ];

    max-jobs = 4;
    log-lines = 1000;

    auto-optimise-store = true;
    min-free = 1024000000; # 512 MB
    max-free = 1024000000; # 1 GB

    # Allow building from source if binary substitution fails
    fallback = true;

    # Quiet the dirty messages when using `nixos-dev`.
    warn-dirty = false;

    connect-timeout = 5;
    stalled-download-timeout = 15;

    http-connections = 64;
    max-substitution-jobs = 64;
    extra-substituters = lib.mkBefore [
      # Prefer HTTP nix-serve via an SSH tunnel to esther.
      # Faster for multiple missing-path queries.
      "http://localhost:5000"

      # Use ca-derivations cache
      # <https://discourse.nixos.org/t/content-addressed-nix-call-for-testers/12881#:~:text=Level%203%20%E2%80%94%20Raider%20of%20the%20unknown>
      "https://cache.ngi0.nixos.org"
    ];

    extra-trusted-public-keys = [
      "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
    ];
  };

  environment.systemPackages = lib.optional config.programs.bash.completion.enable pkgs.nix-bash-completions;

  programs.ssh = {
    extraConfig = ''
      Host esther.7596ff.com
        ServerAliveInterval 15
        Compression yes
    '';

    knownHosts.esther = {
      hostNames = [
        "esther.7596ff.com"
        "esther.7596ff.com.lan"
        "esther.lan"
        "esther"
      ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXvOGvDJoSXkL0l5xueeHmYo1FjUdS1Ti77d4KteSyE";
    };
  };
}
