{ lib
, config
, ...
}:
let
  steamLibrary = "/var/lib/steam";
in
lib.optionalAttrs config.programs.steam.enable {
  persist.directories = [{
    mode = "6775";
    user = "root";
    group = "root";
    directory = steamLibrary;
  }];

  systemd.tmpfiles.rules = [
    "A ${steamLibrary} - - - - user::rwx"
    "A ${steamLibrary} - - - - group::r-x"
    "A ${steamLibrary} - - - - group:users:rwx"
    "A ${steamLibrary} - - - - mask::rwx"
    "A ${steamLibrary} - - - - other::r-x"
    "A ${steamLibrary} - - - - default:user::rwx"
    "A ${steamLibrary} - - - - default:group::r-x"
    "A ${steamLibrary} - - - - default:group:users:rwx"
    "A ${steamLibrary} - - - - default:mask::rwx"
    "A ${steamLibrary} - - - - default:other::r-x"
  ];
}
