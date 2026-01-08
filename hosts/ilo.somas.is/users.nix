{
  config,
  lib,
  ...
}:
{
  users = {
    mutableUsers = false;

    users = {
      root.hashedPassword = "$y$j9T$RI9UZXWVwReRSKDI9qhyw/$atD3ojK0Wp4fSMkzZD7jxM.HR/Sp9uj9UsnA5mYRso7";

      somasis = {
        isNormalUser = true;
        description = "Kylie McClain";
        uid = 1000;

        extraGroups = [
          "systemd-journal"
        ]
        # keep-sorted start
        ++ lib.optional config.hardware.keyboard.qmk.enable "plugdev"
        ++ lib.optional config.hardware.sane.enable "scanner"
        ++ lib.optional config.hardware.uinput.enable "input"
        ++ lib.optional config.programs.tcpdump.enable "pcap"
        ++ lib.optional config.programs.wireshark.enable "wireshark"
        ++ lib.optional config.security.sudo.enable "wheel"
        ++ lib.optional config.security.tpm2.enable "tss"
        ++ lib.optional config.services.printing.enable "lp"
        ++ lib.optional config.services.timesyncd.enable "systemd-timesync"
        ++ lib.optional config.virtualisation.podman.enable "podman"
        ++ lib.optional config.virtualisation.virtualbox.host.enable "vboxusers"
        # keep-sorted end
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
      };
    };
  };

  services.displayManager.autoLogin.user = "somasis";
}
