{
  lib,
  config,
  pkgs,
  ...
}:
{
  home = {
    keyboard.options = [ "compose:ralt" ];
    # language = {
    #   base = "en_US.UTF-8";
    #   collate = "C.UTF-8";
    #   monetary = "en_US.UTF-8";
    #   measurement = "en_US.UTF-8";
    #   # messages = "tok";
    #   name = "en_US.UTF-8";
    #   numeric = "en_US.UTF-8";
    #   telephone = "en_US.UTF-8";
    #   time = "en_US.UTF-8";
    #   # time = "en_DK.UTF-8/UTF-8";
    #   paper = "en_US.UTF-8";
    # };
    sessionVariables.LANGUAGE = "en_US";
  };

  home.packages = with pkgs; [
    location

    hunspell
    hunspellDicts.en-us-large
    hunspellDicts.en-gb-ise
    hunspellDicts.en-au-large

    hunspellDicts.es-any
    hunspellDicts.es-es
    hunspellDicts.es-mx

    hunspellDicts.de-de
    hunspellDicts.fr-any

    hunspellDicts.tok

    # aspell is still used by kakoune's spell.kak, unfortunately.
    aspellDicts.en
    aspellDicts.en-computers

    aspellDicts.es
    aspellDicts.de
    aspellDicts.fr

    aspellDicts.la

    (writeShellApplication {
      name = "spell";
      runtimeInputs = [
        hunspell
        diffutils
      ];

      text = ''
        hunspell() {
            command hunspell ''${d:+-d "$d"} "$@"
        }

        d=
        while getopts :d: arg >/dev/null 2>&1; do
            case "$arg" in
                d) d="$OPTARG"; ;;
                *) usage ;;
            esac
        done
        shift $(( OPTIND - 1 ))

        diff -u "$1" <(hunspell -U "$1")
      '';
    })
  ];
}
