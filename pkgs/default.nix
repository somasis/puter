{
  pkgs ? import <nixpkgs> { },
  ...
}@args:
let
  inherit (pkgs)
    lib

    callPackage
    python3Packages

    runtimeShell

    symlinkJoin
    runCommandLocal

    writeScript
    writeTextFile
    ;
in
rec {
  withLinks =
    package: links:
    # example:
    # withLinks pkgs.bfs [
    #   { target = "bin/bfs"; link = "bin/find"; }
    #   { target = "share/man/man1/bfs.1.gz"; link = "share/man/man1/find.1.gz"; }
    # ]
    assert (lib.isStorePath package);
    assert (lib.isList links && links != [ ]);
    assert ((lib.filter (link: lib.isString link.target && link.target != "") links) != [ ]);
    symlinkJoin {
      name = "${package.pname}-with-links";
      paths = [
        package
        (runCommandLocal "links" { } (
          lib.concatLines (
            map (pair: ''
              mkdir -p $out/${lib.escapeShellArg (builtins.dirOf pair.link)}
              ln -s ${lib.escapeShellArg package}/${lib.escapeShellArg pair.target} $out/${lib.escapeShellArg pair.link}
            '') links
          )
        ))
      ];
    };

  fetchMediaFire = callPackage ./fetchMediaFire { };
  writeCss = callPackage ./writeCss { };
  writeJqScript = callPackage ./writeJqScript { };
  wrapCommand = callPackage ./wrapCommand { };

  # keep-sorted start
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
  greybeard = callPackage ./greybeard { };
  ini2nix = callPackage ./ini2nix { inherit json2nix; };
  jhide = callPackage ./jhide { };
  json2nix = callPackage ./json2nix { };
  krunner-zotero-unstable = callPackage ./krunner-zotero-unstable { };
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

  # keep-sorted start
  greasemonkeyScripts = import ./greasemonkey-userscripts args;
  kakounePlugins = import ./kakoune-plugins args;
  nodePackages.stylelint-config-standard = nodePackages.callPackage ./stylelint-config-standard { };
  tmuxPlugins = import ./tmux-plugins args;
  zotero-addons = import ./zotero-addons args;
  # keep-sorted end
}
