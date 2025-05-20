{ config, pkgs, ... }:
{
  imports = [
    ./qutebrowser.nix
  ];

  home.sessionPath = [ "$HOME/bin" ];

  home.sessionVariables = {
    EDITOR = "nvim";
    LESS = "FR";
  };

  home.packages = with pkgs; [
    tree
    links2
    weechat
    nil
    ledger
    less
    comma
    mosh
  ];

  programs.git = {
    enable = true;
    userName = "Cassandra McCarthy";
    userEmail = "cassie@7596ff.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.ssh = {
    enable = true;

    addKeysToAgent = "yes";
  };

  programs.ssh.matchBlocks = {
    "esther" = {
      hostname = "esther.7596ff.com";
      identityFile = "~/.ssh/id_nogpg";
      user = "cassie";
    };

    "github" = {
      hostname = "github.com";
      identitiesOnly = true;
      identityFile = "~/.ssh/gpg-ssh.pub";
    };

    "galileo" = {
      hostname = "galileo.whatbox.ca";
      identityFile = "~/.ssh/id_nogpg";
      user = "cassie";
    };

    "camus" = {
      hostname = "192.168.1.24";
      user = "root";
    };

    "libra" = {
      hostname = "192.168.1.175";
      user = "root";
      port = 2222;
    };

    "bobo" = {
      hostname = "192.168.1.1";
      port = 2220;
      user = "root";
    };
  };

  programs.gpg.enable = true;
  # programs.gpg.settings = {
  # };

  services.gpg-agent = {
    enableSshSupport = true;
    sshKeys = [ "AD45D4AF957CB4FDAC75B63F4276C19E01F0A552" ];
  };

  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      gruvbox
      nerdtree
      fidget-nvim
    ];

    coc.enable = true;
    coc.settings = {
      languageserver = {
        nix = {
          command = "${pkgs.nil}/bin/nil";
          filetypes = [ "nix" ];
          rootPatterns = [ "flake.nix" ];
          settings = {
            nil = {
              formatting.command = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
            };
          };
        };
      };
    };

    extraLuaConfig = ''
      vim.g.NERDTreeQuitOnOpen = 1;

      vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>')
    '';
  };

  programs.tmux = {
    enable = true;

    clock24 = true;
    historyLimit = 10000;
    mouse = true;
    newSession = true;
  };

  programs.ledger.enable = true;
  programs.ledger.settings = {
    columns = 120;
    date-format = "%F";
    file = "${config.home.homeDirectory}/ledger/main.ledger";
    sort = "date";
    aux-date = true;
    pager = "${pkgs.less}/bin/less";
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (e: [ e.pass-otp ]);

    settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
  };

  programs.zsh = {
    history.append = true;
    history.ignoreAllDups = true;

    initExtra = ''
      autoload -Uz history-search-end
      zle -N history-beginning-search-backward-end history-search-end
      zle -N history-beginning-search-forward-end history-search-end
      bindkey "^[[A" history-beginning-search-backward-end
      bindkey "^[[B" history-beginning-search-forward-end
    '';
  };
}
