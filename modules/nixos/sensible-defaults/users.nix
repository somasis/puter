{ config
, lib
, ...
}:
{
  users.users.root = {
    home = "/root";
    createHome = true;
  };

  persist = {
    users.root.home = "/root";

    directories =
      [
        # Used for keeping declared users' UIDs and GIDs consistent across boots.
        {
          directory = "/var/lib/nixos";
          user = "root";
          group = "root";
          mode = "0755";
        }
      ]
      ++ lib.optional config.services.accounts-daemon.enable {
        directory = "/var/lib/AccountsService";
        mode = "0775";
      };
  };
}
