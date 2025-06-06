{
  lib,
  pkgs,
  ...
}:
let
  memento = pkgs.writeShellScript "qutebrowser-memento" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.dateutils
      ]
    }

    usage() {
        cat <<EOF >&2
    usage: QUTE_FIFO=... qutebrowser-memento [date [URL]]
    EOF
        exit 69
    }

    [[ $# -le 2 ]] || usage

    : "''${QUTE_FIFO:?}"
    exec > "$QUTE_FIFO"

    timetravel="https://timetravel.mementoweb.org/memento"
    date=$(dateconv -z UTC -f "%Y%m%d%H%M%S" "''${1:-now}")

    printf 'open -r %s/%s/%s\n' \
        "$timetravel" \
        "$date" \
        "''${QUTE_URL:-$2}"
  '';
  wayback = pkgs.writeShellScript "wayback" ''
    PATH=${
      lib.makeBinPath [
        pkgs.curl
        pkgs.jq
        pkgs.savepagenow
      ]
    }:"$PATH"

    : "''${QUTE_FIFO:?}"
    : "''${QUTE_TAB_INDEX:?}"

    url="''${QUTE_URL:-''${1?error: no URL provided}}"

    wayback_response=
    wayback_archived_url=

    check_wayback() {
        wayback_response=$(
            curl -f -s -G --url-query "url=$url" "https://archive.org/wayback/available"
        )

        wayback_archived_url=$(
            <<<"$wayback_response" jq -er '
                if .archived_snapshots == {} then
                    ""
                else
                    .archived_snapshots.closest.url
                end
            '
        )
    }

    check_wayback
    # printf 'message-info "wayback: checking if URL archived..."\n' > "$QUTE_FIFO"

    if [ -n "$wayback_archived_url" ]; then
        printf 'message-info "wayback: has URL, redirecting."\n' > "$QUTE_FIFO"
        printf 'cmd-run-with-count %s open -r %s\n' "$QUTE_TAB_INDEX" "$wayback_archived_url" > "$QUTE_FIFO"
    else
        printf 'message-info "wayback: does not have URL, archiving \"%s\"..."' "$url" > "$QUTE_FIFO"
        if wayback_archived_url=$(savepagenow -c "$url"); then
            printf 'message-info "wayback: archived URL, redirecting..."\n' > "$QUTE_FIFO"
            printf 'cmd-run-with-count %s open -r %s\n' "$QUTE_TAB_INDEX" "$wayback_archived_url" > "$QUTE_FIFO"
        else
            printf 'message-error "wayback: failed to archive URL"\n' > "$QUTE_FIFO"
            exit 1
        fi
    fi
  '';
in
{
  programs.qutebrowser = {
    extraConfig = lib.fileContents ./redirects.py;

    aliases =
      let
        search-with-selection = pkgs.writeShellScript "search-with-selection" ''
          PATH=${lib.makeBinPath [ pkgs.s6-portable-utils ]}:"$PATH"
          : "''${QUTE_FIFO:?}"
          : "''${QUTE_SELECTED_TEXT:?}"

          args=( "$@" "$QUTE_SELECTED_TEXT" )
          i=0
          until [[ "$i" -gt "''${#args[@]}" ]]; do
              args[$i]=( "$(s6-quote -d '"' "\"''${args[$i]}")\"" )
              i=$(( i + 1 ))
          done
          printf 'open -rt %s\n' "''${args[*]}" > "$QUTE_FIFO"
        '';
      in
      {
        memento = "spawn -u ${memento}";
        search-with-selection = "spawn -u ${search-with-selection}";
        wayback = "spawn -u ${wayback}";
      };

    keyBindings.normal =
      let
        open = x: "open -r ${x}";
      in
      {
        # "1" = open "https://12ft.io/api/proxy?q={url}";
        # "a" = open "https://web.archive.org/web/*/{url}";
        "raa" = "wayback {url}";
        "raA" = open "https://archive.today/newest/{url}";
        "ram" = "memento";
        "raM" = "memento now";
      };
  };
}
