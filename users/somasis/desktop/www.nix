{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    asciidoctor-with-extensions
    curlFull
    imagemagick
  ];

  home.shellAliases.note = ''$EDITOR "$(make -C ~/src/www/somas.is -s note-new)"'';
}
