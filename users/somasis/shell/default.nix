{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./cd.nix
    ./commands.nix
    ./history.nix
    ./prompt.nix
  ];

  programs = {
    bash = {
      enable = true;
      enableVteIntegration = true;

      sessionVariables = {
        IGNOREEOF = 1;
        TIMEFORMAT = ''
          wall	%3lR
          user	%3lU
          kern	%3lS
          cpu	%%P%
        '';
      };

      shellOptions = [
        "dirspell" # correct spelling of directory names during completion
        "checkjobs" # warn when trying to quit a shell with jobs running
        "globstar" # allow for using ** for recursive globbing
        "lithist" # save multi-line commands to the history with their newlines
      ];

      initExtra = lib.mkAfter (
        ''
          command -v snippets.bash >/dev/null && . snippets.bash || :
        ''
        # s6/s6-rc bash completion.
        + ''
          . ${
            pkgs.fetchurl {
              url = "https://gist.githubusercontent.com/capezotte/45d9d5ebad50aa7419f632a43dad604e/raw/ad60df4d5bcb704a9b90ed9ed23a146d385c2b35/s6-comp.bash";
              hash = "sha256-DQySJr2Ci28RGFBH5VHSk1go7MCP/IhS8yHWOdTB4sI=";
            }
          }
        ''
        # Add automatic completion for aliases.
        # This needs to be done as late as possible in the script, thus `lib.mkAfter`.
        + ''
          . ${pkgs.complete-alias}/bin/complete_alias
          complete -F _complete_alias ''${!BASH_ALIASES[@]}
        ''
      );
    };

    nix-index.enable = true;
  };

  persist.directories = [
    (config.lib.somasis.xdgConfigDir "nix-index")
  ];
}
