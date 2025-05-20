{ pkgs, ... }:
{
  imports = [
    ./default.nix
  ];

  home.username = "cassie";
  home.homeDirectory = "/home/cassie";
  home.stateVersion = "24.11";

  programs.bash.enable = true;

  home.packages = with pkgs; [
    discord
    zotero
    cantata
    kwalletcli
    transmission-remote-gtk
    wl-clipboard
    mpv
  ];

  services.gpg-agent.enable = true;
  services.gpg-agent.pinentryPackage = pkgs.pinentry-all;

  # pkgs.symlinkJoin {
  #   name = "pinentry";
  #   paths = [ pkgs.pinentry-curses pkgs.pinentry-qt ];
  # };

  programs.discocss = {
    enable = true;
    discordAlias = false;

    css = '''';
  };

  services.syncthing = {
    enable = true;
  };

  xsession = {
    enable = true;
  };
}
