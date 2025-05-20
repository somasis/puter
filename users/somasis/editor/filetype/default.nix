let
  nixShellParse = ''
    evaluate-commands %sh{
        [ -z "$kak_opt_filetype" ] || exit

        shebang=$(head -n 1 "$kak_buffile")
        case "$shebang" in
            '#!'*'/env nix-shell'|'#!'*'/env cached-nix-shell')
                interpreter=''${shebang##*/env }
                interpreter=''${interpreter%% *}
                ;;
            *) exit ;; # not a nix-shell script
        esac

        interpreter=''${interpreter%% *}
        interpreter=''${interpreter##* }
        interpreter=''${interpreter%%[0123456789]*}

        case "$interpreter" in
            nix-shell|cached-nix-shell)
                # sheesh
                filetype=$(
                    sed -E \
                        -e '/^#! *(cached-)?nix-shell.* -i .*/!d' \
                        -e 's/.* -i //' \
                        -e 's/ .*//' \
                        "$kak_buffile"
                )

                case "$filetype" in
                    bash) filetype=sh ;;
                esac
                ;;
        esac

        printf "set-option buffer filetype %s\n" "$filetype"
    }
  '';
in
{
  imports = [
    ./c.nix
    ./ledger.nix
    ./nix.nix
    ./perl.nix
    ./prose.nix
    ./python.nix
    ./shell.nix
    ./troff.nix
    ./web.nix
    ./yaml.nix
  ];

  # Detect filetype for files using nix-shell.
  programs.kakoune.config.hooks = [
    {
      name = "BufOpenFile";
      option = ".*";
      commands = nixShellParse;
    }
    {
      name = "BufWritePost";
      option = ".*";
      commands = nixShellParse;
    }
  ];
}
