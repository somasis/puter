{ pkgs
, ...
}:
{
  persist.directories = [
    {
      method = "symlink";
      directory = "www";
    }
  ];

  home.packages = with pkgs; [
    asciidoctor-with-extensions
    curlFull
    imagemagick
  ];

  home.shellAliases.note = ''$EDITOR "$(make -C ~/www/somas.is -s note-new)"'';
}
