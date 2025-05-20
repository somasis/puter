{ config
, pkgs
, lib
, ...
}:
{
  persist.directories = [
    "/var/lib/alsa"
    "/var/lib/pipewire"
  ];

  services.pipewire = {
    enable = true;
    audio.enable = true;

    raopOpenFirewall = true;

    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };

    jack.enable = true;

    # systemWide = true;

    extraConfig = {
      pipewire-pulse."99-local" = {
        "pulse.cmd" = [
          # Automatically use the most recently connected device as the default.
          # <https://wiki.archlinux.org/title/PipeWire#Sound_does_not_automatically_switch_when_connecting_a_new_device>
          {
            cmd = "load-module";
            args = "module-switch-on-connect";
          }

          # Allow for playing to the server's devices over the local network.
          # NOTE: 0.0.0.0 is indeed a bad IP to use for this, but otherwise we have to
          # specifically say the server's IP, which feels worse.
          # { cmd = "load-module"; args = "module-native-protocol-tcp listen=0.0.0.0"; }
          # { cmd = "load-module"; args = "module-zeroconf-publish"; }
        ];
      };

      client."99-local" = {
        # Use the best resampling quality possible since we can waste CPU for quality.
        # <https://wiki.archlinux.org/title/PipeWire#Sound_quality_(resampling_quality)>
        "stream.properties"."resample.quality" = 10;
      };
    };

    wireplumber.extraConfig = {
      "99-local" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.hfphsp-backend" = "none";
        };
      };
    };
  };

  # NOTE(somasis) seems that this is necessary so that bluetoothd
  # correctly advertises the audio capability on the Bluetooth device?
  systemd.services.bluetooth = {
    wants = [ "pipewire.service" ];
    after = [ "pipewire.service" ];
  };

  # NOTE(somasis) required if we do services.pipewire.systemWide = true;
  # users.users = lib.genAttrs [ "cassie" "somasis" ] (_: { extraGroups = [ "pipewire" ]; });

  environment.systemPackages = [
    pkgs.pulseaudio
    pkgs.ponymix
  ];
}
