{
  description = "Compatibility layer for using https://github.com/somasis/puter as a Flake";

  # We can't translate our npins sources to `inputs` because `inputs`
  # has to be a set, it cannot require any evaluation under Flakes.
  inputs = { };

  outputs =
    {
      self ? (builtins.toString ./.),
      ...
    }@flakeArgs:
    let
      sources = flakeArgs.sources or (import "${self}/npins");
      nixpkgs = flakeArgs.nixpkgs or sources.nixpkgs;
      lib = import "${nixpkgs}/lib";

      defaultNix = import ./default.nix;

      nixpkgsForSystem =
        system:
        import nixpkgs {
          # There's some unfree packages in ./pkgs, and no widely used
          # practice for letting the user set allowUnfree in Flake usage.
          config.allowUnfree = true;
          localSystem.system = system;
        };

      # Iterate over an attribute set from the ./default.nix, passing an
      # imported `pkgs` argument to each attribute value for each system
      # exposed to Flakes.
      asSystemAttrs =
        thingToEval: attr: args:
        lib.genAttrs lib.systems.flakeExposed (
          system: (thingToEval (args // { pkgs = nixpkgsForSystem system; })).${attr}
        );
    in
    # devShells are removed in Flake mode because they need to use git-hooks.
    (builtins.removeAttrs (defaultNix flakeArgs) [ "devShells" ])
    // {
      # NOTE Checks from git-hooks aren't available through Flakes because
      # the way we use them, they require impurity.
      checks = asSystemAttrs defaultNix "checks" { };
      # devShells = asSystemAttrs defaultNix "devShells" { };

      # Make `nix fmt` work.
      formatter = asSystemAttrs defaultNix "formatter" { };

      packages = asSystemAttrs defaultNix "packages" {
        # Flake `packages` cannot be functions or attrsets; only derivations.
        omitFunctions = true;
        omitAttrsets = true;
      };
    };
}
