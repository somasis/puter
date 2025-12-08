{
  config,
  pkgs,
  lib,
  ...
}:
let
  url = "https://github.com/somasis/puter.git";
  clonedRepo = "/var/lib/nixos-auto-upgrade-repo";
in
{
  systemd.services.nixos-upgrade.serviceConfig = {
    ExecStartPre = pkgs.writeShellScript "nixos-upgrade-repo" ''
      ${lib.toShellVar "url" url}
      ${lib.toShellVar "clone" clonedRepo}

      if [ -e "$clone"/.git ]; then
          git -C "$clone" reset --hard
          git -C "$clone" pull
      else
          mkdir -p "$clone"
          git clone --depth=1 "$url" "$clone"
      fi
    '';
    ExecStartPost = pkgs.writeShellScript "nixos-upgrade-repo-gc" ''
      git -C ${clonedRepo} gc --prune=all
    '';
  };

  system.autoUpgrade = {
    enable = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    flags = lib.mkDefault [
      "--no-flake"
      "-f"
      clonedRepo
      "-A"
      "nixosConfigurations.${config.networking.hostName}"
    ];
  };

  cache.directories = [ clonedRepo ];
}
