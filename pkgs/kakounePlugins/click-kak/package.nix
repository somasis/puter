{
  lib,
  fetchurl,
  kakouneUtils,
  kakoune,
}:
kakouneUtils.buildKakounePluginFrom2Nix rec {
  pname = "click-kak";
  version = "unstable-2023-06-17";

  src = fetchurl {
    url = "https://codeberg.org/slatian/dotfiles/raw/commit/3b471d684ba898391075272f1a43c407cc7dd2a8/.config/kak/autoload/click.kak";
    hash = "sha256-Oo5ZBQOQ6fV1VBTTJnxW11ltt4V7K5MA5IQZoAv0/W8=";
  };

  unpackPhase = ''
    cp $src ./
  '';

  meta = with lib; {
    homepage = "https://github.com/sawdust-and-diamonds/double-triple-click.kak/issues/1";
    maintainers = with maintainers; [ somasis ];
    license = licenses.mit;
    inherit (kakoune.meta) platforms;
  };
}
