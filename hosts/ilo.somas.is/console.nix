{

  # Only create two virtual terminals, one for Xorg and one for getty.
  services.logind.settings.Login.NAutoVTs = 2;

  # Show the system journal on tty12.
  services.journald.console = "/dev/tty12";
}
