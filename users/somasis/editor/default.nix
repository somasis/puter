{
  config,
  lib,
  pkgs,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };

in
{
  imports = [
    ./filetype
    ./clipboard.nix
  ];

  home.packages = with pkgs; [
    # Used by spell.kak; see spell.nix for dictionaries
    aspell

    # Used by editorconfig.kak
    editorconfig-core-c

    meld

    vscode-langservers-extracted # CSS, HTML, JSON
    marksman # Markdown
    nixd # Nix
    bash-language-server
    taplo # TOML
    yaml-language-server
    jq-lsp
  ];

  xdg = {
    # TODO: Unnecessary when this pull request gets merged
    #       <https://github.com/mawww/kakoune/pull/4699>
    desktopEntries.kakoune =
      {
        name = "Kakoune";
        icon = "kakoune";

        genericName = "Text editor";
        comment = "Edit text files modally";
        categories = [
          "Utility"
          "Development"
          "TextTools"
          "TextEditor"
          "ConsoleOnly"
        ];

        exec = "kak -- %F";
        terminal = true;
        mimeType = [
          "text/*"
          "text/plain"
        ];
      }
      // lib.optionalAttrs config.programs.kitty.enable {
        settings = rec {
          StartupWMClass = "kakoune";
          TerminalOptions = "--class ${StartupWMClass} --instance-group ${StartupWMClass} --config ${config.xdg.configHome}/kitty/application.conf --single-instance --wait-for-single-instance-window-close";
        };
      }
      // lib.optionalAttrs config.programs.konsole.enable {
        settings = rec {
          StartupWMClass = "kakoune";
          TerminalOptions = "--desktopfile kakoune --separate --profile application";
        };
      };

    mimeApps.defaultApplications = lib.genAttrs [
      "text/*"
      "text/plain"
      "application/x-zerosize"
    ] (_: "kakoune.desktop");
  };

  programs.kakoune = {
    enable = true;
    defaultEditor = true;

    config = {
      numberLines = {
        enable = true;
        highlightCursor = true;
      };

      # FIXME showMatching.enable = true;
      showWhitespace = {
        enable = true;
        space = " ";
        tab = "␉";
      };

      keyMappings = [
        {
          docstring = "comment out the line(s) selected";
          mode = "normal";
          key = "<a-c>";
          effect = ": comment-line<ret>";
        }
        {
          docstring = "comment out the line(s) selected";
          mode = "insert";
          key = "<a-c>";
          effect = "<esc>: comment-line<ret>i";
        }
        {
          docstring = "comment out the string(s) selected";
          mode = "normal";
          key = "<a-C>";
          effect = ": comment-block<ret>";
        }
        {
          docstring = "comment out the string(s) selected";
          mode = "insert";
          key = "<a-C>";
          effect = "<esc>: comment-block<ret>i";
        }

        # {
        #   docstring = "unindent line";
        #   mode = "insert";
        #   key = "<s-tab>";
        #   effect = "<esc><i";
        # }

        {
          docstring = "jump to the word left of the cursor";
          mode = "prompt";
          key = "<c-left>";
          effect = "<a-B>";
        }
        {
          docstring = "jump to the word right of the cursor";
          mode = "prompt";
          key = "<c-right>";
          effect = "<a-E>";
        }

        {
          docstring = "create a new window";
          mode = "normal";
          key = "<c-n>";
          effect = ": new<ret>";
        }
        {
          docstring = "create a new window";
          mode = "insert";
          key = "<c-n>";
          effect = ": new<ret>i";
        }
        {
          docstring = "open a file";
          mode = "normal";
          key = "<c-o>";
          effect = ":edit ";
        }
        {
          docstring = "open a file";
          mode = "insert";
          key = "<c-o>";
          effect = "<esc>:edit ";
        }
        {
          docstring = "write the current buffer";
          mode = "normal";
          key = "<c-s>";
          effect = ": write<ret>;";
        }
        {
          docstring = "write the current buffer";
          mode = "insert";
          key = "<c-s>";
          effect = "<esc>: write<ret>i";
        }
        {
          docstring = "close the current buffer";
          mode = "normal";
          key = "<c-w>";
          effect = ": delete-buffer<ret>";
        }
        {
          docstring = "close the current buffer";
          mode = "insert";
          key = "<c-w>";
          effect = "<esc>: delete-buffer<ret>i";
        }
        {
          docstring = "quit Kakoune";
          mode = "normal";
          key = "<c-q>";
          effect = ": quit<ret>";
        }
        {
          docstring = "quit Kakoune";
          mode = "insert";
          key = "<c-q>";
          effect = "<esc>: quit<ret>";
        }

        {
          docstring = "find";
          mode = "normal";
          key = "<c-f>";
          effect = "/";
        }
        {
          docstring = "find";
          mode = "insert";
          key = "<c-f>";
          effect = "<esc>/";
        }

        {
          docstring = "copy selection to clipboard";
          mode = "normal";
          key = "<c-c>";
          effect = "y";
        }
        {
          docstring = "copy selection to clipboard";
          mode = "insert";
          key = "<c-c>";
          effect = "<esc>yi";
        }
        {
          docstring = "cut selection to clipboard";
          mode = "normal";
          key = "<c-x>";
          effect = "d";
        }
        {
          docstring = "cut selection to clipboard";
          mode = "insert";
          key = "<c-x>";
          effect = "<esc>cc";
        } # yank and delete and re-enter insert mode
        {
          docstring = "paste selection from clipboard";
          mode = "normal";
          key = "<c-v>";
          effect = "R";
        }
        {
          docstring = "paste selection from clipboard";
          mode = "insert";
          key = "<c-v>";
          effect = "<esc>Ri";
        }

        {
          docstring = "switch to the next buffer";
          mode = "normal";
          key = "<a-A>";
          effect = ": buffer-next<ret>";
        }
        {
          docstring = "switch to the next buffer";
          mode = "insert";
          key = "<a-A>";
          effect = "<esc>: buffer-next<ret>i";
        }
        {
          docstring = "select buffer contents";
          mode = "normal";
          key = "<c-a>";
          effect = "%";
        }
        {
          docstring = "select buffer contents";
          mode = "insert";
          key = "<c-a>";
          effect = "<esc>%i";
        }
        {
          docstring = "switch to the previous buffer";
          mode = "normal";
          key = "<a-a>";
          effect = ": buffer-previous<ret>";
        }
        {
          docstring = "switch to the previous buffer";
          mode = "insert";
          key = "<a-a>";
          effect = "<esc>: buffer-previous<ret>i";
        }
        {
          docstring = "switch to the debug buffer";
          mode = "normal";
          key = "<a-d>";
          effect = ": buffer *debug*<ret>";
        }
        {
          docstring = "switch to the debug buffer";
          mode = "insert";
          key = "<a-d>";
          effect = "<esc>: buffer *debug*<ret>i";
        }
        {
          docstring = "jump to the word left of the cursor";
          mode = "normal";
          key = "<c-left>";
          effect = "b;";
        }
        {
          docstring = "jump to the word left of the cursor";
          mode = "insert";
          key = "<c-left>";
          effect = "<esc>b;i";
        }
        {
          docstring = "jump to the word right of the cursor";
          mode = "normal";
          key = "<c-right>";
          effect = "w;";
        }
        {
          docstring = "jump to the word right of the cursor";
          mode = "insert";
          key = "<c-right>";
          effect = "<esc>w;i";
        }
        {
          docstring = "select the word left of the cursor";
          mode = "normal";
          key = "<c-s-left>";
          effect = "b";
        }
        {
          docstring = "select the word left of the cursor";
          mode = "insert";
          key = "<c-s-left>";
          effect = "<esc>bi";
        }
        {
          docstring = "expand selection to the word left of the cursor";
          mode = "normal";
          key = "<c-s-left>";
          effect = "B";
        }
        {
          docstring = "expand selection to the word left of the cursor";
          mode = "insert";
          key = "<c-s-left>";
          effect = "<esc>Bi";
        }
        {
          docstring = "expand selection to the word right of the cursor";
          mode = "normal";
          key = "<c-s-right>";
          effect = "W";
        }
        {
          docstring = "expand selection to the word right of the cursor";
          mode = "insert";
          key = "<c-s-right>";
          effect = "<esc>Wi";
        }
        {
          docstring = "delete the word left of the cursor";
          mode = "normal";
          key = "<a-backspace>";
          effect = "bd";
        }
        {
          docstring = "delete the word left of the cursor";
          mode = "insert";
          key = "<a-backspace>";
          effect = "<esc>bdi";
        }
        {
          docstring = "delete the word left of the cursor";
          mode = "normal";
          key = "<c-backspace>";
          effect = "bd";
        }
        {
          docstring = "delete the word left of the cursor";
          mode = "insert";
          key = "<c-backspace>";
          effect = "<esc>bdi";
        }
      ];

      hooks = [
        {
          name = "BufWritePre";
          option = ".*";
          commands = ''evaluate-commands %sh{ [ -n "$kak_opt_lintcmd" ] && echo lint || echo nop }'';
        }

        {
          name = "BufWritePre";
          option = ".*";
          commands = ''evaluate-commands %sh{ [ -n "$kak_opt_formatcmd" ] && echo format || echo nop }'';
        }

        # Load any plugins I have in ~/src/*.kak
        {
          name = "KakBegin";
          option = ".*";

          commands = ''
            evaluate-commands %sh{
                find -H ~/src \
                    ! -path '*/.*/*' \
                    -type d \
                    -name '*.kak' \
                    -maxdepth 1 \
                    -exec find {} \
                        -name '*.kak' \
                        -mindepth 1 \
                        -printf 'source %p\n' \
                        \;
            }
          '';
        }

        # Ensure that the default scratch buffer is entirely empty. Clearing the text is annoying.
        {
          name = "BufCreate";
          option = "\\*scratch\\*";
          commands = "execute-keys <esc>%d";
        }

        {
          name = "BufWritePre";
          option = ".*";
          commands = ''
            # Make directory for buffer prior to writing it.
            nop %sh{ mkdir -p "$(dirname "$kak_hook_param")" }
          '';
        }

        # Load file-specific settings, using editorconfig, modelines, and smarttab.kak's
        {
          name = "WinCreate";
          option = ".*";
          commands = ''
            # Default to space indentation and alignmnet.
            # expandtab

            # Read in all file-specific settings.
            # Modelines are higher priority than editorconfig.
            editorconfig-load %sh{ cd "$(dirname "$kak_buffile")" && upward .editorconfig }
            modeline-parse

            # Don't use noexpandtab when the file is tab-indented; use smarttab so that
            # alignments can be done with spaces.
            # set-option buffer aligntab false

            # autoconfigtab
          '';
        }

        # pass(1) temporary files.
        {
          name = "BufCreate";
          option = "/dev/shm/pass..*";
          commands = "autowrap-disable";
        }

        # Set autowrap highlighters, and update autowrap highlighters when the option changes.
        {
          name = "WinSetOption";
          option = "autowrap_column=.*";
          commands = ''
            add-highlighter -override window/column column %opt{autowrap_column} WrapColumn
          '';
        }

        # Use tab/alt-tab for completion
        {
          name = "InsertCompletionShow";
          option = ".*";
          commands = ''
            map window insert <tab> <c-n>
            map window insert <s-tab> <c-p>
          '';
        }

        {
          name = "InsertCompletionHide";
          option = ".*";
          commands = ''
            unmap window insert <tab> <c-n>
            unmap window insert <s-tab> <c-p>
          '';
        }
      ];

      ui = {
        enableMouse = true;
        assistant = "cat";
        setTitle = true;
        statusLine = "top";
      };
    };

    extraConfig =
      let
        kakColor = lib.replaceStrings [ "#" ] [ "rgb:" ];
      in
      with config.theme.colors;
      ''
        # Configure Kakoune LSP.
        eval %sh{kak-lsp --debug}

        set global lsp_auto_highlight_references true
        set global lsp_hover_anchor true

        lsp-inlay-hints-enable global
        lsp-auto-hover-enable
        lsp-auto-signature-help-enable

        hook global BufSetOption filetype=(.+) %{
            hook buffer BufWritePre .* lsp-formatting-sync
        }

        hook -group lsp-filetype-nix global BufSetOption filetype=nix %{
            set-option buffer lsp_servers %sh{cat ${
              tomlFormat.generate "kak-lsp-nix-servers.toml" {
                nixd = {
                  args = [ "--semantic-tokens=true" ];
                  root_globs = [
                    "flake.nix"
                    "shell.nix"
                  ];
                  settings = {
                    formatting.command = [
                      "nix"
                      "fmt"
                    ];
                    home-manager.expr = lib.concatStrings [
                      "(builtins.getFlake (builtins.toString ./.))"
                      ".nixosConfigurations.<name>.options.home-manager.users.type.getSubOptions []"
                    ];
                  };
                };
              }
            }}
        }

        hook global WinSetOption filetype=nix %{
            hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
            hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
            hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
            hook -once -always window WinSetOption filetype=.* %{
                remove-hooks window semantic-tokens
            }
        }

        map global user l ':enter-user-mode lsp<ret>' -docstring 'LSP mode'

        map global normal <tab> '<a-;><gt>'
        map global normal <s-tab> '<a-;><lt>'

        map -docstring 'Select next snippet placeholder' global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{execute-keys -with-hooks <a-;><gt>}<ret>'
        map global insert <s-tab> '<a-;><lt>'

        map -docstring 'LSP any symbol' global object a '<a-semicolon>lsp-object<ret>'
        map -docstring 'LSP any symbol' global object <a-a> '<a-semicolon>lsp-object<ret>'
        map -docstring 'LSP function or method' global object f '<a-semicolon>lsp-object Function Method<ret>'
        map -docstring 'LSP class interface or struct' global object t '<a-semicolon>lsp-object Class Interface Struct<ret>'
        map -docstring 'LSP errors and warnings' global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>'
        map -docstring 'LSP errors' global object D '<a-semicolon>lsp-diagnostic-object<ret>'

        # Appearance, highlighters, so on
        face global InfoDefault               Information
        face global InfoBlock                 Information
        face global InfoBlockQuote            Information
        face global InfoBullet                Information
        face global InfoHeader                Information
        face global InfoLink                  Information
        face global InfoLinkMono              Information
        face global InfoMono                  Information
        face global InfoRule                  Information
        face global InfoDiagnosticError       Information
        face global InfoDiagnosticHint        Information
        face global InfoDiagnosticInformation Information
        face global InfoDiagnosticWarning     Information

        # Highlight issues, nasty code, and notes, in descending order of goodness.
        add-highlighter global/user-fixme regex \b(BUG|FIXME|REMOVE)\b  1:red+bf
        add-highlighter global/user-note  regex \b(NOTE|HACK|XXX)\b     1:yellow+bf
        add-highlighter global/user-todo  regex \b(TODO|IDEA)\b         1:green+bf

        # Highlight trailing spaces.
        add-highlighter global/user-trailing-spaces \
            regex \h+$ 0:default,red+b

        # Highlight the current word the cursor is on.
        declare-option -hidden regex user_cursor_word
        set-face global UserCursorWord +bu

        hook global -group user-highlight-cursor-word NormalIdle .* %{
            evaluate-commands -draft %{
                try %{
                    execute-keys <space><a-i>w <a-k>\A\S+\z<ret>
                    set-option buffer user_cursor_word "\b\Q%val{selection}\E\b"
                } catch %{
                    set-option buffer user_cursor_word ""
                }
            }
        }

        add-highlighter global/user-highlight-cursor-word \
            dynregex '%opt{user_cursor_word}' 0:UserCursorWord

        # Disable startup changelog unless development version.
        set-option global startup_info_version -1

        set-face global Error               white,red,default+b
        set-face global Information         ${kakColor tooltipForeground},${kakColor tooltipBackground},default

        set-face global PrimaryCursor       ${kakColor accentText},${kakColor accent},default+b
        set-face global PrimaryCursorEol    ${kakColor accentText},${kakColor brightAccent},default+g
        set-face global PrimarySelection    ${kakColor accentText},${kakColor dimAccent},default+g

        set-face global SecondaryCursor     black,magenta,default+b
        set-face global SecondaryCursorEol  black,bright-magenta,default+g
        set-face global SecondarySelection  black,magenta,default+bg

        set-face global LineNumbers         bright-black,default,default
        set-face global LineNumbersWrapped  bright-black,default,default+i
        set-face global LineNumberCursor    white,default,default

        set-face global MatchingChar        +rbi

        set-face global Prompt              ${kakColor brightAccent},default,default+b
        set-face global StatusCursor        ${kakColor accentText},${kakColor accent},default+b
        set-face global StatusLine          ${kakColor toolbarForeground},${kakColor toolbarBackground},default
        set-face global StatusLineInfo      default,default,default
        set-face global StatusLineMode      green,default,default
        set-face global StatusLineValue     green,default,default

        set-face global BufferPadding       bright-black,default,default
        set-face global Whitespace          black,default,default+f
        set-face global WhitespaceIndent    black,default,default+f

        set-face global MenuBackground      ${kakColor menuForeground},${kakColor menuBackground},default
        set-face global MenuForeground      ${kakColor menuSelectedForeground},${kakColor menuSelectedBackground},default+b
        set-face global MenuInfo            bright-black,default,default+i

        lsp-enable
      '';

    plugins = with pkgs.kakounePlugins; [
      active-window-kak
      click-kak
      # Disabled because
      # > error running hook WinSetOption(filetype=)/: 2:5: 'remove-highlighter': no such id: 'gemini'¬
      # > error running hook WinSetOption(filetype=)/: 2:5: 'remove-highlighter': no such id: 'glsl'
      # kakoune-extra-filetypes
      kakoune-filetree
      kakoune-find
      kakoune-lsp
      kakoune-state-save
      # smarttab-kak
      tug
    ];
  };

  cache.directories = [
    (config.lib.somasis.xdgDataDir "meld")
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "kak/state-save";
    }
  ];

  sync.directories = [
    (config.lib.somasis.xdgDataDir "org.kde.syntax-highlighting/themes")
  ];

  editorconfig = {
    enable = true;

    settings = {
      "*" = {
        indent_size = 2;
        indent_style = "space";
        insert_final_newline = true;
        trim_trailing_whitespace = true;

        # NOTE: max_line_length being enabled triggers editorconfig-load to set a highlighter
        #       that is annoying to override.
        # max_line_length          = 100

        # Handled by shfmt(1).
        # Ideally these would be hidden behind a [[shell]] block or something; that's a work-in-progress:
        # <https://github.com/mvdan/sh/issues/664>
        binary_next_line = true;
        switch_case_indent = true;
        keep_padding = true;
      };
    };
  };
}
