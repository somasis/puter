{
  lib,
  jq,
  jqfmt,
  writeScript,
  writeTextFile,
  runtimeShell,

  name ? null,
  text ? null,
  jqArgs ? { },
  jqfmtArgs ? { },
  ...
}:
assert (lib.isString name);
assert (lib.isString text);
let
  inherit
    jq
    jqfmt
    writeScript
    writeTextFile
    runtimeShell
    ;

  jqArgs' = lib.cli.toGNUCommandLineShell { } (
    jqArgs
    // {
      from-file = jqScript;
    }
  );

  jqfmtArgs' = lib.cli.toGNUCommandLineShell { mkOptionName = x: "-${x}"; } (
    jqfmtArgs
    // {
      f = jqScript;
    }
  );

  jqScript = writeScript name ''
    #!${jq}/bin/jq -f
    ${text}
  '';
in
writeTextFile {
  inherit name;
  executable = true;

  checkPhase = ''
    error=0
    ${jq}/bin/jq -n ${jqArgs'} || error=$?

    # 3: syntax error
    [ "$error" -eq 3 ] && exit 1 || :

    # diff -u ${lib.escapeShellArg jqScript} <(${jqfmt}/bin/jqfmt ${jqfmtArgs'}) || error=$?
    # [ "$error" -eq 0 ] || exit 1

    exit 0
  '';

  text = ''
    #!${runtimeShell}
    exec ${jq}/bin/jq ${jqArgs'} "$@"
  '';
}
