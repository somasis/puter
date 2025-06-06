{
  pkgs,
  lib,
  ...
}:
let
  # format = pkgs.writeShellScript "format-hledger" ''
  #   set -euo pipefail
  #   set -x

  #   e=0
  #   input=$(cat)
  #   [[ -n "$input" ]] || exit 127

  #   output=$(${pkgs.hledger-fmt}/bin/hledger-fmt --no-diff - <<<"$input") || e=$?
  #   if [[ "$e" -gt 0 ]] || [[ -z "$output" ]]; then
  #       printf '%s\n' "$input"
  #       exit "$e"
  #   fi
  #   printf '%s\n' "$output"
  # '';

  lint = pkgs.writeShellScript "lint-ledger" ''
    PATH=${
      lib.makeBinPath [
        pkgs.gnused
        pkgs.findutils
        pkgs.coreutils
        pkgs.hledger
      ]
    }

    set -euo pipefail
    set -x

    find "''${kak_buffile%/*}" \
        -maxdepth 1 -type f \
        -exec ln -Tsf {} "''${1%/*}"/ \;

    raw=$(LC_ALL=C hledger check --strict -f "$1" 2>&1)

    # column=$(sed -E '/^\s+\|\s+\^+/!d; s/^\s+\| //; s/\^\^.*/\^/' | tr -d '\n' | wc -c <<< "$raw")

    <<<"$raw" sed -E \
        -e '/^hledger: Error: in file included /d' \
        -e '/^hledger: Error: / { s/^hledger: Error: //; s/:$/: error: / }' \
        -e '/^[0-9]*\s+\|\s/d' \
        | tr '\n' ' ' \
        | sed -e 's/  */ /g' -e 's/ Examples: .*$//'
  '';
in
{
  # home.packages = [ pkgs.hledger-fmt ];

  programs.kakoune.config.hooks = [
    {
      name = "WinSetOption";
      option = "filetype=ledger";
      # set-option window formatcmd "${format}"
      commands = ''
        set-option window lintcmd "${lint}"
      '';
    }
  ];
}
