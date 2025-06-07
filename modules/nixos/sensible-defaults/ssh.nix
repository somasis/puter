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

  programs.mosh.enable = true;

  # Persist all host keys (NixOS has default host key locations!)
  persist.files = lib.flatten (
    map (key: [
      key.path
      "${key.path}.pub"
    ]) config.services.openssh.hostKeys
  );
}
