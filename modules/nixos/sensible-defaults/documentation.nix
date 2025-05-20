{ pkgs
, nixpkgs
, ...
}:
let
  nixpkgs-manual = pkgs.callPackage "${nixpkgs}/doc" { };
in
{
  documentation = {
    info.enable = false;
    doc.enable = true;
    dev.enable = true;
    nixos = {
      enable = true; # Provides `nixos-help`.

      # Include documentation from all modules loaded.
      # Note that this has caused problems in the past, so if
      # the build is mysteriously failing, try disabling this.
      includeAllModules = true;

      # Don't be pedantic about errors since we don't want a lazy
      # module author to break the build.
      options.warningsAreErrors = false;
    };
  };

  environment.systemPackages = [
    pkgs.linux-manual
    nixpkgs-manual
    (pkgs.writeShellScriptBin "nixpkgs-help" ''
      exec "''${BROWSER:-xdg-open}" "file://${nixpkgs-manual}/share/doc/nixpkgs/manual.html"
    '')
  ];
}
