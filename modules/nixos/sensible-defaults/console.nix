{ pkgs, ... }:
{
  environment = {
    pathsToLink = [
      "/share/fonts"
      "/share/consolefonts"
    ];

    systemPackages = with pkgs; [
      spleen
      terminus_font
    ];
  };
}
