{ config
, lib
, ...
}:
let
  gitRepos = "/srv/git";

  sharedRepos = {
    puter = rec {
      remote = "git@esther.7596ff.com:puter.git";
      canonical = "${gitRepos}/puter.git";
      flake = "git+file://${canonical}";
      group = "puter";
      keys = lib.flatten (
        with config.users.users;
        [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXvOGvDJoSXkL0l5xueeHmYo1FjUdS1Ti77d4KteSyE esther.7596ff.com_20240702"
          cassie.openssh.authorizedKeys.keys
          somasis.openssh.authorizedKeys.keys
        ]
      );
    };
  };
in
{
  # This machine hosts the canonical repository for all other machines.

  persist.directories = [
    {
      mode = "6775";
      user = "git";
      inherit (sharedRepos.puter) group;
      directory = sharedRepos.puter.canonical;
    }
  ];

  system.autoUpgrade.flake = sharedRepos.puter.flake;
  environment.sessionVariables.FLAKE = sharedRepos.puter.flake;

  programs.git.config.safe.directory = [ sharedRepos.puter.canonical ];

  users = {
    users.git = {
      isSystemUser = true;
      packages = [ config.programs.git.package ];
      shell = config.programs.git.package; # which is `git-shell`, the shell for restricted git access

      description = "Read-only and maintenance git operations";
      home = "/srv/git";
      createHome = true;
      homeMode = "755";

      openssh.authorizedKeys.keys = sharedRepos.puter.keys;

      group = "git";
      extraGroups = [ sharedRepos.puter.group ];
    };

    groups = {
      git = { };
      ${sharedRepos.puter.group} = {
        # Push access for the repository as hosted at git@esther.7596ff.com:puter.git
        members = [
          "somasis"
          "cassie"
        ];
      };
    };
  };
}
