{ config
, lib
, pkgs
, ...
}:
let
  clipb-kak =
    # Integrate yank with system clipboard.
    pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
      pname = "clipb-kak";
      version = "unstable-2022-03-22";
      src = pkgs.fetchFromGitHub {
        owner = "NNBnh";
        repo = "clipb.kak";
        rev = "b640b2324ef21630753c4b42ddf31207233a98d2";
        hash = "sha256-KxoiZSGvhpNESwcIo/hxga8d7iyOSYpqBvcOej+NSec=";
      };
    };
in
{
  programs.kakoune = {
    plugins = lib.mkMerge [
      (lib.optional config.xsession.enable pkgs.xclip)
      (lib.optional config.programs.kitty.enable config.programs.kitty.package)
      (lib.optional (!config.xsession.enable) pkgs.wl-clipboard)
    ];

    extraConfig = ''
      provide-module clipb %{
          source ${clipb-kak}/share/kak/autoload/plugins/clipb-kak-unstable/rc/clipb.kak
      }

      require-module clipb
    '';

    config.hooks = [
      {
        name = "ModuleLoaded";
        option = "clipb";

        commands = ''
          clipb-enable
          set-option global clipb_multiple_selections "true"
        '';
      }

      {
        name = "ModuleLoaded";
        option = "x11";

        commands = ''
          require-module clipb
          set-option global clipb_get_command "xclip -out -selection clipboard"
          set-option global clipb_set_command "xclip -in -selection clipboard"
        '';
      }

      {
        name = "ModuleLoaded";
        option = "wayland";

        commands = ''
          require-module clipb
          set-option global clipb_get_command "wl-paste --no-newline"
          set-option global clipb_set_command "wl-copy --foreground --paste-once"
        '';
      }

      # {
      #   name = "ModuleLoaded";
      #   option = "kitty";

      #   commands = ''
      #     require-module clipb
      #     set-option global clipb_get_command "kitty +kitten clipboard --get-clipboard /dev/stdout"
      #     set-option global clipb_set_command "kitty +kitten clipboard /dev/stdin"
      #   '';
      # }
    ];
  };
}
