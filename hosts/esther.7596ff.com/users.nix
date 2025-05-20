{
  persist.directories = [
    {
      directory = "/home/cassie";
      user = "cassie";
      group = "cassie";
      mode = "0775";
    }
  ];

  cache.directories = [
    {
      directory = "/var/lib/fail2ban";
      mode = "0750";
    }
  ];

  users = {
    mutableUsers = false;

    users = {
      # See password store: esther.7596ff.com/root
      root.hashedPassword = "$y$j9T$2l81FO6/eJmS4urVYCcJ9/$16Dp8JdCb29R6SsqS1363oVJjxrhL4KGee/P26X7eFD";

      cassie = {
        isNormalUser = true;
        description = "Cassandra McCarthy";
        uid = 1001;

        group = "cassie";
        extraGroups = [
          "users"
          "wheel"
          "tv"
        ];

        createHome = true;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlOPXT+fmM2piNCkaF1H3CP3rGGtpvJrJy+sp7HMZAe cassie@7596ff.com nogpg"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKQyDGjAOBlLgvVDTsFkZixcfrMZ3ga8qmXVx3gBWXOQsES4F6ICuRMP1a+Oxv5W+n+UOWJQ++1E8E6iy8JyISCcPF5aw07/OQ2o6cAMFy3ynF3GRMotyTJYssaExruE+ZuAy8cnRPFaCaIXN9FMcGmAHN8zhA2GK6nEWL4XqPXg/6mjlJNsQ8kLsnqCIoCYKbVHMaiYspK8NgrWHWa3JfUnYwTWPPMZ8nIGGZCZel0rWJjv/VsltRZtAkdS1FqqFVesaW2UNyCLNpbZj1rwBb3g87j47kT5R5/P0K4hzUgOkzLCas4jR4VDqZJ+kCVPSVcVWPHCiBKBtAm/XdsWV5 (none)"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+8VgxRbCKnR8x0giYovtzmHCOUTbmkYSQ7dPSnFQ/Y 7596ff@gmail.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOi+ev0Pho2FPkGf2Obpw9SPipchbParj07fOHpGzd9/ Shortcuts on bacchante"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIJC1tzPBlce7RjJrcUbWB3jceJ8NmNoh0jpM0rrrUV alpine@persephone"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+0A3Rb8z3llTlJHyAltMyXEaI4aYw5UWmdRUgwyAtw cassie@charybdis"
        ];

        hashedPassword = "$6$qMWTYwXR9S9SuvAn$4mv6B8b3Ad3723ts9w0MvrV1nPCs/Bh0KWfDvrSSv1ZiNqflZnFjEN9NloSTA24v8puKOCVgY.9PkJ7dsLX9W0";
      };

      somasis = {
        isNormalUser = true;
        description = "Kylie McClain";
        uid = 1000;

        group = "somasis";
        extraGroups = [
          "users"
          "wheel"
          "tv"
        ];

        createHome = true;
        homeMode = "775";

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwx+D9HPPjg0H6rSLUaXiEOQzF9W4LlX3HRgyD+4eis somasis@esther.7596ff.com_20250221"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkmjWLpicEaQOkM7FAv5bctmZjV5GjISYW7re0oknLU somasis@ilo.somas.is_20220603"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICt+E12KtLbvV4T7oLgs8gY3DHWN6yaWaks/U/Ci4fc9 root@ilo"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcvxl9j1tDudTJPbwLPXxraS7rvlHX0JIE/R/iLxg/G lili.somas.is_20250301"
        ];

        hashedPassword = "$6$1Bxtqgje6BtHxQ0U$MJf.x.Er4EupbYK6eeX4vZBgWCiDc3WpK.X7JSHjTCgbToVS9CsDsl6Fq6dpMFjF/fpsgInY6jmG7JwmWXaZo/";
      };
    };

    groups = {
      cassie.gid = 1001;
      somasis.gid = 1000;
    };
  };

  services.fail2ban = {
    enable = true;
    ignoreIP = [ "192.168.0.0/16" ]; # disallow banning local network IPs
    bantime-increment = {
      # enable progressively extending ban length for repeated offenders
      enable = true;
      rndtime = "10m";
      maxtime = "24h"; # at most one can be banned for a day
    };
  };

  # Allow for users in @wheel to use Nix.
  nix.settings.trusted-users = [ "@wheel" ];

  security = {
    sudo = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false;
    };

    # Bring polkit's rules into harmony with sudo.
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (subject.isInGroup("wheel")) {
              return polkit.Result.YES;
          }
      });
    '';
  };
}
