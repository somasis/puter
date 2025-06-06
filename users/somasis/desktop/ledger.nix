{
  config,
  pkgs,
  lib,
  ...
}:
let
  hledgerConfigFormat =
    attrs:
    let
      attrsToFlags = lib.cli.toGNUCommandLine rec {
        mkOptionName = k: if builtins.stringLength k == 1 then "-${k}" else "--${k}"; # copied from function definition
        mkBool = k: v: if v then [ (mkOptionName k) ] else [ "${mkOptionName k}=no" ];
        optionValueSeparator = "=";
      };
      generalAttrs = attrs.general or { };
      commandAttrs = lib.removeAttrs attrs [ "general" ];

      generalFlags = attrsToFlags generalAttrs;
      commandFlags = lib.mapAttrsToList (
        n: v: lib.concatStringsSep " " ([ "[${n}]" ] ++ (attrsToFlags v))
      ) commandAttrs;
    in
    lib.concatLines (generalFlags ++ commandFlags);
in
{
  home.sessionVariables.LEDGER_FILE = "${config.home.homeDirectory}/ledger/journal.ledger";

  persist.directories = [
    {
      directory = config.lib.somasis.relativeToHome "${config.home.homeDirectory}/ledger";
      method = "symlink";
    }
  ];

  home.packages = [
    pkgs.hledger
    pkgs.hledger-check-fancyassertions
    pkgs.hledger-iadd
    pkgs.hledger-interest
    pkgs.hledger-ui
    # pkgs.hledger-web
    pkgs.puffin

    pkgs.hledger-utils

    pkgs.hledger-fmt
  ];

  xdg.configFile."hledger/hledger.conf".text = hledgerConfigFormat {
    general = {
      pretty = true;
      pager = false;
    };

    balance.cost = true;

    iadd.date-format = "%Y-%m-%d";
  };

  programs.qutebrowser.searchEngines."!ledger" = "https://ledger.somas.is/journal?q={}";

  home.shellAliases = {
    ledger = "hledger";
    led = "hledger";
    le = "hledger";
  };
}
