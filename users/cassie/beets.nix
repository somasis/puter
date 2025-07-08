{ pkgs, lib, ... }:
let
  beets-originquery = pkgs.callPackage (
    {
      lib,
      fetchFromGitHub,
      beets,
      python3Packages,
    }:
    python3Packages.buildPythonApplication rec {
      pname = "beets-originquery";
      version = "1.0.2";

      pyproject = true;
      build-system = [ python3Packages.setuptools ];

      src = fetchFromGitHub {
        repo = pname;
        owner = "x1ppy";
        rev = version;
        hash = "sha256-32S8Ik6rzw6kx69o9G/v7rVsVzGA1qv5pHegYDmTW68=";
      };

      propagatedBuildInputs = with python3Packages; [
        confuse
        jsonpath_rw
        pyyaml
      ];

      nativeBuildInputs = [ beets ];

      meta = with lib; {
        description = "Integrates origin.txt metadata into beets' MusicBrainz queries";
        homepage = "https://github.com/x1ppy/${pname}";
        maintainers = with maintainers; [ somasis ];
        license = licenses.unfree; # <https://github.com/x1ppy/beets-originquery/issues/3>
      };
    }
  ) { beets = pkgs.beetsPackages.beets-minimal; };
in
{
  home.packages = [
    pkgs.python3Packages.requests
    pkgs.ffmpeg
    pkgs.gazelle-origin
    pkgs.sshfs-fuse
  ];

  # NOTE(somasis) Only required if nixpkgs.config.allowUnfree is not set to true.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.pipe (lib.getName pkg) [ (lib.removeSuffix "-unwrapped") ]) [
      "discord"
      "gazelle-origin"
      "beets-originquery"
    ];

  programs.beets = {
    enable = true;
    package = pkgs.beets.override {
      pluginOverrides = {
        originquery = {
          enable = true;
          propagatedBuildInputs = [ beets-originquery ];
        };
      };
    };

    settings = {
      directory = "/mnt/raid/cassie/media/music/flac2";

      threaded = true;

      plugins = [
        "edit"
        "fetchart"
        "ftintitle"
        "mbsync"
        "replaygain"
        "scrub"
        "duplicates"
        # "mbcollection"
        "originquery"
      ];

      original_date = true;

      import = {
        write = true;
        copy = true;
        incremental = true;
        languages = [ "en" ];
        duplicate_verbose_prompt = true;
      };

      musicbrainz = {
        # user = "7596ff";
        # pass = "@@cassie-beets-musicbrainz@@"; # this gets replaced by agenix at startup!

        extra_tags = [
          "year"
          "catalognum"
          "country"
          "media"
          "label"
        ];

        genre = true;
      };

      match = {
        strong_rec_thresh = 0.1;
        max_rec = {
          media = "medium";
        };
      };

      paths = {
        default = "$albumartist_sort - [$original_year] $album%aunique{}/$disc-$track $title";
        comp = "$albumartist_sort - [$original_year] $album%aunique{}/$disc-$track $title";
      };

      edit = {
        itemfields = [
          "track"
          "title"
          "album"
          "albumtype"
          "albumtypes"
          "artist"
          "artist_sort"
          "artist_credit"
          "albumartist"
          "albumartist_sort"
          "albumartist_credit"
        ];

        albumfields = [
          "album"
          "albumtype"
          "albumtypes"
          "albumartist"
          "albumartist_sort"
          "albumartist_credit"
        ];
      };

      fetchart = {
        maxwidth = 1000;
        sources = [
          "filesystem"
          { coverart = "releasegroup"; }
          { coverart = "release"; }
        ];
      };

      ftintitle.format = "ft. {0}";

      replaygain = {
        auto = true;
        backend = "ffmpeg";
      };

      mbcollection = {
        auto = false;
        collection = "390f48f9-4c44-4195-9808-a0ebd011eb5d";
        remove = true;
      };

      originquery = {
        origin_file = "origin.yaml";
        tag_patterns = {
          media = "$.Media";
          year = ''$."Edition year"'';
          label = ''$."Record label"'';
          catalognum = ''$."Catalog number"'';
          albumdisambig = "$.Edition";
        };
      };

      lastgenre = {
        auto = true;

        canonical = true;
        prefer_specific = true;
        whitelist = "/etc/nixos/users/cassie/whitelist.yaml";
      };
    };
  };
}
