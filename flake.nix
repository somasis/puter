{
  description = "puter";

  inputs = {
    keys-github-cassie = {
      url = "https://github.com/7596ff.keys";
      flake = false;
    };

    keys-github-somasis = {
      url = "https://github.com/somasis.keys";
      flake = false;
    };

    agenix.url = "github:ryantm/agenix";
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # NOTE Make sure to change on new releases!
    # See <https://nixos.org/manual/nixos/unstable/#sec-upgrading> for details
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"; # most recent version (potentially beta)
    nixpkgsStable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";

    homeManager = {
      # NOTE Make sure to change on new releases!
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homeManagerStable = {
      # NOTE Make sure to change on new releases!
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgsStable";
    };

    homeManagerUnstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };

    nixosHardware.url = "github:nixos/nixos-hardware";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    impermanence.url = "github:nix-community/impermanence";

    # Secure Boot implementation.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "homeManager";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };

    mosh-server-upnp = {
      url = "github:arcnmx/mosh-server-upnp";
      inputs.nixpkgs.follows = "nixpkgsStable";
    };

    # Use a pre-built nix-index database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };

    # Non-flake content
    avatarSomasis = {
      # jq -nrR \
      #     --arg hash "$(printf '%s' 'kylie@somas.is' | md5sum | cut -d ' ' -f1)" \
      #     --arg size 512 \
      #     --arg fallback "https://avatars.githubusercontent.com/${USER}?size=512" \
      #     '"url = \"https://www.gravatar.com/avatar/\($hash)?s=\($size)&d=\($fallback | @uri)\";"'
      #     '
      flake = false;
      url = "https://www.gravatar.com/avatar/a187e38560bb56f5231cd19e45ad80f6?s=512";
    };

    catgirl.flake = false;
    catgirl.url = "git+https://git.causal.agency/catgirl?ref=somasis/tokipona";
    dmenu-flexipatch.flake = false;
    dmenu-flexipatch.url = "github:bakkeby/dmenu-flexipatch";
    # radiotray-ng.flake = false;
    # radiotray-ng.url = "github:ebruck/radiotray-ng";
    qutebrowser-zotero.flake = false;
    qutebrowser-zotero.url = "github:parchd-1/qutebrowser-zotero";
    plasma-pass.flake = false;
    plasma-pass.url = "git+https://invent.kde.org/plasma/plasma-pass.git";
    sbase.flake = false;
    sbase.url = "git://git.suckless.org/sbase";
    ubase.flake = false;
    ubase.url = "github:michaelforney/ubase";

    control-panel-for-twitter.flake = false;
    control-panel-for-twitter.url = "github:insin/control-panel-for-twitter";
    # zotero-styles.flake = false;
    # zotero-styles.url = "github:citation-style-language/styles";
    # zotero-translators.flake = false;
    # zotero-translators.url = "github:zotero/translators";

    discordThemeCustom.flake = false;
    discordThemeCustom.url = "path:/home/somasis/src/discord-theme-custom";
    discordThemeIrc.flake = false;
    discordThemeIrc.url = "github:somasis/discord-theme-irc";

    # Ad blocking lists
    adblockEasyList.flake = false;
    adblockEasyList.url = "github:thedoggybrad/easylist-mirror";
    adblockHosts.flake = false;
    adblockHosts.url = "github:StevenBlack/hosts";
    uAssets.flake = false;
    uAssets.url = "github:uBlockOrigin/uAssetsCDN";
  };

  outputs =
    { self
    , git-hooks
    , treefmt-nix

    , nixpkgs
    , nixpkgsStable
    , nixpkgsUnstable
    , homeManager

    , ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      treefmtEval = forAllSystems (system:
        treefmt-nix.lib.evalModule nixpkgsFor.${system}.pkgs {
          # See also <https://github.com/numtide/treefmt-nix/tree/main/programs>
          projectRootFile = "flake.nix";
          programs = {
            # Format shell scripts
            beautysh = {
              enable = true;
              indent_size = 4; # make sure this is in agreement with .editorconfig
            };
            # shellcheck.enable = true;
            # shfmt = {
            #   enable = true;
            #   indent_size = 4;
            # };

            black.enable = true;
            clang-format.enable = true;

            deadnix = {
              enable = true;
              no-lambda-arg = true;
              no-lambda-pattern-names = true;
            };

            # Allow keeping certain lines sorted
            # <https://github.com/google/keep-sorted>
            keep-sorted.enable = true;

            # nixfmt-rfc-style.enable = true;
            nixpkgs-fmt.enable = true;
            oxipng.enable = true;
            perltidy.enable = true;

            # Ensure formatting of CSS, HTML, and so on
            prettier.enable = true;

            statix.enable = true;

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
        lib = ./modules/lib.nix;
        impermanence = ./modules/nixos/impermanence.nix;
        sensible-defaults = ./modules/nixos/sensible-defaults;
        meta = ./modules/nixos/meta.nix;
        theme = ./modules/nixos/theme.nix;
      };

      homeManagerModules = {
        default = ./modules/home-manager;
        lib = ./modules/lib.nix;
      };

      overlays = {
        default = final: prev: lib.recursiveUpdate prev (import ./pkgs { pkgs = final; });

        nixpkgsVersions = final: prev: {
          stable = inputs.nixpkgsStable.legacyPackages.${system};
          unstable = inputs.nixpkgsUnstable.legacyPackages.${system};
        };

        # Create an overlay from all flake inputs with packages.
        # pkgs.flakePackages.<input name>.package
        flakePackages = final: prev: {
          flakePackages =
            lib.mapAttrs' (inputName: input: lib.nameValuePair inputName input.packages.${system})
              (
                lib.filterAttrs
                  (
                    _: inputValue: (inputValue ? packages.${system}) && (inputValue.packages.${system} != { })
                  )
                  inputs
              );
        };
      };

      nixosConfigurations = {
        esther = lib.nixosSystem {
          specialArgs = { inherit self inputs nixpkgs; };
          modules = [ ./hosts/esther.7596ff.com ];
        };

        ilo = lib.nixosSystem {
          specialArgs = { inherit self inputs nixpkgs; };
          modules = [ ./hosts/ilo.somas.is ];
        };
      };

      homeConfigurations.somasis = homeManager.lib.homeManagerConfiguration {
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

          default_stages = [
            "pre-commit"
            "post-merge"
            "post-rewrite"
            "post-checkout"
          ];

          hooks = {
            # Git style
            gitlint.enable = true;
            check-merge-conflicts.enable = true;

            # Nix-related hooks
            # statix.enable = true; # Lint Nix code.

            # NOTE(somasis):
            # Ensure code is formatted according to Nix RFC 166.
            # <https://github.com/NixOS/rfcs/pull/166>
            # I think it's good to keep it formatted according to a standard,
            # but I don't really like the default format coming from `nixpkgs-fmt`,
            # which is now abandoned by its author in favor of `nixfmt`.
            # Namely, `nixfmt` is *way* to pedantic about making lists longer
            # than they need to be right now.
            # Ideally this will be improved by the end of 2025 or something?
            # nixfmt-rfc-style.enable = true;
            # nixpkgs-fmt.enable = true;

            # Ensure we don't have commit anything bad
            check-added-large-files.enable = true; # avoid committing binaries when possible
            check-vcs-permalinks.enable = true; # don't use version control links that could rot
            check-symlinks.enable = true; # dead symlinks specifically
            detect-private-keys.enable = true;

            # Ensure we actually follow our .editorconfig rules.
            eclint.enable = true;
            editorconfig-checker.enable = true;

            # hunspell.enable = true;
            # Ensure we don't have dead links in comments or whatever.
            lychee.enable = true;

            # Enforce formatting on shell scripts.
            shellcheck.enable = true;

            # FIXME shfmt has some bugs still
            # shfmt.enable = true;
          };
        };

        formatting = treefmtEval.${system}.config.build.check self;
      });

      devShells = forAllSystems (system: with nixpkgsFor.${system}.pkgs; {
        default = mkShell {
          buildInputs =
            with inputs;
            self.checks.${system}.git-hooks.enabledPackages
            ++ [
              self.formatter.${system}
              agenix.packages.${system}.default
              apacheHttpd # Used for `htpasswd`.
              replace-secret
            ];
        };
      });

      # Use the formatter used by nixpkgs.
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
    };
}
