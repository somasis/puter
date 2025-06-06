{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    man-pages
    man-pages-posix
    stdman

    execline-man-pages
    s6-man-pages
    s6-networking-man-pages
    s6-portable-utils-man-pages
  ];

  # TODO Submit a proper fix for using mandoc as the man provider to home-manager upstream
  programs.man.package = pkgs.mandoc;

  home.sessionVariables = {
    MANPATH = ":${config.home.profileDirectory}/share/man";
    MANWIDTH = 80;
  };
}
