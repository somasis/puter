{
  config,
  lib,
  ...
}:
let
  ansi = config.lib.somasis.colors.format "ansi-8bit-escapecode";
in

{
  # prompt - Set variables such as $PS1, as well as readline configuration. See bash(1).

  programs.bash.initExtra = ''
    _before_command() {
        local command="$BASH_COMMAND"
        case "$command" in
            'sudo '*|'edo '*|'builtin '*)
                command=''${command#* }
                ;;
            '$'*)
                command=''${command% *}
                command=''${command#$}
                command=''${!command}
                ;;
            _*) return ;;
        esac

        case "$command" in
            *' > '*) command=''${command%' > '*} ;;
            *' '[0123456789]'> '*) command=''${command%' '[0123456789]'> '*} ;;
        esac

        printf '\e]0;%s\a' "''${SSH_CONNECTION:+$USER@$HOSTNAME: }''${command}"
    }

    _before_prompt() {
        local last_command_exit_status="$?"

        local symbol='∴'
        local symbol_color="\e[1;32m"
        local symbol_prefix=

        local show_username=
        local show_hostname=''${SSH_CONNECTION:-true}
        local ${lib.toShellVar "usual_username" config.home.username}

        # Don't show inputted keystrokes during prompt generation.
        printf '%b' "''${_before_prompt_enable_echo:=$(stty -echo)}" >&2

        PS1='\[\e[0m\]'

        [[ "$USER" == "$usual_username" ]] || show_username=true
        PS1+=''${show_username:+'\[\e[15;1m\]\u\[\e[0m\]'}

        # Set terminal title: [[somasis@]esther: ]bash: ~/mess/current
        local terminal_title=''${SSH_CONNECTION:+'\u@\h: '}'\s: \w'
        # then, expand it as a prompt string...
        PS1+='\[\e]0;'"$terminal_title"'\a\]'

        # Show hostname only over ssh(1) connections or chroots.
        PS1+=''${SSH_CONNECTION:+''${show_username:+'@'}''${show_hostname:+'\[${ansi config.theme.colors.accent}\]\h\[\e[0m\] '}}

        # Directory.
        PS1+=''${show_username:+' '}'\[\e[1;39m\]\w\[\e[0m\]'

        # git(1) prompt.
        PS1+=" \[\e[1;33m\]$(_git_prompt)\[\e[0m\]"

        # Set symbol color and prefix based on exit status of last command.
        if [[ "$last_command_exit_status" -eq 1 ]]; then
            symbol_color="\e[1;31m"
        elif [[ "$last_command_exit_status" -gt 128 ]]; then
            # when a command dies because it was terminated by a signal,
            # the exit code will be 128+[signal number]
            # 130: command was killed with ctrl-c...
            symbol_color="\e[1;31m"
            symbol_prefix='\[\e[2;31m\]'"$last_command_exit_status "'\[\e[0m\]'
        fi
        PS1+="$symbol_prefix\[$symbol_color\]$symbol\[\e[0m\] "

        # Reenable showing inputted keystrokes, since prompt generation is finished.
        printf '%b' "''${_before_prompt_disable_echo:=$(stty echo)}" >&2

        trap _before_command DEBUG
    }

    PROMPT_COMMAND="_before_prompt''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  '';

  programs.readline = {
    enable = true;

    bindings = {
      "\\x08" = "unix-word-rubout"; # ctrl-backspace
      # TODO undo shortcut!
    };

    variables = {
      # Use a single <tab> for completion, always; even when
      # there's multiple possible completions, and thus it's
      # ambiguous as to which is meant.
      show-all-if-ambiguous = true;

      # Append a symbol to the end of files in the completion list
      # (akin to `ls -F`).
      visible-stats = true;
      colored-stats = false;

      # When browsing history, move the cursor to the point it
      # was at when it was editing the entry in question.
      # history-preserve-point = true;

      # Complete case-insensitively.
      completion-ignore-case = true;

      # Briefly move the cursor over to a matching parenthesis
      # (for visibility).
      blink-matching-paren = true;

      menu-complete-display-prefix = true;

      # Append slashes for completion candidates that are symlinks to directories.
      # Show symlinks with a @ symbol after the name in completion lists.
      mark-symlinked-directories = true;

      # Don't use readline's internal pager for showing completion;
      # just print them to the terminal.
      page-completions = false;
      # print-completions-horizontally = true;

      # "when inserting a single match into the line ... [do] not
      # insert characters from the completion that match characters
      # after point in the word being completed, so [that] portions
      # of the word following the cursor are not duplicated."
      skip-completed-text = true;
    };
  };
}
