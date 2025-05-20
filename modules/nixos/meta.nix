{ config
, lib
, ...
}:
let
  inherit (lib) types options mkOption;
in
{
  options.meta = {
    type = mkOption {
      description = ''
        Type of machine that this host is.

        A server is machine which is not expected to be used graphically,
        and generally automated tasks or background services should be
        considered of higher importance than responsiveness to user input.

        A desktop is a machine which is primarily used by a logged in user
        at a "seat"; user input (be it games or common computing tasks)
        always takes a higher priority than background tasks.

        A workstation is a machine which provides many services, and is
        often used remotely. It is more or less a server that can be used
        as a desktop and thus has similar prioritization of user input.

        A laptop is machine which may have less resources, or entail
        different expectations of what work will be done. It likely has
        less background tasks going on and is restricted by battery life;
        internet access may be considered more useful than storage. Like a
        desktop, but with potentially less resources, or with less expectation
        of constant uptime.
      '';
      type =
        with types;
        nullOr (enum [
          "server"
          "desktop"
          "workstation"
          "laptop"
        ]);
      default = null;
      example = "laptop";
    };

    desktop = mkOption {
      description = ''
        A boolean which indicates that this machine prioritizes a user at the
        desktop (and assumedly, a graphical session) over background processes.
      '';
      type = types.bool;

      default = config.meta.type != "server";
      defaultText = options.literalExpression ''config.meta.type != "server"'';
    };
  };
}
