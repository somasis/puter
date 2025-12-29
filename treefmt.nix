# <https://github.com/numtide/treefmt-nix>
# Used by ./shell.nix and ./default.nix.
# Rather than using `treefmt-nix.mkWrapper pkgs { ... }`, this has to be
# written such that the config can be used by both the checks called to
# in ./default.nix and the `mkWrapper` call in ./shell.nix.
{
  sources ? import ./npins,
  nixpkgs ? sources.nixpkgs,
  pkgs ? import nixpkgs { },
  lib ? pkgs.lib,

  treefmt-nix ? sources.treefmt-nix,
  ...
}:
(import treefmt-nix).evalModule pkgs {
  projectRootFile = "npins/sources.json";

  # See <https://github.com/numtide/treefmt-nix/tree/main/programs>
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
    clang-format = {
      enable = true;
    };

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
    clang-format.options =
      let
        freebsdConfig = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/freebsd/freebsd-src/8494be1b5af7fe4f765532f802ac0a145e061d73/.clang-format";
          hash = "sha256-hRWc+LVlMCiHGr/ihboNa/fR2CKT+Q6I8S8ksdBOpQw=";
        };
      in
      [
        "-style=file:${toString freebsdConfig}"
      ];
    shellcheck.options = [
      "--external-sources"
    ];

    shfmt.options = [
      "--binary-next-line"
      "--case-indent"
    ];
  };
}
