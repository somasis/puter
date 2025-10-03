{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs)
    lib
    stdenvNoCC
    nix-update-script
    fetchurl
    fetchFromGitHub
    callPackage
    ;

  userstyleToGreasemonkeyScript =
    {
      src,

      # Some styles are dependent on their script loading order,
      # and since we don't really have much control over the
      # script loading order, this is an easy workaround.
      cssForceImportant ? false,
      ...
    }@args:
    let
      code_header = ''
        (function () {
          "use strict";

          function domain(domain) {
            return new URLPattern({ domain: domain }).test(document.location);
          }

          var style = "";
      '';

      code_footer = ''
          if (style != "") {
            document.addEventListener("DOMContentLoaded", (event) => {
              GM_addStyle(style);
            });
          };
        })();
      '';

      cssForceImportantSed = lib.optionalString cssForceImportant "-e '/.*:.*;$/ s/;/!important;/'";

      stem = lib.removeSuffix ".user.css" (lib.getName args.src);
    in
    assert (lib.isStorePath args.src);
    pkgs.runCommandNoCC "${stem}.user.js"
      (
        {
          inherit code_header code_footer;
          nativeBuildInputs = [
            pkgs.gnused
            pkgs.nodePackages.prettier
          ];
        }
        // args
      )
      ''
        matches=$(
            sed -En \
                -e '/^@-moz-document\s+domain\(".+"\)/ {
                    s|@-moz-document\s+domain\("(.+)"\).*|// @match *://\1/*|
                    p
                }' \
                "$src"
        )

        original_header=$(
            sed -E '/\/\*\s+==UserStyle==/,/==\/UserStyle==\s+\*\//!d' "$src"
        )
        [ -n "$original_header" ] || exit 1

        edited_header=$(
            sed -E \
                -e '/^@/ s|^|// |' \
                -e 's|^\/\* |// |' \
                -e '/^==\/UserStyle== \*\// {
                    s| \*/||
                    s|^|// |
                }' \
                -e '/\/\/ ==\/?UserStyle==/ s/UserStyle/UserScript/' \
                -e '/\/\/ ==\/UserScript==/ d' \
                <<<"$original_header"

            # '// @run-at document-start' cannot be used with GM_addStyle :(
            # <https://github.com/qutebrowser/qutebrowser/issues/4322>
            printf '%s\n' \
                "$matches" \
                '// @grant GM_addStyle' \
                '// @run-at document-start' \
                '// ==/UserScript=='
        )

        original_code=$(
            sed -E '/\/\*\s+==UserStyle==/,/==\/UserStyle==\s+\*\//d' "$src" \
                | prettier --stdin-filepath "$src"
        )
        [ -n "$original_code" ] || exit 1

        edited_code=$(
            sed -E \
                -e '/^@-moz-document\s+domain\("?/,/^\}$/ {
                    s|@-moz-document\s+(.+)\s+\{|if (\1) {\nstyle +=`|
                    s|^\}|`;\n};|
                }' ${cssForceImportantSed} \
                <<<"$original_code"
        )
        edited_code=$(
            printf '%s\n' \
                "$code_header" \
                "$edited_code" \
                "$code_footer"
        )
        [ -n "$edited_code" ] || exit 1

        printf '%s\n' "$edited_header" "$edited_code" > "$out"
        prettier --write "$out" || exit 1
      '';

  mkUserstyle =
    { src, ... }@args:
    let
      src' = userstyleToGreasemonkeyScript args;
    in
    mkGreasemonkeyScript (args // { src = src'; });

  mkGreasemonkeyScript = lib.makeOverridable (
    {
      pname ? null,
      version ? null,
      src ? null,
      file ? null,

      url ? null,
      hash ? null,
      ...
    }@args:
    assert (lib.isString pname);
    stdenvNoCC.mkDerivation (
      rec {
        inherit pname version;

        name =
          if args ? "name" then
            args.name
          else if args ? "version" then
            "${pname}-${version}.user.js"
          else
            "${pname}.user.js";

        src =
          if args ? "src" then
            args.src
          else if args ? "url" && args ? "hash" then
            if args.url != null && args.hash != null then
              fetchurl {
                inherit (args) url hash;
                downloadToTemp = true;
                postFetch = lib.optionalString (version != null) ''
                  # Ensure that the script's version matches the derivation $version;
                  # most userscript sites don't let us get versioned script URLs,
                  # so this is to prevent us from downloading the wrong version.
                  script_version=$(
                      sed -n \
                          -e '/\/\/.*@version.*/ {
                              s/.*@version\s\s*//
                              p
                          }' \
                          "$downloadedFile" \
                          | tr -cd '[0-9.A-Za-z-]'
                  )

                  expected_version=${lib.escapeShellArg version}

                  if [[ "$script_version" != "$expected_version" ]]; then
                      printf 'Version mismatch between expected version and downloaded version (%s vs. %s)\n' \
                          "$expected_version" \
                          "$script_version" \
                          >&2
                      exit 1
                  fi

                  cat "$downloadedFile" > "$out"
                '';
              }
            else
              throw "url and hash must be specified"
          else
            null;

        unpackPhase = lib.optionalString (src != null) ''
          if [[ -f "$src" ]]; then
              cat "$src" > "$out"
          fi
        '';

        installPhase = (args.installPhase or "") + ''
          sed -i \
              -e '/\/\/.*@downloadURL/d' \
              -e '/\/\/.*@updateURL/d' \
              "$out"
        '';

        passthru = {
          updateScript = nix-update-script { };
        }
        // (args.passthru or { });
      }
      // (lib.removeAttrs args [
        "name"
        "unpackPhase"
        "postPatch"
        "passthru"
      ])
    )
  );
in
{
  inherit mkGreasemonkeyScript;

  fastmail-without-bevels = mkUserstyle {
    pname = "fastmail-without-bevels";
    version = "20250805.14.44";
    src = fetchurl {
      url = "https://userstyles.world/api/style/23557.user.css";
      hash = "sha256-nw5eGInimsa5zB3ZrhnU3QgA3YCy6xdgEEDSdHjD9Uc=";
    };
    cssForceImportant = true;
  };

  anchor-links = mkGreasemonkeyScript {
    pname = "anchor-links";
    src = ./anchor-links.user.js;
  };
  quirks = mkGreasemonkeyScript {
    pname = "quirks";
    src = ./quirks.user.js;
  };
  recaptcha-unpaid-labor = mkGreasemonkeyScript {
    pname = "recaptcha-unpaid-labor";
    src = ./recaptcha-unpaid-labor.user.js;
  };
  rewrite-smolweb = mkGreasemonkeyScript {
    pname = "rewrite-smolweb";
    src = ./rewrite-smolweb.user.js;
  };

  reddit-comment-auto-expander = mkGreasemonkeyScript {
    pname = "reddit-comment-auto-expander";
    version = "0.91";
    url = "https://update.greasyfork.org/scripts/546618/Reddit%20Comment%20Auto-Expander%20%28Smooth%29%3A.user.js";
    hash = "sha256-SdJ8a8eus2+/oSP6MnNgfURK+DQsbJJVbCLSxZU7baY=";
  };

  reddit-highlighter = mkGreasemonkeyScript {
    pname = "reddit-highlighter";
    version = "1.2.0";
    url = "https://greasyfork.org/scripts/39312-reddit-highlighter/code/Reddit%20Highlighter.user.js";
    hash = "sha256-JKOu+pG8rjUTCriwMxn8fNVYtMDGiSeA97oA2iKIfp0=";
  };

  lobsters-highlighter = mkGreasemonkeyScript {
    pname = "lobsters-highlighter";
    version = "1.0.1";
    url = "https://greasyfork.org/scripts/40906-lobsters-highlighter/code/Lobsters%20Highlighter.user.js";
    hash = "sha256-MUno65ouPgiOnMvZ0NW3sTxePRPC+vBHNhukwjnvExc=";
  };

  lobsters-open-in-new-tab = mkGreasemonkeyScript {
    pname = "lobsters-open-in-new-tab";
    version = "0.0.1.20191112103250";
    url = "https://greasyfork.org/scripts/392307-lobste-rs-open-in-new-tab/code/Lobsters%20Open%20in%20New%20Tab.user.js";
    hash = "sha256-VyqfdSVRNPEaT8MmEq9+zaDBke+71jkecgoDD3oPGus=";
  };

  fb-clean-my-feeds = mkGreasemonkeyScript {
    pname = "fb-clean-my-feeds";
    version = "5.02";
    url = "https://greasyfork.org/scripts/431970-fb-clean-my-feeds/code/FB%20-%20Clean%20my%20feeds.user.js";
    hash = "sha256-Oag98n8SIxK0rbGW6JXd0K9d5piWMtq52KpjCzqletw=";
  };

  instagram-video-controls = mkGreasemonkeyScript {
    pname = "instagram-video-controls";
    version = "1.0.3";
    url = "https://greasyfork.org/scripts/451541-instagram-video-controls/code/Instagram%20Video%20Controls.user.js";
    hash = "sha256-HKWz05MP6g2US7TYzmAjwgXcWzRv6nU6nAROXi5Xhos=";
  };

  twitter-direct = mkGreasemonkeyScript {
    pname = "twitter-direct";
    version = "3.1.2";
    url = "https://greasyfork.org/scripts/404632-twitter-direct/code/Twitter%20Direct.user.js";
    hash = "sha256-gCGVnulgirTWUkhkmM0MrATztvA352oifkQnDUp1Z0o=";
  };

  video-quality-fixer-for-twitter = mkGreasemonkeyScript {
    pname = "video-quality-fixer-for-twitter";
    version = "0.2.0";
    src =
      (pkgs.fetchFromGitHub {
        owner = "yuhaofe";
        repo = "Video-Quality-Fixer-for-Twitter";
        rev = "704f5e4387835b95cb730838ae1df97bebe928dc";
        hash = "sha256-oePFTou+Ho29458k129bPcPHmHyzsr0gfrH1H3Yjnpw=";
      })
      + "/vqfft.user.js";
  };

  betterttv = mkGreasemonkeyScript {
    pname = "betterttv";
    version = "0.0.2";
    url = "https://nightdev.com/betterttv/other/betterttv.user.js";
    hash = "sha256-xVHHhhxmhgTV+C0QSWJpvxq0r7R1Pe1LGPzc9bsBvU8=";
  };

  disable-google-search-result-url-redirector = mkGreasemonkeyScript {
    pname = "disable-google-search-result-url-redirector";
    version = "1.1.16";
    url = "https://greasyfork.org/scripts/32635-disable-google-search-result-url-redirector/code/Disable%20Google%20Search%20Result%20URL%20Redirector.user.js";
    hash = "sha256-4A4vzwBcBLuyr0Ua+a6/HaoEFbe5JbQNdBi01lFnRwg=";
  };

  google-image-direct-view = mkGreasemonkeyScript {
    pname = "google-image-direct-view";
    version = "3.6";
    url = "https://greasyfork.org/scripts/398189-google-image-direct-view/code/Google%20Image%20Direct%20View.user.js";
    hash = "sha256-44IE62+Cx8owoTMZEgD/OjPnopVMD7PVrF/1hzbk120=";
  };

  add-site-search-links-to-google-search-result = mkGreasemonkeyScript {
    pname = "add-site-search-links-to-google-search-result";
    version = "1.1.21";
    url = "https://greasyfork.org/scripts/37166-add-site-search-links-to-google-search-result/code/Add%20Site%20Search%20Links%20To%20Google%20Search%20Result.user.js";
    hash = "sha256-IPRNStKVH9rtzCn3JJ/yvXROsdX8WPAomPTudeqXjyc=";
  };

  google-images-search-by-paste = mkGreasemonkeyScript {
    pname = "google-images-search-by-paste";
    version = "1.1.0";
    url = "https://greasyfork.org/scripts/383166-google-images-search-by-paste/code/Google%20Images%20-%20search%20by%20paste.user.js";
    hash = "sha256-bZqylxLoceNXBgmQ3uYD8rpQTpjCo9OXs9eeOESb9To=";
  };

  viewimage = mkGreasemonkeyScript {
    pname = "viewimage";
    version = "4.1.1";
    url = "https://gist.githubusercontent.com/bijij/58cc8cfc859331e4cf80210528a7b255/raw/viewimage.user.js";
    hash = "sha256-O3u5XsGhgv63f49PwHaybekGjL718Biucb0T6wGGws8=";
  };

  fix-google-web-search = mkGreasemonkeyScript {
    pname = "fix-google-web-search";
    version = "2024-05-26";
    url = "https://update.greasyfork.org/scripts/495638/Fix%20Google%20Web%20Search.user.js";
    hash = "sha256-kvcifMx/0CVmTxUe2Md58RJShOV6Ht2YjJiwgz/qYI8=";
  };

  speed-up-google-captcha = mkGreasemonkeyScript {
    pname = "speed-up-google-captcha";
    version = "1.0.1";
    url = "https://greasyfork.org/scripts/382039-speed-up-google-captcha/code/Speed%20up%20Google%20Captcha.user.js";
    hash = "sha256-qpkjGmoW/2MHW2vEVhTToyZ8y7WPO38R9Ig+wv7KG+4=";
  };

  roughscroll = mkGreasemonkeyScript {
    pname = "roughscroll";
    version = "0.1";
    url = "https://gist.githubusercontent.com/oxguy3/ebd9fe692518c7f7a1e9/raw/234f5667d97e6a14fe47ef39ae45b6e5d5ebaf46/RoughScroll.js";
    hash = "sha256-R+1ZM05ZJgNUskjnmo0mtYMH3gPEldTNfBaMc5t5t3Y=";
  };

  show-password-onmouseover = mkGreasemonkeyScript {
    pname = "show-password-onmouseover";
    version = "0.0.1.20140630034959";
    url = "https://greasyfork.org/scripts/32-show-password-onmouseover/code/Show%20Password%20onMouseOver.user.js";
    hash = "sha256-QxWNy+QLQAWrxZ+xp8tKZBIUhl5alVPxybo13AIUZc4=";
  };

  ctrl-enter-is-submit-everywhere = mkGreasemonkeyScript {
    pname = "ctrl-enter-is-submit-everywhere";
    version = "0.1";
    url = "https://openuserjs.org/install/SelaoO/Ctrl+Enter_is_submit_everywhere.user.js";
    hash = "sha256-FshnFfKDwdCAam4Ikq0GlYcoJ0/a7B5vs8QMytLTqig=";
  };

  adguard-extra = mkGreasemonkeyScript {
    pname = "adguard-extra";
    version = "1.1.1";
    url = "https://userscripts.adtidy.org/release/adguard-extra/1.0/adguard-extra.user.js";
    hash = "sha256-NKjnOw3tmjDZBEBGas2LQoxFAD2VXkBdaXC4m0ttdIw=";
  };

  bandcamp-extended-album-history = mkGreasemonkeyScript {
    pname = "bandcamp-extended-album-history";
    version = "0.2";
    url = "https://greasyfork.org/scripts/423498-bandcamp-extended-album-history/code/Bandcamp%20extended%20album%20history.user.js";
    hash = "sha256-JoYHE2joFE5puFX56Ap2ByewqiWupXtPKdjBEhO9K5Y=";
  };

  bandcamp-volume-bar = mkGreasemonkeyScript {
    pname = "bandcamp-volume-bar";
    version = "1.1.8";
    url = "https://greasyfork.org/scripts/38012-bandcamp-volume-bar/code/Bandcamp%20Volume%20Bar.user.js";
    hash = "sha256-l0coImKwtYaK/a5iK5vpmhzCPOrVsySBy5TMpFOdOLQ=";
  };

  hacker-news-highlighter = mkGreasemonkeyScript {
    pname = "hacker-news-highlighter";
    version = "1.3.0";
    url = "https://greasyfork.org/scripts/39311-hacker-news-highlighter/code/Hacker%20News%20Highlighter.user.js";
    hash = "sha256-JPnh4IhsMgwdXZi0vN78UvXMN6XRpqwaiHJj/9KnYOA=";
  };

  hacker-news-date-tooltips = mkGreasemonkeyScript {
    pname = "hacker-news-date-tooltips";
    version = "1.1.0";
    url = "https://greasyfork.org/scripts/23432-hacker-news-date-tooltips/code/Hacker%20News%20Date%20Tooltips.user.js";
    hash = "sha256-wTd7TJZ4iTbt1/jsa8UtBTdQXtb/kpDTfvCyPYF4PAM=";
  };

  imdb-full-summary = mkGreasemonkeyScript {
    pname = "imdb-full-summary";
    version = "3.0.3";
    url = "https://greasyfork.org/scripts/23433-imdb-full-summary/code/IMDb%20Full%20Summary.user.js";
    hash = "sha256-v5vG2t0E6w0iS13L2P8cxYhHRm4+2klTRjBejm0+2bI=";
  };

  substack-popup-dismisser = mkGreasemonkeyScript {
    pname = "substack-popup-dismisser";
    version = "0.2";
    url = "https://greasyfork.org/scripts/465222-substack-popup-dismisser/code/substack_popup_dismisser.user.js";
    hash = "sha256-W6/VuP881P1q/Zn7uM7gPSKnmYmn0dAhY5i9aDGgI64=";
  };

  youtube-autoskip = mkGreasemonkeyScript {
    pname = "youtube-autoskip";
    version = "1.0.2";
    url = "https://gist.githubusercontent.com/codiac-killer/87e027a2c4d5d5510b4af2d25bca5b01/raw/764a0821aa248ec4126b16cdba7516c7190d287d/youtube-autoskip.user.js";
    hash = "sha256-pKxroIOn19WvcvBKA5/+ZkkA2YxXkdTjN3l2SLLcC0A=";
  };

  select-text-inside-a-link-like-opera = mkGreasemonkeyScript {
    pname = "select-text-inside-a-link-like-opera";
    version = "6.0.0";
    src =
      (fetchFromGitHub {
        owner = "eight04";
        repo = "select-text-inside-a-link-like-opera";
        rev = "3692b6a626e83cd073485dcee9929f80a52c10c9";
        hash = "sha256-u5LpbuprShZKHNhw7RnNITfo1gM9pYDzSLHNI+CUYMk=";
      })
      + "/select-text-inside-a-link-like-opera.user.js";

    meta.description = "Allow for selecting link text by dragging.";
  };

  always-on-focus = mkGreasemonkeyScript {
    pname = "always-on-focus";
    version = "1.5.3";
    src =
      (fetchFromGitHub {
        owner = "daijro";
        repo = "always-on-focus";
        rev = "2ab80112642cfbff6fe32a7ea7888d88eaef5815";
        hash = "sha256-/mmgU4iVZaaiS5LJTrkdbSYhy10DQVJOMHUSCCWnMzk=";
      })
      + "/alwaysonfocus.user.js";

    meta.description = ''
      Disables APIs that allow websites to track if you have their tab focused.
    '';
  };

  iso-8601-dates = callPackage (
    {
      matches ? [ ],
    }:
    assert (lib.isList matches);
    mkGreasemonkeyScript {
      pname = "iso-8601-dates";
      version = "1.2.3";

      src =
        (fetchFromGitHub {
          owner = "chocolateboy";
          repo = "userscripts";
          rev = "bf1be5ea11f28b353457e809764d02617070dc82";
          hash = "sha256-DSCPThX/mOqhPYqfFx0xn5mJ4/CZEJGj0nd7He3Dcfc=";
        })
        + "/src/iso_8601_dates.user.js";

      nativeBuildInputs = lib.optionals (matches != [ ]) [ pkgs.gnused ];

      installPhase = lib.optionalString (matches != [ ]) ''
        sed -Ei '
            /^\/\/ @exclude/ {
                r '<(printf '// @match %s\n' ${lib.escapeShellArgs matches})'
                d
            }' \
            "$out"
      '';
    }
  ) { matches = [ ]; };

  collapse-hackernews-parent-comments = mkGreasemonkeyScript {
    pname = "collapse-hackernews-parent-comments";
    version = "1.2.6";

    src =
      (pkgs.fetchFromGitHub {
        owner = "hjk789";
        repo = "Userscripts";
        rev = "00c6934afc078167f180d84f63e0c5db443c8377";
        hash = "sha256-1oUSbBrXN4M3WIGZztE/HwpZdf/O2aK1ROGzRARQvFg=";
      })
      + "/Collapse-HackerNews-Parent-Comments/Collapse-HackerNews-Parent-Comments.user.js";
  };

  control-panel-for-twitter = callPackage (
    {
      settings ? { },
    }:
    assert (lib.isAttrs settings);
    mkGreasemonkeyScript {
      pname = "control-panel-for-twitter";
      version = "200";

      src =
        fetchFromGitHub {
          owner = "insin";
          repo = "control-panel-for-twitter";
          rev = "v4.14.1";
          hash = "sha256-L2chLJJLlKtuuTBfQWwp9oH1QWcHgJdq/mlJfP3mUlI=";
        }
        + "/script.js";

      nativeBuildInputs = with pkgs; [
        jq
        ed
      ];

      installPhase = lib.optionalString (settings != { }) (
        let
          jsonSettings = lib.generators.toJSON { } settings;
        in
        ''
          {
              echo H
              echo '/^const config =/'
              jq -r '
                to_entries[]
                  | "/^ *\(.key): */"
                  , "s/: .*/: \(.value | tojson),/"
              ' <<<${lib.escapeShellArg jsonSettings}
              echo "wq $out";
          } | ed "$src"
        ''
      );
    }
  ) { settings = { }; };

  mastodon-larger-preview = callPackage (
    {
      matches ? [ ],
    }:
    assert (lib.isList matches);
    mkGreasemonkeyScript {
      pname = "mastodon-larger-preview";
      version = "0.1.2";
      src =
        (pkgs.fetchFromGitHub {
          owner = "Frederick888";
          repo = "mastodon-larger-preview";
          rev = "e9005241dfd904373041fdb46d7bf932ac7492f0";
          hash = "sha256-1miMTG8H/lf0BqiKdt9fA9qDiuhHqUiswM5mDqu594s=";
        })
        + "/main.user.js";

      installPhase = lib.optionalString (matches != [ ]) ''
        matches_string=$(printf '// @match %s\n' ${lib.escapeShellArgs matches})
        sed -iE '/^\/\/ @match/ i '"$matches_string" "$out"
      '';
    }
  ) { matches = [ ]; };

  mastodon-pixiv-preview = callPackage (
    {
      matches ? [ ],
    }:
    assert (lib.isList matches);
    mkGreasemonkeyScript {
      pname = "mastodon-pixiv-preview";
      version = "0.1.0";
      src =
        (pkgs.fetchFromGitHub {
          owner = "Frederick888";
          repo = "mastodon-pixiv-preview";
          rev = "b2994b11d041c77945bb59d0ebfe7ceb2920c985";
          hash = "sha256-pglKBOl6WPF0JDWVyk/r6J8MB9RGt9x14cRFd3A0b1E=";
        })
        + "/main.user.js";

      installPhase = lib.optionalString (matches != [ ]) ''
        matches_string=$(printf '// @match %s\n' ${lib.escapeShellArgs matches})
        sed -iE '/^\/\/ @match/ i '"$matches_string" "$out"
      '';
    }
  ) { matches = [ ]; };

  sb = callPackage (
    {
      jq,
      nodePackages,

      settings ? { },
    }:
    assert (lib.isAttrs settings);
    let
      inherit (nodePackages) prettier;
    in
    mkGreasemonkeyScript rec {
      pname = "sb";

      src = pkgs.fetchFromGitHub {
        owner = "mchangrh";
        repo = "sb.js";
        rev = "08b0e7026b1ac154f2783a6f1a15f9dfd731549f";
        hash = "sha256-RFUdmn08H/gJ2PXWbCQYkzjgwrbKLmnCSGbBGl2W/lU=";
      };

      nativeBuildInputs = [
        prettier
      ]
      ++ lib.optionals (settings != { }) [
        jq
      ];

      installPhase = ''
        set -x
        script="$src/docs/sb-loader.user.js"

        script_header=$(
            grep -Pzo \
                '(?s)// ==UserScript==.*// ==/UserScript==' \
                "$script"
        )

        script_without_header=$(
            sed \
                '/\/\/ ==UserScript==/,/\/\/ ==\/UserScript==/d' \
                "$script"
        )
      ''
      + lib.optionalString (settings != { }) ''
        default_settings_js=$(
            grep -Pzo \
                '(?s)/\* START OF SETTINGS \*/.*/\* END OF SETTINGS \*/' \
                "$script" \
                | tr -d '\0' \
        )

        default_settings_json=$(
            prettier --stdin-filepath ".js" <<<"$default_settings_js" \
                | sed -E \
                    -e '/^\/\/\s*/d' \
                    -e 's,\s+// .+|/\*.*\*/,,g' \
                    -e '/^const / { s/ = /": /; s/^const / "/ }' \
                    -e 's/;$/,/' \
                    -e '1 s/^/{/' \
                    -e '$ s/$/}/' \
                | prettier --stdin-filepath ".json"
        )

        merged_settings_js=$(
            jq -rs \
                '(.[0] + .[1]) | to_entries[] | "const \(.key) = \(.value | @json);"' \
                <(printf '%s' "$default_settings_json") \
                <(printf '%s' ${lib.escapeShellArg (builtins.toJSON settings)})
        )
      ''
      + ''
        printf '%s\n' \
            "$script_header" \
            "''${merged_settings_js:-$script_without_header}" \
            | prettier --stdin-filepath "sb.user.js" > "$out"

        set +x
      '';
    }
  ) { settings = { }; };
}
