{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      # PDF manipulation tools
      (mupdf.override {
        # MuPDF with just the command line tools
        enableX11 = false;
        enableCurl = false;
        enableGL = false;
      })

      # PDF editing tools
      stable.ocrmypdf
      tesseract
      stable.pdfarranger

      # Scanning tools
      skanpage
      deskew
      scantailor-advanced

      pdfgrep
    ];

  xdg.configFile = {
    "pdfarranger/config.ini".text =
      lib.generators.toINI
        {
          mkKeyValue =
            k: v:
            if builtins.isBool v then
              lib.generators.mkKeyValueDefault { } "=" k (if v then "True" else "False")
            else
              lib.generators.mkKeyValueDefault { } "=" k v;
        }
        {
          preferences = {
            content-loss-warning = true;
          };
        };

    "scantailor-advanced/scantailor-advanced.ini".text = lib.generators.toINI { } {
      settings = {
        auto_save_project = true;
        color_scheme = "native";
        enable_opengl = true;
        units = "in";
      };
    };
  };

  home.shellAliases = {
    pdfgrep = "pdfgrep --cache";
    tesseract = ''tesseract --user-words "$XDG_DATA_HOME"/tesseract/eng.user-words'';
    ocrmypdf = ''ocrmypdf --user-words "$XDG_DATA_HOME"/tesseract/eng.user-words --sidecar "$XDG_CACHE_HOME"/ocrmypdf/sidecar.txt'';
  };

  persist = {
    directories = [
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "tesseract";
      }
    ];
    files = [
      (config.lib.somasis.xdgConfigDir "skanpagerc")
    ];
  };

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "pdfgrep";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "ocrmypdf";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "skanpage";
    }
  ];
}
