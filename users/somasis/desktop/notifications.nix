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

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "ntfy";
    }
  ];

  systemd.user.services.ntfy-sh = {
    Unit = {
      Description = "Subscribe to notifications from ntfy.sh using the user configuration";
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];

    Service = {
      Type = "simple";
      Restart = "on-failure";

      SyslogIdentifier = "ntfy";

      ExecStartPre = lib.mkIf osConfig.networking.networkmanager.enable "${pkgs.networkmanager}/bin/nm-online -q";
      ExecStart = pkgs.writeShellScript "ntfy-sh-subscribe-with-since" ''
        : "''${XDG_CACHE_HOME:=$HOME/.cache}"

        PATH="''${PATH:+$PATH:}"${
          lib.escapeShellArg (
            lib.makeBinPath [
              pkgs.coreutils
              pkgs.ntfy-sh
            ]
          )
        }

        time_last_ran_file="$XDG_CACHE_HOME/ntfy/utc_last_run_time"

        mkdir -p "''${time_last_ran_file%/*}"
        touch "$time_last_ran_file"
        time_last_ran=$(<"$time_last_ran_file") || :

        trap 'TZ=UTC date +%s > "$time_last_ran_file"' HUP INT

        # shellcheck disable=SC2016
        ntfy subscribe ''${time_last_ran:+--since "$time_last_ran"} --from-config "$@"

        TZ=UTC date +%s > "$time_last_ran_file"
      '';
    };
  };
}
