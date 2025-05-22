{ config
, pkgs
, lib
, ...
}:
let
  steamSharedLibrary = "/var/lib/steam";
in
{
  # Gaming-use optimized kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen;

  programs.steam = {
    enable = true;

    # Allow for using Steam Input on Wayland?
    # That's what the docs say, but doesn't it already work with Wayland?
    # extest.enable = true;

    protontricks.enable = true;
    remotePlay.openFirewall = true;

    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  persist.directories = [{
    mode = "6775";
    user = "root";
    group = "root";
    directory = steamSharedLibrary;
  }];

  systemd.tmpfiles.rules = [
    "A ${steamSharedLibrary} - - - - user::rwx"
    "A ${steamSharedLibrary} - - - - group::r-x"
    "A ${steamSharedLibrary} - - - - group:users:rwx"
    "A ${steamSharedLibrary} - - - - mask::rwx"
    "A ${steamSharedLibrary} - - - - other::r-x"
    "A ${steamSharedLibrary} - - - - default:user::rwx"
    "A ${steamSharedLibrary} - - - - default:group::r-x"
    "A ${steamSharedLibrary} - - - - default:group:users:rwx"
    "A ${steamSharedLibrary} - - - - default:mask::rwx"
    "A ${steamSharedLibrary} - - - - default:other::r-x"
  ];

  environment.systemPackages = [
    (pkgs.wrapRetroArch {
      cores = with pkgs.libretro; [
        stella # Atari - 2600
        virtualjaguar # Atari - Jaguar
        prboom # DOOM
        # mame # MAME
        freeintv # Mattel - Intellivision
        mgba # Nintendo - Game Boy Advance
        sameboy # Nintendo - Game Boy / Nintendo - Game Boy Color
        dolphin # Nintendo - GameCube / Nintendo - Wii
        citra # Nintendo - Nintendo 3DS
        mupen64plus # Nintendo - Nintendo 64
        parallel-n64 # Nintendo - Nintendo 64 (Dr. Mario 64)
        melonds # Nintendo - Nintendo DS
        mesen # Nintendo - Nintendo Entertainment System / Nintendo - Family Computer Disk System
        snes9x # Nintendo - Super Nintendo Entertainment System
        picodrive # Sega - 32X
        flycast # Sega - Dreamcast
        genesis-plus-gx # Sega - Mega-Drive - Genesis
        beetle-saturn # Sega - Saturn
        swanstation # Sony - PlayStation
        pcsx2 # Sony - PlayStation 2
        ppsspp # Sony - PlayStation Portable
      ];
    })
  ];

  hardware.uinput.enable = true;
}
