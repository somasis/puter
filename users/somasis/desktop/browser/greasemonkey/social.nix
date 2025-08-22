{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.qutebrowser.greasemonkey = map config.lib.somasis.drvOrPath [
    # Reddit
    (pkgs.fetchurl {
      hash = "sha256-JKOu+pG8rjUTCriwMxn8fNVYtMDGiSeA97oA2iKIfp0="; # 1.2.0
      url = "https://greasyfork.org/scripts/39312-reddit-highlighter/code/Reddit%20Highlighter.user.js";
    })
    (pkgs.fetchurl {
      hash = "sha256-SdJ8a8eus2+/oSP6MnNgfURK+DQsbJJVbCLSxZU7baY=";
      url = "https://update.greasyfork.org/scripts/546618/Reddit%20Comment%20Auto-Expander%20%28Smooth%29%3A.user.js";
    })

    # Lobsters
    (pkgs.fetchurl {
      hash = "sha256-MUno65ouPgiOnMvZ0NW3sTxePRPC+vBHNhukwjnvExc="; # 1.0.1
      url = "https://greasyfork.org/scripts/40906-lobsters-highlighter/code/Lobsters%20Highlighter.user.js";
    })
    (pkgs.fetchurl {
      hash = "sha256-VyqfdSVRNPEaT8MmEq9+zaDBke+71jkecgoDD3oPGus="; # 0.0.1.20191112103250
      url = "https://greasyfork.org/scripts/392307-lobste-rs-open-in-new-tab/code/Lobsters%20Open%20in%20New%20Tab.user.js";
    })

    # Tumblr
    (pkgs.fetchurl {
      hash = "sha256-0Z9mFpXazMO+qaPHObkJCHBL13A9i4BI+8Mncn6rUUw="; # 2.5
      url = "https://greasyfork.org/scripts/31593-tumblr-images-to-hd-redirector/code/Tumblr%20Images%20to%20HD%20Redirector.user.js";
    })

    # Facebook
    (pkgs.fetchurl {
      hash = "sha256-Oag98n8SIxK0rbGW6JXd0K9d5piWMtq52KpjCzqletw="; # 5.0.2
      url = "https://greasyfork.org/scripts/431970-fb-clean-my-feeds/code/FB%20-%20Clean%20my%20feeds.user.js";
    })

    # Instagram
    (pkgs.fetchurl {
      hash = "sha256-HKWz05MP6g2US7TYzmAjwgXcWzRv6nU6nAROXi5Xhos="; # 1.0.3
      url = "https://greasyfork.org/scripts/451541-instagram-video-controls/code/Instagram%20Video%20Controls.user.js";
    })

    # Twitter
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
      hash = "sha256-gCGVnulgirTWUkhkmM0MrATztvA352oifkQnDUp1Z0o="; # 3.1.2
      url = "https://greasyfork.org/scripts/404632-twitter-direct/code/Twitter%20Direct.user.js";
    })

    # qutebrowser's greasemonkey support doesn't support setting configuration variables,
    # so we just patch in our configuration into the script before installing it.
    (pkgs.runCommandLocal "control-panel-for-twitter.user.js"
      {
        src = inputs.control-panel-for-twitter + "/script.js";
        config = lib.generators.toJSON { } {
          defaultToLatestSearch = true;
          disableTweetTextFormatting = true;
          dontUseChirpFont = true;
          fastBlock = false;
          followButtonStyle = "themed";
          fullWidthMedia = false;
          hideBookmarkMetrics = false;
          hideCommunitiesNav = true;
          hideExploreNav = false;
          hideExploreNavWithSidebar = false;
          hideExplorePageContents = false;
          hideFollowingMetrics = false;
          hideForYouTimeline = false;
          hideLikeMetrics = false;
          hideQuoteTweetMetrics = false;
          hideReplyMetrics = false;
          hideRetweetMetrics = false;
          hideSeeNewTweets = true;
          hideSidebarContent = false;
          hideSpacesNav = true;
          hideTotalTweetsMetrics = false;
          hideTweetAnalyticsLinks = true;
          hideTwitterBlueReplies = true;
          hideViews = false;
          hideWhoToFollowEtc = false;
          restoreOtherInteractionLinks = true;
          retweets = "ignore";
          showBlueReplyFollowersCount = true;
          tweakQuoteTweetsPage = false;
        };
      }
      ''
        {
            echo H
            echo '/^const config =/'
            ${pkgs.jq}/bin/jq -r '
              to_entries[]
                | "/^ *\(.key): */"
                , "s/: .*/: \(.value | tojson),/"
            ' <<< "$config"
            echo "wq $out";
        } | ${pkgs.ed}/bin/ed "$src"
      ''
    )

    # Mastodon
    (pkgs.runCommandLocal "mastodon-larger-preview.user.js" {
      src =
        (pkgs.fetchFromGitHub {
          owner = "Frederick888";
          repo = "mastodon-larger-preview";
          rev = "e9005241dfd904373041fdb46d7bf932ac7492f0";
          hash = "sha256-1miMTG8H/lf0BqiKdt9fA9qDiuhHqUiswM5mDqu594s=";
        })
        + "/main.user.js";
    } ''sed '/^\/\/ @match/ i // @match https://mastodon.social/*' "$src" > "$out"'')
    (pkgs.runCommandLocal "mastodon-pixiv-preview.user.js" {
      src =
        (pkgs.fetchFromGitHub {
          owner = "Frederick888";
          repo = "mastodon-pixiv-preview";
          rev = "b2994b11d041c77945bb59d0ebfe7ceb2920c985";
          hash = "sha256-pglKBOl6WPF0JDWVyk/r6J8MB9RGt9x14cRFd3A0b1E=";
        })
        + "/main.user.js";
    } ''sed '/^\/\/ @match/ i // @match https://mastodon.social/*' "$src" > "$out"'')
  ];
}
