{
  config,
  osConfig,
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
}
