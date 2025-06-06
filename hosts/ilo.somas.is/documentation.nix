{
  pkgs,
  nixpkgs,
  ...
}:
{
  documentation.man = {
    enable = true;
    generateCaches = true;
    man-db.enable = false;
    mandoc.enable = true;
  };
}
