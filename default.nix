# $ nix repl -f .
{
  sources ? (import ./npins),
  self ? (import ./. {}),

  pkgs ? (import sources.nixpkgs { }),
  lib ? pkgs.lib,
  ...
}@args:
let
  nixos =
    nixpkgs:
    configuration:
    import "${nixpkgs}/nixos/lib/eval-config.nix" {
      modules = [ configuration ];
      specialArgs = {
        inherit nixpkgs self sources;
        modulesPath = "${nixpkgs}/nixos/modules";
      };
    };
in
{
  inherit self;

  # Allow for using "${self}" to get the project path.
  outPath = ./.;

  inherit sources;

  lib = import ./lib.nix;

  nixosModules = {
    default = import ./modules/nixos;
    lib = import ./modules/lib.nix;
    impermanence = import ./modules/nixos/impermanence.nix;
    sensible-defaults = import ./modules/nixos/sensible-defaults;
    meta = import ./modules/nixos/meta.nix;
    npins = import ./modules/nixos/npins.nix;
    theme = import ./modules/nixos/theme.nix;
  };

  homeManagerModules = {
    default = import ./modules/home-manager;
    lib = import ./modules/lib.nix;
  };

  overlay = import ./overlay.nix;

  overlays = {
    nixpkgsVersions = final: prev: {
      unstable = import sources.nixos {};
      stable = import sources.nixos-stable {};
      dev = import sources.nixpkgs {};
    };
  };

  nixosConfigurations.ilo = nixos sources.nixos ./hosts/ilo.somas.is;
}
