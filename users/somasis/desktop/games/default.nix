{
  config,
  osConfig,
  pkgs,
  ...
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

      pcsx2 # Sony - PlayStation 2
      crispy-doom
      (
        assert (osConfig.hardware.graphics.enable);
        assert (osConfig.services.udev.enable && osConfig.hardware.uinput.enable);
        retroarch.withCores (
          cores: with cores; [
            stella # Atari - 2600
            # mame # MAME
            mgba # Nintendo - Game Boy Advance
            sameboy # Nintendo - Game Boy / Nintendo - Game Boy Color
            dolphin # Nintendo - GameCube / Nintendo - Wii
            citra # Nintendo - Nintendo 3DS
            mupen64plus # Nintendo - Nintendo 64
            parallel-n64 # Nintendo - Nintendo 64 (Dr. Mario 64)
            melonds # Nintendo - Nintendo DS
            mesen # Nintendo - Nintendo Entertainment System / Nintendo - Family Computer Disk System
            bsnes-mercury # Nintendo - Super Nintendo Entertainment System
            picodrive # Sega - 32X
            flycast # Sega - Dreamcast
            genesis-plus-gx # Sega - Mega-Drive - Genesis
            beetle-saturn # Sega - Saturn
            swanstation # Sony - PlayStation
            ppsspp # Sony - PlayStation Portable
          ]
        )
      )
    ];

  nixpkgs.allowUnfreePackages = [
    "libretro-picodrive"
    "libretro-genesis-plus-gx"
    "SpaceCadetPinball"
    "tetrio-desktop"
  ];

  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgConfigDir "retroarch";
    }
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "crispy-doom";
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
}
