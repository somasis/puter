{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  commaPicker = lib.optionalString config.programs.skim.enable (
    pkgs.writeShellScript "comma-picker" ''
      : "''${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"

      items=$(</dev/stdin)
      case "$(wc -l <<<"$items")" in
          1)
              printf '%s\n' "$items"
              printf '%s%s\n' "''${PS4:-$ }" "$items" >&2
              exit
              ;;
          0) exit 1 ;;
      esac

      hash=$(
          printf '%s\0' "$(tty)" "$items" "$PPID" \
              | sha256sum \
              | cut -d ' ' -f1
      )

      last_choice_file="$XDG_RUNTIME_DIR"/comma."$hash"

      choice=$(
          if [ -z "''${COMMA_PICKER_OVERRIDE:-}" ] && [ -s "$last_choice_file" ]; then
              printf '%s\n' "$last_choice"
              printf 'using last choice (%s); run again with ,, to override\n' "''${last_choice@Q}" >&2
          else
              sk -p ', ' --no-sort --reverse <<< "$items"
              exit $?
          fi
      )

      if [ -n "$choice" ]; then
          printf '%s\n' "$choice" | tee "$last_choice_file"
      fi
    ''
  );
in
{
  home.shellAliases = rec {
    # LC_COLLATE=C sorts uppercase before lowercase.
    ls = "LC_COLLATE=C ls --hyperlink=auto --group-directories-first --dereference-command-line-symlink-to-dir --time-style=iso --color -AFlh";
    chown = "chown -c";
    chmod = "chmod -c";

    vi = "$EDITOR";

    ip = "ip --color=auto";

    bc = "bc -q";
    number = "nl -b a -d '' -f n -w 1";

    diff = "diff --color";

    grep = "grep --color";

    g = "find -L ./ -type f \! -path '*/.*/*' -print0 | xe -0 -N0 grep --color -n";
    f = "bfs -regextype posix-egrep -status";

    xq = "yq -p xml -o xml";

    xz = "xz -T0 -9 -e";
    zstd = "zstd -T0 -19";
    gzip = "pigz -p $(( $(nproc) / 2 )) -9";

    sys = "systemctl --legend=no";
    user = "sys --user";

    journal = "journalctl -e";
    syslog = "journal -b 0 --system";

    # Exclude log level 7 (debug messages) for user journal, since it is usually
    # flooded with debug messages from KDE Plasma or KWin or any of that.
    userlog = "journal --user -p 0..6";

    bus = "busctl --verbose -j";

    wget = "curl -q -Lf# -Z --no-clobber --remote-name-all --remote-header-name --remove-on-error --retry 20 --retry-delay 10";

    since = "datediff -f '%Yy %mm %ww %dd %0Hh %0Mm %0Ss'";

    sudo = lib.mkIf osConfig.security.sudo.enable "sudo "; # trailing space means sudo will use aliases
    doas = lib.mkIf osConfig.security.sudo.enable "sudo";

    watch = "watch -n1 -c ";

    which = "{ alias; declare -f; } | which --read-functions --read-alias";

    ",," = "COMMA_PICKER_OVERRIDE=true ,";
  };

  home.packages = [
    pkgs.rmlint

    pkgs.spacer
    pkgs.nocolor

    (pkgs.writeShellScriptBin "execurl" ''
      fetch_directory=$(${pkgs.coreutils}/bin/mktemp -d)

      fetch() {
          local file

          printf '%s -> ' "$1" >&2
          file=$(
              ${pkgs.curl}/bin/curl \
                  -g \
                  -Lfs# \
                  --output-dir "$fetch_directory" \
                  -o "file" \
                  --remote-name \
                  --remote-time \
                  --no-clobber \
                  --remote-header-name \
                  --remote-name-all \
                  --remove-on-error \
                  -w '%{filename_effective}\n' \
                  "$1"
          )
          printf '%s\n' "$file" >&2

          printf '%s' "$file"
      }

      error_code=0
      arguments=()

      for argument; do
          if ${pkgs.trurl}/bin/trurl --no-guess-scheme --verify --url "$argument" >/dev/null 2>&1; then
              arguments+=( "$(fetch "$argument")" )
          else
              arguments+=( "$argument" )
          fi
      done

      "''${arguments[@]}" || error_code=$?
      ${pkgs.coreutils}/bin/rm -rf "$fetch_directory"
      exit "$error_code"
    '')

    (
      if commaPicker != "" then
        (pkgs.wrapCommand {
          package = pkgs.comma;
          wrappers = [
            {
              command = "/bin/,";
              setEnvironmentDefault.COMMA_PICKER = commaPicker;
            }
          ];
        })
      else
        pkgs.comma
    )
  ];

  programs.bash.initExtra = ''
    . edo

    # ... | peek [COMMAND...] | ...
    peek() {
        if [[ "$#" -eq 0 ]]; then
            tee /dev/stderr
        else
            tee >("$@" >&2)
        fi
    }

    # Spawn a new terminal, detached from the current one, inheriting environment and working directory.
    newt() (
        nohup terminal "$@" >/dev/null 2>&1 &
    )

    man() {
        local man_args=( "$@" )

        local COMMA_NIXPKGS_FLAKE COMMA_PICKER
        : "''${COMMA_NIXPKGS_FLAKE:=nixpkgs}"
        : "''${COMMA_PICKER:=${lib.escapeShellArg commaPicker}}"

        local MANPATH="$MANPATH"
        local old_MANPATH="$MANPATH"

        local man_sections man_section new_man_path
        mapfile -t man_sections < <(
            IFS=:

            if [[ "''${MANPATH:0:1}" == : ]]; then
                local MANPATH=( ''${MANPATH:1} )
            else
                local MANPATH=( ''${MANPATH} )
            fi
            unset IFS

            find -L \
                "''${MANPATH[@]}" \
                -mindepth 1 \
                -type d \
                -name 'man*' \
                -printf '%f\n' \
                2>/dev/null \
                | cut -c4- \
                | sort -u
        )

        MANPATH="$old_MANPATH"

        if command man -w "''${man_args[@]}" >/dev/null 2>&1; then
            command man "''${man_args[@]}"
        else
            local regex
            while [[ "$#" -ge 1 ]]; do
                for man_section in "''${man_sections[@]}"; do
                    if [[ "$1" == "$man_section" ]] && [[ "$#" -ge 2 ]]; then
                        regex='/share/man/man'"$man_section"'/'"$2"'\.'"$man_section"
                        shift
                        break
                    else
                        regex='/share/man/man.*'/"$1"'\.'
                        break
                    fi
                done
                shift

                [[ -t 2 ]] && printf 'searching for packages containing manpage %s...\n' "$1" >&2 || :
                new_man_path=$(nix-locate --minimal --at-root --regex "$regex" 2>/dev/null | grep -v '^(')
                [[ -n "$new_man_path" ]] || continue

                new_man_path=$(eval "$COMMA_PICKER" <<< "$new_man_path")
                new_man_path=$(nix build --no-link --print-out-paths "$COMMA_NIXPKGS_FLAKE"#"$new_man_path")
                new_man_path="$new_man_path/share/man"

                case "$MANPATH" in
                    :*) MANPATH="$new_man_path$MANPATH" ;;
                    "") MANPATH="$new_man_path:" ;;
                    *)  MANPATH="$new_man_path:$MANPATH" ;;
                esac
            done

            [[ -t 2 ]] && printf '\033[1K' >&2 || :

            MANPATH="$MANPATH" command man "''${man_args[@]}"
        fi
    }
  '';

  xdg.configFile."curlrc".text = ''
    show-error

    disallow-username-in-url

    compressed

    parallel
    parallel-max = 4
  '';
}
