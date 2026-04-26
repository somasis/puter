{
  time.timeZone = "America/New_York";

  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # extraLocales = [ "tok/UTF-8" ];
    # extraLocaleSettings.LANGUAGE = "tok:en_US:en";
  };
}
