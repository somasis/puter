{
  config,
  lib,
  osConfig ? { },
  pkgs,
  ...
}:
let
  inherit (lib)
    types

    escapeShellArgs
    foldr
    literalExpression
    makeBinPath
    mapAttrsToList

    mkEnableOption
    mkIf
    mkOption

    optional
    optionalAttrs
    optionalString
    recursiveUpdate
    toShellVar
    ;

  mkPathSafeName = lib.replaceStrings [ "@" ":" "\\" "[" "]" ] [ "-" "-" "-" "" "" ];

  ssh = builtins.head (
    builtins.filter (x: x != null) [
      config.programs.ssh.package
      osConfig.programs.ssh.package
      pkgs.openssh
    ]
  );
  ssh-tunnel =
    prefix:
    pkgs.writeShellScript "ssh-tunnel" ''
      set -euo pipefail

      PATH=${
        makeBinPath [
          pkgs.coreutils
          ssh
        ]
      }:"$PATH"

      : "''${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"

      mkdir -p "$XDG_RUNTIME_DIR"/tunnel

      ssh_args=(
          # Fork only once the forwards have been established successfully.
          -f
          -o ExitOnForwardFailure=yes

          # Automation-related
          -o BatchMode=yes
          -o KbdInteractiveAuthentication=yes

          # Hardening-related
          -o StrictHostKeyChecking=no # Never connect when host has new keys
          -o UpdateHostKeys=yes # *Do* accept graceful key rotation
          -o CheckHostIP=yes # Defend against DNS spoofing

          # Disable various things that do not deal with the tunnel.
          -N # Don't run any commands
          -T # Don't allocate a terminal
          -a # Don't forward ssh-agent
          -x # Don't forward Xorg
          -k # Don't forward GSSAPI credentials
      )

      ${prefix}

      case "$type" in
          "dynamic")
              ssh_args+=( -D "localhost:$port" )
              ;;
          "local")
              listen="$XDG_RUNTIME_DIR"/tunnel/"$socket":"$remote_host":"$remote_port"
              ssh_args+=( -L "$listen" )
              ;;
      esac

      ssh_args+=( "$remote" )

      if [[ -v NOTIFY_SOCKET ]]; then
          ${pkgs.systemd}/bin/systemd-notify --status="$type $name tunnel to $remote_host:$remote_port (via $target) at localhost:$port"
      fi

      exec ssh "''${ssh_args[@]}"
    '';
in
{
  options.services.tunnels = {
    enable = mkEnableOption "Enable SSH tunnel management";

    tunnels = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          let
            t = config.services.tunnels.tunnels."${name}";
          in
          {
            options = {
              enable = mkOption {
                type = types.bool;
                description = ''
                  Enable this tunnel.
                  This is useful for disabling a tunnel when it's already
                  being provided by the local system's services.
                '';
                default =
                  if
                    (
                      (t.type == "local")
                      && (
                        t.remote == osConfig.networking.fqdnOrHostName
                        || t.remote == "${config.home.username}@${osConfig.networking.fqdnOrHostName}"
                      )
                      && (t.remotePort == t.port)
                    )
                    || (
                      (t.type == "dynamic")
                      && (
                        t.remote == osConfig.networking.fqdnOrHostName
                        || t.remote == "${config.home.username}@${osConfig.networking.fqdnOrHostName}"
                      )
                    )
                  then
                    false
                  else
                    true;
                defaultText = ''
                  False when either...

                    - Tunnel type is local, and remote is equal to either
                      osConfig.networking.fqdnOrHostName or "<user>@<fqdnOrHostName>",
                      and remote port is equal to local port.
                    - Tunnel type is dynamic, and rewmote is equal to either
                      osConfig.networking.fqdnOrHostName or "<user>@<fqdnOrHostName>",

                  and true otherwise.
                '';
              };

              name = mkOption {
                type = types.nonEmptyStr;
                description = "Pretty name for use by other stuff";
                default = name;
                defaultText = literalExpression ''config.services.tunnels.tunnels.<name>.port'';
                example = "ircd";
              };

              type = mkOption {
                type = types.enum [
                  "local"
                  "dynamic"
                ];
                description = "What type of tunnel to create: a local port forward (corresponding to ssh(1) option -L), or a dynamic port forward (corresponding to -D).";
                default = "local";
                example = "dynamic";
              };

              port = mkOption {
                type = types.ints.between 1025 65536;
                description = "Port on which the tunnel will be accessible locally";
                default = null;
                example = 9400;
              };

              remote = mkOption {
                type = types.nonEmptyStr;
                description = "Remote SSH host to create a tunnel to";
                default = null;
                example = "snowdenej@nsa.gov";
              };

              remoteHost = mkOption {
                type = types.nonEmptyStr;
                description = ''
                  Remote host which the tunnel should ultimately direct connections to.

                  Generally this should remain the default. The purpose of this setting
                  is primarily to allow hole-punching firewalls, by using the SSH host
                  specified in <remote> to connect to another host which that is
                  inaccessible from outside the SSH host's network.
                '';
                default = "localhost";
                example = "192.168.1.1";
              };

              remotePort = mkOption {
                type = types.port;
                description = "Remote port to tunnel to (only does something when type == local)";
                default = t.port;
                defaultText = literalExpression ''config.services.tunnels.tunnels.<name>.port'';
                example = 9400;
              };

              linger = mkOption {
                type = types.nonEmptyStr;
                description = "How long the tunnel process should be kept around after its last connection (only does something when type == local)";
                default = "5m";
                example = "90s";
              };

              extraOptions = mkOption {
                type = with types; listOf str;
                description = "Extra arguments to pass to the ssh tunnel process";
                default = [ ];
                example = [
                  "-o"
                  "ConnectTimeout=5"
                ];
              };
            };
          }
        )
      );

      description = "Set of tunnels to create";
      example = {
        ircd = {
          port = 9400;

          remote = "snowdenej@nsa.gov";
          remotePort = 9400;

          linger = "600s";
        };
      };

      default = { };
    };
  };

  config = mkIf config.services.tunnels.enable {
    systemd.user =
      (foldr
        (
          tunnel:
          let
            target = "${tunnel.remote}:${tunnel.name}";

            # We can't simply use %t/tunnel/${target}.sock or ${target}, because `ssh`
            # doesn't correctly parse colons in the instance name in -L's syntax
            socket = "tunnel-${mkPathSafeName tunnel.remote}-${mkPathSafeName tunnel.name}.sock";
          in
          units:
          recursiveUpdate units (
            lib.optionalAttrs tunnel.enable {
              targets."tunnels-${mkPathSafeName tunnel.remote}" = {
                Unit = {
                  Description = "Tunnels to ${tunnel.remote}";
                  PartOf = [ "tunnels.target" ];
                };
                Install.WantedBy = [ "tunnels.target" ];
              };

              sockets."tunnel-proxy-${mkPathSafeName target}" = optionalAttrs (tunnel.type == "local") {
                Unit = {
                  Description = "Listen for requests to connect to ${target}";
                  PartOf = [ "tunnels-${mkPathSafeName tunnel.remote}.target" ];
                };
                Install.WantedBy = [
                  "tunnels-${mkPathSafeName tunnel.remote}.target"
                  "sockets.target"
                ];

                Socket.ListenStream = [ tunnel.port ];
              };

              services."tunnel-proxy-${mkPathSafeName target}" = optionalAttrs (tunnel.type == "local") {
                Unit = {
                  Description = "Serve requests to connect to ${target}";
                  PartOf = [ "tunnels-${mkPathSafeName tunnel.remote}.target" ];

                  # Stop when tunnel-proxy-*.service stops/is no longer listening for socket activation
                  BindsTo = [
                    "tunnel-proxy-${mkPathSafeName target}.socket"
                    "tunnel-${mkPathSafeName target}.service"
                  ];

                  # Stop when tunnel-*.service stops
                  After = [
                    "tunnel-proxy-${mkPathSafeName target}.socket"
                    "tunnel-${mkPathSafeName target}.service"
                  ];
                };

                Service = {
                  ProtectSystem = true;

                  ExecStart = pkgs.writeShellScript "tunnel-listen-for-connection" ''
                    PATH=${
                      makeBinPath [
                        pkgs.coreutils
                        pkgs.gawk
                        pkgs.gnugrep
                        pkgs.iproute2
                      ]
                    }:"$PATH"

                    : "''${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"

                    ${toShellVar "target" target}
                    ${toShellVar "type" tunnel.type}
                    ${toShellVar "linger" tunnel.linger}
                    ${toShellVar "socket" socket}

                    mkdir -p "$XDG_RUNTIME_DIR"/tunnel

                    listen="$XDG_RUNTIME_DIR/tunnel/$socket"

                    exec ${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time="$linger" "$listen"
                  '';
                };
              };

              services."tunnel-${mkPathSafeName target}" = {
                Unit = {
                  Description = "Open tunnel to ${target}";
                  PartOf = [ "tunnels-${mkPathSafeName tunnel.remote}.target" ];

                  After = [ "ssh-agent.service" ];
                }
                // optionalAttrs (tunnel.type == "local") { StopWhenUnneeded = true; };

                Service = {
                  # Forking is used because it allows us to know exactly when the
                  # forwards have been established successfully. Otherwise, the
                  # socket's first request might not end up being served.
                  Type = "forking";

                  ExecStart = ssh-tunnel ''
                    ${toShellVar "target" target}
                    ${toShellVar "type" tunnel.type}
                    ${toShellVar "port" tunnel.port}
                    ${toShellVar "remote_host" tunnel.remoteHost}
                    ${toShellVar "remote_port" tunnel.remotePort}
                    ${toShellVar "remote" tunnel.remote}
                    ${toShellVar "socket" socket}
                    ${optionalString (
                      tunnel.extraOptions != [ ]
                    ) "ssh_args+=( ${escapeShellArgs tunnel.extraOptions} )"}
                  '';

                  ExecStopPost = optional (tunnel.type == "local") "${pkgs.coreutils}/bin/rm -f %t/tunnel/${socket}";

                  Restart = "on-failure";
                }
                // optionalAttrs osConfig.networking.networkmanager.enable {
                  ExecStartPre = [ "${pkgs.networkmanager}/bin/nm-online -q" ];
                };
              }
              // optionalAttrs (tunnel.type == "dynamic") {
                Install.WantedBy = [ "tunnels-${mkPathSafeName tunnel.remote}.target" ];
              };
            }
          )
        )
        {
          targets.tunnels = {
            Unit = {
              Description = "All tunnels";
              PartOf = [ "default.target" ];
            };

            Install.WantedBy = [ "default.target" ];
          };
        }
      )
        (mapAttrsToList (n: v: v) config.services.tunnels.tunnels);
  };
}
