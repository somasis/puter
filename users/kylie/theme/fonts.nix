{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    inter
    paratype-pt-sans
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    twitter-color-emoji

    iosevka-bin
    (iosevka-bin.override { variant = "Aile"; })
    (iosevka-bin.override { variant = "Etoile"; })
    (iosevka-bin.override { variant = "Slab"; })
    sarasa-gothic
    spleen

    atkinson-hyperlegible
    atkinson-hyperlegible-next
    atkinson-monolegible
    atkinson-hyperlegible-mono

    lmodern

    linja-namako
    linja-pimeja-pona
    linja-pona
    linja-sike
    linja-suwi
    nasin-nanpa
    sitelen-seli-kiwen

    spleen

    greybeard
  ];

  fonts.fontconfig = {
    enable = true;

    # Better than "slight" on my 1080p monitor.
    hinting = "medium";

    defaultFonts = {
      sansSerif = [
        "Inter"
        "Noto Sans"
        "nasin-nanpa"
        "emoji"
      ];
      serif = [
        "Noto Serif"
        "nasin-nanpa"
        "emoji"
      ];
      monospace = [
        "Iosevka"
        "Sarasa Term CL"
        "nasin-nanpa"
        "emoji"
      ];
      emoji = lib.mkBefore [ "Twitter Color Emoji" ];
    };
  };

  programs.plasma.fonts = {
    general = {
      family = "Inter";
      pointSize = if osConfig.meta.type == "laptop" then 9 else 12;
    };

    fixedWidth = {
      family = "Iosevka";
      pointSize = if osConfig.meta.type == "laptop" then 10 else 12;
    };

    small = {
      family = "Inter";
      pointSize = if osConfig.meta.type == "laptop" then 8 else 9;
    };

    toolbar = {
      family = "Inter";
      weight = "medium";
      pointSize = if osConfig.meta.type == "laptop" then 9 else 13;
    };

    menu = {
      family = "Inter";
      weight = "light";
      pointSize = if osConfig.meta.type == "laptop" then 9 else 12;
    };

    windowTitle = {
      family = "Inter";
      weight = "demiBold";
      pointSize = if osConfig.meta.type == "laptop" then 9 else 12;
    };
  };
}
