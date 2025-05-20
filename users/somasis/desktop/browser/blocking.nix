{ config
, pkgs
, lib
, inputs
, ...
}:
let
  uriList = map (x: "file://${x}");

  adblockCustom = pkgs.writeText "custom.txt" ''
    [Adblock Plus 2.0]
    ! Title: Custom ad blocking rules
    ! Disable smooth scroll hijacking scripts
    /jquery.nicescroll*.js
    /jquery.smoothscroll*.js
    /jquery.smooth-scroll*.js
    /jquery-smoothscroll*.js
    /jquery-smooth-scroll*.js
    /nicescroll*.js
    /smoothscroll*.js
    /smooth-scroll*.js
    /mousewheel-smooth-scroll
    /surbma-smooth-scroll
    /dexp-smoothscroll.js

    trakt.tv##div.top[id*="-wrapper"]:has(a[href="/vip/advertising"])
    trakt.tv##a[href^="/vip/"], body.dashboard [id*="-wrapper"].middle, body.users [id*="-wrapper"].middle
  '';

  lists = with inputs; [
    adblockCustom

    (adblockEasyList + /easylist.txt)
    (adblockEasyList + /easyprivacy.txt)
    (adblockEasyList + /easycookie.txt)
    # (adblockEasyList + /fanboysocial.txt)
    (adblockEasyList + /antiadblock.txt)
    (adblockEasyList + /easylistspanish.txt)

    (uAssets + /filters/privacy.min.txt)
    (uAssets + /filters/resource-abuse.txt)
  ];

  listsNonCosmetic = with inputs; [
    # FIXME currently separated from the rest due to a bad rule that trips
    # up jhide and causes all pages to suddenly have `display: none !important`
    # applied lol. ":not(my-obnaruzhili-blokirovshchik)" is the problem rule.
    (adblockEasyList + /advblock.txt) # EasyList Russian
    (adblockEasyList + /abp-filters-anti-cv.txt)
  ];
in
{
  cache.files = [
    (config.lib.somasis.xdgDataDir "qutebrowser/adblock-cache.dat")
    (config.lib.somasis.xdgDataDir "qutebrowser/blocked-hosts")
  ];

  programs.qutebrowser = {
    settings = {
      # Help with jhide's memory usage.
      qt.chromium.process_model = "process-per-site";

      content.blocking = {
        enabled = true;
        method = "adblock";
        adblock.lists = uriList (lists ++ listsNonCosmetic);
        # hosts.lists = uriList (with inputs; [ adblockHosts ]);
      };
    };

    greasemonkey = [
      (config.lib.somasis.greasemonkey.jhide [ "mail.google.com" "indeed.com" ] (
        map (lib.replaceStrings [ "file://" ] [ "" ])
          # config.programs.qutebrowser.settings.content.blocking.adblock.lists
          (uriList lists)
      ))
    ];
  };
}
