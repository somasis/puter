{
  services = {
    # Only automatically start one getty virtual terminals.
    logind.settings.Login.NAutoVTs = 1;

    # Show the system journal on tty12.
    journald.console = "/dev/tty12";

    kmscon = {
      enable = true;
      hwRender = true;
    };
  };
}
