{
  pkgs,
  config,
  lib,
  ...
}:
{
  # Boone, NC, USA
  location = {
    latitude = 36.21641;
    longitude = -81.67464;
  };

  # Automatically update location and timezone when traveling,
  # with a fallback timezone.
  # services.automatic-timezoned.enable = true;
  services.localtimed.enable = true;
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "nm-localtimed" ''
        if [ "$2" = "connectivity-change" ]; then systemctl start localtimed.service; fi
      '';
    }
  ];

  # time.timeZone can't be set when using automatic-timezoned; but that's bullshit.
  # See <https://github.com/NixOS/nixpkgs/issues/68489>
  # and <https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/systemd/0006-hostnamed-localed-timedated-disable-methods-that-cha.patch#L79-L82>

  # time.timeZone = "America/New_York";

  boot.postBootCommands = ''
    ln -fs /etc/zoneinfo/America/New_York /etc/localtime
  '';

  # systemd.services.set-default-timezone = {
  #   description = "Set the default timezone at boot";
  #   wantedBy = [ "time-set.target" "basic.target" ];
  #   requires = [ "systemd-timesyncd.service" ];
  #   before = [ "localtimed.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${config.systemd.package}/bin/timedatectl set-timezone America/New_York";
  #   };
  # };

  services.geoclue2 = {
    enable = true;

    geoProviderUrl = "https://beacondb.net/v1/geolocate?key=geoclue";

    # appConfig = {
    #   where-am-i = {
    #     isAllowed = true;
    #     isSystem = false;
    #   };
    # };
  };

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

  # TODO: o kepeken toki pona
  #       ilo glibc nanpa 2.36 li jo e sona pi toki pona.
  #       nanpa 2.36 li lon ala poki ilo nixpkgs.
  #       <https://github.com/NixOS/nixpkgs/pull/188492>
  # i18n.extraLocaleSettings.LANGUAGE = "tok:en_US:en";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "tok/UTF-8" ];
    # extraLocaleSettings.LANGUAGE = "tok:en_US:en";
  };
}
