{
  config,
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
}
