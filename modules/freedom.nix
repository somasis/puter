# Don't allow unfree stuff *too* easily--come on, have some principles.
# ...except video games, I guess.
{
  config,
  osConfig ? { },
  lib,
  ...
}:
{
  options.nixpkgs.allowUnfreePackages = lib.mkOption {
    type = with lib.types; listOf nonEmptyStr;
    default = [ ];
    description = ''
      Names of unfree packages to allow. This option exists to allow
      automating a common usage of `nixpkgs.allowUnfreePredicate`.
    '';
  };

  # mkDefault is used so that allowUnfreePredicate can just be overriden easily.
  config = lib.mkIf (config.nixpkgs.allowUnfreePackages != [ ]) {
    nixpkgs.config.allowUnfreePredicate = lib.mkDefault (
      pkg:
      builtins.elem (lib.pipe pkg [
        lib.getName
        (lib.removeSuffix "-unwrapped")
      ]) ((osConfig.nixpkgs.allowUnfreePackages or [ ]) ++ config.nixpkgs.allowUnfreePackages)
    );
  };
}
