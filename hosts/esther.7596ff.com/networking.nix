{ config
, pkgs
, self
, ...
}:
{
  age.secrets = {
    cassie-htpasswd-media = {
      file = "${self}/secrets/cassie-htpasswd-media.age";
      owner = "nginx";
      group = "nginx";
    };
    cassie-htpasswd-zotero = {
      file = "${self}/secrets/cassie-htpasswd-zotero.age";
      owner = "nginx";
      group = "nginx";
    };
  };

  networking = {
    hostName = "esther";
    domain = "7596ff.com";

    # The firewall is largely unnecessary on this machine,
    # because it is already behind a firewall provided by
    # the router, and anything which needs to be accessible
    # outside of the machine is port forwarded as necessary.
    # firewall.enable = false;
    # FIXME "evaluation warning: fail2ban can not be used without a firewall"

    firewall = {
      allowedTCPPorts = [
        80 # nginx
        443 # nginx
      ];
      allowedUDPPorts = [
        80 # nginx
        443 # nginx
      ];
    };

    networkmanager = {
      enable = true;
      plugins = [ pkgs.networkmanager-openvpn ];
    };

    interfaces.enp42s0.wakeOnLan = {
      enable = true;
      policy = [
        "magic"
        "phy"
      ];
    };
  };

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez5-experimental;

    settings.General.Name = config.networking.fqdnOrHostName;
  };

  persist.directories = [
    "/var/lib/bluetooth"

    "/etc/NetworkManager/system-connections"
    "/var/lib/NetworkManager"

    "/var/lib/acme"
  ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "cassie@7596ff.com";
      webroot = "/var/lib/acme/acme-challenge";
    };
  };

  users.users.nginx.extraGroups = [ "cassie" ];

  services.nginx = {
    enable = true;

    virtualHosts."esther.7596ff.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/media" = {
        root = "/mnt/raid/cassie";

        basicAuthFile = config.age.secrets.cassie-htpasswd-media.path;

        extraConfig = ''
          allow all;
          autoindex on;
          client_body_temp_path /tmp;
          client_max_body_size 0;
          create_full_put_path on;
          dav_access user:rw group:rw all:rw;
          dav_ext_methods PROPFIND OPTIONS;
          dav_methods PUT DELETE MKCOL COPY MOVE;
          sendfile on;
        '';
      };

      locations."/airsonic" = {
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.airsonic.port}/airsonic";
      };

      locations."/zotero" = {
        root = "/mnt/raid/cassie";

        basicAuthFile = config.age.secrets.cassie-htpasswd-zotero.path;

        extraConfig = ''
          allow all;
          autoindex on;
          client_body_temp_path /tmp;
          client_max_body_size 0;
          create_full_put_path on;
          dav_access group:rw all:r;
          dav_ext_methods PROPFIND OPTIONS;
          dav_methods PUT DELETE MKCOL COPY MOVE;
          sendfile on;
        '';
      };
    };

    virtualHosts."sonarr.7596ff.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8989/";

        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $http_connection;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_read_timeout 1200s;
          proxy_connect_timeout 1200s;
        '';
      };
    };

    virtualHosts."radarr.7596ff.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:7878/";

        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $http_connection;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_read_timeout 300s;
          proxy_connect_timeout 300s;
        '';
      };
    };

    virtualHosts."lidarr.7596ff.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8686/";

        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $http_connection;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_read_timeout 300s;
          proxy_connect_timeout 300s;
        '';
      };
    };
  };

  services.fail2ban = {
    enable = true;

    bantime = "5m";
    bantime-increment = {
      # For repeat bans, increment ban time (default is to double the bantime
      # for repeat offenses).
      enable = true;

      # Search all jails for determining how many bans an IP has accrued.
      overalljails = true;

      # Randomize ban time slightly.
      rndtime = "2m";

      # Maximum ban time is a day.
      maxtime = "24h";
    };

    ignoreIP = [
      # Don't ban any IPs on the local network
      "192.168.0.0/16"
    ];
  };
}
