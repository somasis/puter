{
  config,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (config.lib.somasis) xdgCacheDir xdgConfigDir xdgDataDir;
in
assert osConfig.services.desktopManager.plasma6.enable;
{
  persist = {
    directories = [
      # NOTE this is just where I've chosen to store my monitor
      # color profiles, nothing official about this
      (xdgDataDir "color-profiles")

      # Need bindfs because we write into ~/share/plasma when
      # installing our theme files in `./users/somasis/theme`.
      {
        method = "bindfs";
        directory = xdgDataDir "plasma";
      }

      # keep-sorted start
      (xdgConfigDir "gtk-3.0") # kde-gtk-config
      (xdgConfigDir "gtk-4.0") # kde-gtk-config
      (xdgConfigDir "kde.org")
      (xdgConfigDir "kdedefaults")
      (xdgConfigDir "kweather")
      (xdgConfigDir "panel-colorizer")
      (xdgConfigDir "plasma-workspace")
      (xdgConfigDir "session")
      (xdgConfigDir "xsettingsd") # kde-gtk-config
      (xdgDataDir "ark")
      (xdgDataDir "baloo")
      (xdgDataDir "color-schemes")
      (xdgDataDir "dbus-1")
      (xdgDataDir "dolphin")
      (xdgDataDir "drkonqirc")
      (xdgDataDir "kactivitymanagerd")
      (xdgDataDir "klipper")
      (xdgDataDir "knewstuff3")
      (xdgDataDir "kscreen")
      (xdgDataDir "kwalletd")
      (xdgDataDir "kwin")
      (xdgDataDir "kxmlgui5")
      (xdgDataDir "libkunitconversion")
      (xdgDataDir "networkmanagement")
      (xdgDataDir "plasma-manager")
      (xdgDataDir "plasma-systemmonitor")
      (xdgDataDir "plasma_icons") # Used for desktop icon widgets.
      (xdgDataDir "plasmashell")
      (xdgDataDir "remoteview")
      (xdgDataDir "sddm")
      (xdgDataDir "systemmonitorrc")
      (xdgDataDir "systemsettings")
      # keep-sorted end
    ];

    files = [
      # keep-sorted start
      ".directory" # Dolphin
      ".gtkrc-2.0" # kde-gtk-config
      (xdgConfigDir "KDE/Sonnet.conf")
      (xdgConfigDir "KDE/UserFeedback.conf")
      (xdgConfigDir "KDE/kjournald.conf")
      (xdgConfigDir "KDE/kunifiedpush-distributor.conf")
      (xdgConfigDir "QtProject.conf")
      (xdgConfigDir "Trolltech.conf")
      (xdgConfigDir "arkrc")
      (xdgConfigDir "baloofileinformationrc")
      (xdgConfigDir "baloofilerc")
      (xdgConfigDir "bluedevilglobalrc")
      (xdgConfigDir "bluedevilreceiverrc")
      (xdgConfigDir "breezerc")
      (xdgConfigDir "device_automounter_kcmrc")
      (xdgConfigDir "dolphinrc")
      (xdgConfigDir "drkonqirc")
      (xdgConfigDir "filetypesrc")
      (xdgConfigDir "gtkrc")
      (xdgConfigDir "gtkrc-2.0")
      (xdgConfigDir "gwenviewrc")
      (xdgConfigDir "kactivitymanagerd-statsrc")
      (xdgConfigDir "kactivitymanagerdrc")
      (xdgConfigDir "kclockdrc")
      (xdgConfigDir "kclockrc")
      (xdgConfigDir "kcminputrc")
      (xdgConfigDir "kconf_updaterc")
      (xdgConfigDir "kded5rc")
      (xdgConfigDir "kdeglobals")
      (xdgConfigDir "kglobalshortcutsrc")
      (xdgConfigDir "kiorc")
      (xdgConfigDir "kioslaverc")
      (xdgConfigDir "klipperrc")
      (xdgConfigDir "krunnerrc")
      (xdgConfigDir "kscreenlockerrc")
      (xdgConfigDir "kservicemenurc")
      (xdgConfigDir "ksmserverrc")
      (xdgConfigDir "ksplashrc")
      (xdgConfigDir "ktimezonedrc")
      (xdgConfigDir "ktrashrc")
      (xdgConfigDir "kwalletrc")
      (xdgConfigDir "kwinoutputconfig.json")
      (xdgConfigDir "kwinrc")
      (xdgConfigDir "kwinrulesrc")
      (xdgConfigDir "kxkbrc")
      (xdgConfigDir "partitionmanagerrc")
      (xdgConfigDir "plasma-localerc")
      (xdgConfigDir "plasma-nm")
      (xdgConfigDir "plasma-org.kde.plasma.desktop-appletsrc")
      (xdgConfigDir "plasmanotifyrc")
      (xdgConfigDir "plasmaparc")
      (xdgConfigDir "plasmarc")
      (xdgConfigDir "plasmashellrc")
      (xdgConfigDir "powerdevilrc")
      (xdgConfigDir "powermanagementprofilesrc")
      (xdgConfigDir "spectaclerc")
      (xdgConfigDir "systemmonitorrc")
      (xdgConfigDir "systemsettingsrc")
      (xdgConfigDir "trashrc")
      (xdgConfigDir "xdg-desktop-portal-kderc")
      (xdgDataDir "user-places.xbel")
      # keep-sorted end
    ];
  };

  cache = {
    directories = [
      # keep-sorted start
      (xdgCacheDir "dolphin")
      (xdgCacheDir "drkonqi")
      (xdgCacheDir "elisa")
      (xdgCacheDir "fontconfig")
      (xdgCacheDir "kalk")
      (xdgCacheDir "kcrash-metadata")
      (xdgCacheDir "kio_http")
      (xdgCacheDir "krunner")
      (xdgCacheDir "kscreenlocker_greet")
      (xdgCacheDir "ksplash")
      (xdgCacheDir "kweather")
      (xdgCacheDir "kwin")
      (xdgCacheDir "mesa_shader_cache")
      (xdgCacheDir "mesa_shader_cache_db")
      (xdgCacheDir "obexd")
      (xdgCacheDir "org.kde.ki18n")
      (xdgCacheDir "org.kde.kunifiedpush")
      (xdgCacheDir "org.kde.unitconversion")
      (xdgCacheDir "plasma-systemmonitor")
      (xdgCacheDir "plasma_engine_potd")
      (xdgCacheDir "plasmashell")
      (xdgCacheDir "spectacle")
      (xdgCacheDir "systemsettings")
      (xdgCacheDir "thumbnails")
      (xdgCacheDir "xdg-desktop-portal-kde")
      (xdgCacheDir "xwaylandvideobridge")
      # keep-sorted end
    ];

    files = [
      # keep-sorted start
      (xdgCacheDir "xdg-desktop-portal-kderc")
      (xdgDataDir "krunnerstaterc")
      (xdgDataDir "qtposition-geoclue2")
      # keep-sorted end
    ];
  };

  home.packages =
    with pkgs;
    with kdePackages;
    [
      # keep-sorted start
      breeze-gtk
      cameractrls-gtk3
      emojirunner
      glib.bin # used by plasma-panel-colorizer
      gwenview
      hackneyed
      isoimagewriter
      kalk
      kclock
      kconfig # used by plasma-panel-spacer-extended
      kde-gtk-config
      kdialog
      kdotool
      kjournald
      korganizer
      ksystemlog
      kweather
      kwin-switch-to-last-used-desktop
      lokalize
      p7zip # used by Ark
      papirus-icon-theme
      plasma-applet-commandoutput
      plasma-panel-colorizer
      plasma-panel-spacer-extended
      qtbase # qdbus, among other things
      syncplay
      waypipe
      wl-clipboard
      # keep-sorted end
    ];

  programs.plasma.enable = true;

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
