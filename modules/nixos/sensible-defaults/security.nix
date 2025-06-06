{
  config,
  lib,
  ...
}:
{
  # Allow for users in @wheel to use Nix.
  nix.settings.trusted-users = [ "@wheel" ];

  security = {
    sudo = {
      enable = lib.mkDefault true;
      execWheelOnly = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault false;
    };

    polkit = {
      # Required so that authorization logging takes effect.
      debug = true;

      extraConfig =
        ''
          /* Log authorization checks */
          polkit.addRule(function(action, subject) {
              polkit.log("action=" + action);
              polkit.log("subject=" + subject);
          });
        ''
        + (lib.optionalString (!config.security.sudo.wheelNeedsPassword) ''
          /* Don't require a password prompt if the user is in wheel,
           * since they could just bypass it with `sudo` anyway. */
          polkit.addRule(function(action, subject) {
              if (subject.isInGroup("wheel")) {
                  return polkit.Result.YES;
              }
          });
        '');
    };
  };

  boot.initrd.network.ssh = {
    # Add the SSH keys of all users in the wheel group to the initrd
    # SSH server's authorized keys as well.
    authorizedKeys = config.lib.somasis.sshKeysForGroup "wheel";
  };
}
