{
  lib,
  config,
  ...
}:
let
  inherit (config.lib.somasis) mkColorOption;
in
import ../heme.nix {
  inherit lib config;

  mkThemeColorOption =
    name: default:
    mkColorOption {
      format = "hex";
      inherit default;
    };
}
