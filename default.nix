# $ nix repl -f .
{
  sources ? (import ./npins),
  self ? (import ./. { }),

  system ? (builtins.currentSystem or null),

  nixpkgs ? sources.nixpkgs,

  pkgs ? (import nixpkgs { inherit system; }),
  lib ? pkgs.lib,

  git-hooks ? sources.git-hooks,
  treefmt-nix ? sources.treefmt-nix,
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

  treefmt = (import treefmt-nix).evalModule pkgs ./treefmt.nix;
  gitHooksPkg = (import git-hooks).run (import ./git-hooks.nix args);
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
    defaults = import ./modules/nixos/defaults;
    theme = import ./modules/nixos/theme.nix;
  };

  homeManagerModules = {
    default = import ./modules/home-manager;
    lib = import ./modules/lib.nix;
  };

  overlays = {
    default = import ./overlay.nix;
    nixpkgsVersions = final: prev: {
      unstable = import sources.nixos-unstable { inherit (final.stdenv.hostPlatform) system; };
      stable = import sources.nixos-stable { inherit (final.stdenv.hostPlatform) system; };
      dev = import sources.nixpkgs { inherit (final.stdenv.hostPlatform) system; };
    };
  };

  formatter = treefmt.config.build.wrapper;

  checks = {
    formatting = treefmt.config.build.check self.outPath;
  }
  # FIXME? Hide git-hooks from pure eval Nix, since it requires impurity
  # because of git-hooks.nix' usage of builtins.currentSystem in their
  # vendored flake-compat ./default.nix.
  // (if builtins ? "currentSystem" then { pre-commit = gitHooksPkg; } else { });

  devShells.default = import ./shell.nix args;

  packages = import ./pkgs args;

  nixosConfigurations.ilo = nixos sources.nixos-unstable ./hosts/ilo.somas.is;
}
