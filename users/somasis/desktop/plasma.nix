{
  config,
  osConfig,
  pkgs,
  ...
}:
assert osConfig.services.desktopManager.plasma6.enable;
{
  persist = {
    directories = [
      (config.lib.somasis.xdgConfigDir "gtk-3.0") # kde-gtk-config
      (config.lib.somasis.xdgConfigDir "gtk-4.0") # kde-gtk-config
      (config.lib.somasis.xdgConfigDir "xsettingsd") # kde-gtk-config
      (config.lib.somasis.xdgConfigDir "kde.org")
      (config.lib.somasis.xdgConfigDir "kdedefaults")
      (config.lib.somasis.xdgConfigDir "plasma-workspace")
      (config.lib.somasis.xdgConfigDir "session")

      # NOTE this is just where I've chosen to store my monitor
      # color profiles, nothing official about this
      (config.lib.somasis.xdgDataDir "color-profiles")

      (config.lib.somasis.xdgDataDir "baloo")
      (config.lib.somasis.xdgDataDir "dbus-1")
      (config.lib.somasis.xdgDataDir "dolphin")
      (config.lib.somasis.xdgDataDir "drkonqirc")
      (config.lib.somasis.xdgDataDir "kactivitymanagerd")
      (config.lib.somasis.xdgDataDir "klipper")
      (config.lib.somasis.xdgDataDir "knewstuff3")
      (config.lib.somasis.xdgDataDir "kscreen")
      (config.lib.somasis.xdgDataDir "kwalletd")
      (config.lib.somasis.xdgDataDir "kwin")
      (config.lib.somasis.xdgDataDir "kxmlgui5")
      (config.lib.somasis.xdgDataDir "libkunitconversion")
      (config.lib.somasis.xdgDataDir "networkmanagement")
      (config.lib.somasis.xdgDataDir "plasma")
      (config.lib.somasis.xdgDataDir "plasmashell")
      (config.lib.somasis.xdgDataDir "remoteview")
      (config.lib.somasis.xdgDataDir "sddm")
      (config.lib.somasis.xdgDataDir "systemmonitorrc")
      (config.lib.somasis.xdgDataDir "systemsettings")

      (config.lib.somasis.xdgConfigDir "panel-colorizer")
      (config.lib.somasis.xdgDataDir "color-schemes")
    ];

    files = [
      ".gtkrc-2.0" # kde-gtk-config
      ".directory" # Dolphin

      (config.lib.somasis.xdgConfigDir "KDE/kunifiedpush-distributor.conf")
      (config.lib.somasis.xdgConfigDir "KDE/kjournald.conf")
      (config.lib.somasis.xdgConfigDir "KDE/UserFeedback.conf")
      (config.lib.somasis.xdgConfigDir "KDE/Sonnet.conf")

      (config.lib.somasis.xdgConfigDir "QtProject.conf")
      (config.lib.somasis.xdgConfigDir "Trolltech.conf")
      (config.lib.somasis.xdgConfigDir "baloofileinformationrc")
      (config.lib.somasis.xdgConfigDir "gwenviewrc")
      (config.lib.somasis.xdgConfigDir "partitionmanagerrc")
      (config.lib.somasis.xdgConfigDir "xdg-desktop-portal-kderc")
      (config.lib.somasis.xdgConfigDir "gtkrc")
      (config.lib.somasis.xdgConfigDir "gtkrc-2.0")
      (config.lib.somasis.xdgConfigDir "baloofilerc")
      (config.lib.somasis.xdgConfigDir "bluedevilglobalrc")
      (config.lib.somasis.xdgConfigDir "bluedevilreceiverrc")
      (config.lib.somasis.xdgConfigDir "plasma-nm")
      (config.lib.somasis.xdgConfigDir "krunnerrc")
      (config.lib.somasis.xdgConfigDir "filetypesrc")
      (config.lib.somasis.xdgConfigDir "device_automounter_kcmrc")
      (config.lib.somasis.xdgConfigDir "dolphinrc")
      (config.lib.somasis.xdgConfigDir "drkonqirc")
      (config.lib.somasis.xdgConfigDir "kactivitymanagerd-statsrc")
      (config.lib.somasis.xdgConfigDir "kactivitymanagerdrc")
      (config.lib.somasis.xdgConfigDir "kcminputrc")
      (config.lib.somasis.xdgConfigDir "kconf_updaterc")
      (config.lib.somasis.xdgConfigDir "kded5rc")
      (config.lib.somasis.xdgConfigDir "kdeglobals")
      (config.lib.somasis.xdgConfigDir "kglobalshortcutsrc")
      (config.lib.somasis.xdgConfigDir "kiorc")
      (config.lib.somasis.xdgConfigDir "kioslaverc")
      (config.lib.somasis.xdgConfigDir "klipperrc")
      (config.lib.somasis.xdgConfigDir "kscreenlockerrc")
      (config.lib.somasis.xdgConfigDir "kservicemenurc")
      (config.lib.somasis.xdgConfigDir "ksmserverrc")
      (config.lib.somasis.xdgConfigDir "ktimezonedrc")
      (config.lib.somasis.xdgConfigDir "ktrashrc")
      (config.lib.somasis.xdgConfigDir "kwalletrc")
      (config.lib.somasis.xdgConfigDir "kwinoutputconfig.json")
      (config.lib.somasis.xdgConfigDir "kwinrc")
      (config.lib.somasis.xdgConfigDir "kxkbrc")
      (config.lib.somasis.xdgConfigDir "plasma-localerc")
      (config.lib.somasis.xdgConfigDir "plasma-org.kde.plasma.desktop-appletsrc")
      (config.lib.somasis.xdgConfigDir "plasmanotifyrc")
      (config.lib.somasis.xdgConfigDir "plasmaparc")
      (config.lib.somasis.xdgConfigDir "plasmarc")
      (config.lib.somasis.xdgConfigDir "plasmashellrc")
      (config.lib.somasis.xdgConfigDir "powerdevilrc")
      (config.lib.somasis.xdgConfigDir "powermanagementprofilesrc")
      (config.lib.somasis.xdgConfigDir "spectaclerc")
      (config.lib.somasis.xdgConfigDir "systemsettingsrc")
      (config.lib.somasis.xdgConfigDir "trashrc")

      (config.lib.somasis.xdgConfigDir "breezerc")
      (config.lib.somasis.xdgConfigDir "kwinrulesrc")

      (config.lib.somasis.xdgDataDir "user-places.xbel")
    ];
  };

  cache = {
    directories = [
      (config.lib.somasis.xdgCacheDir "kcrash-metadata")
      (config.lib.somasis.xdgCacheDir "drkonqi")
      (config.lib.somasis.xdgCacheDir "elisa")
      (config.lib.somasis.xdgCacheDir "fontconfig")
      (config.lib.somasis.xdgCacheDir "kio_http")
      (config.lib.somasis.xdgCacheDir "krunner")
      (config.lib.somasis.xdgCacheDir "kscreenlocker_greet")
      (config.lib.somasis.xdgCacheDir "kwin")
      (config.lib.somasis.xdgCacheDir "mesa_shader_cache")
      (config.lib.somasis.xdgCacheDir "mesa_shader_cache_db")
      (config.lib.somasis.xdgCacheDir "obexd")
      (config.lib.somasis.xdgCacheDir "org.kde.ki18n")
      (config.lib.somasis.xdgCacheDir "org.kde.unitconversion")
      (config.lib.somasis.xdgCacheDir "plasma_engine_potd")
      (config.lib.somasis.xdgCacheDir "plasmashell")
      (config.lib.somasis.xdgCacheDir "systemsettings")
      (config.lib.somasis.xdgCacheDir "thumbnails")
      (config.lib.somasis.xdgCacheDir "xwaylandvideobridge")
    ];

    files = [
      (config.lib.somasis.xdgDataDir "krunnerstaterc")
      (config.lib.somasis.xdgDataDir "qtposition-geoclue2")
      # (config.lib.somasis.xdgDataDir "recently-used.xbel")
    ];
  };

  nixpkgs.allowUnfreePackages = [ "unrar" ];

  home.packages =
    with pkgs;
    with libsForQt5;
    with kdePackages;
    with flakePackages;
    [
      plasma-manager.rc2nix

      alligator
      cameractrls-gtk3
      gwenview
      isoimagewriter
      kara
      kclock
      kde-gtk-config
      kjournald
      merkuro
      korganizer
      kpat
      kalk
      ksystemlog
      kweather
      lokalize

      # Used by Ark
      p7zip

      kdialog

      breeze-gtk
      hackneyed
      kde-rounded-corners
      papirus-icon-theme

      plasma-applet-commandoutput

      plasma-panel-colorizer
      glib.bin # Used by plasma-panel-colorizer

      plasma-panel-spacer-extended
      kconfig # Used by plasma-panel-spacer-extended

      kurve
      cava

      qtbase # qdbus, among other things

      syncplay

      waypipe
      wl-clipboard

      emojirunner
    ];

  programs.plasma = {
    enable = true;
  };

  # Prefer to let Plasma manage theme configuration.
  qt.enable = false;
  gtk.enable = false;
  home.file.".gtkrc-2.0".enable = false;

  # Force usage of Breeze's theme on GTK 4
  home.sessionVariables.GTK_THEME = "Breeze";

  xsession.preferStatusNotifierItems = true;

  systemd.user.targets.tray.Unit = {
    Requires = [ "plasma-core.target" ];
    After = [ "plasma-xembedsniproxy.service" ];
  };

  # Ensure Electron apps use Wayland, instead of Xwayland.
  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
