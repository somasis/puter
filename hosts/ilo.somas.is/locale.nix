{
  pkgs,
  config,
  lib,
  ...
}:
{
  # Automatically update location and timezone when traveling,
  # with a fallback timezone.
  services.localtimed.enable = true;
  environment.etc.localtime.source = "${pkgs.tzdata}/share/zoneinfo/America/New_York";

  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  cache.directories = [
    {
      directory = "/var/lib/geoclue";
      user = "geoclue";
      group = "geoclue";
    }
    {
      directory = "/var/lib/systemd/timesync";
      user = "systemd-timesync";
      group = "systemd-timesync";
    }
  ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "tok/UTF-8" ];
    # extraLocaleSettings.LANGUAGE = "tok:en_US:en";
  };
}
