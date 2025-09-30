{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.lib.somasis) randomPort;

  seed = host: "${config.home.username}@${host}";
  syncthingGuiPortFor = host: randomPort ''${seed host}:syncthing-gui'';
  syncthingGuiPort = syncthingGuiPortFor osConfig.networking.fqdnOrHostName;
in
{
  services.syncthing = {
    enable = true;
    extraOptions = [
      "--gui-address=http://127.0.0.1:${toString syncthingGuiPort}"
      "--no-port-probing"
    ];

    tray = {
      enable = true;
      package = pkgs.syncthingtray-qt6;
    };
  };

  # The service conflicts with the Plasma applet.
  systemd.user.services.syncthingtray.Install.WantedBy = lib.mkForce [ ];

  persist.files = [
    (config.lib.somasis.xdgConfigDir "syncthingtray.ini")
    (config.lib.somasis.xdgConfigDir "syncthingfileitemaction.ini")
  ];
}
