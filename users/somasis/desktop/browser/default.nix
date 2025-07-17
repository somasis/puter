{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.lib.somasis)
    relativeToHome
    xdgConfigDir
    xdgCacheDir
    xdgDataDir
    ;

  dictcli = "${config.programs.qutebrowser.package}/share/qutebrowser/scripts/dictcli.py";

  tc = config.theme.colors;

  qutebrowser-darkman-set =
    with config.theme;
    with config.programs.qutebrowser;
    pkgs.writeShellScript "qutebrowser-darkman" ''
      set -euo pipefail

      : "''${QUTE_FIFO:=}"

      set_temp=
      case "''${1:-}" in
          --temp)
              set_temp=--temp
              shift
              ;;
      esac

      settings=()
      case "''${1:-$(darkman get)}" in
          light)
              settings=(
                  'colors.webpage.darkmode.enabled:false'
                  'colors.tabs.bar.bg:"${settings.colors.tabs.bar.bg}"'
                  'colors.completion.even.bg:"${settings.colors.completion.even.bg}"'
                  'colors.completion.odd.bg:"${settings.colors.completion.odd.bg}"'
                  'colors.completion.fg:"${settings.colors.completion.fg}"'
              )
          ;;
          dark)
              settings=(
                  'colors.webpage.darkmode.enabled:true'
                  'colors.tabs.bar.bg:"${colors.darkWindowBackground}"'
                  'colors.completion.even.bg:"${colors.menuLightBackground}"'
                  'colors.completion.odd.bg:"${colors.menuLightBackground}"'
                  'colors.completion.fg:"${colors.menuLightForeground}"'
              )
          ;;
      esac

      # Construct the list of settings key:values
      qutebrowser_command=
      for setting in "''${settings[@]}"; do
          name=''${setting%%:*}
          value=''${setting#*:}
          qutebrowser_command="''${qutebrowser_command:+$qutebrowser_command ;; }set $set_temp $name $value"
      done

      printf ':%s\n' "$qutebrowser_command" > "$QUTE_FIFO"
    '';

  translate = pkgs.writeShellScript "translate" ''
    set -euo pipefail

    : "''${QUTE_FIFO:?}"
    : "''${QUTE_URL:=''${1?no URL was provided}}"
    PATH=${lib.makeBinPath [ pkgs.translate-shell ]}:"$PATH"

    url=$(trans -no-browser -- "$QUTE_URL")
    printf 'open -t -r %s\n' "$url" > "''${QUTE_FIFO}"
  '';

  yank-text-anchor = pkgs.writeShellScript "yank-text-anchor" ''
    set -euo pipefail

    PATH=${
      lib.makeBinPath [
        config.programs.jq.package
        pkgs.coreutils
        pkgs.gnused
        pkgs.trurl
        pkgs.util-linux
      ]
    }

    : "''${QUTE_FIFO:?}"
    exec >>"''${QUTE_FIFO}"

    : "''${QUTE_SELECTED_TEXT:-}"
    if [ -z "$QUTE_SELECTED_TEXT" ]; then
        printf 'message-error "%s"\n' "yank-text-anchor: no text selected"
        exit 1
    fi

    : "''${QUTE_URL:?}"

    # Strip fragment (https://hostname.com/index.html#fragment).
    url=$(trurl -s fragment= -f - <<<"$QUTE_URL")

    # Strip trailing newline.
    text_start=$(printf '%s' "$QUTE_SELECTED_TEXT")

    text_end=
    text_start=$(
        sed \
            -e 's/^[[:space:]][[:space:]]*//' \
            -e 's/[[:space:]][[:space:]]*$//' \
            <<<"$text_start"
    )

    if [ "''${#text_start}" -ge 300 ]; then
        # Use range-based matching if >=300 characters in text.
        text_end=$(<<<"$text_start" tr -d '\n' | tr '[:space:]' ' ' | rev | cut -d' ' -f1-5 | rev)
        text_start=$(<<<"$text_start" tr '[:space:]' ' ' | cut -d ' ' -f1-5)
    fi

    if [ -n "$text_end" ]; then
        text_end=$(jq -Rr '@uri' <<<"$text_end")
    fi

    text_start=$(jq -Rr '@uri' <<<"$text_start")

    url="$url#:~:text=$text_start''${text_end:+,$text_end}"

    printf 'yank -q inline "%s" ;; message-info "Yanked URL of highlighted text to clipboard: %s"\n' "''${url}" "''${url}"
  '';

  inherit (osConfig.services) tor;

  proxies =
    lib.optional (
      tor.enable && tor.client.enable
    ) "socks://${tor.client.socksListenAddress.addr}:${toString tor.client.socksListenAddress.port}"
    ++ lib.optionals config.services.tunnels.enable (
      lib.mapAttrsToList (_: tunnel: "socks://127.0.0.1:${toString tunnel.port}") (
        lib.filterAttrs (_: tunnel: tunnel.type == "dynamic") config.services.tunnels.tunnels
      )
    );
in
{
  imports = [
    ./greasemonkey
    ./blocking.nix
    ./reader.nix
    ./redirects.nix
    ./search.nix
  ];

  persist = {
    directories = [
      (xdgConfigDir "qutebrowser")
      (xdgConfigDir "chromium")
    ];

    # files = [
    #   # BUG(?): Can't make autoconfig.yml an impermanent file; I think qutebrowser
    #   #         modifies it atomically (write new file -> rename to replace) so I
    #   #         think that it gets upset when a bind mount is used.
    #   # (xdgConfigDir "qutebrowser/autoconfig.yml")
    #   # (xdgConfigDir "qutebrowser/bookmarks/urls")
    #   # (xdgConfigDir "qutebrowser/quickmarks")
    # ];
  };

  cache = {
    directories = [
      (xdgCacheDir "chromium")
      (xdgCacheDir "qutebrowser")
      (xdgDataDir "qutebrowser/greasemonkey/requires")
      (xdgDataDir "qutebrowser/qtwebengine_dictionaries")

      # WebEngine's Local storage, I think.
      # I think it also has cookies stored in it.
      (xdgDataDir "qutebrowser/webengine")
    ];
    files = [
      (xdgDataDir "qutebrowser/adblock-cache.dat")
      (xdgDataDir "qutebrowser/blocked-hosts")
    ];
  };

  log = {
    files = [
      (xdgDataDir "qutebrowser/cmd-history")
      (xdgDataDir "qutebrowser/history.sqlite")
      (xdgDataDir "qutebrowser/state")
    ];
  };

  # Some qutebrowser data is synchronized between computers
  sync = {
    directories = [
      (xdgDataDir "qutebrowser/sessions")
    ];
    files = [
      (xdgConfigDir "qutebrowser/bookmarks/urls")
      (xdgConfigDir "qutebrowser/quickmarks")
    ];
  };

  # Ensure the default session exists, if necessary. Prevents a possible write error later on
  # when rebuilding or starting a session for the first time.
  systemd.user.tmpfiles.rules = [
    "f ${config.sync.persistentStoragePath}/${relativeToHome config.xdg.dataHome}/qutebrowser/sessions/${config.programs.qutebrowser.settings.session.default_name}.yml - - - -  "
    "f ${config.xdg.dataHome}/qutebrowser/sessions/.stignore - - - - _autosave.yml"
  ];

  home.sessionVariables."BROWSER" = lib.mkIf config.programs.qutebrowser.enable "qutebrowser";
  xdg.mimeApps = {
    defaultApplications = lib.mkIf config.programs.qutebrowser.enable (
      lib.genAttrs [
        "application/xhtml"
        "text/html"
        "text/xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ] (_: "org.qutebrowser.qutebrowser.desktop")
    );

    # associations.removed = lib.genAttrs
    #   [
    #     "application/xhtml"
    #     "text/html"
    #     "text/xml"
    #     "x-scheme-handler/http"
    #     "x-scheme-handler/https"
    #     "x-scheme-handler/about"
    #     "x-scheme-handler/unknown"
    #   ]
    #   (_: "chromium.desktop")
    # ;
  };

  nixpkgs.allowUnfreePackages = [ "widevine-cdm" ];

  programs = {
    qutebrowser = {
      enable = true;

      package = pkgs.qutebrowser.override {
        withPdfReader = config.programs.qutebrowser.settings.content.pdfjs;
        enableWideVine = true;
      };

      loadAutoconfig = true;

      settings = rec {
        changelog_after_upgrade = "patch";

        logging.level.console = "error";

        # Clear default aliases
        aliases = { };

        # Always restore open sites when qutebrowser is reopened.
        # Equivalent of Firefox's "Restore previous session" setting.
        auto_save.session = true;

        # Load a restored tab as soon as it takes focus.
        session.lazy_restore = true;

        session.default_name = "${config.home.username}@${osConfig.networking.fqdnOrHostName}";

        # Unlimited tab focus switching history.
        tabs = {
          focus_stack_size = -1;
          undo_stack_size = -1;

          # Close when the last tab is closed.
          last_close = "close";
        };

        # Open a blank page when :open is given with no arguments.
        url = rec {
          default_page = "about:blank";
          start_pages = default_page;
        };

        completion = {
          delay = 110; # seems to be about right to make history completion not slow down the input showing up

          cmd_history_max_items = 10000;

          # Shrink the completion menu to the amount of items.
          shrink = true;

          scrollbar = {
            width = 16;
            padding = 4;
          };
        };

        hints = {
          radius = 0;
          border = "1px solid ${tc.accent}";
        };

        keyhint = {
          radius = 10;
          delay = 0;
        };
        prompt = {
          filebrowser = true;
          radius = 10;
        };

        content = {
          proxy = "system";

          webrtc_ip_handling_policy = "default-public-interface-only";

          tls.certificate_errors = "ask-block-thirdparty";

          cookies.accept = "no-3rdparty";
          fullscreen.window = true;

          javascript = {
            # Allow JavaScript to read from or write to the xos-upclipboard.
            clipboard = "access-paste";
            can_open_tabs_automatically = true;
          };

          # Draw the background color and images also when the page is printed.
          print_element_backgrounds = false;

          # Request that websites minimize non-essential animations and motion.
          prefers_reduced_motion = true;

          # List of user stylesheet filenames to use. These apply globally.
          user_stylesheets = map builtins.toString [
            (pkgs.writeText "system.user.css" ''
              @font-face {
                  font-family: ui-sans-serif;
                  src: local(sans-serif);
              }

              @font-face {
                  font-family: ui-serif;
                  src: local(serif);
              }

              @font-face {
                  font-family: ui-monospace;
                  src: local(monospace);
              }

              @font-family {
                  font-family: -apple-system;
                  src: local(sans-serif);
              }

              @font-family {
                  font-family: BlinkMacSystemFont;
                  src: local(sans-serif);
              }
            '')

            # NOTE: causes problems with some websites (Twitter, for example) not showing
            #       anything when highlighting text in input boxes and textareas.
            # (pkgs.writeText "system-highlight-color.user.css" ''
            #   :focus {
            #       outline-color: ${config.lib.somasis.colors.rgb tc.accent};
            #   }
            # '')

            (pkgs.writeText "highlight-anchors.user.css" ''
              h1:target,h2:target,h3:target,h4:target,h5:target,h6:target {
                  background-color: #ffff00;
              }
            '')
          ];
        };

        # Languages preferences.
        spellcheck.languages = [
          "en-US"
          "en-AU"
          "en-GB"
          "es-ES"
        ];
        content.headers.accept_language = lib.concatStringsSep "," (
          lib.reverseList (
            lib.imap1 (i: v: ''${v};q=${lib.substring 0 5 (builtins.toString (i * .001))}'') (
              lib.reverseList [
                "en-US"
                "en"
                "tok"
                "es"
              ]
            )
          )
        );

        # Use the actual title for notification titles, rather
        # than the site's URL of origin.
        content.notifications.show_origin = false;

        confirm_quit = [ "downloads" ];

        zoom.mouse_divider = 2048; # Allow for more precise zooming increments.

        qt.highdpi = true;

        # Fonts.
        fonts = {
          default_family = "sans-serif";
          default_size = "${toString config.programs.plasma.fonts.general.pointSize}pt";

          web = {
            family = rec {
              sans_serif = "sans-serif";
              serif = "serif";
              fixed = "monospace";
              standard = serif;
            };

            size.default_fixed = 14;
          };

          completion = {
            entry = "default_size monospace";
            category = "bold default_size sans-serif";
          };

          statusbar = "default_size monospace";
          keyhint = "default_size monospace";
          hints = "default_size monospace";

          downloads = "default_size sans-serif";

          messages = {
            error = "default_size monospace";
            info = "default_size monospace";
            warning = "default_size monospace";
          };
        };

        # Downloads bar.
        downloads.position = "bottom";

        # Statusbar.
        statusbar.position = "top";
        statusbar.widgets = [
          "keypress"
          "url"
          "scroll"
          "history"
          "tabs"
          "progress"
        ];

        completion.open_categories = [
          "quickmarks"
          "searchengines"
          "bookmarks"
          "history"
          "filesystem"
        ];

        colors = {
          webpage.bg = "";

          downloads = {
            bar.bg = tc.windowBackground;
            start.bg = tc.windowBackground;
            stop.bg = tc.brightGreen;
            error.bg = tc.red;
          };

          statusbar = {
            normal.bg = tc.headerBackground;
            normal.fg = tc.headerForeground;

            command.bg = tc.terminalBackground;
            command.fg = tc.terminalForeground;

            insert.bg = tc.dimGreen;
            insert.fg = tc.headerForeground;

            passthrough.bg = tc.brightBrown;
            passthrough.fg = tc.headerForeground;

            private.bg = tc.dimPurple;
            private.fg = tc.headerForeground;

            progress.bg = tc.accent;

            url = {
              fg = tc.toolbarForeground;
              hover.fg = tc.blue;

              error.fg = tc.brightRed;
              warn.fg = tc.orange;

              success.http.fg = tc.brightRed;
              success.https.fg = tc.brightAccent;
            };
          };

          tooltip.bg = tc.tooltipBackground;
          tooltip.fg = tc.tooltipForeground;

          keyhint = {
            bg = tc.tooltipBackground;
            fg = tc.tooltipForeground;
            suffix.fg = tc.red;
          };

          hints = {
            bg = tc.tooltipBackground;
            fg = tc.tooltipForeground;
            match.fg = tc.red;
          };

          prompts = {
            bg = tc.windowBackground;
            fg = tc.windowForeground;
            border = "2px solid ${tc.accent}";
            selected.bg = tc.accent;
            selected.fg = tc.accentText;
          };

          completion = rec {
            even.bg = tc.white;
            odd.bg = tc.white;
            fg = tc.black;

            category = {
              inherit (even) bg;
              inherit fg;
              border.bottom = even.bg;
              border.top = even.bg;
            };

            item.selected = rec {
              bg = tc.accent;
              border.bottom = bg;
              border.top = bg;
              fg = tc.white;
              match.fg = tc.red;
            };

            scrollbar.bg = even.bg;
            scrollbar.fg = tc.accent;
          };

          tabs = {
            bar.bg = tc.windowBackground;
            odd.bg = tc.toolbarBackground;
            even.bg = tc.toolbarBackground;

            even.fg = tc.toolbarForeground;
            odd.fg = tc.toolbarForeground;

            selected = {
              even.bg = tc.brightAccent;
              even.fg = tc.accentText;
              odd.bg = tc.brightAccent;
              odd.fg = tc.accentText;
            };

            pinned = {
              even.bg = tc.dimAccent;
              even.fg = tc.accentText;
              odd.bg = tc.dimAccent;
              odd.fg = tc.accentText;
              selected.even.bg = tc.brightAccent;
              selected.even.fg = tc.accentText;
              selected.odd.bg = tc.brightAccent;
              selected.odd.fg = tc.accentText;
            };
          };

          messages = rec {
            error.bg = tc.errorBackground;
            error.fg = tc.errorForeground;
            error.border = error.bg;
            warning.bg = tc.warningBackground;
            warning.fg = tc.warningForeground;
            warning.border = warning.bg;
            info.bg = tc.infoBackground;
            info.fg = tc.infoForeground;
            info.border = info.bg;
          };

          contextmenu = {
            menu.bg = tc.menuBackground;
            menu.fg = tc.menuForeground;
            selected.bg = tc.menuSelectedBackground;
            selected.fg = tc.menuSelectedForeground;
            disabled.fg = tc.menuDisabledForeground;
          };
        };

        # Tabs.
        tabs = {
          position = "left";

          title = {
            format = "{perc}{audio}{current_title}";
            format_pinned = "{audio}{current_title}";
            elide = "middle";
          };

          favicons.scale = if osConfig.meta.type == "laptop" then 1.0 else 1.25;
          indicator.width = 0;
          width = if osConfig.meta.type == "laptop" then "16%" else "20%";
          close_mouse_button = "middle";
          select_on_remove = "next";
        };

        fonts.tabs = {
          unselected = "default_size sans-serif";
          selected = "600 default_size sans-serif";
        };

        # Window.
        window.title_format = "{current_title}{title_sep}qutebrowser{private}";

        # Messages.
        messages.timeout = 5000;

        # Interacting with page elements.
        input = {
          insert_mode = {
            auto_enter = true;
            auto_leave = true;
            leave_on_load = true;
            plugins = true;
          };

          spatial_navigation = false;
        };

        url.open_base_url = true;

        scrolling.bar = "always";
      };

      # enableDefaultBindings = false;
      aliases = {
        history-filter = "spawn --output-messages qutebrowser-history-filter";
        translate = "spawn -u ${translate}";
        yank-text-anchor = "spawn -u ${yank-text-anchor}";
        darkman-set = "spawn -u --output-messages ${qutebrowser-darkman-set}";
      };

      keyBindings = lib.mkMerge [
        # Keys that should bind on all modes
        (lib.genAttrs
          [
            "normal"
            "insert"
            "passthrough"
            "caret"
            "yesno"
            "caret"
          ]
          (mode: {
            # Firefox-ish navigation controls...
            "<Alt+Escape>" = "stop";
            "<Alt+Left>" = "back --quiet";
            "<Alt+Right>" = "forward --quiet";
            "<Alt+Up>" = "navigate up";

            "<Alt+Shift+Left>" = "navigate prev";
            "<Alt+Shift+Right>" = "navigate next";
            "<Alt+Shift+Up>" = "navigate strip";

            "<Alt+Shift+a>" = "tab-prev";
            "<Alt+a>" = "tab-next";

            "<Ctrl+Shift+Up>" = "tab-move -";
            "<Ctrl+Shift+Down>" = "tab-move +";

            "<Ctrl+r>" = "reload";
            "<F5>" = "reload";
            "<Ctrl+Shift+r>" = "reload -f";
            "<Ctrl+F5>" = "reload -f";

            "<Ctrl+t>" = "open -t";

            "<Ctrl+w>" = "tab-close";
            "<Ctrl+Shift+w>" = "tab-close -o";

            "<Alt+`>" = "cmd-set-text :";
            "<Ctrl+l>" = "cmd-set-text :open {url}";
          })
        )
        {
          passthrough."<Shift+Escape>" = "mode-leave";

          normal."<Shift+Escape>" = "mode-enter passthrough";

          normal."zpt" = "translate {url}";
          normal."ya" = "yank-text-anchor";

          normal."ql" = "cmd-set-text -s :quickmark-load";
          normal."qL" = "bookmark-list";
          normal."qa" = "cmd-set-text -s :quickmark-add {url} \"{url:host}\"";
          normal."qd" = lib.mkMerge [
            "cmd-set-text :quickmark-del {url:domain}"
            "fake-key -g <Tab>"
          ];

          normal."bl" = "cmd-set-text -s :bookmark-load";
          normal."bL" = "bookmark-list -j";
          # normal."ba" =
          #   let
          #     escape-command =
          #       pkgs.writeShellScript "escape-command" ''
          #         command="''${1?no command given}"
          #         shift

          #         escape() {
          #             local escape="$1"
          #             local unescaped="$2"
          #             local escaped="$unescaped"
          #             local final
          #             escaped=''${escaped//$escape/\\$escape}
          #             final="$escaped"
          #             [[ "$escaped" == "$unescaped" ]] || final="\"$unescaped\""
          #             printf '%s' "$final"
          #         }

          #         : "''${QUTE_FIFO:?}"
          #         : "''${QUTE_URL:?}"

          #         args=( "$@" )
          #         escaped_args=()
          #         for arg in "''${args[@]}"; do
          #             arg=$(escape '"' "$arg")
          #             escaped_args+=( "$arg" )
          #         done

          #         printf "$command\n" "''${escaped_args[@]}" > "$QUTE_FIFO"
          #       '';
          #   in
          #   "spawn -u ${escape-command} 'cmd-set-text -s :bookmark-add %s %s' {url} {title}"
          # ;
          normal."ba" = "cmd-set-text -s :bookmark-add {url} \"{title}\"";
          normal."bd" = lib.mkMerge [
            "cmd-set-text :bookmark-del {url:domain}"
            "fake-key -g <Tab>"
          ];

          normal."dd" = "download";
          normal."dc" = "download-cancel";
          normal."dq" = "download-clear";
          normal."dD" = "download-delete";
          normal."do" = "download-open";
          normal."dr" = "download-remove";
          normal."dR" = "download-retry";

          normal."!" = "cmd-set-text :open !";
          normal."gss" = "cmd-set-text -s :open site:{url:domain}";

          normal."cnp" =
            if proxies != [ ] then
              ''config-cycle -p content.proxy ${lib.concatStringsSep " " ([ "system" ] ++ proxies)}''
            else
              "nop";

          normal.";;" = "hint all";

          normal."<Ctrl+f>" = "cmd-set-text /";
          normal."<Ctrl+Shift+f>" = "cmd-set-text ?";
          normal."<Ctrl+Shift+i>" = "devtools window";

          # Emulate Tree Style Tabs keyboard shortcuts.
          normal."<F1>" = lib.mkMerge [
            "config-cycle tabs.show never always"
            "config-cycle statusbar.show in-mode always"
          ];

          # Provide some Kakoune-style keyboard shortcuts.
          normal."gg" = "scroll-to-perc 0";
          normal."ge" = "scroll-to-perc 100";

          normal."zsm" = "open -rt https://mastodon.social/authorize_interaction?uri={url}";
          normal."zst" = "open -rt https://twitter.com/share?url={url}";

          normal."cnt" =
            if
              (with tor; enable && client.enable && settings.ControlPort != [ ] && settings.ControlPort != null)
            then
              "spawn --userscript tor_identity"
            else
              "nop";

          prompt."<Alt+Up>" = "rl-filename-rubout";
        }
        {
          prompt = lib.genAttrs [
            "<Ctrl+y>"
            "<Alt+e>"
            "<Ctrl+Shift+w>"
          ] (key: null);

          normal = lib.genAttrs [
            "G"
            "gd"
            "ad"
            "cd"
            "<Escape>"
            "F"
            "f"
            "gi"
            "q"
            "wf"
            "r"
            "d"
            "b"
            "<Ctrl+Tab>"
            "<Ctrl+Shift+Tab>"
            "q"
            "<Ctrl+q>"
            "<F11>"
          ] (key: null);
        }
      ];

      extraConfig = lib.concatStrings [
        ''
          c.hints.padding = {"top": 2, "bottom": 2, "left": 2, "right": 2}
        ''
        # TODO how is this done properly in programs.qutebrowser.settings?
        (lib.optionalString (osConfig.meta.type == "laptop") ''
          c.statusbar.padding = {"top": 14, "bottom": 0, "left": 2, "right": 8}
          c.tabs.padding = {"top": 6, "bottom": 6, "left": 8, "right": 6}
        '')
        (lib.optionalString (osConfig.meta.type != "laptop") ''
          c.statusbar.padding = {"top": 28, "bottom": 0, "left": 4, "right": 11}
          c.tabs.padding = {"top": 6, "bottom": 6, "left": 8, "right": 6}
        '')
      ];
    };

    chromium = {
      enable = false;
      package = pkgs.ungoogled-chromium.override { enableWideVine = true; };

      dictionaries = with pkgs.hunspellDictsChromium; [
        en-us
        en-gb
      ];

      extensions = [
        # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
        # { id = "naepdomgkenhinolocfifgehidddafch"; } # Browserpass
      ];

      commandLineArgs = [
        "--homepage=${config.programs.qutebrowser.settings.url.default_page}"
      ];
    };

    browserpass = {
      inherit (config.programs.chromium) enable;
      browsers = [ "chromium" ];
    };
  };

  systemd.user = {
    services.qutebrowser-dictionaries = {
      Unit.Description = "Install/update qutebrowser's spell checking dictionaries";

      Service = {
        Type = "oneshot";

        ExecCondition = pkgs.writeShellScript "if-qutebrowser-dictionaries" ''
          ${lib.toShellVar "PATH" (
            lib.makeBinPath [
              pkgs.coreutils
              pkgs.gnugrep
            ]
          )}
          ${lib.toShellVar "spellcheck_languages" config.programs.qutebrowser.settings.spellcheck.languages}

          dictionaries=()
          installed_dictionaries=()

          list=$(${dictcli} list)
          mapfile -s 1 -t dictionaries < <(<<<"$list" cut -d' ' -f1 | sort)
          mapfile -s 1 -t dictionaries_to_update < <(<<<"''${list}" grep -i 'update' | cut -d' ' -f1 | sort)
          mapfile -s 1 -t installed_dictionaries < <(<<<"$list" grep -Ev ' +- +$' | cut -d' ' -f1 | sort)

          for dict in "''${dictionaries[@]}"; do
              for lang in "''${spellcheck_languages[@]}"; do
                  case "''${dict,,}" in
                      "''${lang,,}"*)
                          case " ''${installed_dictionaries[*]} " in
                              *" ''${dict} "*) : ;;
                              *) dictionaries_to_install+=( "''${dict}" ) ;;
                          esac
                          ;;
                  esac
              done
          done

          if [[ -n "''${dictionaries_to_install[*]}''${dictionaries_to_update[*]}" ]]; then
              exit 0
          else
              exit 1 # nothing to do
          fi
        '';

        ExecStart = pkgs.writeShellScript "install-or-install-qutebrowser-dictionaries" ''
          ${lib.toShellVar "PATH" (
            lib.makeBinPath [
              pkgs.coreutils
              pkgs.gnugrep
            ]
          )}
          ${lib.toShellVar "spellcheck_languages" config.programs.qutebrowser.settings.spellcheck.languages}

          dictionaries=()
          dictionaries_to_update=()
          installed_dictionaries=()
          needed_dictionaries=()

          list=$(${dictcli} list)
          mapfile -s 1 -t dictionaries < <(<<<"''${list}" cut -d' ' -f1 | sort)
          mapfile -s 1 -t dictionaries_to_update < <(<<<"''${list}" grep -i 'update' | cut -d' ' -f1 | sort)
          mapfile -s 1 -t installed_dictionaries < <(<<<"''${list}" grep -Ev ' +- +$' | cut -d' ' -f1 | sort)

          for dict in "''${dictionaries[@]}"; do
              for lang in "''${spellcheck_languages[@]}"; do
                  case "''${dict,,}" in
                      "''${lang,,}"*)
                          case " ''${installed_dictionaries[*]} " in
                              *" ''${dict} "*) : ;;
                              *) dictionaries_to_install+=( "''${dict}" ) ;;
                          esac
                          ;;
                  esac
              done
          done

          ${dictcli} install "''${dictionaries_to_install[@]}" || exit 1

          if [[ -n "''${dictionaries_to_update[*]}" ]]; then
              ${dictcli} update || exit 1
          fi
        '';
        RemainAfterExit = false;
      };
    };

    timers.qutebrowser-dictionaries = {
      Unit.Description = "Install/update qutebrowser's spell checking dictionaries";
      Install.WantedBy = [ "timers.target" ];

      Timer = {
        OnCalendar = "monthly";
        Persistent = true;
      };
    };
  };

  home.packages =
    with pkgs;
    with kdePackages;
    (
      (lib.optional config.programs.qutebrowser.enable somasis-qutebrowser-tools)
      ++ (lib.optional config.programs.chromium.enable plasma-browser-integration)
    );

  services.darkman =
    let
      qutebrowser-change-color = mode: ''
        if ${pkgs.procps}/bin/pgrep -u "$USER" -laf '(python)?.*/bin/\.?qutebrowser(-wrapped)?' >/dev/null 2>&1; then
            # Method from home-manager's `modules/program/qutebrowser.nix`, to avoid using
            # `qutebrowser`, which would cause an infinite recursion...
            hash="$(echo -n "$USER" | md5sum | cut -d' ' -f1)"
            socket="''${XDG_RUNTIME_DIR:-/run/user/$UID}/qutebrowser/ipc-$hash"
            if [[ -S $socket ]]; then
              command=${
                lib.escapeShellArg (
                  builtins.toJSON {
                    args = [
                      ":darkman-set --temp ${mode}"
                    ];
                    target_arg = null;
                    protocol_version = 1;
                  }
                )
              }
              echo "$command" | ${pkgs.socat}/bin/socat -lf /dev/null - UNIX-CONNECT:"$socket"
            fi
            unset hash socket command
        fi
      '';
    in
    {
      lightModeScripts.qutebrowser = qutebrowser-change-color "light";
      darkModeScripts.qutebrowser = qutebrowser-change-color "dark";
    };
}
