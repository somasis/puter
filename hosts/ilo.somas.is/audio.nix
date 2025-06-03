{ pkgs, ... }:
{
  # Enable ALSA and preserve the mixer state across boots.
  cache.directories = [ "/var/lib/alsa" ];

  # Necessary for realtime usage.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig = {
      pipewire-pulse."99-network" = {
        "pulse.cmd" = [
          {
            cmd = "load-module";
            args = "module-native-protocol-tcp";
          }
          {
            cmd = "load-module";
            args = "module-zeroconf-discover";
          }
        ];
      };

      pipewire."99-network" = {
        "context.modules" = [
          # { name = "libpipewire-module-pulse-tunnel"; args = { }; }
          {
            name = "libpipewire-module-zeroconf-discover";
            args = { };
          }
        ];
      };
    };
  };

  # <https://wiki.archlinux.org/title/PipeWire#Sharing_audio_devices_with_computers_on_the_network>
  # environment.etc."pipewire/pipewire.conf.d/network-audio.conf".text = ''
  #   context.exec = [
  #       { path = "pactl" args = "load-module module-native-protocol-tcp" }
  #   ]
  # '';
}
