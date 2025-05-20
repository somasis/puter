{ config
, pkgs
, ...
}:
let
  wordSeparators = lib.concatStrings [
    # Kitty defaults
    # "@"
    # "-"
    # "."
    # "/"
    # "_"
    # "~"
    # "?"
    # "&"
    # "="
    # "%"
    # "+"
    # "#"

    # Alacritty defaults
    ","
    "│"
    "`"
    "|"
    ":"
    ''\''
    "\\\""
    "'"
    " "
    "("
    ")"
    "["
    "]"
    "{"
    "}"
    "<"
    ">"

    # More rarely occuring
    "‹"
    "›"

    # Unicode box characters/tree characters
    "─"
    "→"

    "\t"

    "¬" # Used by Kakoune for the newline indicator
    ";"

    "‘"
    "’"
    "‚"
    "‛"
    "“"
    "”"
    "„"
    "‟"

    "="
  ];
in
{
  home.packages = [ (pkgs.writeShellScriptBin "xterm" ''exec alacritty "$@"'') ];

  services.sxhkd.keybindings."super + b" = "alacritty";

  programs.alacritty = {
    enable = true;

    settings =
      let
        alacrittyExtendedKeys = pkgs.fetchFromGitHub {
          owner = "alexherbo2";
          repo = "alacritty-extended-keys";
          rev = "acbdcb765550b8d52eb77a5e47f5d2a0ff7a2337";
          hash = "sha256-KKzJWZ1PEKHVl7vBiRuZg8TyhE0nWohDNWxkP53amZ8=";
        };
      in
      {
        include = [ "${alacrittyExtendedKeys}/keys.yml" ];

        cursor = {
          style = {
            shape = "Beam";
            blinking = "On";
          };
          unfocused_hollow = false;
          thickness = 0.25;
          blink_interval = 750;
        };

        font.size = 10.0;

        colors = {
          primary = {
            inherit (config.theme.colors)
              foreground
              background
              ;
          };

          normal = {
            inherit (config.theme.colors)
              black
              red
              green
              yellow
              blue
              magenta
              cyan
              white
              ;
          };

          bright = {
            black = config.theme.colors.brightBlack;
            red = config.theme.colors.brightRed;
            green = config.theme.colors.brightGreen;
            yellow = config.theme.colors.brightYellow;
            blue = config.theme.colors.brightBlue;
            magenta = config.theme.colors.brightMagenta;
            cyan = config.theme.colors.brightCyan;
            white = config.theme.colors.brightWhite;
          };

          footer_bar = {
            background = config.theme.colors.accent;
            foreground = "#ffffff";
          };
        };

        scrolling = {
          multiplier = 2;
          history = 20000;
        };

        selection = {
          save_to_clipboard = true;
          semantic_escape_chars = wordSeparators;
        };
      };
  };
}
