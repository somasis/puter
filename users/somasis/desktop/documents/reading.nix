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

  persist = with config.lib.somasis; {
    directories = [
      (xdgDataDir "okular")
    ];

    files = [
      (xdgConfigDir "okularpartrc")
      (xdgConfigDir "okularrc")
    ];
  };

  # got tired of having to download PDFs just to see if they were worth checking out
  programs.qutebrowser.settings.content.pdfjs = true;
}
