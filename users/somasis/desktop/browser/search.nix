{ config
, lib
, pkgs
, ...
}:
let
  systemVersion = lib.versions.majorMinor lib.version;
  unstableVersion = lib.versions.majorMinor pkgs.unstable.lib.version;
  channel = if systemVersion == unstableVersion then "unstable" else systemVersion;

  inherit (lib) replaceStrings;

  wikipedia = lang: "https://${lang}.wikipedia.org/w/index.php?search={}";
in
{
  programs.qutebrowser = rec {
    searchEngines = {
      "DEFAULT" = "https://duckduckgo.com/?q={}";
      "!" = "https://duckduckgo.com/?q=!+{}";
      "!i" = "https://duckduckgo.com/?q={}&ia=images";
      "!kagi" = "https://kagi.com/search?q={}";

      # "!g" = "https://google.com/search?udm=14&q={}";
      # "!gi" = "https://google.com/search?tbm=isch&source=hp&q={}";
      "!yt" = "https://www.youtube.com/results?search_query={}";

      "!appstate" = "https://gb1.appstate.edu/search?q={}";
      "!apppeople" = "https://search.appstate.edu/search.php?last={}&type=all";

      "!libgen" = "http://libgen.rs/index.php?req={}";
      "!anna" = "https://annas-archive.org/search?q={}";
      "!annapdf" = searchEngines."!anna" + "&ext=pdf";
      "!worldcat" = "https://www.worldcat.org/search?q={}";

      "!bookfinder" = "https://www.bookfinder.com/search/?keywords={}";
      "!abebooks" = "https://www.abebooks.com/servlet/SearchResults?kn={}";
      "!plato" = "https://plato.stanford.edu/search/searcher.py?query={}";
      "!iep" = replaceStrings [ "{}" ] [ "site:https://iep.utm.edu+{}" ] searchEngines.DEFAULT;
      "!doi" = "https://doi.org/{unquoted}";

      "!pkg" = "https://parcelsapp.com/en/tracking/{}";

      "!discogs" = "https://www.discogs.com/search/?q={}";

      "!mbartist" = "https://musicbrainz.org/search?query={}&type=artist";
      "!mbrecording" = "https://musicbrainz.org/search?query={}&type=recording";
      "!mbrelease" = "https://musicbrainz.org/search?query={}&type=release";
      "!mbreleasegroup" = "https://musicbrainz.org/search?query={}&type=release_group";
      "!mbseries" = "https://musicbrainz.org/search?query={}&type=series";
      "!mbwork" = "https://musicbrainz.org/search?query={}&type=work";

      "!imdb" = "https://www.imdb.com/find/?s=all&q={}";
      "!ltrbox" = "https://letterboxd.com/search/{}/";
      "!trakt" = "https://trakt.tv/search?query={}";

      "!osm" = "https://www.openstreetmap.org/search?query={}";
      "!osmwiki" = "https://wiki.openstreetmap.org/wiki/Special:Search?search={}&go=Go";
      "!gmaps" = "https://www.google.com/maps/search/{}";
      "!flight" =
        "https://flightaware.com/ajax/ignoreall/omnisearch/disambiguation.rvt?searchterm={}&token=";

      "!red" = "https://redacted.ch/torrents.php?searchstr={}";
      "!redartist" = "https://redacted.ch/artist.php?artistname={}";
      "!redforums" = "https://redacted.ch/forums.php?action=search&search={}";
      "!redlog" = "https://redacted.ch/log.php?search={}";
      "!redrequests" = "https://redacted.ch/requests.php?search={}";
      "!redusers" = "https://redacted.ch/user.php?action=search&search={}";
      "!rutracker" = "https://rutracker.org/forum/tracker.php?nm={}";
      "!nyaa" = "https://nyaa.si/?q={}";

      "!gh" = "https://github.com/search?q={}";

      "!nix" = "file://${config.nix.package.doc}/share/doc/nix/manual/index.html?search={}";
      "!nixdiscuss" = "https://discourse.nixos.org/search?q={}";
      "!nixpkgsissues" = "https://github.com/NixOS/nixpkgs/issues?q={}";
      "!nixopts" = "https://search.nixos.org/options?channel=${channel}&sort=alpha_asc&query={}";
      "!nixpkgs" = "https://search.nixos.org/packages?channel=${channel}&sort=alpha_asc&query={}";
      "!nixwiki" = "https://wiki.nixos.org/w/index.php?search={}";
      "!hmissues" = "https://github.com/nix-community/home-manager/issues?q={}";

      "!mdn" = "https://developer.mozilla.org/en-US/search?q={}";
      "!c" = replaceStrings [ "{}" ] [ "site:en.cppreference.com/w/c+{}" ] searchEngines.DEFAULT;

      "!greasyfork" = "https://greasyfork.org/en/scripts?q={}";
      "!openuserjs" = "https://openuserjs.org/?q={}";
      "!userstyles" = "https://userstyles.world/search?q={}";

      "!twitter" = "https://twitter.com/search?q={}";
      "!bsky" = "https://bsky.app/search?q={}";
      "!whosampled" = "https://www.whosampled.com/search/?q={}";

      "!wiki" = wikipedia "en";
      "!wiki#en" = wikipedia "en";
      "!wiki#es" = wikipedia "es";
      "!wiki#jp" = wikipedia "ja";
      "!wiki#tok" = "https://wikipesija.org/index.php?search={}";

      "!etym" = "https://www.etymonline.com/search?q={}";
      "!wikt" = "https://en.wiktionary.org/wiki/{}";
      "!en" = "${searchEngines."!wikt"}#English";
      "!es" = "${searchEngines."!wikt"}#Spanish";
      "!jp" = "${searchEngines."!wikt"}#Japanese";
      "!tok" = "https://wikipesija.org/wiki/nimi:{unquoted}";
      "!esen" = "https://www.wordreference.com/es/en/translation.asp?spen={}";
      "!enes" = "https://www.wordreference.com/es/translation.asp?tranword={}";
      "!linku" = "https://linku.la/?q={}";

      "!archman" = "https://man.archlinux.org/search?q={}";
      "!archpkgs" = "https://archlinux.org/packages/?sort=&q={}";
      "!archwiki" = "https://wiki.archlinux.org/index.php?title=Special%3ASearch&search={}";

      "!debman" = "https://manpages.debian.org/jump?q={}";
      "!debpkgs" = "https://packages.debian.org/search?keywords={}";

      "!repology" = "https://repology.org/projects/?search={}";

      "!ia" = "https://archive.org/search?query={}";
      "!a" = "https://web.archive.org/web/*/{unquoted}";
      "!A" = "https://archive.today/{unquoted}";

      "!adb" = "http://adb.arcadeitalia.net/dettaglio_mame.php?game_name={}&arcade_only=0&autosearch=1";
      "!cdromance" = "https://cdromance.com/?s={}";
      "!emugen" = "https://emulation.gametechwiki.com/index.php?title=Special%3ASearch&search={}";
      "!redump" = "http://redump.org/discs/quicksearch/{quoted}";
      "!vimm" = "https://vimm.net/vault/?p=list&q={}";

      "!gemini" = "https://portal.mozz.us/gemini/{unquoted}";

      "!ph" = "https://phish.in/search?term={}";
      "!phday" = "https://phish.in/{unquoted}";
    };

    keyBindings.normal.gsw = "search-with-selection !wikt";

    greasemonkey = map config.lib.somasis.drvOrPath [
      # Google
      (pkgs.fetchurl {
        hash = "sha256-4A4vzwBcBLuyr0Ua+a6/HaoEFbe5JbQNdBi01lFnRwg="; # 1.1.16
        url = "https://greasyfork.org/scripts/32635-disable-google-search-result-url-redirector/code/Disable%20Google%20Search%20Result%20URL%20Redirector.user.js";
      })
      (pkgs.fetchurl {
        hash = "sha256-44IE62+Cx8owoTMZEgD/OjPnopVMD7PVrF/1hzbk120="; # 3.6
        url = "https://greasyfork.org/scripts/398189-google-image-direct-view/code/Google%20Image%20Direct%20View.user.js";
      })
      (pkgs.fetchurl {
        hash = "sha256-IPRNStKVH9rtzCn3JJ/yvXROsdX8WPAomPTudeqXjyc="; # 1.1.21
        url = "https://greasyfork.org/scripts/37166-add-site-search-links-to-google-search-result/code/Add%20Site%20Search%20Links%20To%20Google%20Search%20Result.user.js";
      })
      (pkgs.fetchurl {
        hash = "sha256-r4UF6jr3jhVP7JxJNPBzEpK1fkx5t97YWPwf37XLHHE="; # 1.1.0
        url = "https://greasyfork.org/scripts/383166-google-images-search-by-paste/code/Google%20Images%20-%20search%20by%20paste.user.js";
      })
      (pkgs.fetchurl {
        hash = "sha256-O3u5XsGhgv63f49PwHaybekGjL718Biucb0T6wGGws8="; # 4.1.1
        url = "https://gist.githubusercontent.com/bijij/58cc8cfc859331e4cf80210528a7b255/raw/viewimage.user.js";
      })
      (pkgs.fetchurl {
        hash = "sha256-O+CuezLYKcK2Qh4jq4XxrtEEIPKOaruHnUGQNwkkCF8="; # 1.3.4
        url = "https://greasyfork.org/scripts/381497-reddit-search-on-google/code/Reddit%20search%20on%20Google.user.js";
      })
      (pkgs.fetchurl {
        hash = "sha256-kvcifMx/0CVmTxUe2Md58RJShOV6Ht2YjJiwgz/qYI8="; # 2024-05-26
        url = "https://update.greasyfork.org/scripts/495638/Fix%20Google%20Web%20Search.user.js";
      })
      # (pkgs.fetchurl { hash = "sha256-WCgJGlz+FOPCSo+dPDxXB6mdzXBa81mlZ7km+11dBhY="; url = "https://update.greasyfork.org/scripts/495275/Open%20Google%27s%20New%20%22Web%22%20Search%20by%20Default.user.js"; })
    ];
  };
}
