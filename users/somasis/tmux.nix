{
  config,
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;

    secureSocket = false;

    terminal = "tmux-256color";

    historyLimit = 20000;
    escapeTime = 25;

    plugins = [ pkgs.tmuxPlugins.better-mouse-mode ];

    extraConfig = ''
      set-option -g history-file "$XDG_CACHE_HOME/tmux/history"

      set-option -g display-time 5000

      set-option -g mouse on
      set-option -s extended-keys on

      set-option -g allow-rename on
      set-option -g allow-passthrough on
      set-option -g cursor-style blinking-bar
      set-option -g scroll-on-clear on

      # Inform tmux of my terminal emulator's features
      set-option -sa terminal-features "xterm-kitty:256:extkeys:osc7:hyperlinks:sixel:strikethrough"

      # Set terminal (client) titles appropriately.
      set-option -g set-titles on
      set-option -g set-titles-string "tmux#{?T,: #T,}"

      # Status bar
      set-option -g status on
      set-option -g status-position top
      set-option -g status-justify left
      set-option -g status-interval 5

      set-option -g status-left ""
      set-option -g status-left-length 0
      set-option -g status-right "#{?DISPLAY,,%I:%M %p}"

      set-option -g status-style "bg=default,fg=${config.theme.colors.accent}"
      set-option -g status-left-style "fg=${config.theme.colors.accent}"
      set-option -g status-right-style "fg=${config.theme.colors.accent}"

      set-option -g pane-border-lines heavy
      set-hook -g client-focus-out  "set-option pane-border-lines single"
      set-hook -g client-focus-in   "set-option pane-border-lines heavy"
      set-hook -g pane-focus-in     "if-shell -F '#{!=:#{window_panes},1}' 'set-option -pt:. pane-border-status off'"
      set-hook -g pane-focus-out    "if-shell -F '#{!=:#{window_panes},1}' 'set-option -pt:. pane-border-status top'"

      # Windows
      set-option -g monitor-activity on
      set-option -g visual-activity on
      set-option -g renumber-windows on
      set-option -g focus-events on

      set-option -g window-status-style "bg=default,fg=${config.theme.colors.accent}"
      set-option -g window-status-current-style "bg=${config.theme.colors.accentText},fg=${config.theme.colors.accent},bold,reverse"
      set-option -g window-status-activity-style "bg=${config.theme.colors.accent},fg=${config.theme.colors.accentText},bold,reverse"
      set-option -g window-status-bell-style "bg=${config.theme.colors.accentText},fg=${config.theme.colors.orange},bold,reverse"

      # akin to catgirl(1)
      set-option -g window-status-format " #I #W "
      set-option -g window-status-current-format " #I #T "
      set-option -g window-status-separator ""

      set-option -g pane-active-border-style "bg=default,fg=${config.theme.colors.accent}"

      set-option -g set-clipboard on

      # Binds
      bind-key -T root F1 set-option status
    '';
  };

  xdg.configFile."tmux/application.conf".text = ''
    source-file "$XDG_CONFIG_HOME/tmux/tmux.conf"

    set-option -g status off

    set-option -g exit-empty on

    set-option -g set-titles on # Refers to *terminal window title*.

    # Set window title rules.
    set-option -g automatic-rename off
    set-option -g allow-rename off
    set-option -g renumber-windows on

    set-option -g history-limit 0

    set-option -gw xterm-keys on
  '';
}
