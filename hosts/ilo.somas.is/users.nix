{
  config,
  lib,
  ...
}:
{
  users = {
    mutableUsers = false;

    users = {
      # Disable root login.
      root.hashedPassword = "!";

      somasis = {
        isNormalUser = true;
        description = "Kylie McClain";
        uid = 1000;

        extraGroups =
          [ "systemd-journal" ]
          ++ lib.optional config.hardware.brillo.enable "video"
          ++ lib.optional config.hardware.sane.enable "scanner"
          ++ lib.optional config.hardware.uinput.enable "input"
          ++ lib.optional config.programs.adb.enable "adbusers"
          ++ lib.optional config.security.sudo.enable "wheel"
          ++ lib.optional config.services.printing.enable "lp"
          ++ lib.optional config.services.timesyncd.enable "systemd-timesync"
          ++ lib.optionals config.networking.networkmanager.enable [
            "network"
            "networkmanager"
          ];

        # $ mkpasswd -m sha-512 -s
        # and don't forget...
        # $ pass edit ilo.somas.is/users/somasis
        # $ sudo zfs change-key ilo.somas.is/nixos
        # $ pass edit ilo.somas.is/zfs/nixos
        hashedPassword = "$6$1vjLB9lSU6Xw8J.L$8zmUO3J9dXUQfAIqIkCBroOpQ3KXUjBJsmu5NZrnO3IB1GyIqXpkUUgZP3XXCJ1./x9TK./06M4bnvYX/PYzs/";

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkmjWLpicEaQOkM7FAv5bctmZjV5GjISYW7re0oknLU somasis@ilo.somas.is_20220603"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwx+D9HPPjg0H6rSLUaXiEOQzF9W4LlX3HRgyD+4eis somasis@esther.7596ff.com_20250221"
        ];
      };
    };
  };

  # IDEA: Synchronize user passwords with password store?
  # system.activationScripts.pass-users = {
  #   text = ''
  #     set -eu
  #     set -o pipefail

  #     for u in ${builtins.attrNames config.users.users}; do
  #         if p=$(pass "${config.networking.fqdnOrHostName}/users/$u" 2>&1); then
  #             printf '%s:%s\n' "$u" "$(tr -d '\n' <<< "$p" | mkpasswd -m sha-512 -s)"
  #         fi
  #     done
  #     # chpasswd -e
  #   '';
  # };
}
