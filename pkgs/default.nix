{ pkgs ? import <nixpkgs> { }
, ...
}@args:
let
  inherit (pkgs)
    lib

    callPackage
    python3Packages

    runtimeShell

    symlinkJoin
    runCommandLocal

    writeShellScript
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
              map
                (pair: ''
                  mkdir -p $out/${lib.escapeShellArg (builtins.dirOf pair.link)}
                  ln -s ${lib.escapeShellArg package}/${lib.escapeShellArg pair.target} $out/${lib.escapeShellArg pair.link}
                '')
                links
            )
          ))
        ];
      };

  fetchMediaFire =
    { url
    , name ? "${builtins.baseNameOf url}"
    , hash
    , postFetch ? ""
    , postUnpack ? ""
    , meta ? { }
    , ...
    }:
      assert (
        lib.any (prefix: lib.hasPrefix prefix url) [
          "https://www.mediafire.com/file/"
          "https://mediafire.com/file/"
          "http://www.mediafire.com/file/"
          "http://mediafire.com/file/"
        ]
      );
      pkgs.stdenvNoCC.mkDerivation {
        inherit
          name
          url
          hash
          postFetch
          postUnpack
          meta
          ;

        nativeBuildInputs = [
          pkgs.cacert
          pkgs.python3Packages.mediafire-dl
        ];

        outputHash = hash;
        outputHashAlgo = if hash != "" then null else "sha256";

        builder = pkgs.writeShellScript "fetch-mediafire-builder.sh" ''
          source $stdenv/setup

          download="$PWD"/download
          mkdir -p "$download"

          pushd "$download"
          mediafire-dl "$url"
          ls -CFlah
          popd

          mv "$download"/* "$out"
          rmdir "$download"
        '';
      };

  writeCss =
    name: stylelintUserConfig: text:
      assert (lib.isString name);
      assert (lib.isAttrs stylelintUserConfig);
      assert (lib.isString text);
      let
        stylelintConfig =
          if stylelintUserConfig == { } then
            { extends = "stylelint-config-standard"; }
          else
            stylelintUserConfig;
      in
      writeTextFile {
        inherit name;
        inherit text;

        derivationArgs = {
          nativeCheckInputs = with pkgs; [
            stylelint
            stylelint-config-standard
          ];
          stylelintConfig = lib.generators.toJSON { } stylelintConfig;
          passAsFile = [ "stylelintConfig" ];
        };

        checkPhase = ''
          check() {
              exit_code=0

              stylelint ''${stylelintConfig:+--config "$stylelintConfig"} --formatter unix --stdin-filename "$name" < "$name" || exit_code=$?

              case "$exit_code" in
                  78) # invalid config file/config not found <https://stylelint.io/user-guide/cli#exit-codes>
                      exit_code=0
                      ;;
              esac

              return "$exit_code"
          }
        '';
      };

  writeJqScript =
    name: args: text:
      assert (lib.isString name);
      assert (lib.isAttrs args);
      assert (lib.isString text);
      let
        args' = {
          inherit (pkgs) jq jqfmt;
        } // args;

        inherit (args') jq jqfmt;

        jqArgs =
          lib.removeAttrs args' [
            "jq"
            "jqfmt"
            "jqfmtArgs"
          ]
          // {
            from-file = jqScript;
          };

        jqfmtArgs = (args'.jqfmtArgs or { }) // {
          f = jqScript;
        };

        jqArgs' = lib.cli.toGNUCommandLineShell { } jqArgs;
        jqfmtArgs' = lib.cli.toGNUCommandLineShell { mkOptionName = x: "-${x}"; } jqfmtArgs;

        jqScript = writeScript name ''
          #!${jq}/bin/jq -f
          ${text}
        '';
      in
      writeTextFile {
        inherit name;
        executable = true;

        checkPhase = ''
          error=0
          ${jq}/bin/jq -n ${jqArgs'} || error=$?

          # 3: syntax error
          [ "$error" -eq 3 ] && exit 1 || :

          # diff -u ${lib.escapeShellArg jqScript} <(${jqfmt}/bin/jqfmt ${jqfmtArgs'}) || error=$?
          # [ "$error" -eq 0 ] || exit 1

          exit 0
        '';

        text = ''
          #!${runtimeShell}
          exec ${jq}/bin/jq ${jqArgs'} "$@"
        '';
      };

  wrapCommand = callPackage ./wrapCommand;

  aw-watcher-media-player = callPackage ./aw-watcher-media-player { };
  aw-watcher-netstatus = callPackage ./aw-watcher-netstatus { };
  bandcamp-collection-downloader = callPackage ./bandcamp-collection-downloader { };
  borg-takeout = callPackage ./borg-takeout { };
  dates = callPackage ./dates { inherit table; };
  dmenu = callPackage ./dmenu { };
  dmenu-emoji = callPackage ./dmenu-emoji { inherit wrapCommand; };
  dmenu-pass = callPackage ./dmenu-pass { };
  dmenu-run = callPackage ./dmenu-run { };
  ellipsis = callPackage ./ellipsis { };
  execshell = callPackage ./execshell { };
  fcitx5-ilo-sitelen = callPackage ./fcitx5-ilo-sitelen { };
  ffsclient = callPackage ./ffsclient { };
  hledger-fmt = callPackage ./hledger-fmt { };
  optimize = callPackage ./optimize { };
  ini2nix = callPackage ./ini2nix { inherit json2nix; };
  jhide = callPackage ./jhide { };
  jqfmt = callPackage ./jqfmt { };
  json2nix = callPackage ./json2nix { };
  linja-luka = callPackage ./linja-luka { };
  linja-namako = callPackage ./linja-namako { };
  linja-pi-tomo-lipu = callPackage ./linja-pi-tomo-lipu { };
  linja-pimeja-pona = callPackage ./linja-pimeja-pona { };
  linja-pona = callPackage ./linja-pona { };
  linja-suwi = callPackage ./linja-suwi { };
  location = callPackage ./location { };
  mail-deduplicate = python3Packages.callPackage ./mail-deduplicate { };
  mimetest = callPackage ./mimetest { };
  newslinkrss = python3Packages.callPackage ./newslinkrss { };
  nocolor = callPackage ./nocolor { };
  qute-pass = callPackage ./qute-pass { inherit dmenu-pass; };
  sbase = callPackage ./sbase { };
  scooper = callPackage ./scooper { };
  sol = callPackage ./sol { };
  somasis-qutebrowser-tools = callPackage ./somasis-qutebrowser-tools { };
  sonapona = callPackage ./sonapona { };
  table = callPackage ./table { };
  ubase = callPackage ./ubase { };
  ubuntu-wallpapers = callPackage ./ubuntu-wallpapers { };
  wcal = callPackage ./wcal { };
  wineprefix = callPackage ./wineprefix { };

  emojirunner = callPackage ./emojirunner { };
  krunner-zotero = callPackage ./krunner-zotero { };
  plasma-pass-unstable = callPackage ./plasma-pass { };
  signal-desktop-patched = callPackage ./signal-desktop-patched { };

  beets-fetchartist = callPackage ./beets-fetchartist { };
  beets-noimport = callPackage ./beets-noimport { };
  beets-originquery = callPackage ./beets-originquery { };

  nodePackages.stylelint-config-standard = nodePackages.callPackage ./stylelint-config-standard { };
  passExtensions = import ./pass-extensions args;
  kakounePlugins = import ./kakoune-plugins args;
  tmuxPlugins = import ./tmux-plugins args;
  zotero-addons = import ./zotero-addons args;
}
