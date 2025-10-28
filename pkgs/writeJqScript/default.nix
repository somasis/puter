{
  lib,
  jq,
  jqfmt,
  writeScript,
  writeTextFile,
  runtimeShell,
}:
name: args: text:
assert (lib.isString name);
assert (lib.isAttrs args);
assert (lib.isString text);
let
  args' = {
    inherit jq jqfmt;
  }
  // args;

  inherit (args') jq jqfmt;

  jqArgs =
    lib.removeAttrs args' [
      "jq"
      "jqfmt"
      "jqfmtArgs"
    ]
    // {
      from-file = jqScript;
    };

  jqfmtArgs = (args'.jqfmtArgs or { }) // {
    f = jqScript;
  };

  jqArgs' = lib.cli.toGNUCommandLineShell { } jqArgs;
  jqfmtArgs' = lib.cli.toGNUCommandLineShell { mkOptionName = x: "-${x}"; } jqfmtArgs;

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
