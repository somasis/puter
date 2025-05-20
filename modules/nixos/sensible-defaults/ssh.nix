{ config
, lib
, ...
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

  programs.mosh.enable = true;

  persist = {
    # Persist all host keys (NixOS has default host key locations!)
    files = lib.flatten (
      map
        (key: [
          key.path
          "${key.path}.pub"
        ])
        config.services.openssh.hostKeys
    );

    # Persist root's own user keys
    users.root.directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };

  # Default to the root user when SSHing into the router.
  programs.ssh.extraConfig = ''
    Host bobo.lan bobo openwrt router
      User root
  '';
}
