{
  config,
  pkgs,
  lib,
  ...
}:
let
  myfirefox = pkgs.firefox-esr;
  myfirefoxpwa = pkgs.firefoxpwa.overrideAttrs (_: {
    firefoxRuntime = myfirefox.unwrapped;
  });
in
{
  data = with config.lib.somasis; {
    directories = [
      ".mozilla"
      (xdgCacheDir "mozilla/firefox")
      (xdgDataDir "firefoxpwa")
      ".pki" # Created by Firefox.
    ];
  };

  home.sessionVariables.BROWSER = "firefox-esr";

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "application/xhtml"
    "text/html"
    "text/xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ] (_: "firefox-esr.desktop");

  home.packages =
    with pkgs;
    with kdePackages;
    [
      # I think firefoxpwa can't find the default browser if it's not at `firefox`?
      (pkgs.writeShellScriptBin "firefox" ''
        exec firefox-esr "$@"
      '')

      (myfirefox.override {
        nativeMessagingHosts = [
          plasma-browser-integration
          myfirefoxpwa
        ];
      })
      myfirefoxpwa
    ];
}
