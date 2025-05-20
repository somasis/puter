{ lib
, config
, pkgs
, ...
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
    sessionVariables.LANGUAGE = "tok:en_US";
  };

  i18n.inputMethod = {
    enabled = lib.mkIf config.xsession.enable "fcitx5";
    fcitx5.addons =
      with pkgs;
      with kdePackages;
      [
        # ja
        fcitx5-mozc
        fcitx5-anthy

        # tok
        fcitx5-ilo-sitelen

        fcitx5-table-extra
        fcitx5-table-other

        fcitx5-gtk
        kdePackages.fcitx5-qt
      ];
  };

  # xdg.configFile = {
  #   # "fcitx5/config" = fcitxConfig };

  #   "fcitx5/conf/spell" = fcitxConfig {
  #     ProviderOrder = [
  #       "Presage"
  #       "Enchant"
  #       "Custom"
  #     ];
  #   };
  # };

  systemd.user.sessionVariables = lib.mkIf (config.i18n.inputMethod.enabled != null) {
    inherit (config.home.sessionVariables)
      GTK_IM_MODULE
      QT_IM_MODULE
      XMODIFIERS
      ;
  };

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "fcitx5";
    }
  ];

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "fcitx";
    }
    {
      method = "symlink";
      directory = ".anthy";
    }
  ];

  programs.kakoune.plugins = [ pkgs.kakounePlugins.kakoune-fcitx ];

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
    aspellDicts.en-science

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
