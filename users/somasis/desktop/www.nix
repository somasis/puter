{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    asciidoctor
    curlFull
    imagemagick
  ];

  home.shellAliases.note = ''$EDITOR "$(make -C ~/src/www/somas.is -s note-new)"'';
}
