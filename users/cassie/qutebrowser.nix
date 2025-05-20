{ lib, pkgs, ... }:
let
  # Convert an argument (either a path, or a path-like string) into a derivation
  # by reading the path into a text file. If passed a derivation, the function
  # does nothing and simply returns the argument.
  #
  # Type: :: (derivation|str|path) -> derivation
  drvOrPath =
    x: if !lib.isDerivation x then pkgs.writeText (builtins.baseNameOf x) (builtins.readFile x) else x;
in
{
  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;

    extraConfig = lib.fileContents (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/tinted-theming/base16-qutebrowser/refs/heads/main/themes/default/base16-catppuccin-mocha.config.py";
        hash = "sha256-fKjgEMUkzOd4qFNMsgGedzX8HTYDKZrS1X0GuY6uNXU=";
      }
    );

    keyBindings.normal = {
      "o" = "cmd-set-text -s :open -t";
      "O" = "cmd-set-text -s :open";
      "b" = "back";
      "<Ctrl-v>" = "spawn mpv {url}";
    };

    searchEngines = {
      nixpkgs = "https://search.nixos.org/packages?type=packages&query={}";
    };

    greasemonkey = map drvOrPath [
      (
        (pkgs.fetchFromGitHub {
          owner = "yuhaofe";
          repo = "Video-Quality-Fixer-for-Twitter";
          rev = "704f5e4387835b95cb730838ae1df97bebe928dc";
          hash = "sha256-oePFTou+Ho29458k129bPcPHmHyzsr0gfrH1H3Yjnpw=";
        })
        + "/vqfft.user.js"
      )
      (pkgs.fetchurl {
        name = "SendToClient.user.js";
        url = "https://gist.githubusercontent.com/notmarek/4f8fea8ae4e7cc524cba51a3594a128c/raw/SendToClient.user.js";
        hash = "sha256-NJ3FX6zuzAkMkQ3M6clLcRZ+7+vN06278V6s1E/pCZ0=";
      })
    ];

    settings = {
      auto_save.session = true;

      # completion.open_categories = ''["quickmarks", "bookmarks", "searchengines", "history", "filesystem"]'';

      downloads.position = "bottom";

      tabs.last_close = "blank";
      tabs.position = "right";
      tabs.select_on_remove = "last-used";
    };
  };
}
