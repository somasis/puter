{ config
, lib
, osConfig
, ...
}:
# Based off GNOME Colors, as always
# <https://raw.githubusercontent.com/gnome-colors/gnome-colors/refs/heads/master/gnome-colors/Palette.svg>
let
  # Visualize this by looking at the palette file linked above.
  palette = {
    brightPink = "#f9a1ac"; # Illustrious 1
    pink = "#dc6472"; # Illustrious 2
    dimPink = "#c6464b"; # Illustrious 3

    brightYellow = "#fce94f"; # Butter 1
    yellow = "#edd400"; # Butter 2
    dimYellow = "#c4a000"; # Butter 3

    brightOrange = "#faa546"; # Human 1
    orange = "#e07a1f"; # Human 2
    dimOrange = "#ce5c00"; # Human 3

    brightBrown = "#b49372"; # Dust 1
    brown = "#906e4c"; # Dust 2
    dimBrown = "#745536"; # Dust 3

    brightGreen = "#97bf60"; # Wise 1
    green = "#709937"; # Wise 2
    dimGreen = "#51751e"; # Wise 3

    brightBlue = "#729fcf"; # Brave 1
    blue = "#3465a4"; # Brave 2
    dimBlue = "#204a87"; # Brave 3

    brightPurple = "#ad7fa8"; # Noble 1
    purple = "#75507b"; # Noble 2
    dimPurple = "#5c3566"; # Noble 3

    brightRed = "#de5657"; # Wine 1
    red = "#c22f2f"; # Wine 2
    dimRed = "#a40000"; # Wine 3

    brightWhite = "#eeeeec"; # Aluminum 1
    white = "#d3d7cf"; # Aluminium 2
    dimWhite = "#babdb6"; # Aluminum 3

    dimBlack = "#888a85"; # Aluminum 4
    brightBlack = "#555753"; # Aluminum 5
    black = "#2e3436"; # Aluminum 6

    # From Tango color palette.
    cyan = "#06989a";
    brightCyan = "#34e2e2";
    dimCyan = "#06989a";
  };

  contrastsBestAgainstLight = with palette; [
    # brightPink
    pink
    dimPink

    # brightYellow
    # yellow
    dimYellow

    # brightOrange
    orange
    dimOrange

    # brightBrown
    brown
    dimBrown

    # brightGreen
    green
    dimGreen

    # brightBlue
    blue
    dimBlue

    brightPurple
    purple
    dimPurple

    brightRed
    red
    dimRed

    # brightWhite
    # white
    # dimWhite

    dimBlack
    brightBlack
    black
  ];
  contrastsBestAgainstDark = with palette; [
    brightPink
    # pink
    # dimPink

    brightYellow
    yellow
    # dimYellow

    brightOrange
    # orange
    # dimOrange

    brightBrown
    # brown
    # dimBrown

    brightGreen
    # green
    # dimGreen

    brightBlue
    # blue
    # dimBlue

    # brightPurple
    # purple
    # dimPurple

    # brightRed
    # red
    # dimRed

    brightWhite
    white
    dimWhite

    # dimBlack
    # brightBlack
    # black
  ];
in
with palette;
{
  theme.colors = palette // rec {
    # Colors by user interface functionality
    accent =
      if osConfig.networking.fqdnOrHostName == "esther.7596ff.com" then
        purple
      # else if osConfig.networking.fqdnOrHostName == "ilo.somas.is" then  blue
      else
        blue;

    brightAccent =
      if osConfig.networking.fqdnOrHostName == "esther.7596ff.com" then
        brightPurple
      # else if osConfig.networking.fqdnOrHostName == "ilo.somas.is" then brightBlue
      else
        brightBlue;

    dimAccent =
      if osConfig.networking.fqdnOrHostName == "esther.7596ff.com" then
        dimPurple
      # else if osConfig.networking.fqdnOrHostName == "ilo.somas.is" then dimBlue
      else
        dimBlue;

    accentLightText = "#eeeeec";
    accentDarkText = "#101010";

    accentText =
      if lib.any (x: accent == x) contrastsBestAgainstDark then
        accentDarkText
      else if lib.any (x: accent == x) contrastsBestAgainstLight then
        accentLightText
      else
        "#ffffff";

    brightAccentText =
      if lib.any (x: brightAccent == x) contrastsBestAgainstDark then
        accentDarkText
      else if lib.any (x: brightAccent == x) contrastsBestAgainstLight then
        accentLightText
      else
        "#ffffff";

    dimAccentText =
      if lib.any (x: dimAccent == x) contrastsBestAgainstDark then
        accentDarkText
      else if lib.any (x: dimAccent == x) contrastsBestAgainstLight then
        accentLightText
      else
        "#101010";

    lightWindowBackground = "#d8d8d8";
    lightWindowForeground = "#000000";

    darkWindowBackground = "#1f1f1f";
    darkWindowForeground = "#eeeeec";

    windowBackground = lightWindowBackground;
    windowForeground = lightWindowForeground;

    # Window/top toolbar header
    headerBackground = "#202020";
    headerForeground = "#dcdcdc";

    toolbarBackground = "#1f1f1f";
    toolbarForeground = "#eeeeec";

    buttonBackground = "#fafafa";
    buttonForeground = "#29292a";

    tooltipBackground = "#f5f5b5";
    tooltipForeground = "#000000";

    menuLightBackground = "#e4e4e4";
    menuLightForeground = accentDarkText;
    menuLightSelectedBackground = accent;
    menuLightSelectedForeground = accentText;
    menuBackground = menuLightBackground;
    menuForeground = menuLightForeground;
    menuSelectedBackground = menuLightSelectedBackground;
    menuSelectedForeground = menuLightSelectedForeground;
    menuDisabledForeground = "#7a7a7a";

    errorBackground = red;
    errorForeground = "#ffffff";
    warningBackground = orange;
    warningForeground = "#ffffff";
    infoBackground = tooltipBackground;
    infoForeground = tooltipForeground;

    terminalBackground = "#1f1f1f";
    terminalForeground = white;

    # Terminal color palette
    color0 = black;
    color1 = red;
    color2 = green;
    color3 = yellow;
    color4 = blue;
    color5 = pink;
    color6 = cyan;
    color7 = white;
    color8 = brightBlack;
    color9 = brightRed;
    color10 = brightGreen;
    color11 = brightYellow;
    color12 = brightBlue;
    color13 = brightPink;
    color14 = brightCyan;
    color15 = brightWhite;
  };
}
