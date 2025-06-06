{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.lib.somasis) randomPort;

  seed = host: "${config.home.username}@${host}";

  syncthingGuiPortFor = host: randomPort ''${seed host}:syncthing-gui'';
  syncthingListenPortFor = host: randomPort ''${seed host}:syncthing-listen'';

  syncthingGuiPort = syncthingGuiPortFor osConfig.networking.fqdnOrHostName;
in
# assert (
#   if osConfig.networking.firewall.enable then
#     (lib.elem syncthingGuiPort osConfig.networking.firewall.allowedTCPPorts) &&
#     (lib.elem syncthingListenPort osConfig.networking.firewall.allowedTCPPorts) &&
#     (lib.elem syncthingListenPort osConfig.networking.firewall.allowedUDPPorts) &&
#     (lib.elem syncthingLocalAnnouncePort osConfig.networking.firewall.allowedUDPPorts)
#   else
#     true
# );
{
  services.tunnels.tunnels = {
    "somasis@esther.7596ff.com:syncthing" = rec {
      name = "syncthing";
      remote = "somasis@esther.7596ff.com";
      port = syncthingGuiPortFor remote;
    };

    "somasis@esther.7596ff.com:syncthing-data" = rec {
      name = "syncthing-data";
      remote = "somasis@esther.7596ff.com";
      port = syncthingListenPortFor remote;
    };

    "somasis@ariel.whatbox.ca:syncthing" = {
      name = "syncthing";
      remote = "somasis@ariel.whatbox.ca";
      port = 10730;
    };

    "somasis@ariel.whatbox.ca:syncthing-data" = {
      name = "syncthing-data";
      remote = "somasis@ariel.whatbox.ca";
      port = 29581;
    };
  };

  # NOTE(somasis) services.syncthing will have declarative
  # device and folder settings like NixOS in home-manager >=24.11.
  services.syncthing = {
    enable = true;

    # guiAddress = "https://0.0.0.0:${toString syncthingGuiPort}";
    extraOptions = [
      "--gui-address=http://127.0.0.1:${toString syncthingGuiPort}"
      "--skip-port-probing"
    ];

    # settings = {
    #   options = {
    #     listenAddresses = [
    #       "tcp://0.0.0.0:${toString syncthingListenPort}"
    #       "quic://0.0.0.0:${toString syncthingListenPort}"
    #       "dynamic+https://relays.syncthing.net/endpoint"
    #     ];
    #     localAnnouncePort = systemSyncthingLocalAnnouncePort;
    #   };
    #
    #   folders = {
    #     "${sync.persistentStoragePath}" = {
    #       options = {
    #         # Watch files for changes on a 60 second accumulation cycle,
    #         fsWatcherEnabled = true;
    #         fsWatcherDelayS = 60;
    #         # and at most allow 5 minutes between syncs.
    #         fsWatcherTimeoutS = 300;
    #       };
    #     };
    #
    #   devices = lib.mkMerge [
    #     osConfig.services.syncthing.devices
    #     {
    #       "somasis@ilo.somas.is".id = "OQG653K-5UFOPID-3TJULNJ-IORJSOB-3L7OISV-75MFQ62-W5QDEZJ-COJHXA7";
    #       "somasis@esther.7596ff.com" = rec {
    #         id = "P3ENKXP-WFL6CCI-ZT4EFP3-JJZVHFI-GOYW2XH-JB3E6D3-JSSJ5CH-KS7W2QG";
    #         options.addresses =
    #           let t = config.services.tunnels.tunnels."${name}:syncthing-data"; in [
    #             "dynamic"
    #             "tcp://esther.7596ff.com:${toString (syncthingListenPortFor name)}"
    #             "quic://esther.7596ff.com:${toString (syncthingListenPortFor name)}"
    #             "tcp://localhost:${toString t.port}"
    #             "quic://localhost:${toString t.port}"
    #           ];
    #       };

    #       "lili.somas.is".id = "ZJ2ZCFK-UYG6BFA-ZYNF4HY-J6NVT25-LKJRV4U-DLM3XRP-LOTQKDW-NZBPOQP";

    #       "somasis@ariel.whatbox.ca" = rec {
    #         id = "IKC4NUE-OMC5A3L-33SFLBV-PPVO5R6-ETMFVSM-BS62MGQ-7XYB7RL-YCCDJA7";
    #         options.addresses =
    #           let t = config.services.tunnels.tunnels."${name}:syncthing-data"; in [
    #             "dynamic"
    #             "tcp://ariel.whatbox.ca:${toString t.remotePort}"
    #             "quic://ariel.whatbox.ca:${toString t.remotePort}"
    #             "tcp://localhost:${toString t.port}"
    #             "quic://localhost:${toString t.port}"
    #           ];
    #       };
    #     }
    #   ];
    # };

    tray = {
      enable = false;
      package = pkgs.syncthingtray-qt6; # Provide Plasma widget
    };
  };

  home.packages = [ config.services.syncthing.tray.package ];

  persist.files = [
    (config.lib.somasis.xdgConfigDir "syncthingtray.ini")
    (config.lib.somasis.xdgConfigDir "syncthingfileitemaction.ini")
  ];
}
