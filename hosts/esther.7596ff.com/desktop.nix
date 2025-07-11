{
  config,
  pkgs,
  ...
}:
{
  persist.directories = [
    "/var/lib/cups"
    "/var/lib/power-profiles-daemon"
    "/var/lib/sddm"
    "/var/lib/udisks2"
    "/var/lib/upower"
  ];

  cache.directories = [
    "/var/cache/cups"
  ];

  log.directories = [
    "/var/spool/cups"
  ];

  # boot.plymouth.enable = true;

  # Show the system journal on tty12.
  services.journald.console = "/dev/tty12";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [ "nvidia-drm.fbdev=1" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };

  # Necessary so that machine can provide location facilities
  services.geoclue2 = {
    enable = true;

    # Mozilla Location Services has since been discontinued; BeaconDB is a replacement
    geoProviderUrl = "https://beacondb.net/v1/geolocate";
  };

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  # NOTE(somasis) Caused issues with automatic suspension of USB devices
  # being far too quick, especially with keyboards and mice. Giant pain
  # to figure this one out.
  # powerManagement.powertop.enable = false;

  services.printing.enable = true;

  # NOTE Required to make CUPS's printer discovery more reliable;
  # it was a real pain to use before adding this.
  services.avahi.nssmdns4 = true;

  services.saned.enable = true;
  hardware.sane = {
    enable = true;
    openFirewall = true;
  };

  users.users =
    let
      desktopGroups = [
        "lp"
        "scanner"
        "gamemode"
        "systemd-journald"
        "input"
        "vboxusers"
      ];
    in
    {
      cassie.extraGroups = desktopGroups;
      somasis.extraGroups = desktopGroups;
    };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages =
    with pkgs;
    with libsForQt5;
    with kdePackages;
    [
      wineWow64Packages.stableFull

      qtbase # qdbus and friends
      kio-zeroconf

      plasma-disks
      kara
      krohnkite
      karousel
      kzones
      plasma-panel-colorizer

      hackneyed

      krename
      kjournald
      filelight
      kdenetwork-filesharing

      skanpage # scanning utility
      tesseract # OCR tool used by skanpage

      kweather

      (gimp-with-plugins.override {
        plugins = with gimpPlugins; [
          gmic
          bimp
        ];
      })
    ];

  services.playerctld.enable = true;

  programs.partition-manager.enable = true;

  # Make Electron apps use Wayland support by default
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = [
    pkgs.liberation_ttf
    pkgs.nasin-nanpa
  ];

  hardware.sensor.hddtemp = {
    enable = true;
    drives = [
      "/dev/disk/by-id/ata-ST12000VN0008-2YS101_ZRT1LPT5"
      "/dev/disk/by-id/ata-ST12000VN0008-2YS101_ZRT1N2JD"
      "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_5QHDU6UB"
      "/dev/disk/by-id/ata-WDC_WD120EFBX-68B0EN0_D7HTJUZN"
    ];
  };

  programs.kdeconnect.enable = true;
  programs.kde-pim = {
    enable = true;
    kmail = true;
    kontact = true;
    merkuro = true;
  };

  # Allow PipeWire (and possibly other things) acquire realtime
  # permissions from the kernel.
  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };
}
