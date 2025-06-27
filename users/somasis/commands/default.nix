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
    {
      method = "symlink";
      directory = "bin";
    }
  ];

  home.packages = with pkgs; [
    # keep-sorted start
    as-tree
    dateutils
    execline
    file
    ltrace
    ncdu
    nq
    patchutils
    pigz
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
    strace
    teip
    tree
    trurl
    xe
    xurls
    xz
    zstd
    # keep-sorted end

    # uq is unmaintained by upstream now and this Awk pretty much
    # gets you the whole way anyway. <https://unix.stackexchange.com/a/11941>
    # I would argue that this code is so simple that it cannot really be copyrighted.
    (pkgs.writeShellScriptBin "uq" ''
      ${lib.getExe pkgs.gawk} '!seen[$0]++' "$@"
    '')

    (pkgs.writeShellScriptBin "pe" ''
      ${lib.getExe pkgs.xe} -LL -j0 "$@" | sort -snk1 | cut -d' ' -f2-
    '')

    (pkgs.writeShellScriptBin "upward" ''
      usage() {
          cat >&2 <<EOF
      usage: ''${0##*/} <filename>

      Search for <filename>, starting from the current working directory, and
      ascending in the tree until a file named <filename> is found.
      If a matching file is found, print its physical path. Exits
      unsuccessfully if no file is found.
      EOF
          exit 69
      }

      [ $# -gt 0 ] || usage

      e=0
      while [ $# -gt 0 ]; do
          while [ "$PWD" != / ]; do
              [ -f "$1" ] && printf '%s\n' "$(readlink -f "$1")" && break
              e=$((e + 1))
              cd ../
          done
          shift
      done

      [ "$e" -gt 0 ] && exit 1
    '')

    # moreutils's /bin/ts conflicts with outils.
    (symlinkJoin {
      name = "outils-moreutils";
      paths = [
        outils
        moreutils
      ];
    })

    (withLinks bfs [
      {
        target = "bin/bfs";
        link = "bin/find";
      }
      {
        target = "share/man/man1/bfs.1.gz";
        link = "share/man/man1/find.1.gz";
      }
    ])

    # Prefer bsdtar over GNU tar
    (withLinks libarchive [
      {
        target = "bin/bsdcpio";
        link = "bin/cpio";
      }
      {
        target = "bin/bsdtar";
        link = "bin/tar";
      }
      {
        target = "share/man/man1/bsdcpio.1.gz";
        link = "share/man/man1/cpio.1.gz";
      }
      {
        target = "share/man/man1/bsdtar.1.gz";
        link = "share/man/man1/tar.1.gz";
      }
    ])

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
}
