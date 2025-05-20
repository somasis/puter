{ config
, osConfig
, lib
, ...
}:
{
  services.syncthing = {
    enable = true;
    extraOptions = [
      "--no-default-folder"
      "--logflags=0" # Don't prefix log lines with date and time, since systemd does
    ];
  };

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "syncthing";
    }
    {
      method = "symlink";
      directory = "shared";
    }
    {
      method = "symlink";
      directory = "sync";
    }
  ];

  systemd.user.services.syncthing = {
    # Unit.ConditionACPower = true;

    Service = {
      Environment = [ "GOMAXPROCS=1" ];

      # Make syncthing more amicable to running while other programs are.
      Nice = 19;
      CPUSchedulingPolicy = "idle";
      # CPUSchedulingPriority = 15;
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
      OOMScoreAdjust = 1000;
      OOMPolicy = "continue";
    };
  };
}
