{
  description = "puter";

  inputs = {
    keys-github-somasis = {
      url = "https://github.com/somasis.keys";
      flake = false;
    };

    # NOTE Make sure to change on new releases!
    # See <https://nixos.org/manual/nixos/unstable/#sec-upgrading> for details
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # NOTE Make sure to change on new releases!
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    # We can use the nix-community version only when
    # <https://github.com/nix-community/flake-compat/issues/1>
    # is taken care of.
    # flake-compat.url = "github:nix-community/flake-compat";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    impermanence.url = "github:nix-community/impermanence";

    nixos-cli.url = "github:nix-community/nixos-cli";

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure Boot implementation.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Use a pre-built nix-index database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Non-flake content
    avatarSomasis = {
      # jq -nrR \
      #     --arg hash "$(printf '%s' 'kylie@somas.is' | md5sum | cut -d ' ' -f1)" \
      #     '"url = \"https://www.gravatar.com/avatar/\($hash)\";"'
      #     '
      flake = false;
      type = "file";
      url = "https://www.gravatar.com/avatar/a187e38560bb56f5231cd19e45ad80f6?s=512";
    };

    qutebrowser-zotero.flake = false;
    qutebrowser-zotero.url = "github:parchd-1/qutebrowser-zotero";
    plasma-pass.flake = false;
    plasma-pass.url = "git+https://invent.kde.org/plasma/plasma-pass.git";

    control-panel-for-twitter.flake = false;
    control-panel-for-twitter.url = "github:insin/control-panel-for-twitter";

    # Ad blocking lists
    adblockEasyList.flake = false;
    adblockEasyList.url = "github:thedoggybrad/easylist-mirror";
    adblockHosts.flake = false;
    adblockHosts.url = "github:StevenBlack/hosts";
    uAssets.flake = false;
    uAssets.url = "github:uBlockOrigin/uAssetsCDN";
  };

  outputs =
    {
      self,
      git-hooks,
      treefmt-nix,

      nixpkgs,
      nixpkgs-stable,
      nixpkgs-master,
      home-manager,
      nixos-hardware,

      agenix,
      lix-module,
      nixos-cli,
      disko,

      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      treefmt = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgsFor.${system}.pkgs {
          # See also <https://github.com/numtide/treefmt-nix/tree/main/programs>
          projectRootFile = "flake.nix";

          settings.formatter = {
            shellcheck.options = [
              "--external-sources"
            ];

            shfmt.options = [
              "--binary-next-line"
              "--case-indent"
            ];
          };

          programs = {
            # Format shell scripts
            shellcheck = {
              enable = true;
              excludes = [ "\.envrc" ];
            };
            shfmt = {
              enable = true;
              indent_size = 4;
            };

            # black.enable = true;
            clang-format.enable = true;

            deadnix = {
              enable = true;
              no-lambda-arg = true;
              no-lambda-pattern-names = true;
            };

            # Allow keeping certain lines sorted
            # <https://github.com/google/keep-sorted>
            keep-sorted.enable = true;

            nixfmt.enable = true;
            # oxipng.enable = true;
            # perltidy.enable = true;

            # Ensure formatting of CSS, HTML, and so on
            prettier.enable = true;

            # statix.enable = true;

            # typos.enable = true;
          };
        }
      );
      system = builtins.currentSystem or "x86_64-linux";

      # config.allowUnfree is set primarily so `nix flake check` doesn't get tripped up.
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );
    in
    {
      nixosModules = {
        default = ./modules/nixos;
        freedom = ./modules/freedom.nix;
        lib = ./modules/lib.nix;
        impermanence = ./modules/nixos/impermanence.nix;
        sensible-defaults = ./modules/nixos/sensible-defaults;
        meta = ./modules/nixos/meta.nix;
        theme = ./modules/nixos/theme.nix;
      };

      homeManagerModules = {
        default = ./modules/home-manager;
        freedom = ./modules/home-manager/freedom.nix;
        lib = ./modules/lib.nix;
      };

      overlays = {
        default = final: prev: lib.recursiveUpdate prev (import ./pkgs { pkgs = final; });

        nixpkgsVersions = final: prev: {
          stable = inputs.nixpkgs-stable.legacyPackages.${system};
          unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
          master = inputs.nixpkgs-master.legacyPackages.${system};
        };

        # Create an overlay from all flake inputs with packages.
        # pkgs.flakePackages.<input name>.package
        flakePackages = final: prev: {
          flakePackages =
            lib.mapAttrs' (inputName: input: lib.nameValuePair inputName input.packages.${system})
              (
                lib.filterAttrs (
                  _: inputValue: (inputValue ? packages.${system}) && (inputValue.packages.${system} != { })
                ) inputs
              );
        };
      };

      nixosConfigurations = {
        ilo = lib.nixosSystem {
          specialArgs = {
            inherit
              self
              inputs
              nixpkgs
              disko
              ;
          };
          modules = [ ./hosts/ilo.somas.is ];
        };
      };

      homeConfigurations.somasis = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor.${system};
        modules = [ ./users/somasis ];
      };

      packages = forAllSystems (
        system:
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) (
          import ./pkgs { pkgs = nixpkgsFor.${system}; }
        )
      );

      # Development environment
      checks = forAllSystems (system: {
        git-hooks = git-hooks.lib.${system}.run {
          src = ./.;

          hooks = {
            # Git style
            gitlint.enable = true;

            check-merge-conflicts.enable = true;

            # Nix-related hooks
            # FIXME: maybe statix is a little too harsh for pre-commit usage...
            # statix.enable = true; # Lint Nix code.

            # Ensure we don't have commit anything bad
            check-added-large-files.enable = true; # avoid committing binaries when possible
            check-executables-have-shebangs = {
              enable = true;
              excludes = [ ".+.desktop$" ];
            };

            check-shebang-scripts-are-executable.enable = true;
            check-vcs-permalinks.enable = true; # don't use version control links that could rot
            check-symlinks.enable = true; # dead symlinks specifically
            detect-private-keys.enable = true;

            # Ensure we actually follow our .editorconfig rules.
            # editorconfig-checker = {
            #   enable = true;
            #   types = lib.mkForce [ "text" ];

            #   # Disable max-line-length checks, since nixfmt doesn't always wrap lines exactly,
            #   # for example with long strings that go over the line but can't be wrapped easily.
            #   entry = "${pkgs.editorconfig-checker}/bin/editorconfig-checker -disable-max-line-length";
            # };

            # Ensure we don't have dead links in comments or whatever.
            # lychee.enable = true;

            # shellcheck.enable = true;

            treefmt = {
              enable = true;
              package = treefmt.${system}.config.build.wrapper;
            };
          };
        };

        formatting = treefmt.${system}.config.build.check self;
      });

      devShells = forAllSystems (
        system: with nixpkgsFor.${system}.pkgs; {
          default = mkShell {
            shellHook = self.checks.${system}.git-hooks.shellHook + ''
              # Used by nixos-cli.
              export NIXOS_CONFIG="git+file://$PWD"
            '';

            buildInputs =
              with inputs;
              self.checks.${system}.git-hooks.enabledPackages
              ++ [
                # Add treefmt to path
                self.formatter.${system}

                disko.packages.${system}.default

                # `agenix`, used for secrets management (see also: `./secrets/secrets.nix`)
                agenix.packages.${system}.default

                # Used for `htpasswd`.
                apacheHttpd
                replace-secret

                nix-update
              ];
          };
        }
      );

      formatter = forAllSystems (system: treefmt.${system}.config.build.wrapper);
    };
}
