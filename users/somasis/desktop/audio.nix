{ config
, pkgs
, ...
}:
{
  home.packages = [
    pkgs.ponymix

    (pkgs.writeShellScriptBin "ponymix-snap" ''
      snap=5
      [ "$FLOCKER" != "$0" ] \
          && export FLOCKER="$0" \
          && exec flock -n "$0" "$0" "$@"

      ${pkgs.ponymix}/bin/ponymix "$@"
      b=$(${pkgs.ponymix}/bin/ponymix --short get-volume)
      c=$((b - $((b % snap))))
      ${pkgs.ponymix}/bin/ponymix --short set-volume "$c" >/dev/null
    '')
  ];

  cache.directories = [ (config.lib.somasis.xdgConfigDir "pulse") ];
}
