{
  self,
  sources,
  config,
  pkgs,
  ...
}:
{
  imports = [
    self.nixosModules.defaults
    self.nixosModules.npins

    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "majuna";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.somasis = {
    isNormalUser = true;
    description = "Kylie McClain";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.avahi = {
    enable = true;
    debug = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      workstation = true;
    };
  };

  environment.systemPackages = with pkgs; [
    htop
    kakoune
    lm_sensors
    tmux
  ];

  nix.settings.trusted-users = [ "somasis" ];

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tor = {
    enable = true;
    client = {
      enable = true;
      onionServices.ssh = {
        settings = {
          HiddenServicePort = "22 127.0.0.1:22";
        };
      };
    };
  };

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  powerManagement.powertop.enable = true;

  system.stateVersion = "25.05";
}
