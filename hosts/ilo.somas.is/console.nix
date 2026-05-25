{
  services = {
    # Show the system journal on tty12.
    journald.console = "/dev/tty12";

    kmscon = {
      enable = true;
      hwRender = true;
      extraConfig = ''
        font-engine=pango
      '';
    };
  };
}
