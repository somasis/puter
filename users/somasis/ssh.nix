{
  config,
  pkgs,
  osConfig,
  lib,
  ...
}:
{
  # Exception to the rule: ~/.ssh is used instead of ~/etc/ssh.
  persist.directories = [ ".ssh" ];

  systemd.user.services.ssh-keygen = {
    Unit = {
      Description = "Automatically generate a user's SSH key if it doesn't exist";
      After = [ "ssh-agent.service" ];
      ConditionPathExists = "!~/.ssh";
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "auto-ssh-keygen" ''
        ${pkgs.openssh}/bin/ssh-keygen -C "$USER@$(hostname -f)_$(date -I)" -N ""
      '';
    };
  };

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;

    addKeysToAgent = "yes";

    # ssh_config(5): ControlPath supports environemnt variable expansion.
    controlPersist = "5m";
    compression = true;

    # Send an in-band keep-alive every 30 seconds.
    serverAliveInterval = 30;

    # I use ssh_config(5)'s Tag feature for determining how much
    # forwarding (of X11, of agent, etc.) to do.

    matchBlocks = {
      # trusted = {
      #   match = "tagged trusted";

      #   forwardAgent = true;
      #   forwardX11 = true;
      #   forwardX11Trusted = true;
      # };

      "*" = {
        # Too often, IPv6 is broken on the wifi I'm on.
        # addressFamily = "inet";

        # Use my local language and timezone whenever possible.
        sendEnv = [
          "LANG"
          "LANGUAGE"
          "TZ"
        ];

        extraOptions = {
          # Can be spoofed, and dies over short connection route failures
          TCPKeepAlive = "no";

          # Accept unknown keys for unfamiliar hosts, yell when known hosts change their key.
          StrictHostKeyChecking = "accept-new";
        };
      };

      # Trusted hosts
      "esther.7596ff.com" = {
        # extraOptions.Tag = "trusted";

        host = "esther.7596ff.com esther.7596ff.com.lan esther";
        hostname = "esther.7596ff.com";

        forwardAgent = true;
      };

      "ariel.whatbox.ca" = {
        extraOptions.Tag = "trusted";

        host = "ariel.whatbox.ca whatbox genesis";
        hostname = "ariel.whatbox.ca";
      };

      # Random hosts
      "git.causal.agency".port = 2222;

      # Use GitHub SSH over the HTTPS port, to trick firewalls.
      # <https://help.github.com/articles/using-ssh-over-the-https-port/>
      "github.com" = {
        hostname = "ssh.github.com";
        user = "git";
        port = 443;
      };

      # Use GitLab.com SSH over the HTTPS port, to trick firewalls.
      # <https://docs.gitlab.com/ee/user/gitlab_com/#alternative-ssh-port>
      "gitlab.com" = {
        hostname = "altssh.gitlab.com";
        user = "git";
        port = 443;
      };
    };
  };

  home.packages = [ pkgs.mosh ];
  home.sessionVariables = {
    "MOSH_TITLE_NOPREFIX" = 1; # Disable prepending "[mosh]" to terminal title
    "SSH_AUTH_SOCK" = "$XDG_RUNTIME_DIR/ssh-agent";
  };
}
