{
  services = {
    logind.settings.Login = {
      # Don't automatically start any getty services on virtual terminals.
      NAutoVTs = 0;

      # But always reserve tty11 for a getty service.
      ReserveVt = 11;
    };

    # Show the system journal on tty12.
    journald.console = "/dev/tty12";
  };
}
