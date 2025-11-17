{
  time.timeZone = "America/New_York";

  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  cache.directories = [
    {
      directory = "/var/lib/geoclue";
      user = "geoclue";
      group = "geoclue";
    }
  ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # extraLocales = [ "tok/UTF-8" ];
    # extraLocaleSettings.LANGUAGE = "tok:en_US:en";
  };
}
