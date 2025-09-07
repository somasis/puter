{
  config,
  osConfig,
  pkgs,
  inputs,
  ...
}:
assert osConfig.services.desktopManager.plasma6.enable;
{
  persist = {
    directories = [
      ".cert/nm-openvpn"
    ]
    ++
      map
        (x: {
          directory = config.lib.somasis.xdgConfigDir x;
          method = "symlink";
        })
        [
          "gtk-3.0" # kde-gtk-config
          "gtk-4.0" # kde-gtk-config
          "xsettingsd" # kde-gtk-config
          "kde.org"
          "kdedefaults"
          "plasma-workspace"
          "session"
        ]
    ++
      map
        (x: {
          directory = config.lib.somasis.xdgDataDir x;
          method = "symlink";
        })
        [
          "baloo"
          "dbus-1"
          "dolphin"
          "drkonqirc"
          "icons"
          "kactivitymanagerd"
          "klipper"
          "knewstuff3"
          "kscreen"
          "kwalletd"
          "kwin"
          "kxmlgui5"
          "libkunitconversion"
          "plasma"
          "plasmashell"
          "remoteview"
          "sddm"
          "systemmonitorrc"
          "systemsettings"
        ];

    files = [
      ".gtkrc-2.0" # kde-gtk-config
      ".directory" # Dolphin
    ]
    ++ map config.lib.somasis.xdgConfigDir [
      "KDE/kunifiedpush-distributor.conf"
      "KDE/kjournald.conf"
      "KDE/UserFeedback.conf"
      "KDE/Sonnet.conf"

      "QtProject.conf"
      "Trolltech.conf"
      "baloofileinformationrc"
      "gwenviewrc"
      "partitionmanagerrc"
      "xdg-desktop-portal-kderc"
      "gtkrc"
      "gtkrc-2.0"
      "baloofilerc"
      "bluedevilglobalrc"
      "bluedevilreceiverrc"
      "plasma-nm"
      "krunnerrc"
      "filetypesrc"
      "device_automounter_kcmrc"
      "dolphinrc"
      "drkonqirc"
      "kactivitymanagerd-statsrc"
      "kactivitymanagerdrc"
      "kcminputrc"
      "kconf_updaterc"
      "kded5rc"
      "kdeglobals"
      "kglobalshortcutsrc"
      "kiorc"
      "kioslaverc"
      "klipperrc"
      "kscreenlockerrc"
      "kservicemenurc"
      "ksmserverrc"
      "ktimezonedrc"
      "ktrashrc"
      "kwalletrc"
      "kwinoutputconfig.json"
      "kwinrc"
      "kxkbrc"
      "plasma-localerc"
      "plasma-org.kde.plasma.desktop-appletsrc"
      "plasmanotifyrc"
      "plasmaparc"
      "plasmarc"
      "plasmashellrc"
      "powerdevilrc"
      "powermanagementprofilesrc"
      "spectaclerc"
      "systemsettingsrc"
      "trashrc"
    ]
    ++ map config.lib.somasis.xdgDataDir [
      "user-places.xbel"
    ];
  };

  cache = {
    directories = [
      (config.lib.somasis.xdgCacheDir "kcrash-metadata")
    ]
    ++
      map
        (x: {
          directory = config.lib.somasis.xdgCacheDir x;
          method = "symlink";
        })
        [
          "drkonqi"
          "elisa"
          "fontconfig"
          "kio_http"
          "krunner"
          "kscreenlocker_greet"
          "kwin"
          "mesa_shader_cache"
          "mesa_shader_cache_db"
          "obexd"
          "org.kde.ki18n"
          "org.kde.unitconversion"
          "plasma_engine_potd"
          "plasmashell"
          "systemsettings"
          "thumbnails"
          "xwaylandvideobridge"
        ];

    files = map config.lib.somasis.xdgDataDir [
      "krunnerstaterc"
    ];
  };

  log = {
    files = map config.lib.somasis.xdgDataDir [
      "qtposition-geoclue2"
      # "recently-used.xbel"
    ];
  };

  sync = {
    directories =
      map
        (x: {
          method = "symlink";
          directory = config.lib.somasis.xdgConfigDir x;
        })
        [
          "panel-colorizer"
        ]
      ++
        map
          (x: {
            method = "symlink";
            directory = config.lib.somasis.xdgDataDir x;
          })
          [
            "color-schemes"
          ];

    files = map config.lib.somasis.xdgConfigDir [
      "breezerc"
      "kwinrulesrc"
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
      ksystemlog
      kweather
      lokalize

      pdfarranger

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

      qtbase # qdbus, among other things

      syncplay

      waypipe
      wl-clipboard

      krunner-pass-unstable
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
