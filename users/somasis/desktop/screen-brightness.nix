{ osConfig
, config
, lib
, pkgs
, ...
}:
lib.optionalAttrs osConfig.hardware.brillo.enable {
  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "brillo";
    }
  ];

  home.packages = [ pkgs.brillo ];

  services.sxhkd.keybindings = {
    # Hardware: decrease screen backlight - fn + f4
    "@XF86MonBrightnessDown" = ''
      ${pkgs.brillo}/bin/brillo -Ll \
          | ${pkgs.xe}/bin/xe -I '!!' -j0 \
                ${pkgs.brillo}/bin/brillo -s !! -u 100000 -q -U 2
    '';

    # Hardware: increase screen backlight - fn + f5
    "@XF86MonBrightnessUp" = ''
      ${pkgs.brillo}/bin/brillo -Ll \
          | ${pkgs.xe}/bin/xe -I '!!' -j0 \
              ${pkgs.brillo}/bin/brillo -s !! -u 100000 -q -A 2
    '';
  };

  # systemd.user.services = {
  #   brightness = {
  #     Unit = {
  #       Description = "Restore the user's last display brightness level";
  #       PartOf = [ "graphical-session-pre.target" ];
  #       Before = [ "xiccd.service" "wallpaper.service" "sctd.service" ];
  #     };
  #     Install.WantedBy = [ "graphical-session-pre.target" "game.target" ];
  #     Service = {
  #       Type = "oneshot";

  #       ConditionPathExistsGlob = "%C/brillo/backlight.*";

  #       ExecStartPre = "${pkgs.brillo}/bin/brillo -elG";
  #       ExecStart = "${brightness} restore";
  #       ExecStop = "${brightness} save";
  #       RemainAfterExit = true;
  #     };
  #   };

  #   xsecurelock.Service = {
  #     ExecStartPre = [ "-${brightness} save-and-max" ];
  #     ExecStopPost = [ "-${brightness} restore" ];
  #   };
  # };
}
