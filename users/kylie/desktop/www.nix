{
  programs = {
    mr.settings = {
      "src/www/somas.is".checkout = "git clone git@github.com:somasis/www.somas.is.git somas.is";
      "src/www/wiki.musl-libc.org".checkout =
        "git clone git@github.com:somasis/musl-wiki.git wiki.musl-libc.org";
    };

    bash.initExtra = ''
      note() {
        $EDITOR "$(make -C ~/src/www/somas.is -s note-new)"
      }

      rhizome() {
        $EDITOR "$(make -C ~/src/www/somas.is -s rhizome-new)"
      }
    '';
  };
}
