{ config
, lib
, osConfig
, pkgs
, ...
}:
{
  programs.git = {
    # Use SSH for signing commits, rather than GPG.
    extraConfig.gpg.format = "ssh";

    # Sign all commits and tags by default.
    signing.signByDefault = true;
    signing.key = null;
    # It is unnecessary to set `signing.key`, because git-config says
    # > user.signingKey
    # >     [...] If not set Git will call gpg.ssh.defaultKeyCommand
    # >     (e.g.: "ssh-add -L") and try to use the first key available.
    # which means it'll just use the first available key in the agent.
    extraConfig.gpg.ssh.defaultKeyCommand = "ssh-add -L";

    # Store trusted signatures.
    extraConfig.gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
  };
}
