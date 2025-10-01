{
  pkgs,
  lib,
  ...
}:
{
  fonts = {
    enableDefaultPackages = false;

    packages = with pkgs; [
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
      sarasa-gothic # CJK in a style similar to Iosevka
      spleen

      lmodern

      linja-namako
      linja-pimeja-pona
      linja-pona
      linja-sike
      linja-suwi
      nasin-nanpa
      sitelen-seli-kiwen
    ];

    fontconfig = {
      allowBitmaps = false;
      useEmbeddedBitmaps = true;

      cache32Bit = true;

      antialias = true;
      hinting = {
        enable = true;

        # Better for my 1080p monitor.
        style = "medium";
      };

      subpixel = {
        rgba = "none";
        lcdfilter = "none";
      };

      defaultFonts = {
        sansSerif = lib.mkForce [
          "Inter"
          "Noto Sans"
          "nasin-nanpa"
          "emoji"
        ];
        serif = lib.mkForce [
          "Noto Serif"
          "nasin-nanpa"
          "emoji"
        ];
        monospace = lib.mkForce [
          "Iosevka"
          "Sarasa Term CL"
          "nasin-nanpa"
          "emoji"
        ];
        emoji = lib.mkBefore [ "Twitter Color Emoji" ];
      };
    };
  };

  console = {
    packages = [
      pkgs.spleen
      pkgs.uw-ttyp0
      pkgs.uni-vga
    ];
    font = "${pkgs.spleen}/share/consolefonts/spleen-12x24.psfu";
  };
}
