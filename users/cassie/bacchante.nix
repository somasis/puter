{ pkgs, ... }:
{
  imports = [
    ./default.nix
  ];

  home.username = "7596ff";
  home.homeDirectory = "/Users/7596ff";
  home.stateVersion = "24.11";

  home.shellAliases = {
    "nixos" = "darwin-rebuild switch --flake ~/.config/nix";
    "ledger" = "ledger -f ~/ledger/main.ledger";
  };

  home.packages = with pkgs; [
    mpv
  ];

  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.tmux.extraConfig = ''
    set -g default-command ${pkgs.zsh}/bin/zsh
    set -g default-shell "$SHELL"
  '';
}
