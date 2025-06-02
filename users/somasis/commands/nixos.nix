{ lib
, pkgs
, config
, osConfig
, ...
}:
{
  services.tunnels.tunnels.nix-serve-http = {
    port = 5000;
    remote = "somasis@esther.7596ff.com";
  };

  nix.settings.show-trace = true;

  cache.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgCacheDir "nix";
    }
  ];

  programs.bash = {
    initExtra = ''
      nix-cd() {
          edo pushd "$(nix-output "$1" | head -n1)"
      }
    '';
  };

  xdg.configFile."nix-init/config.toml".source =
    (pkgs.formats.toml { }).generate "nix-init-config.toml"
      {
        maintainers = [ "somasis" ];

        access-tokens."github.com".command = lib.optionals config.programs.password-store.enable [
          "pass"
          "${osConfig.networking.fqdnOrHostName}/gh/github.com/somasis"
        ];
      };

  home.packages = [
    pkgs.nurl
    pkgs.nix-init

    (pkgs.writeShellScriptBin "nix-output" ''
      exec nix build --no-link --print-out-paths "$@"
    '')
  ];
}
