{
  pkgs,
  lib,
  config,
  self,
  osConfig,
  ...
}:
let
  inherit (config.lib.somasis) xdgCacheDir xdgConfigDir;

  lo = pkgs.libreoffice-fresh;

  loExtensions = [
    # <https://extensions.libreoffice.org/en/extensions/show/27416>
    (pkgs.fetchurl {
      url = "https://extensions.libreoffice.org/assets/downloads/90/1676301090/TemplateChanger-L-2.0.1.oxt";
      hash = "sha256-i1+Huqsq2fYstUS4HevqpNc0/1zKRBQONMz6PB9HYh4=";
    })

    # <https://extensions.libreoffice.org/en/extensions/show/27347>
    (pkgs.fetchurl {
      url = "https://extensions.libreoffice.org/assets/downloads/73/1672894181/open_recent_doc.oxt";
      hash = "sha256-4ZZlqJKPuEw/9Sg7vyjLHERFL9yqWamtwAvldJkgFTg=";
    })

    # <https://extensions.libreoffice.org/en/extensions/show/english-dictionaries>
    (pkgs.fetchurl {
      url = "https://extensions.libreoffice.org/assets/downloads/41/1680302696/dict-en-20230401_lo.oxt";
      hash = "sha256-TXRr6BgGAQ4xKDY19OtowN6i4MdINS2BEtq2zLJDkZ0=";
    })

    # <https://extensions.libreoffice.org/en/extensions/show/spanish-dictionaries>
    (pkgs.fetchurl {
      url = "https://extensions.libreoffice.org/assets/downloads/98/1659525229/es.oxt";
      hash = "sha256-EPpR3/t48PwV/XkXcIE/VR2kPPAHtSy4+2zLC0EX6F8=";
    })

    # <https://extensions.libreoffice.org/en/extensions/show/dictionnaires-francais>
    (pkgs.fetchurl {
      url = "https://extensions.libreoffice.org/assets/downloads/z/lo-oo-ressources-linguistiques-fr-v5-7.oxt";
      hash = "sha256-lHPFZQg2QmN5jYd6wy/oSccQhXNyUXBVQzRsi6NCGt8=";
    })

    # <https://extensions.libreoffice.org/en/extensions/show/german-de-de-frami-dictionaries>
    (pkgs.fetchurl {
      url = "https://extensions.libreoffice.org/assets/downloads/z/dict-de-de-frami-2017-01-12.oxt";
      hash = "sha256-r1FQFeMGxjQ3O1OCgIo5aRIA3jQ5gR0vFQLpuRwjtGo=n";
    })

    # <https://extensions.libreoffice.org/en/extensions/show/latin-spelling-and-hyphenation-dictionaries>
    (pkgs.fetchurl {
      url = "https://extensions.libreoffice.org/assets/downloads/z/dict-la-2013-03-31.oxt";
      hash = "sha256-2DDGbz6Fihz7ruGIoA2HZIL78XK7MgJr3UeeoaYywtI=n";
    })

    # <https://extensions.libreoffice.org/en/extensions/show/languagetool>
    (pkgs.fetchurl {
      url = "https://writingtool.org/writingtool/releases/WritingTool-1.0.oxt";
      hash = "sha256-fACV86IIsMMmMnNMfgtePt9bMvRaDICSyLKhVQUXNKw=";
    })
  ]
  ++ lib.optional config.programs.zotero.enable "${config.programs.zotero.package}/usr/lib/zotero-bin-${pkgs.zotero.version}/extensions/zoteroOpenOfficeIntegration@zotero.org/install/Zotero_OpenOffice_Integration.oxt";

  loInstallExtensions =
    assert (builtins.isList loExtensions);
    pkgs.writeShellScript "libreoffice-install-extensions" ''
      PATH=${
        lib.makeBinPath [
          pkgs.gnugrep
          pkgs.coreutils
          lo
        ]
      }
      ${lib.toShellVar "exts" loExtensions}

      ext_is_installed() {
          for installed_ext in "''${installed_exts[@]}"; do
              installed_ext_basename=''${installed_ext##*/}
              [[ "$1" == "$installed_ext_basename" ]] && return 0
          done
          return 1
      }

      mapfile -t installed_exts < <(unopkg list | grep '^  URL:' | cut -d ' ' -f4-)

      for ext in "''${exts[@]}"; do
          ext_is_installed "$(basename "$ext")" || unopkg add -v -s "$ext"
      done
    '';

  loWrapperBeforeCommands = pkgs.writeShellScript "libreoffice-before-execute" ''
    if [[ "$(pgrep -c -u "''${USER:=$(id -un)}" 'soffice\.bin')" -eq 0 ]]; then
        ${loInstallExtensions} || :
    fi
  '';

  loWrapped = lo.override {
    extraMakeWrapperArgs = [
      "--add-flags '--nologo'"
      "--run ${loWrapperBeforeCommands}"
    ];
  };
in
rec {
  home.packages = with pkgs; [
    loWrapped

    languagetool

    # Free replacements for corefonts
    caladea # Cambria
    carlito # Calibri
    comic-relief # Comic Sans MS
    gelasio # Georgia
    liberation-sans-narrow # Arial Narrow
    liberation_ttf # Arial, Helvetica, Times New Roman, Courier New
  ];

  # See for more details:
  # <https://wiki.documentfoundation.org/UserProfile#User_profile_content>
  persist = {
    directories = [
      (xdgConfigDir "libreoffice/4")
    ];

    files = [
      (xdgConfigDir "LanguageTool/LibreOffice/Languagetool.cfg")
      (xdgConfigDir "LanguageTool/LibreOffice/LanguageTool.log")
    ];
  };

  cache.directories = [
    (xdgConfigDir "LanguageTool/LibreOffice/cache")
    (xdgCacheDir "libreoffice/backups")
  ];

  xdg = {
    configFile = {
      "libreoffice/jre".source = lo.unwrapped.jdk;
      "LanguageTool/LibreOffice/.keep".source = builtins.toFile "keep" "";
    };

    mimeApps.associations.removed = lib.genAttrs [ "text/plain" ] (_: "libreoffice.desktop");
  };
}
