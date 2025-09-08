{ pkgs, ... }:
{
  hardware.sane = {
    enable = true;
    openFirewall = true;

    extraBackends = [
      pkgs.sane-airscan
    ];
  };

  environment.systemPackages = with pkgs.kdePackages; [
    skanpage
  ];
}
