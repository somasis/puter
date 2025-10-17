{
  self,
  sources,
  config,
  pkgs,
  # lib,
  ...
}:
{
  imports = with self; with sources; [
    "${agenix}/modules/age.nix"
    (import sources.nixos-cli { inherit pkgs; }).module
  ];

  environment = {
    # Link the complete flake into /etc/nixos.
    # TODO Is there some better way to do this while also including the
    # complete Git repository used?
    etc.nixos.source = self.outPath;

    systemPackages = with pkgs; [
      nix-output-monitor
      nvd
    ];
  };

  services.nixos-cli = {
    enable = true;
    config = {
      use_nvd = true;
      apply = {
        imply_impure_with_tag = true;
        use_git_commit_msg = true;
        use_nom = true;
      };
    };
  };

  nix.settings = {
    extra-substituters = [ "https://watersucks.cachix.org" ];
    extra-trusted-public-keys = [
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
    ];
  };
}
