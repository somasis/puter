{
  pkgs,
  lib,
  config,
  ...
}:
let
  format = pkgs.writeShellScript "format-nix" ''
    : "''${kak_buffile:="$PWD"/file.nix}"

    : "''${format_in:?format_in not set}"
    : "''${format_out:?format_out not set}"

    bufdir="''${kak_buffile%/*}"
    bufext="''${kak_buffile##*.}"

    has_formatter() {
        local cache_file="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}}/kakoune/user-nix-format/$flakehash"
        local has_formatter=$(<"$cache_file") || :
        has_formatter=''${has_formatter:-0}
        if ! { case "$has_formatter" in 0|1) return 0 ;; esac; return 1; }; then
            if nix-instantiate \
                --eval \
                --readonly-mode \
                --argstr flake "$1" \
                --expr '{ flake }: (builtins.getFlake flake).formatter.''${builtins.currentSystem}.name' \
                >/dev/null 2>&1
                then
                echo 0 > "$cache_file"
                has_formatter=0
            else
                echo 1 > "$cache_file"
                has_formatter=1
            fi
        fi
        return "$has_formatter"
    }

    cd "''${bufdir}"
    flake=$(upward "flake.nix")
    flake="''${flake%/flake.nix}"
    if [[ -z "$flake" ]]; then
        nixfmt -f "$buffile" - < "$format_in" > "$format_out"
        exit $?
    fi

    flakehash=$(<<<"$flake" sha256sum)
    flakehash=''${flakehash%%[[:blank:]]*}

    e=0
    if [ -n "$flake" ] && has_formatter "$flake"; then
        # `nix fmt` wants to edit in place and there's no way around it!
        cat > "$format_out"

        e=0
        mv "$format_out" "$bufdir/.''${format_out##*/}.nix"
        if nix fmt "$bufdir/.''${format_out##*/}.nix" >/dev/null; then
            mv "$bufdir/.''${format_out##*/}.nix" "$format_out"
        fi
    fi

    return "$e"
  '';

  statixFormat = pkgs.writeJqScript "format-statix" { raw-output = true; } ''
    .file as $file
      | .report[]
      | (.severity | ascii_downcase) as $severity
      | (.note | ascii_downcase) as $note
      | .diagnostics[]
      | ([ $file, .at.from.line, .at.to.line ] | join(":"))
        + ": "
        + (try ($severity + ": ") catch "")
        + .message
        + (try (" (" + $note + ")") catch "")
  '';

  lint = pkgs.writeShellScript "lint-nix" ''
    statix check -o json "$@" | ${statixFormat}
  '';
in
{
  home.packages = [
    pkgs.nixfmt-rfc-style
    pkgs.statix
  ];

  programs.kakoune.config.hooks = [
    {
      name = "WinSetOption";
      option = "filetype=nix";
      commands = ''
        set-option window tabstop 2
        set-option window indentwidth 2

        set-option window formatcmd "run() { . ${format}; } && run"
        set-option window lintcmd ${lint}
      '';
    }
  ];
}
