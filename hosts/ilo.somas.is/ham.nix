{ lib, pkgs, ... }:
{
  hardware.rtl-sdr = {
    enable = true;
    package = pkgs.rtl-sdr-blog;
  };

  # sdr++ fails if pipewire is doing jack stuff
  services.pipewire.jack.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    gnuradio
    gqrx
    (sdrpp.override {
      portaudio_sink = true;
    })
  ];
}
