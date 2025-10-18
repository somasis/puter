{
  pkgs,
  config,
  ...
}@args:
{
  config.lib.somasis = import ../lib.nix args;
}
