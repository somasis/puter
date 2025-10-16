{
  config,
  lib,
  pkgs,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  radiotrayConfig = {
    bookmarks = "${config.xdg.dataHome}/radiotray-ng/bookmarks.json";

    notifications = true;
    notifications-verbose = false;

    split-title = true;
    track-info-copy = true;

    volume-level = 50;
  };

  radiotrayConfigFile = jsonFormat.generate "radiotray-ng.json" radiotrayConfig;

  radiotrayPkg = pkgs.radiotray-ng;
in
{
  home = {
    packages = [ radiotrayPkg ];

    # Merge radiotray-ng's configuration at activation time, so that
    activation.merge-radiotray-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! [[ -v DRY_RUN ]]; then
          config_path=${lib.escapeShellArg config.xdg.configHome}/radiotray-ng/radiotray-ng.json
          default_config=${lib.escapeShellArg radiotrayConfigFile}

          if ! [[ -s "$config_path" ]]; then
              touch "$config_path"
              printf '{}' > "$config_path"
          fi

          merged_config=$(${pkgs.jq}/bin/jq -s '.[0] // .[1]' "$default_config" "$config_path")

          printf '%s' "$merged_config" > "$config_path"
      fi
    '';
  };

  persist.directories = [
    (config.lib.somasis.xdgConfigDir "radiotray-ng")
  ];

  sync.directories = [
    (config.lib.somasis.xdgDataDir "radiotray-ng")
  ];

  xdg.autostart.entries = [
    "${radiotrayPkg}/etc/xdg/autostart/radiotray-ng.desktop"
  ];
}
