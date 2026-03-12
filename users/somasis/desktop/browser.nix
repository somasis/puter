{
  config,
  pkgs,
  lib,
  ...
}:
{
  persist = with config.lib.somasis; {
    directories = [
      ".mozilla"
      (xdgCacheDir "mozilla/firefox")
      (xdgDataDir "firefoxpwa")
    ];
  };

  cache.directories = [
    ".pki" # Created by Firefox.
  ];

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
      (firefox-esr.override {
        nativeMessagingHosts = [
          plasma-browser-integration
          firefoxpwa
        ];
      })
    ];
}
