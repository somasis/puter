{
  pkgs,
  ...
}:
let
  statixFormat = pkgs.writeJqScript {
    name = "format-statix";

    jqArgs.raw-output = true;

    text = ''
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
  };

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

        set-option window formatcmd 'nixfmt -f "$kak_buffile"'
        set-option window lintcmd ${lint}
      '';
    }
  ];
}
