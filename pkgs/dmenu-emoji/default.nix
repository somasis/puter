{
  lib,
  wrapCommand,
  writeShellApplication,
  coreutils,
  dmenu,
  gnugrep,
  gnused,
  moreutils,
  unicode-emoji,
  gawk,
  xclip,
  xdotool,
}:
wrapCommand {
  package = writeShellApplication {
    name = "dmenu-emoji";

    runtimeInputs = [
      coreutils
      dmenu
      gnugrep
      gnused
      moreutils
      unicode-emoji
      gawk
      xclip
      xdotool
    ];

    text = builtins.readFile ./dmenu-emoji.bash;

    meta = with lib; {
      description = "An emoji picker that uses dmenu";
      license = licenses.unlicense;
      maintainers = with maintainers; [ somasis ];
    };
  };

  wrappers = [
    {
      command = "/bin/dmenu-emoji";
      setEnvironmentDefault.DMENU_EMOJI_LIST = "${unicode-emoji}/share/unicode/emoji/emoji-test.txt";
    }
  ];
}
