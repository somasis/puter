{
  config,
  pkgs,
  ...
}:
{
  programs = {
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        pager = "cat";
      };

      gitCredentialHelper.enable = true;

      extensions = [
        pkgs.gh-eco
      ];
    };

    gh-dash.enable = true;
  };

  persist.files = [
    (config.lib.somasis.xdgConfigDir "gh/hosts.yml")
  ];
}
