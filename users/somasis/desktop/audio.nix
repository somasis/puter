{ config
, pkgs
, ...
}:
{
  home.packages = with pkgs; [
    jamesdsp

    ponymix
    (writeShellScriptBin "ponymix-snap" ''
      snap=5
      [ "$FLOCKER" != "$0" ] \
          && export FLOCKER="$0" \
          && exec flock -n "$0" "$0" "$@"

      ${ponymix}/bin/ponymix "$@"
      b=$(${ponymix}/bin/ponymix --short get-volume)
      c=$((b - $((b % snap))))
      ${ponymix}/bin/ponymix --short set-volume "$c" >/dev/null
    '')
  ];

  cache.directories = [
    (config.lib.somasis.xdgConfigDir "pulse")
    (config.lib.somasis.xdgCacheDir "jamesdsp")
  ];

  persist.directories = [
    { method = "bindfs"; directory = config.lib.somasis.xdgConfigDir "jamesdsp"; }
  ];

  sync = {
    directories = [
      { method = "symlink"; directory = config.lib.somasis.xdgConfigDir "jamesdsp/irs"; }
      { method = "symlink"; directory = config.lib.somasis.xdgConfigDir "jamesdsp/liveprog"; }
      { method = "symlink"; directory = config.lib.somasis.xdgConfigDir "jamesdsp/presets"; }
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "jamesdsp/application.conf")
    ];
  };
}
