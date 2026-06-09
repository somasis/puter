{
  services = {
    # Show the system journal on tty12.
    journald.console = "/dev/tty12";

    kmscon = {
      enable = true;
      config = {
        hwaccel = true;
        font-engine = "pango";
      };
    };
  };
}
