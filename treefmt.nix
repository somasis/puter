# <https://github.com/numtide/treefmt-nix>
# Used by ./shell.nix and ./default.nix.
# Rather than using `treefmt-nix.mkWrapper pkgs { ... }`, this has to be
# written such that the config can be used by both the checks called to
# in ./default.nix and the `mkWrapper` call in ./shell.nix.
{
  # See also <https://github.com/numtide/treefmt-nix/tree/main/programs>
  projectRootFile = "npins/sources.json";

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
      excludes = [ "npins/*" ];
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

  settings.formatter = {
    shellcheck.options = [
      "--external-sources"
    ];

    shfmt.options = [
      "--binary-next-line"
      "--case-indent"
    ];
  };
}
