{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [
    ./steam.nix
    # ./minecraft.nix # TODO doesn't work on nixos-unstable currently
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

      dolphin-emu
      pcsx2 # Sony - PlayStation 2
      crispy-doom
      (
        assert (osConfig.hardware.graphics.enable);
        assert (osConfig.services.udev.enable && osConfig.hardware.uinput.enable);
        stable.retroarch.withCores (
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

  persist = {
    directories = with config.lib.somasis; [
      # keep-sorted start
      ".lbreakouthd"
      ".zaz"
      (xdgCacheDir "dolphin-emu")
      (xdgCacheDir "kpat")
      (xdgCacheDir "libkcardgame-themes")
      (xdgConfigDir "PCSX2")
      (xdgConfigDir "dolphin-emu")
      (xdgConfigDir "opentyrian")
      (xdgConfigDir "retroarch")
      (xdgConfigDir "tetrio-desktop")
      (xdgDataDir "SpaceCadetPinball")
      (xdgDataDir "crispy-doom")
      (xdgDataDir "dolphin-emu")
      # keep-sorted end
    ];

    files = with config.lib.somasis; [
      (xdgConfigDir "kpatrc")
    ];
  };
}
