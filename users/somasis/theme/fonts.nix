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

    lmodern

    linja-luka
    linja-namako
    linja-pi-pu-lukin
    linja-pi-tomo-lipu
    linja-pimeja-pona
    linja-pona
    linja-sike
    linja-suwi
    nasin-nanpa
    sitelen-seli-kiwen

    spleen
  ];

  fonts.fontconfig = {
    enable = true;
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
      pointSize = if osConfig.meta.type == "laptop" then 10 else 12;
    };

    fixedWidth = {
      family = "Iosevka";
      pointSize = if osConfig.meta.type == "laptop" then 10 else 12;
    };

    small = {
      # family = "PT Sans";
      family = "Inter";
      pointSize = if osConfig.meta.type == "laptop" then 8 else 10;
    };

    toolbar = {
      # family = "PT Sans";
      family = "Inter Display";
      pointSize = if osConfig.meta.type == "laptop" then 10 else 13;
    };

    menu = {
      # family = "PT Sans";
      family = "Inter Display";
      pointSize = if osConfig.meta.type == "laptop" then 10 else 12;
    };

    windowTitle = {
      # family = "Inter Display";
      # weight = "Bold";
      family = "Inter Display";
      weight = "medium";
      pointSize = if osConfig.meta.type == "laptop" then 10 else 12;
    };
  };
}
