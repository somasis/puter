{
  config,
  lib,
  nixpkgs,
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
  inherit (pkgs) fetchpatch;
  patches = [
    # Here's an example:
    # # Added 2025-04-17: switch to maintained fork of Cantata
    # (fetchpatch {
    #   url = "https://github.com/NixOS/nixpkgs/pull/387720.patch";
    #   hash = "sha256-dPu/9KNaB1mAcYIiVMAZ8tFdCX9YjuutuL0qKAJ1uj0=";
    # })

    # Added 2025-10-08: fixes for CMake 4
    (fetchpatch {
      url = "https://github.com/NixOS/nixpkgs/pull/449133.patch";
      hash = "sha256-ejdJ1UzJwndu/IYTj+ntPFgYG4XEeHaQOqfxzNEIvac=";
    })
    (fetchpatch {
      url = "https://github.com/NixOS/nixpkgs/pull/449438.patch";
      hash = "sha256-0nwBsfPzuLEpU7nl2xbXJpYm04HYmtvwOkiT7cwqbb8=";
    })
    (fetchpatch {
      url = "https://github.com/NixOS/nixpkgs/pull/449469.patch";
      hash = "sha256-ryFomEaJ/NgaQK4oIEuUa7wdOnsdpyjrBWKZVA9otqM=";
    })
    (fetchpatch {
      url = "https://github.com/NixOS/nixpkgs/pull/449515.patch";
      hash = "sha256-ufW1OfXe3mSCpK2XMiRNilvkc9jSqLYDbfS+p/MUo4k=";
    })
    (fetchpatch {
      url = "https://github.com/NixOS/nixpkgs/pull/450061.patch";
      hash = "sha256-vhYwsURT/KWilRlUuQIQe+dKZRA547f7kj8j2sn47hg=";
    })
    (fetchpatch {
      url = "https://github.com/NixOS/nixpkgs/pull/450251.patch";
      hash = "sha256-tWel4NUYbr/8jHEFcG2V6OJOQj0UAGpCDuHKwS5Fyc4=";
    })

    # Added 2025-10-09: fix failing trurl tests
    (fetchpatch {
      url = "https://github.com/NixOS/nixpkgs/pull/450487.patch";
      hash = "sha256-ooxmucGPN9piqSL8oIbcO/uru8BZRa6lwwXCnpikwVU=";
    })
  ];

  # deadnix: skip
  nixpkgs-quirks =
    if patches != [ ] then
      let
        args = { inherit (pkgs.stdenvNoCC) system hostPlatform; };
      in
      import ((import nixpkgs args).applyPatches {
        name = "nixpkgs-quirks";
        src = nixpkgs;
        inherit patches;
      }) args
    else
      nixpkgs;

  overlay = final: prev: {
    # Continuing the earlier example, make sure to do an override
    # for the patched package too.
    # inherit (nixpkgs-quirks.pkgs) cantata;
    inherit (nixpkgs-quirks.pkgs)
      fw-ectool
      halibut
      intel-graphics-compiler
      quick-lint-js
      trurl
      ;
  };
in
{
  # Fix issues with poorly rendered fonts that can occur
  # when running Qt 6 applications on Wayland.
  # Issue first showed up in qutebrowser <https://github.com/qutebrowser/qutebrowser/discussions/7938>
  # but it can happen in other applications, like KDE's systemsettings.
  # Necessary as of 2025-03-13 NixOS 24.11.
  environment.sessionVariables.QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";

  nixpkgs.overlays = [ overlay ];
  home-manager.sharedModules = [
    (lib.optionalAttrs (!config.home-manager.useGlobalPkgs) {
      nixpkgs.overlays = [ overlay ];
    })
  ];
}
