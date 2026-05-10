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

      kylie = {
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
        ++ lib.optional config.security.tpm2.enable config.security.tpm2.tssGroup
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
        hashedPassword = "$6$VyXUgBu/7jFpjURy$O2T1ApHWDRETETbC4wjkfJYomXPlU6QXb0Xg6fMdcQh2eH.hzc8HKoCbYaT4ctVvQGbz1Q2/PcT8P9H.Kr5We1";
      };
    };
  };

  services.displayManager.autoLogin.user = "kylie";
}
