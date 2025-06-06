{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  home.packages = [
    pkgs.libnotify
    pkgs.ntfy-sh
  ];

  services.systembus-notify.enable = true;

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "ntfy";
    }
  ];

  systemd.user.services.ntfy-sh = {
    Unit = {
      Description = "Subscribe to notifications from ntfy.sh";
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];

    Service = {
      Type = "simple";
      Restart = "on-failure";

      ExecStartPre = lib.mkIf osConfig.networking.networkmanager.enable "${pkgs.networkmanager}/bin/nm-online -q";
      ExecStart = [ "${pkgs.ntfy-sh}/bin/ntfy subscribe --from-config -S" ];
    };
  };
}
