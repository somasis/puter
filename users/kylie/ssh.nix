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
  # $ mkdir -m go-rwx /data/home/somasis/.ssh
  data.directories = [
    ".ssh"
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
    # NOTE: Workaround the agents AUTH_SOCK values conflicting; remove once
    # <https://github.com/nix-community/home-manager/pull/8533> is merged
    ssh-agent.enable = !osConfig.security.tpm2.enable;
    ssh-tpm-agent.enable = osConfig.security.tpm2.enable;
  };

  programs.ssh = {
    enable = true;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";

        # ssh_config(5): ControlPath supports environemnt variable expansion.
        ControlPersist = "5m";
        Compression = true;

        # Send an in-band keep-alive every 30 seconds.
        ServerAliveInterval = 30;

        # Too often, IPv6 is broken on the wifi I'm on.
        # AddressFamily = "inet";

        # Use my local language and timezone whenever possible.
        SendEnv = [
          "LANG"
          "LANGUAGE"
          "TZ"
        ];

        # Can be spoofed, and dies over short connection route failures
        TCPKeepAlive = "no";

        # Accept unknown keys for unfamiliar hosts, yell when known hosts change their key.
        StrictHostKeyChecking = "accept-new";
      };

      "box.somas.is whatbox box" = {
        HostName = "box.somas.is";
        User = "somasis";
      };

      # Random hosts
      "git.causal.agency".Port = 2222;

      # Use GitHub SSH over the HTTPS port, to trick firewalls.
      # <https://help.github.com/articles/using-ssh-over-the-https-port/>
      "github.com" = {
        HostName = "ssh.github.com";
        User = "git";
        Port = 443;
      };

      # Use GitLab.com SSH over the HTTPS port, to trick firewalls.
      # <https://docs.gitlab.com/ee/user/gitlab_com/#alternative-ssh-port>
      "gitlab.com" = {
        HostName = "altssh.gitlab.com";
        User = "git";
        Port = 443;
      };
    };
  };

  home = {
    packages = [ pkgs.mosh ];
    sessionVariables.MOSH_TITLE_NOPREFIX = 1; # Disable prepending "[mosh]" to terminal title
  };
}
