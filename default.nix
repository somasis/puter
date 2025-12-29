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

  treefmt ? import ./treefmt.nix,
  ...
}@args:
let
  nixos =
    nixpkgs: configuration:
    import "${nixpkgs}/nixos" {
      inherit configuration;

      # Ensure that `system` is not determined impurely.
      system = null;

      specialArgs = {
        inherit nixpkgs self;
        sources =
          with builtins;
          with lib;
          mapAttrs (_: v: v { pkgs = import nixpkgs { }; }) (
            # Required since lockfile ver. 5.
            removeAttrs sources [ "__functor" ]
          );
      };
    };

  gitHooksPkg = (import git-hooks).run (import ./git-hooks.nix args);
in
{
  inherit sources self;

  description = "https://github.com/somasis/puter";

  # Allow for using "${self}" to get the project path.
  outPath = ./.;

  lib = import ./lib.nix;

  nixosModules = {
    default = import ./modules/nixos;

    # keep-sorted start
    defaults = import ./modules/nixos/defaults;
    impermanence = import ./modules/nixos/impermanence.nix;
    lib = import ./modules/lib.nix;
    meta = import ./modules/nixos/meta.nix;
    npins = import ./modules/nixos/npins.nix;
    theme = import ./modules/nixos/theme.nix;
    # keep-sorted end

    sensible-defaults = builtins.trace "nixosModules.sensible-defaults was renamed to nixosModules.defaults" (
      import ./modules/nixos
    );
  };

  homeManagerModules = {
    default = import ./modules/home-manager;

    # keep-sorted start
    catgirl = import ./modules/home-manager/programs/catgirl.nix;
    impermanence = import ./modules/home-manager/impermanence.nix;
    lib = import ./modules/lib.nix;
    stw = import ./modules/home-manager/services/stw.nix;
    tunnels = import ./modules/home-manager/services/tunnels.nix;
    xsecurelock = import ./modules/home-manager/services/xsecurelock.nix;
    xssproxy = import ./modules/home-manager/services/xssproxy.nix;
    zotero = import ./modules/home-manager/programs/zotero.nix;
    # keep-sorted end
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

  nixosConfigurations = {
    ilo = nixos sources.nixos-unstable ./hosts/ilo.somas.is;
    majuna = nixos sources.nixos-unstable ./hosts/majuna;
  };
}
