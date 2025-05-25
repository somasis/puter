{ config
, osConfig
, lib
, ...
}: {
  sync = with config.lib.somasis; {
    files = [
      (xdgConfigDir "konsolerc")
      (xdgConfigDir "konsolesshconfig")
    ];
  };

  cache = with config.lib.somasis; {
    files = [
      (xdgDataDir "konsole/konsolestaterc")
    ];
  };

  programs = {
    konsole = {
      enable = true;
      defaultProfile = "somasis";
      customColorSchemes.somasis = ./konsole.colorscheme;
      profiles = with lib; rec {
        somasis = {
          colorScheme = "somasis";
          font = {
            name = config.programs.plasma.fonts.fixedWidth.family;
            size = config.programs.plasma.fonts.fixedWidth.pointSize;
          };

          extraConfig = {
            Appearance = {
              LineSpacing = 0;
              BoldIntense = false;
            };

            "Cursor Options".CursorShape = 1; # I-Beam

            General = {
              DimWhenInactive = false;
              InvertSelectionColors = false;
              SemanticInputClick = true;
              SemanticUpDown = true;
              TerminalCenter = true;
              TerminalMargin = 3;
              TerminalColumns = 90;
            };

            "Interaction Options" = {
              AllowEscapedLinks = true;
              AutoCopySelectedText = false;
              EscapedLinksSchema = concatStringsSep ";" [
                "http://"
                "https://"
                "file://"
                "gopher://"
                "gemini://"
                "ftp://"
                "ftps://"
                "ssh://"
                "git://"
              ];
            };

            Scrolling = {
              HistoryMode = 2; # Unlimited history
              MarkerColor = config.lib.somasis.colors.kde config.theme.colors.orange;
              ScrollBarPosition = 2; # Disable scrollbar
            };

            "Terminal Features" = {
              BlinkingCursorEnabled = true;
              FlowControlEnabled = false;
            };
          };
        };

        application.extraConfig = somasis.extraConfig // {
          General = {
            Environment =
              concatStringsSep "," (mapAttrsToList (n: v: assert isValidPosixName n; "${n}=${v}") {
                TERM = "xterm-256color";
                COLORTERM = "truecolor";
                EDITOR = "kate -b";
              });

            Icon = "window";

            LocalTabTitleFormat = "%n";
          };

          "Interaction Options" = {
            ColorFilterEnabled = false;
            CtrlRequiredForDrag = false;
            MiddleClickPasteMode = 1;
            OpenLinksByDirectClickEnabled = false;
            UnderlineFilesEnabled = true;
          };

          # Disable all scrolling related enhancements
          Scrolling = {
            HighlightScrolledLines = false;
            HistoryMode = 1; # Limited history
            ScrollBarPosition = 2; # Disable scrollbar
          };
        };
      };
    };

    bash.initExtra = ''
      # Disable flow control keybinds, but only on a graphical terminal.
      # Flow control should be only controlled with Ctrl+S and Ctrl+Q on a vt,
      # so it can't be accidentally engaged without is being fixable that way.
      [[ -v DISPLAY ]] && PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND; }stty -ixon"
    '';
  };
}
