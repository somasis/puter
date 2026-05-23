{
  self,
  config,
  lib,
  pkgs,
  ...
}:
# Quirks and workarounds for issues.
# Ideally these can be removed on system upgrades, so try and
# remove things if they don't appear necessary anymore.

# Leave dead code in here so that sometimes no quirks are needed,
# without deadnix wanting to change this file.
let
  # deadnix: skip
  inherit (pkgs) fetchpatch2;
  patches = [
    # Here's an example:
    # # Added 2025-04-17: switch to maintained fork of Cantata
    # (fetchpatch2 {
    #   url = "https://github.com/NixOS/nixpkgs/pull/387720.patch";
    #   hash = "sha256-dPu/9KNaB1mAcYIiVMAZ8tFdCX9YjuutuL0qKAJ1uj0=";
    # })

    # Remove once <https://github.com/NixOS/nixpkgs/pull/481370> is merged
    ./0001-beets-filetote-1.1.1-1.3.4-unbreak-use-finalAttrs.patch
  ];

  # deadnix: skip
  nixpkgs-quirks =
    let
      args = {
        inherit (pkgs) config;
        inherit (pkgs.stdenvNoCC) hostPlatform;
      };
    in
    if patches != [ ] then
      import ((import pkgs.path args).applyPatches {
        name = "nixpkgs-quirks";
        src = pkgs.path;
        inherit patches;
      }) args
    else
      import pkgs.path args;

  overlay = final: prev: {
    # Continuing the earlier example, make sure to do an override
    # for the patched package too.
    # inherit (nixpkgs-quirks) cantata;

    python3Packages = prev.python3Packages // {
      beets-filetote = nixpkgs-quirks.python3Packages.beets-filetote.overrideAttrs (
        finalAttrs: prevAttrs: {
          patches = (prevAttrs.patches or [ ]) ++ [
            (prev.fetchpatch2 {
              url = "https://github.com/gtronset/beets-filetote/pull/287.patch";
              hash = "sha256-DHr6buno1iwO2MwIXFSU3IIOBvqj0+Iy5jKuySxNIy8=";
            })
          ];
        }
      );
    };

    # 2026-03-25 tests seem to be broken
    # > FAIL: testdata/script/fix.txtar:20: stdout and redirects.golden-auto differ
    xurls = prev.xurls.overrideAttrs (
      finalAttrs: prevAttrs: {
        doCheck = false;
      }
    );
  };
in
{
  # Fix issues with poorly rendered fonts that can occur
  # when running Qt 6 applications on Wayland.
  # Issue first showed up in qutebrowser <https://github.com/qutebrowser/qutebrowser/discussions/7938>
  # but it happens in other applications too; I've noticed it affecting the
  # sharpness of my Plasma widgets on my panel, when on a 1080p display.
  # Necessary as of 2026-03-25 NixOS 26.05 (unstable).
  environment.sessionVariables.QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";

  nixpkgs = {
    overlays = [ overlay ];
    config.permittedInsecurePackages = [
      # Used by various Matrix clients (in my case, NeoChat).
      "olm-3.2.16"
    ];
  };

  home-manager.sharedModules = [
    (lib.optionalAttrs (!config.home-manager.useGlobalPkgs) (
      { osConfig, ... }:
      {
        nixpkgs = {
          overlays = [ overlay ];
          config.permittedInsecurePackages = osConfig.nixpkgs.config.permittedInsecurePackages;
        };
      }
    ))
  ];
}
