{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  imports = [
    ./convert.nix
    ./ripping.nix
    ./tagging.nix
  ];

  home.packages = with pkgs; [
    (beets-unstable.override {
      pluginOverrides.alias = {
        enable = true;
        propagatedBuildInputs = [ beets-alias ];
      };
    })
    rsgain
    unflac
  ];

  cache.directories = [ (config.lib.somasis.xdgCacheDir "MusicBrainz") ];
  sync.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "MusicBrainz";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "beets";
    }
  ];

  xdg.userDirs.music = "${config.home.homeDirectory}/audio/library";

  # Workaround a bug when two users are running beets at once
  home.shellAliases.beet = ''TMPDIR="$XDG_RUNTIME_DIR" beet'';

  # programs.beets = {
  #   enable = true;
  #   package = pkgs.symlinkJoin {
  #     name = "beets-final";

  #     paths = [
  #       # Provide a wrapper for the actual `beet` program, so that we can perform some
  #       # pre-command-initialization actions.
  #       # <https://nixos.wiki/wiki/Nix_Cookbook#Wrapping_packages>
  #       (pkgs.writeShellScriptBin "beet" ''
  #         #! ${pkgs.runtimeShell}
  #         set -eu
  #         set -o pipefail

  #         ${lib.toShellVar "PATH" (lib.makeBinPath [ pkgs.coreutils pkgs.utillinux pkgs.systemd ])}":${placeholder "out"}:$PATH"
  #         directory=$(readlink -m ${lib.escapeShellArg config.programs.beets.settings.directory})
  #         BEETS_LOCK="$directory/beets.lock"

  #         # Mount any required mount units
  #         directory_escaped=$(systemd-escape -p "$directory")
  #         user_mount_units=$(systemctl --user --plain --full --all --no-legend list-units -t mount | cut -d' ' -f1)

  #         # Work through the parts of the escaped path and find the longest
  #         # unit name prefix match.
  #         # 1. Split apart the escaped path
  #         # 2. Accumulate parts for each run of the `for` loop
  #         # 3. Read in the list of user mount units
  #         # The longest matching one will be the final line.
  #         unit=$(
  #             directory_acc=
  #             IFS=-
  #             for directory_part in $directory_escaped; do
  #                 directory_acc="''${directory_acc:+$directory_acc-}$directory_part"

  #                 while IFS="" read -r unit; do
  #                     case "$unit" in
  #                         "$directory_acc"*.mount) printf '%s\n' "$unit"; break ;;
  #                     esac
  #                 done <<< "$user_mount_units"
  #             done | tail -n1
  #         )

  #         [[ -n "$unit" ]] && systemctl --user start "$unit"

  #         # Maintain a cross-device lock, so that we don't conflict if the directory is
  #         # over a network device of some sort (sshfs)
  #         if [[ -e "$BEETS_LOCK" ]]; then
  #             printf 'Lock "%s" is currently held, sleeping until free...\n' "$BEETS_LOCK" >&2
  #             while [[ -e "$BEETS_LOCK" ]]; do
  #                 sleep 5
  #             done
  #         fi
  #         printf '%s\n' ${lib.escapeShellArg osConfig.networking.fqdnOrHostName} > "$BEETS_LOCK"

  #         # Trap Ctrl-C, since it seems really problematic for database health
  #         e=0
  #         trap : INT
  #         trap 'rm -f "$BEETS_LOCK"' EXIT

  #         # Feed secret-beets info via a FIFO so it never hits the disk.
  #         ${beets}/bin/beet -c <(secret-beets) "$@" || e=$?

  #         trap - INT
  #         exit $?
  #         EOF
  #       '')

  #       secret-beets

  #       beets.man
  #       beets.doc
  #       beets
  #     ];
  #   };

  #   settings = {
  #     directory = "${config.xdg.userDirs.music}/lossy";
  #     library = "${config.xdg.userDirs.music}/lossy/beets.db";

  #     # Default `beet list` options
  #     sort_case_insensitive = false;
  #     sort_item = "artist+ date+ album+ disc+ track+";
  #     sort_album = "artist+ date+ album+ disc+ track+";

  #     plugins = [ "parentwork" "noimport" ]
  #       ++ lib.optional config.services.mpd.enable "mpdupdate";

  #     parentwork.auto = true;
  #   };
  # };
  #
  # programs.qutebrowser.searchEngines."!beets" = "file:///${beets.doc}/share/doc/beets-${beets.version}/html/search.html?q={}";
}
