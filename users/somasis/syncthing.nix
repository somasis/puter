{ config, ... }:
{
  services.syncthing.enable = true;

  persist.directories = [
    {
      method = "symlink";
      directory = "shared";
    }
    {
      method = "symlink";
      directory = "sync";
    }
    # {
    #   method = "symlink";
    #   directory = config.lib.somasis.xdgStateDir "syncthing";
    # }
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
