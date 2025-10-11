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

  persist = {
    directories = [
      (config.lib.somasis.xdgConfigDir "kdeconnect")
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "kdeconnect.notifyrc")
    ];
  };

  cache.directories = [
    (config.lib.somasis.xdgDataDir "kpeoplevcard")
    (config.lib.somasis.xdgCacheDir "kdeconnect.app")
    (config.lib.somasis.xdgCacheDir "kdeconnect.daemon")
    (config.lib.somasis.xdgCacheDir "kdeconnect.sms")
  ];

  programs.qutebrowser = {
    aliases.kdeconnect = "spawn ${config.services.kdeconnect.package}/bin/kdeconnect-handler";
    keyBindings.normal."zk" = "kdeconnect {url}";
  };
}
