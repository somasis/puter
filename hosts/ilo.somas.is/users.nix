{
  config,
  lib,
  ...
}:
{
  persist.files = [
    "/etc/passwd"
    "/etc/shadow"
    "/etc/group"
  ];

  users = {
    mutableUsers = true;

    users.somasis = {
      isNormalUser = true;
      description = "Kylie McClain";
      uid = 1000;

      extraGroups = [
        "systemd-journal"
      ]
      # keep-sorted start
      ++ lib.optional config.hardware.brillo.enable "video"
      ++ lib.optional config.hardware.sane.enable "scanner"
      ++ lib.optional config.hardware.uinput.enable "input"
      ++ lib.optional config.programs.adb.enable "adbusers"
      ++ lib.optional config.programs.tcpdump.enable "pcap"
      ++ lib.optional config.security.sudo.enable "wheel"
      ++ lib.optional config.security.tpm2.enable "tss"
      ++ lib.optional config.services.printing.enable "lp"
      ++ lib.optional config.services.timesyncd.enable "systemd-timesync"
      ++ lib.optional config.virtualisation.podman.enable "podman"
      # keep-sorted end
      ++ lib.optionals config.networking.networkmanager.enable [
        "network"
        "networkmanager"
      ];
    };
  };

  services.displayManager.autoLogin.user = "somasis";
}
