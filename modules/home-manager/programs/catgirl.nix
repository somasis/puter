# FIXME it really don't work right now
{ lib
, config
, pkgs
, ...
}:
let
  inherit (lib)
    escape
    mapAttrs'
    mkIf
    nameValuePair

    generators
    ;

  inherit (lib.options)
    mkOption
    mkEnableOption
    mkPackageOption
    ;

  inherit (lib.types)
    attrsOf
    bool
    either
    enum
    listOf
    nonEmptyListOf
    nonEmptyStr
    nullOr
    path
    strMatching
    submodule

    ints
    ;

  cfg = config.programs.catgirl;
  pkg = config.programs.catgirl.package;

  configFormat = pkgs.formats.keyValue {
    listsAsDuplicateKeys = true;

    mkKeyValue =
      key: value:
      if builtins.isBool value then
        if value then "${escape [ ''='' ] key}" else ""
      else if builtins.isNull value then
        ""
      else if builtins.isAttrs value && key == "hash" then
        generators.mkKeyValueDefault { } " = " key "${toString value.seed},${toString value.bound}"
      else
        generators.mkKeyValueDefault { } " = " key value;
  };

  # <https://defs.ircdocs.horse/defs/chantypes>
  # <https://modern.ircdocs.horse/#channels>
  channelType = strMatching "^[&#!+][^ \a,]+";

  # <https://modern.ircdocs.horse/#clients>
  nickType = strMatching "^[^ ,*?!@$:&#!+.]+";

  mkUtilityOption =
    description: args:
    mkOption (
      {
        inherit description;
        type = nullOr path;
      }
      // args
    );

  mkGlobOption =
    desc: args:
    mkOption (
      {
        description = "${desc}, which may contain ‘*’, ‘?’ and ‘[]’ wildcards as in {manpage}glob(7)";
        type = nonEmptyStr;
        default = "*";
      }
      // args
    );

  # nick[!user@host [command [channel [message]]]]
  mkPatternOption =
    description: args:
    mkOption (
      {
        type = listOf (submodule {
          options = {
            nick = mkGlobOption "User nickname to match" { };
            user = mkGlobOption "User to match" { };
            host = mkGlobOption "User host to match" { };

            command = mkGlobOption "IRC commands to match against" {
              type = either
                (enum [
                  "INVITE"
                  "JOIN"
                  "NICK"
                  "NOTICE"
                  "PART"
                  "PRIVMSG"
                  "QUIT"
                  "SETNAME"
                ])
                nonEmptyStr;
            };

            channel = mkGlobOption "Channel to match against" { type = channelType; };

            message = mkGlobOption "Message to match against" { };
          };
        });
        default = [ ];
      }
      // args
    );

  settingsType = submodule {
    options = {
      copy =
        mkUtilityOption "utility to be used by the `/copy` command for copying a URL to the clipboard"
          { };
      notify =
        mkUtilityOption "utility to be used for sending notifications about message highlights"
          { };
      open = mkUtilityOption "utility to be used by the `/open` command for opening URLs" { };

      nick = mkOption {
        type = nullOr (either nickType (nonEmptyListOf nickType));
        description = ''
          Nickname(s) to attempt to connect with.
          If a list of nicks is given, the first one available will be used.
          If the list is empty or this option is null, `catgirl` will use the value of $USER.
        '';
        example = [
          "kylie"
          "kylie1"
          "kylie2"
        ];
      };

      port = mkOption { type = nullOr ints.u16; };

      hash = {
        seed = mkOption {
          type = ints.unsigned;
          description = "Initial seed for the color hash function that gives random colors to nicks and channels";
          default = 0;
        };

        bound = mkOption {
          type = ints.unsigned;
          description = "Maximum IRC color value which may be produced by color hash function";
          default = 75;
          example = 15;
        };
      };

      ignore = mkPatternOption "a list of case-insensitive message ignore patterns" { };
      highlight = mkPatternOption "a list of case-insensitive message highlight patterns" { };

      # Options which are booleans
      restrict = mkOption {
        type = bool;
        default = false;
      };
      quiet = mkOption {
        type = bool;
        default = false;
      };
      debug = mkOption {
        type = bool;
        default = false;
      };

      sasl-external = mkOption {
        type = bool;
        default = false;
      };
      cert = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
      };
      priv = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
      };

      log = mkOption {
        type = bool;
        default = false;
      };
      save = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
      };

      # Options which are non-empty strings
      join = mkOption {
        type = listOf (
          either channelType (
            attrsOf (submodule {
              options = {
                name = mkOption {
                  type = channelType;
                  description = "Name of channel to join";
                };

                key = mkOption {
                  type = nullOr nonEmptyStr;
                  description = "Key required to join channel";
                };
              };
            })
          )
        );

        description = "Channels to join";

        default = [ ];
      };

      real = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
      };
      user = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
      };
      host = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
      };

      pass = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
      };
    };
  };
in
{
  options.programs.catgirl = {
    enable = mkEnableOption "a curses-based, TLS-only IRC client";
    package = mkPackageOption pkgs "catgirl" { };

    settings = mkOption {
      type = settingsType;
      description = "Settings that should be set in all client configurations;";

      default = { };
    };

    networks = mkOption {
      type = attrsOf settingsType;
      description = ''
        Networks that client configurations should be created for; has higher priority than programs.catgirl.settings.
      '';

      default = { };
      example = {
        libera = {
          host = "irc.libera.chat";
          sasl-external = true;
          join = "#debian";
        };

        tilde = {
          host = "irc.tilde.chat";
          sasl-external = true;
          join = "#lobby";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkg ];

    xdg.configFile = mkIf (cfg.networks != { }) (
      mapAttrs'
        (
          n: v:
            nameValuePair "catgirl/${n}.conf" {
              source = configFormat.generate "${n}.conf" (lib.traceValSeq (cfg.settings // v));
            }
        )
        cfg.networks
    );
  };
}
