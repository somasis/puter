{ config
, lib
, ...
}:
let
  inherit (lib) optional;
  inherit (lib.options) mkOption types;

  pre = config.presets;

  mkPresetOption =
    description: options:
    mkOption {
      inherit description;
      default = null;
      type = with types; nullOr enum options;
    };

  importPreset =
    presetOpt: presetCfg: presetPath:
    optional (presetCfg != null) "${presetPath}/${presetCfgValue}.nix";
in
{
  options.presets = {
    programs.terminal = mkPresetOption "Terminal preset" [
      "kitty"
      "alacritty"
      "xterm"
    ];
  };

  config = {
    imports = importPreset pre.terminal ./programs/terminal;
  };
}
