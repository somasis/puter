{
  pkgs ? import <nixpkgs> { },
  omitFunctions ? false,
  omitAttrsets ? false,
  ...
}@args:
let
  args' = builtins.removeAttrs args [
    "omitAttrsets"
    "omitFunctions"
  ];

  inherit (pkgs)
    callPackage
    python3Packages
    ;

  functions = {
    withLinks = callPackage ./withLinks;
    wrapCommand = callPackage ./wrapCommand;
    writeCss = import ./writeCss;
    writeJqScript = callPackage ./writeJqScript;
  };

  attrsets = {
    greasemonkeyScripts = import ./greasemonkey-userscripts args';
    kakounePlugins = import ./kakoune-plugins args';
    tmuxPlugins = import ./tmux-plugins args';
    zotero-addons = import ./zotero-addons args';
  };

  derivations =
    with functions;
    with attrsets;
    rec {
      # keep-sorted start
      avahi2dns = callPackage ./avahi2dns { };
      aw-watcher-media-player = callPackage ./aw-watcher-media-player { };
      aw-watcher-netstatus = callPackage ./aw-watcher-netstatus { };
      beets-alias = callPackage ./beets-alias { };
      beets-fetchartist = callPackage ./beets-fetchartist { };
      beets-noimport = callPackage ./beets-noimport { };
      beets-originquery = callPackage ./beets-originquery { };
      borg-takeout = callPackage ./borg-takeout { };
      cogapp = callPackage ./cogapp { };
      dates = callPackage ./dates { inherit table; };
      dmenu = callPackage ./dmenu { };
      dmenu-emoji = callPackage ./dmenu-emoji { inherit wrapCommand; };
      dmenu-run = callPackage ./dmenu-run { };
      ellipsis = callPackage ./ellipsis { };
      emojirunner = callPackage ./emojirunner { };
      execshell = callPackage ./execshell { };
      fcitx5-ilo-sitelen = callPackage ./fcitx5-ilo-sitelen { };
      gitmal = callPackage ./gitmal { };
      greybeard = callPackage ./greybeard { };
      ini2nix = callPackage ./ini2nix { inherit json2nix; };
      jhide = callPackage ./jhide { };
      json2nix = callPackage ./json2nix { };
      krunner-zotero-unstable = callPackage ./krunner-zotero-unstable { };
      kwin-switch-to-last-used-desktop = callPackage ./kwin-switch-to-last-used-desktop { };
      linja-luka = callPackage ./linja-luka { };
      linja-namako = callPackage ./linja-namako { };
      linja-pi-tomo-lipu = callPackage ./linja-pi-tomo-lipu { };
      linja-pimeja-pona = callPackage ./linja-pimeja-pona { };
      linja-pona = callPackage ./linja-pona { };
      linja-suwi = callPackage ./linja-suwi { };
      location = callPackage ./location { };
      mail-deduplicate = python3Packages.callPackage ./mail-deduplicate { };
      mimetest = callPackage ./mimetest { };
      nanoid-cpp = callPackage ./nanoid-cpp { };
      newslinkrss = python3Packages.callPackage ./newslinkrss { };
      nocolor = callPackage ./nocolor { };
      optimize = callPackage ./optimize { };
      phish-cli = callPackage ./phish-cli { };
      qman = callPackage ./qman { inherit cogapp; };
      scooper = callPackage ./scooper { };
      sol = callPackage ./sol { };
      somasis-qutebrowser-tools = callPackage ./somasis-qutebrowser-tools { };
      sonapona = callPackage ./sonapona { };
      table = callPackage ./table { };
      wcal = callPackage ./wcal { };
      wineprefix = callPackage ./wineprefix { };
      # keep-sorted end
    };
in
derivations
// (if omitAttrsets then { } else attrsets)
// (if omitFunctions then { } else functions)
