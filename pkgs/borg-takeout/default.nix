{
  lib,
  symlinkJoin,
  writeShellApplication,
  coreutils,
  dateutils,
  gnugrep,
  gnused,
  htmlq,
  jq,
  libarchive,
  borgConfig ? { },
}:
let
  extraArgs = borgConfig.extraArgs or "";

  preHook = borgConfig.preHook or "";

  make =
    name: runtimeInputs:
    writeShellApplication {
      inherit name;
      inherit runtimeInputs;

      text =
        ''
          # shellcheck disable=SC2034,SC2090,SC2317
          ${preHook}

          type=$(type -t borg)
          case "$type" in
              function)
                  prev_borg=$(declare -f borg)

                  eval "prev_$prev_borg"
                  borg() {
                      local ${lib.toShellVar "extraArgs" extraArgs}

                      # shellcheck disable=SC2086
                      prev_borg $extraArgs "$@"
                  }
                  ;;
              *)
                  borg() {
                      local ${lib.toShellVar "extraArgs" extraArgs}

                      # shellcheck disable=SC2086
                      command borg $extraArgs "$@"
                  }
                  ;;
          esac
        ''
        + builtins.readFile (./. + "/${name}.bash");
    };
in
symlinkJoin {
  name = "borg-takeout";

  paths = [
    (make "borg-import-google" [
      coreutils
      dateutils
      gnugrep
      htmlq
      libarchive
    ])
    (make "borg-import-facebook" [
      coreutils
      dateutils
      gnugrep
      libarchive
    ])
    (make "borg-import-instagram" [
      coreutils
      dateutils
      gnugrep
      libarchive
    ])
    (make "borg-import-letterboxd" [
      coreutils
      jq
      libarchive
    ])
    (make "borg-import-tumblr" [
      coreutils
      dateutils
      jq
      libarchive
    ])
    (make "borg-import-twitter" [
      coreutils
      dateutils
      gnused
      jq
      libarchive
    ])
  ];

  meta = with lib; {
    description = "Various utilities for using `borg` to process archives from online services";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
  };
}
