{
  config,
  lib,
  ...
}:
{
  services.openssh = {
    enable = true;

    settings = {
      MaxAuthTries = 3;
      MaxSessions = 32; # default is 10
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };

  programs = {
    # Only use IPv4 by default, since we don't provide a
    # v6 on the local network anymore. This has the further
    # effect of making Nix not have a long delay trying to
    # connect to Esther over IPv6, and then falling back on
    # IPv4. ConnectTimeout is used since network latency can
    # be variable but IPv4 being a turned off on the router is
    # a constant.
    ssh.extraConfig = ''
      AddressFamily inet
    '';

    mosh.enable = true;
  };

  # Persist all host keys (NixOS has default host key locations!)
  persist.files = lib.flatten (
    map (key: [
      key.path
      "${key.path}.pub"
    ]) config.services.openssh.hostKeys
  );
}
