{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.lib.somasis) commaList;
  pathList = lib.concatStringsSep ":";

  sponsorBlockSettings = {
    categories = [
      "sponsor"
      "selfpromo"
      "exclusive_access"
    ];
    actionTypes = [ "skip" ];
  };

  # Use % instead of $, just so I don't have to clutter
  # this with a lot of escapes for Nix's string interpolation.
  mpvTitle = [
    ''%{?pause==yes:⏸}%{?pause==no:⏵} ''

    ''%{!playlist-count==1:(%{playlist-pos-1}/%{playlist-count}) }'' # show playlist count if more than 1
    ''%{!duration==0: (%{time-pos}/%{duration})}''

    ''%{?metadata/by-key/Track: %{metadata/by-key/Track}. }''
    ''%{?metadata/by-key/Uploader:%{metadata/by-key/Uploader} - }''
    ''%{?metadata/by-key/Artist:%{metadata/by-key/Artist} - }''
    ''%{media-title}''
    ''%{?metadata/by-key/Album: (%{metadata/by-key/Album})}''

    ''%{?chapter: (%{chapter-metadata/title})}''

    # ''%{?chapter-metadata/title:: %{chapter}. "%{chapter-metadata/title}"}''
  ];

  sponsorBlock =
    pkgs.runCommandLocal "sb.user.js"
      rec {
        settings_json = builtins.toJSON sponsorBlockSettings;

        sb = pkgs.fetchFromGitHub {
          owner = "mchangrh";
          repo = "sb.js";
          rev = "08b0e7026b1ac154f2783a6f1a15f9dfd731549f";
          hash = "sha256-RFUdmn08H/gJ2PXWbCQYkzjgwrbKLmnCSGbBGl2W/lU=";
        };

        sb_userscript_header = sb + "/build/header.user.js";
        sb_nosettings = sb + "/docs/sb-nosettings.min.js";
        sb_user = sb + "/docs/sb.user.js";
      }
      ''
        PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.gnused
            pkgs.jq
            pkgs.nodePackages.prettier
          ]
        }:"$PATH"

        default_settings_js=$(
            grep -Pzo \
                '(?s)/\* START OF SETTINGS \*/.*/\* END OF SETTINGS \*/' \
                "$sb_user" \
                | tr -d '\0' \
        )

        default_settings_json=$(
            prettier --stdin-filepath ".js" <<<"$default_settings_block" \
                | sed -E \
                    -e '/^\/\/\s*/d' \
                    -e 's,\s+// .+|/\*.*\*/,,g' \
                    -e '/^const / { s/ = /": /; s/^const / "/ }' \
                    -e 's/;$/,/' \
                    -e '1 s/^/{/' \
                    -e '$ s/$/}/' \
                | prettier --stdin-filepath ".json"
        )

        # if ! jq -e <<< "$default_settings_json" >/dev/null; then
        #     printf "error: JSON magic ain't work right\n" >&2
        #     printf 'default_settings_js:\n%s\n' "$default_settings_js" >&2
        #     printf 'default_settings_json:\n%s\n' "$default_settings_json" >&2
        #     exit 1
        # fi

        merged_settings_js=$(
            jq -rs \
                '(.[0] + .[1]) | to_entries[] | "const \(.key) = \(.value | @json);"' \
                <(printf '%s' "$default_settings_json") \
                <(printf '%s' "$settings_json")
        )

        cat \
            "$sb_userscript_header" \
            <(printf '%s\n' "$merged_settings_js") \
            "$sb_nosettings" \
            > $out
      '';
in
{
  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "mpv";
    }
  ];
  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "jellyfin-mpv-shim";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "jellyfin.org";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "jellyfinmediaplayer";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "Jellyfin Media Player";
    }
  ];

  programs = {
    mpv = {
      enable = true;

      config = rec {
        hwdec = "auto-safe";

        # Buffer before starting playback, to prevent playback
        # from ending up stopping due to a slow start to streaming.
        cache-pause-initial = true;

        # Use yt-dlp's format preference.
        ytdl = true;
        ytdl-format = "ytdl";

        alang = commaList [
          "jpn"
          "tok"
          "en"
        ];
        slang = commaList [
          "en-US"
          "en"
          "tok"
          "es"
        ];

        sub-file-paths = pathList [
          "sub"
          "Sub"
          "subs"
          "Subs"
          "subtitle"
          "Subtitle"
          "subtitles"
          "Subtitles"
        ];
        sub-auto = "fuzzy";
        sub-font = "monospace";
        sub-filter-regex-append = "opensubtitles\.org";

        cover-art-auto = "fuzzy";
        audio-display = false;

        image-display-duration = "inf";

        screenshot-format = "png";
        screenshot-template = "%tY-%tm-%tdT%tH:%tM:%tSZ %F %P";
        screenshot-tag-colorspace = true;

        osd-font = "monospace";
        osd-font-size = 48;

        osd-on-seek = "msg-bar";

        osd-fractions = true;

        osd-margin-x = 24;
        osd-margin-y = 24;

        title = lib.replaceStrings [ "%" ] [ "$" ] (lib.concatStrings mpvTitle);
        term-title = ''mpv: ${title} ${lib.replaceStrings [ "%" ] [ "$" ] " (%{time-pos}/%{duration})"}'';

        # Watch later preferences
        watch-later-directory = "${config.xdg.cacheHome}/mpv/watch-later";
        watch-later-options-remove = commaList [
          "volume"
          "mute"
        ];
        save-position-on-quit = true;
        resume-playback-check-mtime = true;

        # osc = false; # required for thumbnail
      };

      # bindings = {
      #   ":" = ""
      # };

      scriptOpts = {
        # thumbnail = {
        #   osc = false;
        #   network = true;
        # };

        osc = {
          windowcontrols = false;

          deadzonesize = 0;
          vidscale = false;
          scalewindowed = 1.5;

          hidetimeout = 1000;
          unicodeminus = true;
        };

        console.font = "monospace";

        ytdl_hook.ytdl_path = "${config.programs.yt-dlp.package}/bin/yt-dlp";

        # <https://github.com/po5/mpv_sponsorblock/issues/31>
        sponsorblock = {
          local_database = false;
          server_address = "https://sponsor.ajay.app";
          categories = lib.concatStringsSep "," sponsorBlockSettings.categories;
        };
      };

      scripts = [
        # pkgs.mpvScripts.autoload
        pkgs.mpvScripts.mpris
        pkgs.mpvScripts.sponsorblock
        # pkgs.mpvScripts.thumbnail

        # Conflicts with mpvScripts.thumbnail
        # pkgs.mpvScripts.youtube-quality
      ];

      # package = pkgs.wrapMpv pkgs.mpv-unwrapped {
      #   # Use TZ=UTC for `mpv` so that screenshot-template always uses UTC time.
      #   # extraMakeWrapperArgs = [ "--set" "TZ" "UTC" ];

      #   # We can't use programs.mpv.scripts because of this being set.
      #   scripts = [
      #     # pkgs.mpvScripts.autoload
      #     pkgs.mpvScripts.mpris
      #     pkgs.mpvScripts.sponsorblock
      #     # pkgs.mpvScripts.thumbnail

      #     # Conflicts with mpvScripts.thumbnail
      #     # pkgs.mpvScripts.youtube-quality
      #   ];
      # };
    };

    yt-dlp = {
      enable = true;

      settings = {
        # Use bestvideo (but only >=1080p and >=30fps) and
        # bestaudio (from whichever stream has it)
        format = "bestvideo[height<=?1080][fps<=?30]+bestaudio/best";

        audio-multistreams = true;

        # Embed video metadata as much as possible
        embed-subs = true;
        # write-auto-subs = true;
        sub-langs = commaList [
          "en-US"
          "en.*"
          "tok"
          "es-en.*"
          "es-MX"
          "es.*"
        ];

        # embed-chapters = true;
        # embed-info-json = true;
        # embed-metadata = true;
        # embed-thumbnail = true;

        # concurrent-fragments = 4;

        trim-filenames = 128;

        # Use cookies from qutebrowser if available
        # FIXME(somasis 2025-04-28) disable temporarily, as this causes it to error out for me right now
        # cookies-from-browser = lib.mkIf config.programs.qutebrowser.enable
        #   "chromium:${config.xdg.dataHome}/qutebrowser/webengine";

        # Mark the video watched on its platform, if possible.
        mark-watched = true;
      };
    };

    qutebrowser = {
      greasemonkey = map config.lib.somasis.drvOrPath [
        # YouTube
        # (pkgs.fetchurl { hash = "sha256-YcjlG8GSSynwWvTLiWE+F6Wmdri5ZURSeqWXS1eaOIc="; url = "https://greasyfork.org/scripts/468740-restore-youtube-username-from-handle-to-custom/code/Restore%20YouTube%20Username%20from%20Handle%20to%20Custom.user.js"; })
        # (pkgs.fetchurl { hash = "sha256-d0uEUoCFkh4Wfnr7Kaw/eSvG1Q6r/Fe7hMaTiOmbpOQ="; url = "https://greasyfork.org/scripts/431573-youtube-cpu-tamer-by-animationframe/code/YouTube%20CPU%20Tamer%20by%20AnimationFrame.user.js"; })
        # (pkgs.fetchurl { hash = "sha256-UpnrCuxWSkVeVTp2BpCl0FQd85GUVeL2gPkff2f/yQs="; url = "https://greasyfork.org/scripts/811-resize-yt-to-window-size/code/Resize%20YT%20To%20Window%20Size.user.js"; })
        # (pkgs.fetchurl { hash = "sha256-6FK4x/rZA1BxWOmYLjVU4rEFqXHgpwAy0rYedQzza2g="; url = "https://greasyfork.org/scripts/370755-youtube-peek-preview/code/Youtube%20Peek%20Preview.user.js"; })
        (pkgs.fetchurl {
          hash = "sha256-pKxroIOn19WvcvBKA5/+ZkkA2YxXkdTjN3l2SLLcC0A=";
          url = "https://gist.githubusercontent.com/codiac-killer/87e027a2c4d5d5510b4af2d25bca5b01/raw/764a0821aa248ec4126b16cdba7516c7190d287d/youtube-autoskip.user.js";
        })
        # (pkgs.fetchurl { hash = "sha256-LnorSydM+dA/5poDUdOEZ1uPoAOMQwpbLmadng3qCqI="; url = "https://greasyfork.org/scripts/23329-disable-youtube-60-fps-force-30-fps/code/Disable%20YouTube%2060%20FPS%20(Force%2030%20FPS).user.js"; })
        # (pkgs.fetchurl { hash = "sha256-DnGZSjC1YkrJZ1H9qQ50GjR9DK84kc4JPHfA2OxHY14="; url = "https://greasyfork.org/scripts/471062-youtube-shorts-blocker/code/YouTube%20Shorts%20Blocker.user.js"; })

        # ((pkgs.fetchFromGitHub { owner = "RobertWesner"; repo = "YouTube-Play-All"; rev = "927cf27fb2a949e903378264960fc01261e4f3a0"; hash = "sha256-sPUMHf/PdTg++Ut8m0nbgZ+jmj1Ez9fr/UhP3/Ad1Jk="; }) + "/script.user.js")

        sponsorBlock

        # ((pkgs.fetchFromGitHub { owner = "Anarios"; repo = "return-youtube-dislike"; rev = "5c73825aadb81b6bf16cd5dff2b81a88562b6634"; hash = "sha256-+De9Ka9MYsR9az5Zb6w4gAJSKqU9GwqqO286hi9bGYY="; }) + "/Extensions/UserScript/Return Youtube Dislike.user.js")
      ];

      aliases.mpv = "spawn -u ${lib.getExe config.programs.mpv.package}";
      keyBindings.normal."zpv" = "mpv --loop=inf {url}";
    };
  };

  home = {
    packages = [
      pkgs.jellyfin-mpv-shim
      pkgs.jellyfin-media-player
    ];

    shellAliases.ytaudio = "yt-dlp --format bestaudio --extract-audio --audio-format wav";
  };
}
