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

    # Automatically `nice` programs for better performance.
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;

      extraRules = [
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

  # ananicy spams the log constantly
  # systemd.services.ananicy-cpp.serviceConfig.StandardOutput = "null";

  powerManagement.cpuFreqGovernor = "powersave";

  # Auto-tune with powertop on boot.
  powerManagement.powertop.enable = true;
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
