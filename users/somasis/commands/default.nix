{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./nixos.nix
    ./sonapona.nix
  ];

  home.sessionPath = [ "$HOME/bin" ];

  persist.directories = [
    "bin"
  ];

  programs.jq.enable = true;
  home.file.".jq".text = lib.concatLines (
    map lib.fileContents [
      (
        pkgs.fetchFromGitHub {
          owner = "fearphage";
          repo = "jq-duration";
          rev = "a888df2a4a699482d782b06c74b4a39f05d8efd0";
          hash = "sha256-K8EllZ6ijeR9aGz9tX+ZAL92GqIJM/rWgyITBNJIEkg=";
        }
        + "/duration.jq"
      )
    ]
  );

  home.packages = with pkgs; [
    # keep-sorted start
    (lib.meta.hiPrio num-utils) # conflicts with sgt-puzzles
    as-tree
    dateutils
    ellipsis
    execline
    file
    frangipanni
    fx
    html-tidy
    ijq
    ini2nix
    jc
    jqfmt
    json2nix
    lowdown
    # ltrace # TODO fails to build with GCC 15
    mimetest
    ncdu
    nq
    pandoc
    pastel
    patchutils
    pigz
    pup
    pv
    rlwrap
    rsync
    rwc
    s6
    s6-dns
    s6-linux-utils
    s6-networking
    s6-portable-utils
    s6-rc
    snooze
    sqlite-interactive.bin
    strace
    table
    teip
    tree
    trurl
    xe
    xmlstarlet
    xurls
    xz
    yq-go
    zstd
    # keep-sorted end

    (ugrep.override {
      wrapWithFilterUtils = true;
      createGrepReplacementLinks = true;
    })

    # moreutils's /bin/ts conflicts with outils.
    (symlinkJoin {
      name = "outils-moreutils";
      paths = [
        outils
        moreutils
      ];
    })

    (withLinks {
      package = pkgs.bfs;
      links = [
        {
          target = "bin/bfs";
          link = "bin/find";
        }
        {
          target = "share/man/man1/bfs.1.gz";
          link = "share/man/man1/find.1.gz";
        }
      ];
    })

    # Prefer bsdtar over GNU tar
    (withLinks {
      package = pkgs.libarchive;
      links = [
        {
          target = "bin/bsdcpio";
          link = "bin/cpio";
        }
        {
          target = "bin/bsdtar";
          link = "bin/tar";
        }
        {
          target = "bin/bsdunzip";
          link = "bin/unzip";
        }
        {
          target = "share/man/man1/bsdcpio.1.gz";
          link = "share/man/man1/cpio.1.gz";
        }
        {
          target = "share/man/man1/bsdtar.1.gz";
          link = "share/man/man1/tar.1.gz";
        }
        {
          target = "share/man/man1/bsdunzip.1.gz";
          link = "share/man/man1/unzip.1.gz";
        }
      ];
    })

    (busybox.override {
      enableStatic = true;

      # Otherwise the symlinks replace the coreutils in my environment.
      enableAppletSymlinks = false;
    })

    # (toybox.override { enableStatic = true; })

    (writeScriptBin "todos" ''
      #!${gawk}/bin/gawk -f
      /(^| )#.* (TODO|NOTE|HACK|XXX|BUG)/ {
          gsub("TODO", "\033[1;32m&\033[0m");
          # gsub("NOTE", "\033[1;34m&\033[0m");
          gsub("HACK", "\033[1;33m&\033[0m");
          # gsub("XXX", "\033[1;33m&\033[0m");
          gsub("BUG", "\033[1;31m&\033[0m");
          gsub("^ *", "");
          print FILENAME ":" FNR "\t" $0
      }
    '')
  ];

  home.shellAliases.mdcat = ''
    lowdown -t term \
        --term-all-metadata \
        --term-hpadding 0 \
        --parse-hilite \
        --parse-math \
        | less -R
  '';
}
