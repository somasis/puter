{ pkgs, ... }:
{
  hardware.sane = {
    enable = true;
    openFirewall = true;

    extraBackends = [
      pkgs.sane-airscan
    ];
  };

  environment.systemPackages = [ pkgs.simple-scan ];
}
