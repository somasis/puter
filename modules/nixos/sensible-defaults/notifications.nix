# Reimplementation of <https://github.com/stendler/systemd-ntfy-poweronoff>.
{
  pkgs,
  self,
  config,
  ...
}:
let
  ntfy = pkgs.writeShellScript "ntfy" ''
    if ! [[ -r "$NTFY_TOKEN_FILE" ]]; then
        echo "NTFY_TOKEN_FILE (''${NTFY_TOKEN_FILE@Q}) is not readable" >&2
        exit 127
    fi

    # coreutils uptime does not have `--since`
    startup_time="$(TZ=UTC ${pkgs.procps}/bin/uptime -s) (UTC)"
    NTFY_MESSAGE="Machine on since $startup_time."

    case "''${1?no mode provided}" in
        startup)
            local_ipv4=$(
                ${pkgs.iproute2}/bin/ip -4 route get 1 \
                    | ${pkgs.gnused}/bin/sed -n 's/^.*src \([0-9.]*\) .*$/\1/p'
            )
            public_ipv4=$(${pkgs.curl}/bin/curl -4 https://icanhazip.com || echo "")

            NTFY_MESSAGE="$NTFY_MESSAGE
            Local IPv4: $local_ipv4
            Public IPv4: $public_ipv4"
            ;;
        shutdown) : ;;
        *)
            echo "invalid mode provided: $1" >&2
            exit 127
            ;;
    esac

    export NTFY_MESSAGE

    ${pkgs.curl}/bin/curl \
        ''${NTFY_TOKEN_FILE:+--variable "%NTFY_TOKEN@$NTFY_TOKEN_FILE"} \
        ''${NTFY_TOKEN_FILE:+--expand-header 'Authorization: Bearer {{NTFY_TOKEN}}'} \
        ''${NTFY_TAGS:+--variable %NTFY_TAGS} \
        ''${NTFY_TAGS:+--expand-header 'Tags: {{NTFY_TAGS}}'} \
        --variable %NTFY_TITLE \
        --expand-header 'Title: {{NTFY_TITLE}}' \
        --variable %NTFY_MESSAGE \
        --expand-data '{{NTFY_MESSAGE}}' \
        --url "$NTFY_TOPIC"
  '';
in
{
  age.secrets.ntfy-token.file = "${self}/secrets/ntfy-token-${config.networking.fqdnOrHostName}.age";

  systemd.services = {
    ntfy-startup = {
      description = "Send a notification on system startup";
      partOf = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";

        Environment = [
          "NTFY_TOPIC=https://ntfy.box.somas.is/system"
          "NTFY_TOKEN_FILE=${config.age.secrets.ntfy-token.path}"

          ''NTFY_TITLE="%H powered on"''
          "NTFY_TAGS=origin:%H,green_circle"
        ];

        RestartPreventExitStatus = [ 127 ];

        ExecStart = "${ntfy} startup";
      };
    };

    ntfy-shutdown = {
      description = "Send a notification on system shutdown (when service is stopped)";
      bindsTo = [ "network-online.target" ];
      after = [
        "network-online.target"
        "network.target"
      ];
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "oneshot";

        Environment = [
          "NTFY_TOPIC=https://ntfy.box.somas.is/system"
          "NTFY_TOKEN_FILE=${config.age.secrets.ntfy-token.path}"

          ''NTFY_TITLE="%H powering off"''
          "NTFY_TAGS=origin:%H,red_circle"
        ];

        RestartPreventExitStatus = [ 127 ];

        ExecStart = "${pkgs.coreutils}/bin/true";
        RemainAfterExit = true;
        ExecStop = "${ntfy} shutdown";
      };
    };
  };
}
