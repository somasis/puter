{ lib
, fetchFromGitHub
, kakouneUtils
, perl
, tree
,
}:
kakouneUtils.buildKakounePluginFrom2Nix rec {
  pname = "kakoune-filetree";
  version = "unstable-2023-12-02";

  src = fetchFromGitHub {
    owner = "occivink";
    repo = "kakoune-filetree";
    rev = "be8158ce83e295830a48057c0580fe17a843d661";
    hash = "sha256-EfSZb5plZSU7obzLsxv0pV5G7dpolW1a4c3LLdWB5fg=";
  };

  runtimeInputs = [
    perl
    tree
  ];

  configurePhase = ''
    substituteInPlace ./filetree.kak \
        --replace-fail "tree " "${tree}/bin/tree " \
        --replace-fail "perl " "${perl}/bin/perl "
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    maintainers = with maintainers; [ somasis ];
    description = "View and navigate files from Kakoune";
  };
}
