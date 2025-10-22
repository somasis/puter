{
  config,
  pkgs,
  osConfig,
  ...
}:
{
  # Exception to the rule: ~/.ssh is used instead of ~/etc/ssh.
  # Remember, ssh(1) suggests ~/.ssh should only be readable by
  # the user, not by the group or anyone else:
  # $ mkdir -m go-rwx /persist/home/somasis/.ssh
  persist.directories = [
    {
      # We must use bindfs because home-manager manages ~/.ssh/config for us,
      # and it will error during build when trying to follow the ~/.ssh symlink.
      method = "bindfs";
      directory = ".ssh";
    }
  ];

  systemd.user.services = {
    ssh-tpm-keygen = {
      Unit = {
        Description = "Automatically generate a user SSH key, using TPM if available";
        Before = [
          "ssh-tpm-agent.service"
          "ssh-keygen.service"
        ];

        # Only attempt execution if machine has TPM2,
        ConditionSecurity = "tpm2";

        # and if additionally there are no existing TPM-generated keys.
        ConditionPathExistsGlob = "!%h/.ssh/id_*.tpm";
      };
      Install.WantedBy = [ "ssh-tpm-agent.service" ];

      Service = {
        Type = "oneshot";
        ExecStart = ''
          ${config.services.ssh-tpm-agent.package}/bin/ssh-tpm-keygen -C "%u@%H_tpm" -N ""
        '';
      };
    };

    ssh-keygen = {
      Unit = {
        Description = "Automatically generate a user SSH key";
        Before = [ "ssh-agent.service" ];
        ConditionPathExistsGlob = "!%h/.ssh/id_*";
      };
      Install.WantedBy = [ "ssh-agent.service" ];

      Service = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.openssh}/bin/ssh-keygen -C "%u@%H" -N ""
        '';
      };
    };
  };

  services = {
    ssh-agent.enable = true;
    ssh-tpm-agent.enable = osConfig.security.tpm2.enable;
  };

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";

        # ssh_config(5): ControlPath supports environemnt variable expansion.
        controlPersist = "5m";
        compression = true;

        # Send an in-band keep-alive every 30 seconds.
        serverAliveInterval = 30;

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

      "esther.7596ff.com" = {
        host = "esther.7596ff.com esther";
        hostname = "esther.7596ff.com";

        forwardAgent = true;
      };

      "box.somas.is" = {
        host = "whatbox box";
        hostname = "box.somas.is";
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

  home = {
    packages = [ pkgs.mosh ];
    sessionVariables.MOSH_TITLE_NOPREFIX = 1; # Disable prepending "[mosh]" to terminal title
  };
}
