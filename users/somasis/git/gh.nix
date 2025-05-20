{ config
, osConfig
, pkgs
, ...
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

      package = pkgs.wrapCommand {
        package = pkgs.gh;

        wrappers = [
          {
            setEnvironmentDefault.GH_HOST = "github.com";
            beforeCommand = [
              ''
                set +x
                : "''${GH_TOKEN:=$(${config.programs.password-store.package}/bin/pass "gh/$GH_HOST/''${USER:-$(id -un)}")}"
                export GH_TOKEN
              ''
            ];
          }
        ];
      };
    };

    gh-dash.enable = true;
  };
}
