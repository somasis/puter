let
  steamLibrary = "/var/lib/steam";
in
{
  persist.directories = [{
    mode = "3775";
    user = "nobody";
    group = "users";
    directory = steamLibrary;
  }];

  systemd.tmpfiles.rules = [
    "A ${steamLibrary} - - - - default:user:cassie:rwX"
    "A ${steamLibrary} - - - - default:user:somasis:rwX"
    "A ${steamLibrary} - - - - default:other::rw"
  ];
}
