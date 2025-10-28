# $ nix repl -f .
{
  sources ? (import ./npins),
  self ? (import ./. { }),

  system ? (builtins.currentSystem or null),

  pkgs ? (import sources.nixpkgs { inherit system; }),
  lib ? pkgs.lib,

  treefmt-nix ? (import sources.treefmt-nix),
  ...
}@args:
let
  nixos =
    nixpkgs: configuration:
    import "${nixpkgs}/nixos/lib/eval-config.nix" {
      modules = [ configuration ];

      # Ensure that `system` is not determined impurely.
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
      unstable = import sources.nixos-unstable { inherit (final) system; };
      stable = import sources.nixos-stable { inherit (final) system; };
      dev = import sources.nixpkgs { inherit (final) system; };
    };
  };

  checks =
    # Allow for overriding pkgs. See ./flake.nix for how we actually turn
    # this back into a pure evaluation that follows the Flakes schema.
    {
      pkgs ? args.pkgs,
      ...
    }:
    {
      formatting = (treefmt-nix.evalModule pkgs ./treefmt.nix).config.build.check self.outPath;
    };

  formatter =
    {
      pkgs ? args.pkgs,
      ...
    }:
    (treefmt-nix.evalModule pkgs ./treefmt.nix).config.build.wrapper;

  packages =
    {
      pkgs ? args.pkgs,
      ...
    }@args:
    import ./pkgs/default.nix args;

  devShells =
    {
      pkgs ? args.pkgs,
      ...
    }@args:
    {
      default = import ./shell.nix args;
    };

  nixosConfigurations.ilo = nixos sources.nixos-unstable ./hosts/ilo.somas.is;
}
