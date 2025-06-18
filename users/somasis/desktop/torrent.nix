{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tremotesf ];

  xdg.autostart.entries = [
    "${pkgs.tremotesf}/share/applications/org.equeim.Tremotesf.desktop"
  ];

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "tremotesf";
    }
  ];
}
