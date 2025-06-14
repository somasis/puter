{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36";

  inherit (builtins) toString;
  inherit (pkgs) writeShellScript;
  inherit (lib)
    catAttrs
    concatLists
    foldr
    makeBinPath
    unique
    ;

  inherit (config.lib.somasis) feeds;

  inherit (pkgs) runCommandLocal writeJqScript writeText;
  inherit (builtins) toJSON;
in
{
  imports = [
    # ./aggregators.nix
    # ./redacted.nix
    # ./yt-dlp.nix
  ];

  news.display = "silent";

  xdg.dataFile."home-manager-news.atom".source =
    runCommandLocal "home-manager-news.atom"
      {
        filter = writeJqScript "home-manager-news-filter" { } ''
          map(select(.condition == true))
              | sort_by(.time)
              | map(
                  . + {
                  # Generate titles for feed items
                  #   1. Strip any ending punctuation (for when it's a short message)
                  #   2. Crudely un-hardwrap the first line of the message
                  #   3. Keep only the first line of the message
                  #   4. Remove any remaining ending punctuation
                    title: (
                        .message
                            | sub("\\.?\n$|:\n.*"; ""; "p")
                            | sub(
                                "(?<pre>[^\\s]+)\n(?<suf>[^\n]+).*";
                                "\(.pre) \(.suf)";
                                "pg"
                            )
                            | rtrimstr(".")
                            | sub("\\. .*"; ""; "p")
                    )
                  }
              )
              | map_values(.id = (.time + .message | @base64))
              # Now, shape our input in terms that yq can output as xml
              | {
                  feed: {
                    "+@xmlns": "http://www.w3.org/2005/Atom",
                    title: "home-manager",
                    updated: (map(.time) | sort | last),
                    entry: map(
                      {
                        id,
                        updated: .time,
                        title: { "+@type": "text", "+content": .title },
                        content: { "+@type": "text/plain", "+content": .message }
                      }
                    )
                  }
              }
        '';

        json = writeText "home-manager-news.json" (toJSON config.news.entries);
      }
      ''
        $filter < $json > filtered.json
        ${pkgs.yq-go}/bin/yq --input-format json --output-format xml --xml-strict-mode < filtered.json > $out
      '';

  programs.newsboat = {
    enable = false;

    maxItems = 10000;

    browser = toString (
      writeShellScript "newsboat-browser" ''
        ${pkgs.coreutils}/bin/nohup ${pkgs.xdg-utils}/bin/xdg-open "$1" >/dev/null 2>&1 &
      ''
    );

    extraConfig =
      let
        newsboatHTMLRenderer = writeShellScript "newsboat-html-renderer" ''
          ${pkgs.rdrview}/bin/rdrview \
              -T body \
              -H "$@" \
              | ${pkgs.html-tidy}/bin/tidy \
                  -q \
                  -asxml \
                  -w 0 2>/dev/null \
              | ${pkgs.w3m-batch}/bin/w3m \
                  -dump \
                  -T text/html
        '';
      in
      ''
        keep-articles-days 365

        bind-key o open-in-browser-noninteractively

        download-full-page yes

        mark-as-read-on-hover yes

        articlelist-format "%4i %f %D %?T?|%-17T| ?%t"
        datetime-format %Y-%m-%d
        feedlist-format "%4i %n %11u %t%?T? #%T? "

        # newsboat(1): "Configure a high number to keep the selected item in the center"
        scrolloff 100000

        show-keymap-hint yes

        text-width 100

        cache-file "${config.xdg.cacheHome}/newsboat/cache.db"

        html-renderer "${newsboatHTMLRenderer}"
        user-agent "${userAgent}"
      ''
    # + optionalString (tor.enable && tor.client.enable) ''
    #   # socks5h: "CURLPROXY_SOCKS5_HOSTNAME [...] Proxy resolves URL hostname."
    #   use-proxy yes
    #   proxy ${tor.client.socksListenAddress.addr}:${toString tor.client.socksListenAddress.port}
    #   proxy-type socks5h
    #   download-timeout 60
    # ''
    ;

    # Create a list of queries from all URLs' tags.
    queries =
      {
        "!!! unread" = ''unread = "yes"'';
      }
      // (foldr (a: b: a // b) { } (
        map (x: { "... ${x}" = ''tags # "${x}"''; }) (
          unique (concatLists (catAttrs "tags" config.programs.newsboat.urls))
        )
      ));

    urls = [
      { url = "https://leahneukirchen.org/blog/index.atom"; }
      { url = "https://leahneukirchen.org/trivium/index.atom"; }
      {
        tags = [ "computer" ];
        url = "https://text.causal.agency/feed.atom";
      }
      { url = "https://www.7596ff.com/rss.xml"; }
      { url = "https://pikhq.com/index.xml"; }
      {
        tags = [
          "computer"
          "development"
        ];
        url = "https://www.uninformativ.de/blog/feeds/en.atom";
      }
      {
        tags = [
          "computer"
          "nixos"
          "openbsd"
        ];
        url = "https://dataswamp.org/~solene/rss.xml";
      }
      {
        tags = [
          "computer"
          "nixos"
        ];
        title = "Determinate Systems";
        url = "https://determinate.systems/posts?format=rss";
      }
      {
        tags = [ "OpenBSD" ];
        title = "Ted Unangst: flak";
        url = "https://flak.tedunangst.com/rss";
      }
      {
        tags = [ "computer" ];
        url = "https://mforney.org/blog/atom.xml";
      }
      {
        tags = [ "computer" ];
        url = "https://ariadne.space/feed/";
      }
      {
        tags = [ "computer" ];
        url = "https://whynothugo.nl/posts.xml";
      }
      {
        tags = [ "computer" ];
        url = "https://jcs.org/rss";
      }
      {
        tags = [ "computer" ];
        title = "hisham.hm";
        url = "https://hisham.hm/?x=feed:rss2&category=1";
      }
      {
        tags = [ "computer" ];
        title = "Wandering Thoughts: Chris Siebenmann";
        url = "https://utcc.utoronto.ca/~cks/space/blog/?atom";
      }
      {
        tags = [ "computer" ];
        title = "Abort Retry Fail";
        url = "https://www.abortretry.fail/feed";
      }
      {
        title = "journcy";
        url = feeds.urls.gemini "gemini://journcy.net";
      }
      { url = "https://feed.tedium.co/"; }

      # Comics
      {
        tags = [ "comics" ];
        url = "https://xkcd.com/atom.xml";
      }
      {
        tags = [ "comics" ];
        title = "Honestly Undefined";
        url = "https://rakhim.org/honestly-undefined/index.xml";
      }
      {
        tags = [ "comics" ];
        url = "https://wizardzines.com/comics/index.xml";
      }

      # Computers
      {
        tags = [ "computer" ];
        url = "https://www.latacora.com/blog/index.xml";
      }
      {
        tags = [ "computer" ];
        url = "https://sanctum.geek.nz/arabesque/feed/";
      }
      {
        tags = [ "computer" ];
        url = "https://ewontfix.com/feed.rss";
      }
      {
        tags = [ "computer" ];
        url = "https://beepb00p.xyz/atom.xml";
      }
      {
        tags = [
          "computer"
          "tumblr"
        ];
        url = "https://onethingwell.org/rss";
      }
      {
        tags = [ "computer" ];
        url = "https://nixers.net/newsletter/feed.xml";
      }
      {
        tags = [
          "computer"
          "linux"
        ];
        url = feeds.urls.filter "https://www.phoronix.com/rss.php" feeds.filters.discardContent;
      }
      {
        tags = [
          "computer"
          "nixos"
        ];
        title = "Planet NixOS";
        url = "https://planet.nixos.org/atom.xml";
      }
      {
        tags = [ "computer" ];
        url = "https://blog.qutebrowser.org/feeds/all.atom.xml";
      }
      {
        tags = [ "computer" ];
        url = "https://frame.work/blog.rss";
      }

      # Forums
      {
        tags = [ "nixos" ];
        title = "NixOS Discourse: announcements";
        url = "https://discourse.nixos.org/c/announcements/8.rss";
      }
      {
        tags = [ "nixos" ];
        title = "NixOS Discourse: Nixpkgs architecture";
        url = "https://discourse.nixos.org/c/dev/nixpkgs/44.rss";
      }
      {
        tags = [
          "computer"
          "kakoune"
        ];
        title = "Kakoune: plugins";
        url = "https://discuss.kakoune.com/c/plugins/5.rss";
      }
      {
        tags = [
          "computer"
          "kakoune"
        ];
        title = "Kakoune: recipes and guides";
        url = "https://discuss.kakoune.com/c/recipes-and-guides/8.rss";
      }
      {
        tags = [
          "computer"
          "kakoune"
        ];
        title = "Kakoune: terminal tools";
        url = "https://discuss.kakoune.com/c/terminal-tools/15.rss";
      }
      {
        tags = [ "computer" ];
        title = "qutebrowser: discussions";
        url = "https://github.com/qutebrowser/qutebrowser/discussions.atom";
      }

      # Music
      {
        tags = [
          "music"
          "review"
        ];
        url = "https://constantlyhating.substack.com/feed";
      }
      {
        tags = [ "music" ];
        url = "https://expandingdan.substack.com/feed";
      }
      {
        tags = [ "music" ];
        url = "https://phish.net/feed/index.xml";
        title = "Phish.net";
      }

      # News
      {
        tags = [
          "computer"
          "news"
        ];
        url = "https://lwn.net/headlines/newrss";
      }
      {
        tags = [
          "news"
          "usa"
        ];
        url = "https://www.democracynow.org/democracynow.rss";
      }
      {
        tags = [
          "japan"
          "news"
        ];
        title = "The Japan Times";
        url = feeds.urls.filter "https://www.japantimes.co.jp/feed/" feeds.filters.discardContent;
      }
      {
        tags = [
          "australia"
          "local"
          "news"
        ];
        title = "ABC News: top stories";
        url = feeds.urls.filter "https://www.abc.net.au/news/feed/45910/rss.xml" feeds.filters.discardContent;
      }
      {
        tags = [
          "australia"
          "local"
          "news"
        ];
        title = "ABC News: Adelaide";
        url = feeds.urls.filter "https://www.abc.net.au/news/feed/8057540/rss.xml" feeds.filters.discardContent;
      }
      {
        tags = [
          "australia"
          "local"
          "news"
        ];
        title = "ABC News: Arts and Entertainment";
        url = feeds.urls.filter "https://www.abc.net.au/news/feed/472/rss.xml" feeds.filters.discardContent;
      }

      {
        tags = [ "news" ];
        title = "The Ecologist";
        url = "https://theecologist.org/whats_new/feed";
      }

      {
        tags = [ "news" ];
        url = "https://www.currentaffairs.org/feed";
      }
      {
        tags = [ "news" ];
        url = "https://thebaffler.com/feed";
      }
      {
        tags = [
          "local"
          "news"
        ];
        title = "The Appalachian";
        url = "https://theappalachianonline.com/feed/";
      }
      {
        tags = [
          "local"
          "notification"
        ];
        title = "Town of Boone: alerts";
        url = "https://www.townofboone.net/RSSFeed.aspx?ModID=63&CID=All-0";
      }
      {
        tags = [
          "events"
          "local"
        ];
        title = "Explore Boone: events";
        url = "https://www.exploreboone.com/event/rss/";
      }
      {
        tags = [
          "local"
          "news"
        ];
        title = "Watauga Democrat: local";
        url = "https://www.wataugademocrat.com/search/?f=rss&t=article&c=news/local&l=50&s=start_time&sd=desc";
      }
      {
        tags = [ "local" ];
        title = "Watauga Democrat: classifieds";
        url = "https://www.wataugademocrat.com/classifieds/?f=rss&s=start_time&sd=asc";
      }
      {
        tags = [
          "local"
          "news"
        ];
        title = "Watauga Democrat: Appalachian State University";
        url = "https://www.wataugademocrat.com/search/?f=rss&t=article&c=news/asu_news&l=50&s=start_time&sd=desc";
      }
      {
        tags = [
          "local"
          "news"
        ];
        title = "Watauga Online";
        url = "https://wataugaonline.com/feed/";
      }
      {
        tags = [
          "local"
          "news"
        ];
        title = "High Country Press";
        url = "https://feeds.feedburner.com/HCPress";
      }
      {
        tags = [ "local" ];
        url = "https://www.ncrabbithole.com/feed";
      }

      {
        tags = [
          "film"
          "media"
          "news"
        ];
        url = feeds.urls.filter "https://www.avclub.com/rss" feeds.filters.discardContent;
      }
      {
        tags = [
          "film"
          "media"
        ];
        url = feeds.urls.filter "https://www.filmcomment.com/feed/atom/" feeds.filters.discardContent;
      }

      {
        tags = [ "journal" ];
        url = "https://newleftreview.org/feed";
      }
      {
        tags = [
          "media"
          "news"
        ];
        url = "https://www.404media.co/rss";
      }
      {
        tags = [ "news" ];
        url = "https://www.jphilll.com/feed";
      }

      {
        tags = [
          "news"
          "technology"
        ];
        title = "Ars Technica";
        url = "http://feeds.arstechnica.com/arstechnica/index";
      }

      # Notifications
      # { tags = [ "computer" "github" "notification" ]; title = "GitHub: timeline"; url = feeds.urls.secret "https://github.com/somasis.private.atom?token=%s" "www/github.com/somasis.private.atom"; }
      # { tags = [ "media" "music" "notification" ]; title = "Music: new releases"; url = feeds.urls.secret "https://muspy.com/feed?id=%s" "www/muspy.com/kylie@somas.is.rss"; }

      # OpenStreetMap
      {
        tags = [
          "news"
          "openstreetmap"
        ];
        title = "weeklyOSM";
        url = feeds.urls.filter "https://www.weeklyosm.eu/feed" feeds.filters.discardContent;
      }
      {
        tags = [
          "notification"
          "openstreetmap"
        ];
        title = "OpenStreetMap: notes in Watauga County";
        url = "https://www.openstreetmap.org/api/0.6/notes/feed?bbox=-81.918076,36.111477,-81.455917,36.391293";
      }
      {
        tags = [
          "notification"
          "openstreetmap"
        ];
        title = "OpenStreetMap: notes in Cabarrus County";
        url = "https://www.openstreetmap.org/api/0.6/notes/feed?bbox=-80.7872772,35.1850329,-80.2963257,35.5093128";
      }
      {
        tags = [
          "notification"
          "openstreetmap"
        ];
        title = "OpenStreetMap: changes to review in Watauga County";
        url = "https://resultmaps.neis-one.org/osm-suspicious-feed-bbox?hours=96&mappingdays=-1&tsearch=review_requested%3Dyes&anyobj=t&bbox=-81.918076,36.111477,-81.455917,36.391293";
      }
      {
        tags = [
          "notification"
          "openstreetmap"
        ];
        title = "OpenStreetMap: changes to review in Cabarrus County";
        url = "https://resultmaps.neis-one.org/osm-suspicious-feed-bbox?hours=96&mappingdays=-1&tsearch=review_requested%3Dyes&anyobj=t&bbox=-80.7872772,35.1850329,-80.2963257,35.5093128";
      }
      {
        tags = [
          "newsletter"
          "openstreetmap"
        ];
        title = "OpenStreetMap US";
        url = "https://us3.campaign-archive.com/feed?u=162692bfdedb78ec46fd108a3&id=801ce00e6d";
      }
      {
        tags = [
          "development"
          "openstreetmap"
        ];
        url = "https://osmand.net/rss.xml";
      }
      {
        tags = [
          "development"
          "openstreetmap"
        ];
        url = "https://organicmaps.app/rss.xml";
      }

      {
        tags = [
          "computer"
          "development"
        ];
        url = "https://drewdevault.com/blog/index.xml";
      }
      {
        tags = [
          "news"
          "security"
        ];
        url = "https://maia.crimew.gay/feed.xml";
      }

      # Tumblr
      {
        tags = [ "tumblr" ];
        title = "Phidica";
        url = "https://phidica.tumblr.com/rss";
      }
      {
        tags = [ "tumblr" ];
        title = "rf9weu8hjf789234hf9";
        url = "https://www.tumblr.com/rf9weu8hjf789234hf9";
      }
      {
        tags = [ "tumblr" ];
        title = "Journcy";
        url = "https://journcy.tumblr.com/rss";
      }
      {
        tags = [
          "computer"
          "tumblr"
        ];
        url = "https://control--panel.com/rss";
      }

      # System
      {
        tags = [
          "computer"
          "nixos"
        ];
        url = "https://nixos.org/blog/announcements-rss.xml";
      }
      {
        tags = [
          "computer"
          "nixos"
        ];
        title = "NixOS: Breaking changes on nixos-unstable";
        url = "https://discourse.nixos.org/t/breaking-changes-announcement-for-unstable/17574.rss";
      }

      # toki pona
      {
        tags = [
          "podcast"
          "toki pona"
        ];
        title = "kalama sin";
        url = "https://feeds.redcircle.com/901407e0-53e9-4aa2-aa3d-509393d10783";
      }
      {
        tags = [ "toki pona" ];
        title = "jan Josan";
        url = "https://jonathangabel.com/feed.xml";
      }
      {
        tags = [ "toki pona" ];
        title = "jan Ke Tami";
        url = "https://janketami.wordpress.com/feed/";
      }
      {
        tags = [
          "comics"
          "toki pona"
        ];
        title = "kijetesantakalu o!";
        url = "https://kijetesantakalu-o.tumblr.com/rss";
      }

      {
        tags = [
          "games"
          "urbanterror"
        ];
        title = "Urban Terror: news";
        url = "https://www.urbanterror.info/rss/news/all";
      }
      {
        tags = [ "urbanterror" ];
        title = "Urban Terror: blogs";
        url = "https://www.urbanterror.info/rss/blogs/all/";
      }

      {
        tags = [ "philosophy" ];
        url = "https://crittheoryworkgroup.blog/feed/";
      }
      {
        tags = [ "technology" ];
        url = "https://theluddite.org/feed.rss";
      }
      {
        tags = [
          "law"
          "philosophy"
        ];
        url = "https://lpeproject.org/blog/";
      }
    ];
  };

  # cache.directories = [{ method = "symlink"; directory = config.lib.somasis.xdgCacheDir "newsboat"; }];

  programs.qutebrowser = lib.optionalAttrs config.programs.dmenu.enable {
    aliases."feeds" =
      let
        quteFeeds = writeShellScript "qutebrowser-feeds" ''
          PATH=${
            makeBinPath [
              pkgs.coreutils
              pkgs.moreutils
              pkgs.sfeed
              pkgs.xclip
            ]
          }:$PATH

          : "''${QUTE_FIFO:?}"
          : "''${QUTE_HTML:?}"

          feeds=$(<"$QUTE_HTML" sfeed_web "$1" | cut -f1)

          if [[ -n "$feeds" ]]; then
              feeds=$(dmenu -l 4 -g 2 -p "qutebrowser [feeds]:" <<<"$feeds")
              xclip -selection clipboard -i <<< "$feeds"

              printf 'message-info "%s"\n' \
                  "feeds: copied feed to clipboard" \
                  > "''${QUTE_FIFO}"
          else
              printf 'message-warning "%s"\n' \
                  "feeds: no feeds were found" \
                  > "''${QUTE_FIFO}"
          fi
        '';
      in
      "spawn -u ${quteFeeds} {url:domain}";

    keyBindings.normal."zpf" = "feeds";
  };

  home.packages = [ pkgs.rssguard ];

  persist = {
    directories = [ (config.lib.somasis.xdgConfigDir "RSS Guard 4") ];
    files = [ (config.lib.somasis.xdgConfigDir "RSS Guardrc") ];
  };

  cache.directories = [ (config.lib.somasis.xdgConfigDir "RSS Guard") ];
}
