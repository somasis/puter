# $ nix repl -f .
{
  sources ? (import ./npins),
  self ? (import ./. { }),

  pkgs ? (import sources.nixpkgs { }),
  lib ? pkgs.lib,
  ...
}:
let
  nixos =
    nixpkgs: configuration:
    import "${nixpkgs}/nixos/lib/eval-config.nix" {
      modules = [ configuration ];
      system = null;
      specialArgs = {
        inherit nixpkgs self sources;
        modulesPath = "${nixpkgs}/nixos/modules";
      };
    };
in
{
  inherit sources self;

  # Allow for using "${self}" to get the project path.
  outPath = ./.;

  lib = import ./lib.nix;

  nixosModules = {
    default = import ./modules/nixos;
    impermanence = import ./modules/nixos/impermanence.nix;
    lib = import ./modules/lib.nix;
    meta = import ./modules/nixos/meta.nix;
    npins = import ./modules/nixos/npins.nix;
    sensible-defaults = import ./modules/nixos/sensible-defaults;
    theme = import ./modules/nixos/theme.nix;
  };

  homeManagerModules = {
    default = import ./modules/home-manager;
    lib = import ./modules/lib.nix;
  };

  overlays = {
    default = import ./overlay.nix;
    nixpkgsVersions = final: prev: {
      unstable = import sources.nixos-unstable { };
      stable = import sources.nixos-stable { };
      dev = import sources.nixpkgs { };
    };
  };

  nixosConfigurations.ilo = nixos sources.nixos-unstable ./hosts/ilo.somas.is;
}
