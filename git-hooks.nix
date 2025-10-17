# <https://github.com/cachix/git-hooks.nix>
# Used by ./shell.nix.
let
  sources = import ./npins;

  pkgs = import sources.nixpkgs { };
  git-hooks = import sources.git-hooks;
in
git-hooks.run rec {
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
      excludes = [ ".+\.desktop$" ];
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

    quick-lint-js = {
      enable = true;
      name = "quick-lint-js";
      description = "Lint Javascript files";
      package = pkgs.quick-lint-js;
      entry = "${hooks.quick-lint-js.package}/bin/quick-lint-js";
      files = "\\.js$";
    };

    treefmt = {
      enable = true;
      package = import ./treefmt.nix;
    };
  };
}
