{
  pkgs,
  ...
}:
{
  nix.settings.show-trace = true;

  home.packages = [
    pkgs.nurl

    (pkgs.writeShellScriptBin "nix-output" ''
      exec nix build --no-link --print-out-paths "$@"
    '')
  ];

  programs = {
    bash.initExtra = ''
      nix-cd() {
          edo pushd "$(nix-output "$1" | head -n1)"
      }
    '';

    nix-init = {
      enable = true;
      settings = {
        maintainers = [ "somasis" ];
        access-tokens."github.com".command = [
          "gh"
          "auth"
          "token"
        ];
      };
    };
  };
}
