{ config
, lib
, nixpkgs
, pkgs
, ...
}:
# Quirks and workarounds for issues.
# Ideally these can be removed on system upgrades, so try and
# remove things if they don't appear necessary anymore.
let
  inherit (pkgs) fetchpatch;

  nixpkgsArgs = { inherit (pkgs.stdenvNoCC) system hostPlatform; };

  nixpkgs-patched = import
    ((import nixpkgs nixpkgsArgs).applyPatches {
      name = "nixpkgs-quirks";
      src = nixpkgs;
      patches = [
        # Added 2025-04-17: switch to maintained fork of Cantata
        (fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/pull/387720.patch";
          hash = "sha256-dPu/9KNaB1mAcYIiVMAZ8tFdCX9YjuutuL0qKAJ1uj0=";
        })
      ];
    })
    nixpkgsArgs;

  overlay = final: prev: {
    inherit (nixpkgs-patched.pkgs) cantata;
  };
in
{
  # Fix issues with poorly rendered fonts that can occur
  # when running Qt 6 applications on Wayland.
  # Issue first showed up in qutebrowser <https://github.com/qutebrowser/qutebrowser/discussions/7938>
  # but it can happen in other applications, like KDE's systemsettings.
  # Necessary as of 2025-03-13 NixOS 24.11.
  environment.sessionVariables.QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";

  # Seems to be necessary to fix a weird crash right now?
  # > nix-daemon[38088]: terminate called after throwing an instance of 'nix::Unsupported'
  # > nix-daemon[38088]:   what():  error: operation 'queryRealisation' is not supported by store 'ssh://nix-ssh@esther.7596ff.com'
  # > systemd-coredump[38109]: Process 38088 (nix-daemon) of user 0 terminated abnormally with signal 6/ABRT, processing...
  nix.sshServe.protocol = "ssh-ng";

  nixpkgs.overlays = [ overlay ];
  home-manager.sharedModules = [
    (lib.optionalAttrs (!config.home-manager.useGlobalPkgs) { nixpkgs.overlays = [ overlay ]; })
  ];
}
