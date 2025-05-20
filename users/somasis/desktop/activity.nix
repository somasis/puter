{ config
, pkgs
, lib
, ...
}:
{
  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "activitywatch";
    }
  ];

  sync.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "activitywatch";
    }
    {
      method = "symlink";
      directory = config.home.sessionVariables.AW_SYNC_DIR;
    }
  ];

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "activitywatch";
    }
  ];

  home.packages = [
    pkgs.aw-notify
    pkgs.aw-qt
    config.services.activitywatch.package
  ];

  home.sessionVariables.AW_SYNC_DIR = config.lib.somasis.xdgDataDir "aw-sync";

  services.activitywatch = {
    enable = false; # Use aw-qt for managing it.
    # package = pkgs.aw-server-rust; # TODO

    # settings = {
    #   custom_static = {
    #     aw-watcher-media-player = "${pkgs.aw-watcher-media-player.src}/visualization";
    #     # aw-watcher-utilization = "${pkgs.aw-watcher-utilization.src}/visualization";
    #     # aw-watcher-input = "${pkgs.aw-watcher-input}/visualization/dist";
    #   };
    # };

    # watchers = {
    #   aw-watcher-window = lib.mkIf (config.xsession.enable) {
    #     package = pkgs.activitywatch;
    #     settings.poll_time = 1;
    #   };

    #   aw-watcher-window-wayland.package = pkgs.aw-watcher-window-wayland;

    #   # aw-watcher-afk = {
    #   #   package = pkgs.activitywatch;
    #   #   settings.timeout = config.services.screen-locker.inactiveInterval * 60;
    #   # };

    #   # aw-watcher-input.package = pkgs.aw-watcher-input;
    #   # aw-watcher-utilization.package = pkgs.aw-watcher-utilization;
    #   # aw-watcher-media-player.package = pkgs.aw-watcher-media-player;
    # };
  };
  # systemd.user.services = {
  #   # "activitywatch-watcher-aw-watcher-afk".Unit.AssertEnvironment = [ "DISPLAY" ];
  #   "activitywatch-watcher-aw-watcher-window".Unit.AssertEnvironment = [ "DISPLAY" ];
  # };
}
