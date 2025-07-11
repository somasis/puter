{
  config,
  pkgs,
  lib,
  ...
}:
let
  skimList = lib.concatStringsSep ",";
  attrsToSkimList = a: skimList (lib.mapAttrsToList (n: v: "${n}:${builtins.toString v}") a);
in
{
  programs.skim = {
    enable = true;
    defaultOptions =
      let
        binds = attrsToSkimList { ctrl-h = "unix-word-rubout"; };

        colors = attrsToSkimList {
          bg = -1;
          fg = -1;

          matched_bg = -1;
          matched = 1;

          current_bg = "#ffffff";
          current = config.theme.colors.accent;

          current_match_bg = 1;
          current_match = -1;

          query_bg = -1;
          query = -1;

          info = 0;
          border = 0;
          prompt = 9;
          pointer = config.theme.colors.accent;
          marker = 9;
          spinner = 2;
          header = 12;
        };
      in
      [
        "--inline-info"

        "--prompt '/ '"
        "--cmd-prompt '∴ '"

        "--color=bw,${colors}"
        "--bind=${binds}"
      ];
  };
}
