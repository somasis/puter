{
  sources,
  pkgs,
  lib ? pkgs.lib,
  config,
  ...
}:
{
  config = {
    environment = {
      systemPackages = [ pkgs.npins ];
      etc.npins.source = pkgs.linkFarm "npins-sources" (
        lib.mapAttrsToList (name: src: {
          inherit name;
          path = src.outPath;
        }) sources
      );
    };

    nix = {
      # Disable all points of dependency pulling other than npins.
      # channels.enable = false;
      # registry = lib.mkForce {};

      # Use Flake registry to provide access to npins' source paths;
      # and rather than putting those paths directly into NIX_PATH,
      # have the NIX_PATH entries refer to the flake registry. This
      # ensures that we don't have to make permanent paths to our
      channel.enable = false;
      nixPath = [
        "nixos-config=${../../hosts/${config.networking.fqdnOrHostName}}"
      ]
      ++ (lib.mapAttrsToList (n: _: "${n}=/etc/npins/${n}") sources);

      registry = lib.mapAttrs (n: v: {
        to = {
          type = "path";
          path = v;
        };
      }) sources;
    };
  };
}
