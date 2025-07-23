{
  config,
  pkgs,
  lib,
  ...
}:
{
  persist = {
    directories = [
      {
        method = "symlink";
        directory = config.lib.somasis.xdgDataDir "password-store";
      }
    ];

    files = [
      (config.lib.somasis.xdgConfigDir "kleopatrarc")
    ];
  };

  sync.directories = [
    ".gnupg"
  ];

  home.packages =
    with pkgs;
    with kdePackages;
    [
      # keep-sorted start
      gnupg
      kleopatra
      pinentry-qt
      qtpass
      # keep-sorted end
    ];

  programs.password-store = {
    enable = true;

    settings.PASSWORD_STORE_CLIP_TIME = builtins.toString 60;

    package = pkgs.pass-wayland.withExtensions (
      exts:
      with exts;
      with pkgs.passExtensions;
      [
        (pass-audit.overrideAttrs (oldAttrs: {
          doCheck = false;
        }))
        pass-update

        pass-otp
        pass-botp

        pass-meta
      ]
    );
  };

  # Provide libsecret service for various apps
  services.pass-secret-service.enable = true;

  # programs.qutebrowser = {
  #   aliases.pass = "spawn -u ${lib.getExe qute-pass}";

  #   keyBindings.normal = {
  #     # Login
  #     "zll" = "pass -H";
  #     "zlL" = "pass -H -d <Enter>";
  #     "zlz" = "pass -H -S";

  #     "zlZ" = "pass -m fields";

  #     # Specific fills
  #     "zlu" = "pass -m username";
  #     "zle" = "pass -m email";
  #     "zlp" = "pass -m password";
  #     "zlo" = "pass -m otp";

  #     "zlg" = "pass -m generate-for-url {url:host}";
  #     "zlG" = "pass -m generate-for-url -n {url:host}";
  #   };
  # };

  # NOTE Workaround <https://github.com/NixOS/nixpkgs/issues/183604>
  programs.bash.initExtra =
    let
      completions = "${config.programs.password-store.package}/share/bash-completion/completions";
    in
    lib.mkAfter ''
      source ${completions}/pass-*
      source ${completions}/pass
    '';

  home.sessionVariables = {
    # Used by `bin/phishin-like-show`, among other things.
    PHISHIN_USER_EMAIL_COMMAND = "pass meta www/phish.in email";
    PHISHIN_USER_PASSWORD_COMMAND = "pass meta www/phish.in password";
    PHISHNET_SECRET_COMMAND = "pass api/phish-cli/phish.net | head -n1";
  };
}
