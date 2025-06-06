{
  config,
  pkgs,
  self,
  ...
}:
let
  rarbg-selfhosted = pkgs.callPackage (
    {
      lib,
      buildGoModule,
      fetchFromGitHub,
    }:
    buildGoModule rec {
      pname = "rarbg-selfhosted";
      version = "0.0.5";

      src = fetchFromGitHub {
        owner = "mgdigital";
        repo = "rarbg-selfhosted";
        rev = "v${version}";
        hash = "sha256-4eVdyMZSh+s8eXhtbC9CDBPRcbpzeteruq3FA3jw6Yc=";
      };

      vendorHash = "sha256-xA4o977hm8gSbMJrWTbaLWWM/EUXyuXInUvcKl/Z8YY=";

      ldflags = [
        "-s"
        "-w"
      ];

      meta = with lib; {
        description = "A self-hosted Torznab API for the RARBG backup, compatible with Prowlarr, Radarr, Sonarr etc";
        homepage = "https://github.com/mgdigital/rarbg-selfhosted";
        license = licenses.unfree; # FIXME: nix-init did not found a license
        maintainers = with maintainers; [ somasis ];
        mainProgram = "rarbg-selfhosted";
      };
    }
  ) { };
  # whatmp3 = pkgs.callPackage ({ lib, buildPythonPackage, fetchFromGithub }: buildPythonPackage rec {
  #   name = "whatmp3";
  #   version = "3.9";

  #   src = fetchFromGithub {
  #     owner = "RecursiveForest";
  #     repo = "whatmp3";
  #     rev = "v${version}";
  #     hash = lib.fakeHash;
  #   };

in
#   propagatedBuildInputs = [ pkgs.flac pkgs.lame ];
# }) {};
{
  age.secrets = {
    cassie-beets-musicbrainz-password.file = "${self}/secrets/cassie-beets-musicbrainz-password.age";
    cassie-transmission.file = "${self}/secrets/cassie-transmission.json.age";
    cassie-openvpn-galileo.file = "${self}/secrets/cassie-openvpn-galileo.ovpn.age";
  };

  persist.directories = [
    "/var/lib/airsonic"
    "/var/lib/sonarr"
    "/var/lib/radarr"
    {
      directory = "/var/lib/minecraft";
      user = "minecraft";
      group = "minecraft";
    }
  ];

  environment.systemPackages = [
    rarbg-selfhosted
    pkgs.rclone
    pkgs.tsocks
  ];

  networking.firewall.allowedTCPPorts = [
    4040
    9990
    8977
  ];

  services.airsonic = {
    enable = true;

    maxMemory = 2048;
    port = 4040;
    listenAddress = "0.0.0.0";

    jvmOptions = [
      "-Dserver.context-path=/airsonic"
    ];
  };

  # services.gonic = {
  #   enable = true;
  #   settings = {
  #     music-path = [
  #       "/mmy/raid/cassie/media/music/flac2"
  #     ];
  #   };
  # };

  users.users.airsonic.extraGroups = [ "cassie" ];

  services.sonarr = {
    enable = true;

    user = "cassie";
    group = "cassie";
    openFirewall = true;
  };

  services.radarr = {
    enable = true;

    user = "cassie";
    group = "cassie";
    openFirewall = true;
  };

  services.lidarr = {
    enable = true;

    user = "cassie";
    group = "cassie";
  };

  systemd.services."rarbg-selfhosted" = {
    enable = true;

    after = [ "network.target" ];
    description = "Hosts the Rarbg DB as a Torznab-compatible service";
    script = "${rarbg-selfhosted}/bin/rarbg-selfhosted";

    environment = {
      PATH_SQLITE_DB = "/home/cassie/Downloads/rarbg_db.sqlite";
      PATH_TRACKERS = "/home/cassie/Downloads/trackers.txt";
    };

    serviceConfig = {
      WorkingDirectory = "/home/cassie";
    };

    upheldBy = [
      "sonarr.service"
      "radarr.service"
    ];
  };

  fileSystems."/mnt/galileo" = {
    device = "cassie@galileo.whatbox.ca:/home/cassie/files";
    fsType = "sshfs";
    options = [
      "nodev"
      "noatime"
      "_netdev"
      "allow_other"
      "dir_cache=yes"
      "ServerAliveInterval=15"
      "IdentityFile=/home/cassie/.ssh/id_ed25519"
      "StrictHostKeyChecking=no"
    ];
  };

  services.prometheus = {
    enable = false;

    port = 9990;

    scrapeConfigs = [
      {
        job_name = "prometheus";
        scrape_interval = "5s";
        static_configs = [
          { targets = [ "localhost:9990" ]; }
        ];
      }
    ];
  };

  services.transmission = {
    enable = false;

    user = "cassie";
    group = "cassie";

    openRPCPort = true;
    openFirewall = true;

    credentialsFile = config.age.secrets.cassie-transmission.path;

    settings = {
      blocklist-enabled = true;
      blocklist-url = "https://raw.githubusercontent.com/Naunter/BT_BlockLists/master/bt_blocklists.gz";

      download-dir = "/mnt/raid/cassie/media";
      download-queue-size = 2;

      incomplete-dir-enabled = true;
      incomplete-dir = "/mnt/raid/cassie/media/incomplete";

      lpd-enabled = true;

      rpc-enabled = true;
      rpc-authentication-required = true;
      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;
      rpc-whitelist-enabled = false;

      speed-limit-down = 50;
      speed-limit-up = 5;
      upload-slots-per-torrent = 4;

      alt-speed-down = 25;
      alt-speed-up = 1;
    };
  };

  services.minecraft-server = {
    enable = false;
    eula = true;
    openFirewall = true;
    jvmOpts = "-Xmx8192M -Xms2048M";

    package =
      let
        version = "1.21.3";
        url = "https://piston-data.mojang.com/v1/objects/45810d238246d90e811d896f87b14695b7fb6839/server.jar";
        sha256 = "e153b89b02c0839cdf5e8c1d57c80dd42a3fffb80c60817632080c041bf8afb5";
      in
      pkgs.minecraft-server.overrideAttrs (old: rec {
        name = "minecraft-server-${version}";
        inherit version;

        src = pkgs.fetchurl {
          inherit url sha256;
        };
      });
  };

  services.openvpn.servers = {
    galileo = {
      autoStart = false;
      config = ''config = "config ${config.age.secrets.cassie-openvpn-galileo.path}"'';
    };
  };

  # NOTE(somasis) Create a symbolic link at /srv/http/media that points to /mnt/raid/cassie/media.
  systemd.tmpfiles.settings.http = {
    "/srv/http/media".L.argument = "/mnt/raid/cassie/media";
  };

  programs.obs-studio = {
    enable = true;
  };
}
