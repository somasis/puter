{
  config,
  pkgs,
  lib,
  ...
}:
let
  keepassKeyFile = "${config.xdg.configHome}/keepassxc/keepassxc.keyx";
  keepassDatabaseFile = "${config.home.homeDirectory}/sync/keepassxc.kdbx";

  keepass =
    subcommand:
    {
      database ? keepassDatabaseFile,
      extraArgs ? [ ],
      ...
    }@args:
    lib.concatStringsSep " " (
      [
        "keepassxc-cli"
        subcommand
      ]
      ++ lib.cli.toGNUCommandLine { } (
        {
          key-file = keepassKeyFile;
          no-password = true;
        }
        // lib.removeAttrs args [
          "database"
          "extraArgs"
        ]
      )
      ++ [
        (lib.escapeShellArg database)
        (lib.escapeShellArgs extraArgs)
      ]
    );
in
{
  persist = with config.lib.somasis; {
    directories = [
      (xdgConfigDir "keepassxc")
    ];

    files = [
      (xdgConfigDir "KeePassXCrc")
    ];
  };

  cache = with config.lib.somasis; {
    directories = [
      (xdgCacheDir "keepassxc")
    ];
  };

  home.packages =
    with pkgs;
    with kdePackages;
    [
      # keep-sorted start
      keepassxc
      libsecret
      rofi # used by qute-keepassxc
      # keep-sorted end
    ];

  xdg.autostart.entries = [
    # Start with database unlocked and window minimized.
    (
      pkgs.makeDesktopItem {
        name = "keepassxc";
        desktopName = "KeepassXC";
        icon = "keepassxc";
        exec = "/usr/bin/env keepassxc --minimized --keyfile ${keepassKeyFile} ${keepassDatabaseFile}";
      }
      + "/share/applications/keepassxc.desktop"
    )
  ];

  home.sessionVariables = {
    # Used by `bin/phishin-auth-login`, among other things.
    PHISHIN_USER_EMAIL_COMMAND = keepass "show" {
      attributes = "username";
      extraArgs = [ "/www/Phish.in" ];
    };
    PHISHIN_USER_PASSWORD_COMMAND = keepass "show" {
      attributes = "password";
      extraArgs = [ "/www/Phish.in" ];
    };

    PHISHNET_SECRET_COMMAND = keepass "show" {
      attributes = "password";
      extraArgs = [ "/API keys/Phish.net" ];
    };
  };
}
