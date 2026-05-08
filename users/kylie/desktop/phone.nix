{
  config,
  osConfig,
  ...
}:
assert osConfig.programs.kdeconnect.enable;
{
  services.kdeconnect = {
    enable = true;
    inherit (osConfig.programs.kdeconnect) package;
  };

  data = {
    directories = [
      (config.lib.somasis.xdgConfigDir "kdeconnect")
      (config.lib.somasis.xdgDataDir "kpeoplevcard")
      (config.lib.somasis.xdgCacheDir "kdeconnect.app")
      (config.lib.somasis.xdgCacheDir "kdeconnect.daemon")
      (config.lib.somasis.xdgCacheDir "kdeconnect.sms")
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "kdeconnect.notifyrc")
    ];
  };
}
