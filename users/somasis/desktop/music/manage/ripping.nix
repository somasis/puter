{
  pkgs,
  # config,
  lib,
  ...
}:
{
  home.packages = [
    pkgs.whipper
    # pkgs.nicotine-plus
  ];

  # persist.directories = [
  #   {
  #     method = "bindfs";
  #     directory = config.lib.somasis.xdgConfigDir "nicotine";
  #   }
  #   {
  #     method = "bindfs";
  #     directory = config.lib.somasis.xdgDataDir "nicotine";
  #   }
  # ];

  # xdg.autostart.entries = [
  #   "${pkgs.nicotine-plus}/share/applications/org.nicotine_plus.Nicotine.desktop"
  # ];

  xdg.configFile."whipper/whipper.conf".text =
    lib.generators.toINI
      # Stolen from <https://github.com/nix-community/home-manager/blob/6ce3493a3c5c6a8f4cfa6f5f88723272e0cfd335/modules/services/mopidy.nix#L9-L20>
      {
        mkKeyValue =
          key: value:
          let
            value' =
              if lib.isBool value then
                (if value then "True" else "False")
              else
                lib.concatStrings (
                  builtins.map (x: if x == "%" then "%${x}" else "${x}") (lib.stringToCharacters (toString value))
                );
          in
          "${key} = ${value'}";
      }
      {
        # LG AP70NS50 External disc drive
        # <https://www.lg.com/us/burners-drives/lg-AP70NS50-external-dvd-drive>
        "drive:HL-DT-ST%3ADVDRAM%20AP70NS50%20%3A1.01" = {
          vendor = "HL-DT-ST";
          model = "DVDRAM AP70NS50";
          release = "1.01";
          read_offset = 6;
          defeats_cache = true;
        };

        "whipper.cd.rip" = {
          working_directory = "~/audio/source/rip";

          track_template = "%A - %d (%y)/%t - %a - %n";
          disc_template = "%A - %d (%y)/%A - %d (%y) (disc %N)";

          cover_art = "file";
          cdr = true;
          prompt = true;
        };
      };
}
