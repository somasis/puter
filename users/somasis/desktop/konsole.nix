{
  config,
  lib,
  ...
}:
let
  baseProfile = {
    colorScheme = "somasis";
    font = {
      name = config.programs.plasma.fonts.fixedWidth.family;
      size = config.programs.plasma.fonts.fixedWidth.pointSize;
    };

    extraConfig = {
      Appearance = {
        LineSpacing = 0;
        BoldIntense = true; # otherwise, nothing seems to even happen with bold fonts!
      };

      "Cursor Options".CursorShape = 1; # I-Beam

      General = {
        DimWhenInactive = false;
        InvertSelectionColors = true;
        SemanticInputClick = true;
        SemanticUpDown = true;
        TerminalCenter = true;
        TerminalMargin = 2;
        TerminalColumns = 90;
      };

      "Interaction Options" = {
        AllowEscapedLinks = true;
        AutoCopySelectedText = false;
        EscapedLinksSchema = lib.concatStringsSep ";" [
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
        HistoryMode = 1; # Limited history
        HistorySize = 10000; # lines
        MarkerColor = config.lib.somasis.colors.kde config.theme.colors.orange;
        ScrollBarPosition = 2; # Disable scrollbar
      };

      "Terminal Features" = {
        BlinkingCursorEnabled = true;
        FlowControlEnabled = false;
      };
    };
  };
in
{
  cache = with config.lib.somasis; {
    files = [
      (xdgDataDir "konsole/konsolestaterc")
    ];
  };

  programs = {
    konsole = {
      enable = true;

      extraConfig = {
        FileLocation = {
          scrollbackUseCacheLocation = true;
          scrollbackUseSystemLocation = false;
        };

        KonsoleWindow = {
          FocusFollowsMouse = true;
          RememberWindowSize = false;
          ShowWindowTitleOnTitleBar = true;
          UseSingleInstance = true;
        };

        MemorySettings.EnableMemoryMonitoring = true;

        "Notification Messages".CloseAllTabs = true;

        SearchSettings.SearchNoWrap = true;

        TabBar = {
          CloseTabOnMiddleMouseButton = true;
          ExpandTabWidth = true;
        };

        ThumbnailsSettings.EnableThumbnails = false;
      };

      defaultProfile = "somasis";
      customColorSchemes.somasis = ./konsole.colorscheme;
      profiles = with lib; {
        somasis = baseProfile;

        application = lib.recursiveUpdate baseProfile {
          extraConfig = {
            General = {
              Environment = lib.concatStringsSep "," (
                mapAttrsToList
                  (
                    n: v:
                    assert isValidPosixName n;
                    "${n}=${v}"
                  )
                  {
                    TERM = "xterm-256color";
                    COLORTERM = "truecolor";
                  }
              );

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
    };

    bash.initExtra = ''
      # Disable flow control keybinds, but only on a graphical terminal.
      # Flow control should be only controlled with Ctrl+S and Ctrl+Q on a vt,
      # so it can't be accidentally engaged without is being fixable that way.
      if [[ -v DISPLAY ]] || [[ -v WAYLAND_DISPLAY ]]; then
          PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND; }stty -ixon"
      fi
    '';
  };
}
