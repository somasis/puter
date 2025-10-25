{
  pkgs,
  ...
}:
{
  services = {
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "ignore";

      HandlePowerKey = "sleep";
      HandlePowerKeyLongPress = "poweroff";

      PowerKeyIgnoreInhibited = "yes";
    };

    upower = {
      enable = true;
      criticalPowerAction = "PowerOff";

      percentageLow = 15;
      percentageCritical = 5;
      percentageAction = 0;
    };

    power-profiles-daemon.enable = false;
    tuned = {
      enable = true;
      ppdSettings.main.default = "power-saver";
    };
    tlp.enable = false;

    # Automatically `nice` programs for better performance.
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;

      extraRules = [
        {
          name = "bindfs";
          type = "BG_CPUIO";
        }

        {
          name = "baloorunner";
          type = "BG_CPUIO";
        }

        {
          name = "konversation";
          type = "Chat";
        }
        {
          name = "equibop";
          type = "Chat";
        }
        {
          name = "radiotray-ng";
          type = "Player-Audio";
        }

        {
          name = "darkman";
          type = "Service";
        }
        {
          name = "usbguard-notifier";
          type = "Service";
        }
        {
          name = "systembus-notify";
          type = "Service";
        }
        {
          name = "mpris-scrobbler";
          type = "Service";
        }
        {
          name = "mpris-proxy";
          type = "Service";
        }
        {
          name = "music-discord-rpc";
          type = "Service";
        }
        {
          name = "systemd-lock-handler";
          type = "BG_CPUIO";
        }
        {
          name = "qutebrowser";
          type = "Doc-View";
        }
        {
          name = "zotero";
          type = "Doc-View";
        }
        {
          name = "elisa";
          type = "Player-Audio";
        }
      ];
    };

    systemd-lock-handler.enable = true;
  };

  powerManagement = {
    cpuFreqGovernor = "powersave";

    # Auto-tune with powertop on boot.
    powertop.enable = true;
  };

  cache.directories = [ "/var/cache/powertop" ];
  persist.directories = [ "/var/lib/upower" ];

  systemd.shutdown."wine-kill" = pkgs.writeShellScript "wine-kill" ''
    ${pkgs.procps}/bin/pkill '^winedevice\.exe$' || :
    if [[ -n "$(${pkgs.procps}/bin/pgrep '^winedevice\.exe$')" ]]; then
        ${pkgs.procps}/bin/pkill -e -9 '^winedevice\.exe$' || :
    fi
    exit 0
  '';
}
