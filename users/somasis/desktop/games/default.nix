{ config
, lib
, osConfig
, pkgs
, ...
}:
{
  imports = [
    ./steam.nix
    ./minecraft.nix
    ./urbanterror.nix
  ];

  home.packages =
    with pkgs;
    with kdePackages;
    [
      kpat
      kbounce
      kmahjongg
      kdiamond
      bomber
      killbots
      kmines
      knetwalk
      knavalbattle
      kfourinline
      kmahjongg
      ksnakeduel
      granatier

      knights
      stockfish
      gnuchess

      lbreakouthd
      opentyrian
      sgt-puzzles
      space-cadet-pinball
      tetrio-desktop
      zaz

      itch

      lutris

      # (
      #   assert (osConfig.hardware.graphics.enable);
      #   assert (osConfig.services.udev.enable && osConfig.hardware.uinput.enable);
      #   pkgs.retroarch.override (prev: {
      #     cores = with pkgs.libretro; [
      #       stella # Atari - 2600
      #       virtualjaguar # Atari - Jaguar
      #       prboom # DOOM
      #       # mame # MAME
      #       freeintv # Mattel - Intellivision
      #       mgba # Nintendo - Game Boy Advance
      #       sameboy # Nintendo - Game Boy / Nintendo - Game Boy Color
      #       dolphin # Nintendo - GameCube / Nintendo - Wii
      #       citra # Nintendo - Nintendo 3DS
      #       mupen64plus # Nintendo - Nintendo 64
      #       parallel-n64 # Nintendo - Nintendo 64 (Dr. Mario 64)
      #       melonds # Nintendo - Nintendo DS
      #       mesen # Nintendo - Nintendo Entertainment System / Nintendo - Family Computer Disk System
      #       snes9x # Nintendo - Super Nintendo Entertainment System
      #       picodrive # Sega - 32X
      #       flycast # Sega - Dreamcast
      #       genesis-plus-gx # Sega - Mega-Drive - Genesis
      #       beetle-saturn # Sega - Saturn
      #       swanstation # Sony - PlayStation
      #       pcsx2 # Sony - PlayStation 2
      #       ppsspp # Sony - PlayStation Portable
      #     ];

      #     # settings = prev.settings // settingsRender settings;
      #   })
      # )
    ];

  home.shellAliases = lib.mkIf osConfig.programs.gamemode.enable {
    pcsx2 = "gamemoderun pcsx2-qt -fullscreen -bigpicture";
  };

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "lutris";
    }

    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "retroarch";
    }
  ];

  sync = {
    directories = [
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "lutris";
      }
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "games";
      } # used for ROM files as well

      {
        method = "symlink";
        directory = config.lib.somasis.xdgConfigDir "retroarch";
      }
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "retroarch";
      }
      {
        method = "symlink";
        directory = config.lib.somasis.xdgConfigDir "PCSX2";
      }

      {
        method = "symlink";
        directory = config.lib.somasis.xdgConfigDir "opentyrian";
      }
      {
        method = "symlink";
        directory = config.lib.somasis.xdgConfigDir "tetrio-desktop";
      }
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "SpaceCadetPinball";
      }
      {
        method = "symlink";
        directory = ".lbreakouthd";
      }
      {
        method = "symlink";
        directory = ".zaz";
      }
    ];
  };
}
