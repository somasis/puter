{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    with kdePackages;
    [
      okular
    ];

  persist = {
    files = [
      (config.lib.somasis.xdgConfigDir "okularpartrc")
      (config.lib.somasis.xdgConfigDir "okularrc")
    ];
  };

  # got tired of having to download PDFs just to see if they were worth checking out
  programs.qutebrowser.settings.content.pdfjs = true;

  services.tunnels.tunnels.home-printer = {
    port = 6631;
    remote = "somasis@esther.7596ff.com";
    remoteHost = "BRWD88083FAD788.lan";
    remotePort = 631;
  };
}
