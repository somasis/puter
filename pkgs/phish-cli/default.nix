{
  lib,
  symlinkJoin,
  writeShellApplication,
  pkgs,
}:
let
  bins = [
    ../../bin/beet-import-phish
    ../../bin/phish-download-show
    ../../bin/phish-list-shows
    ../../bin/phish-show-notes
    ../../bin/phishin-auth-login
    ../../bin/phishin-like-show
  ];

  mans = [ ];

  inherit (builtins) readFile;
  inherit (lib)
    pipe
    splitString
    filter
    concatStrings
    hasPrefix
    replaceStrings
    getAttrFromPath
    ;
in
symlinkJoin {
  name = "phish-cli";

  paths = map (
    textPath:
    writeShellApplication {
      name = baseNameOf textPath;
      text = builtins.readFile textPath;

      runtimeInputs = pipe (readFile textPath) [
        (splitString "\n")
        (x: filter (hasPrefix "#! nix-shell") x)
        (x: concatStrings (map (replaceStrings [ ''#! nix-shell -i bash -p '' ] [ "" ]) x))
        (splitString " ")
        (map (pkgAttr: getAttrFromPath ([ "pkgs" ] ++ (splitString "." pkgAttr)) pkgs))
      ];
    }
  ) bins;

  postInstall = lib.optionalString (mans != [ ]) (lib.escapeShellArgs ([ "installManPage" ] ++ mans));

  meta = with lib; {
    licenses = licenses.cc0;
    maintainers = [ maintainers.somasis ];
    mainProgram = null;
  };
}
