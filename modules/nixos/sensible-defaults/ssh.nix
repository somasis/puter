{
  config,
  lib,
  self,
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

  boot.initrd = {
    systemd = lib.mkIf (config.boot.initrd.systemd.network.networks != { }) {
      enable = true;
      network.enable = true;
    };

    network.ssh = {
      enable = true;
      hostKeys = [ config.age.secrets.initrd_ssh_host_key.path ];
    };
  };

  age.secrets.initrd_ssh_host_key.file = "${self}/secrets/${config.networking.fqdnOrHostName}/initrd_ssh_host_ed25519_key.age";
}
