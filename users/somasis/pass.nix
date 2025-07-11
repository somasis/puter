{
  config,
  pkgs,
  osConfig,
  lib,
  ...
}:
{
  persist.directories = [
    {
      method = "symlink";
      directory = config.lib.somasis.xdgDataDir "password-store";
    }
  ];

  sync.directories = [
    ".gnupg"
  ];

  programs.gpg = {
    enable = true;

    settings = {
      keyserver = "hkps://keys.openpgp.org";
      trust-model = "tofu";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableSshSupport = false;
  };

  # systemd.user = rec {
  #   services.gpg-refresh = {
  #     Unit.Description = "Refresh GPG keys from keyserver";
  #     Install.WantedBy = [ "default.target" ];

  #     Service = {
  #       Type = "oneshot";
  #       ExecStartPre = lib.mkIf osConfig.networking.networkmanager.enable "${pkgs.networkmanager}/bin/nm-online -q";
  #       ExecStart = "${lib.getExe config.programs.gpg.package} --batch --refresh-keys";
  #     };
  #   };

  #   timers.gpg-refresh = {
  #     Unit = {
  #       Description = "${services.gpg-refresh.Unit.Description}, every week on a random day";
  #       PartOf = [ "timers.target" ];
  #     };
  #     Install.WantedBy = [ "timers.target" ];

  #     Timer = {
  #       OnCalendar = "weekly";
  #       Persistent = true;
  #       RandomizedDelaySec = "6d";
  #     };
  #   };
  # };

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

  home.packages = [ pkgs.qtpass ];

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

  #   # selectors for username/password/otp input boxes. I know right
  #   extraConfig =
  #     let
  #       flatMap = f: l: lib.flatten (map f l);
  #       quote = q: s: "${q}${lib.escape [ q ] s}${q}";

  #       # ensure that specific forms come before non-specific
  #       inForms =
  #         l:
  #         (flatMap (x: ''form[id*=log_in i] ${x}'') l)
  #         ++ (flatMap (x: ''form[id*=log-in i] ${x}'') l)
  #         ++ (flatMap (x: ''form[id*=login i] ${x}'') l)
  #         ++ (flatMap (x: ''form[id*=sign_in i] ${x}'') l)
  #         ++ (flatMap (x: ''form[id*=sign-in i] ${x}'') l)
  #         ++ (flatMap (x: ''form[id*=signin i] ${x}'') l)
  #         ++ (flatMap (x: ''form ${x}'') l);

  #       # ensure autocompletes come first
  #       asNames =
  #         l:
  #         (flatMap
  #           (x: [
  #             ''[autocomplete=${x} i]''
  #             ''[autocomplete~=${x} i]''
  #             ''[autocomplete*=${x} i]''
  #           ])
  #           l)
  #         ++ (flatMap
  #           (x: [
  #             ''[name=${x} i]''
  #             ''[id=${x} i]''
  #             ''[placeholder=${x} i]''
  #             ''[aria-label=${x} i]''
  #           ])
  #           l)
  #         ++ (flatMap
  #           (x: [
  #             ''[name~=${x} i]''
  #             ''[id~=${x} i]''
  #             ''[placeholder~=${x} i]''
  #             ''[aria-label~=${x} i]''
  #           ])
  #           l)
  #         ++ (flatMap
  #           (x: [
  #             ''[name*=${x} i]''
  #             ''[id*=${x} i]''
  #             ''[placeholder*=${x} i]''
  #             ''[aria-label*=${x} i]''
  #           ])
  #           l);

  #       # ensure that we prioritize required/autofocused forms before all else
  #       preferSpecial =
  #         l:
  #         (map (x: "${x}[required][autofocus]") l)
  #         ++ (map (x: "${x}[required]") l)
  #         ++ (map (x: "${x}[autofocus]") l)
  #         ++ l;

  #       # generate a list with a whole lot of selectors in highest to lowest priority
  #       # start with the element that we need to check multiple of, then process it
  #       # a few times
  #       #
  #       # process:
  #       #     1. Start with "username", wrapped in quotes to create '"username"', and pass it to `asNames`
  #       #     2. asNames generates
  #       #       [
  #       #         ''[autocomplete="username" i]'', ''[autocomplete~="username" i]'', ''[autocomplete*="username" i]'',i
  #       #         ''[name="username" i]'', ''[id="username" i]'', ''[placeholder="username" i]'', ''[aria-label="username" i]'',
  #       #         ''[name~="username" i]'', ''[id~="username" i]'', ''[placeholder~="username" i]'', ''[aria-label~="username" i]'',
  #       #         ''[name*="username" i]'', ''[id*="username" i]'', ''[placeholder*="username" i]'', ''[aria-label*="username" i]''
  #       #       ]
  #       #       and passes it to the next function.
  #       #     3. Prefix each item with 'input[type="text"]
  #       #     4. Receive list `x`, and generate once big list that is each item in
  #       #        `x` with '[required][autofocus]' appended,
  #       #        then `x` with '[required]' appended,
  #       #        then `x` with '[autofocus]' appended,
  #       #        then `x` again, in that order.
  #       #     5. Append the form selectors to each time, same process but with
  #       #        'form[id*=login i] ' and 'form ' so that we prefer login forms before
  #       #        any other forms.
  #       #     ∴  giant huge priority-sorted list of selectors
  #       usernameSelectors =
  #         lib.pipe
  #           (map (quote "\"") [
  #             "login"
  #             "user"
  #             "alias"
  #             "username"
  #             ""
  #           ])
  #           [
  #             asNames
  #             (map (x: ''input[type="text"]${x}''))
  #             preferSpecial
  #             inForms
  #           ];

  #       emailSelectors =
  #         lib.pipe
  #           (map (quote "\"") [
  #             "email"
  #             ""
  #           ])
  #           [
  #             asNames
  #             (flatMap (x: [
  #               ''input[type="email"]${x}''
  #               ''input[type="text"]${x}''
  #             ]))
  #             preferSpecial
  #             inForms
  #           ];

  #       passwordSelectors =
  #         lib.pipe
  #           (map (quote "\"") [
  #             "current-password"
  #             "password"
  #             ""
  #           ])
  #           [
  #             asNames
  #             (map (x: ''input[type="password"]${x}''))
  #             preferSpecial
  #             inForms
  #           ];

  #       newPasswordSelectors =
  #         lib.pipe
  #           (map (quote "\"") [
  #             "new-password"
  #             "password"
  #             ""
  #           ])
  #           [
  #             asNames
  #             (map (x: ''input[type="password"]${x}''))
  #             preferSpecial
  #             inForms
  #           ];

  #       otpSelectors =
  #         lib.pipe
  #           (map (quote "\"") [
  #             "otp"
  #             "2fa"
  #             ""
  #           ])
  #           [
  #             asNames
  #             (map (x: ''input[type="number"]${x}''))
  #             preferSpecial
  #             inForms
  #           ];

  #       # cardSelectors = lib.pipe (map (quote "\"") [ "credit" "card" [
  #       #   asNames
  #       #   (map (x: ''input[type="text"]${x}''))
  #       #   inForms
  #       # ];

  #       # cvvSelectors = lib.pipe (map (quote "\"") [ "cvv" [
  #       #   asNames
  #       #   (map (x: ''input[type="text"]${x}''))
  #       #   inForms
  #       # ];

  #       # stolen from browserpass
  #       # <https://github.com/browserpass/browserpass-extension/blob/858cc821d20df9102b8040b78d79893d4b7af352/src/inject.js#L62-L134>
  #       submitSelectors =
  #         lib.pipe
  #           [
  #             "[type=submit i]"
  #             "button[name=login i]"
  #             "button[name=log-in i]"
  #             "button[name=log_in i]"
  #             "button[name=signin i]"
  #             "button[name=sign-in i]"
  #             "button[name=sign_in i]"
  #             "button[id=login i]"
  #             "button[id=log-in i]"
  #             "button[id=log_in i]"
  #             "button[id=signin i]"
  #             "button[id=sign-in i]"
  #             "button[id=sign_in i]"
  #             "button[class=login i]"
  #             "button[class=log-in i]"
  #             "button[class=log_in i]"
  #             "button[class=signin i]"
  #             "button[class=sign-in i]"
  #             "button[class=sign_in i]"
  #             "input[type=button i][name=login i]"
  #             "input[type=button i][name=log-in i]"
  #             "input[type=button i][name=log_in i]"
  #             "input[type=button i][name=signin i]"
  #             "input[type=button i][name=sign-in i]"
  #             "input[type=button i][name=sign_in i]"
  #             "input[type=button i][id=login i]"
  #             "input[type=button i][id=log-in i]"
  #             "input[type=button i][id=log_in i]"
  #             "input[type=button i][id=signin i]"
  #             "input[type=button i][id=sign-in i]"
  #             "input[type=button i][id=sign_in i]"
  #             "input[type=button i][class=login i]"
  #             "input[type=button i][class=log-in i]"
  #             "input[type=button i][class=log_in i]"
  #             "input[type=button i][class=signin i]"
  #             "input[type=button i][class=sign-in i]"
  #             "input[type=button i][class=sign_in i]"

  #             "button[name*=login i]"
  #             "button[name*=log-in i]"
  #             "button[name*=log_in i]"
  #             "button[name*=signin i]"
  #             "button[name*=sign-in i]"
  #             "button[name*=sign_in i]"
  #             "button[id*=login i]"
  #             "button[id*=log-in i]"
  #             "button[id*=log_in i]"
  #             "button[id*=signin i]"
  #             "button[id*=sign-in i]"
  #             "button[id*=sign_in i]"
  #             "button[class*=login i]"
  #             "button[class*=log-in i]"
  #             "button[class*=log_in i]"
  #             "button[class*=signin i]"
  #             "button[class*=sign-in i]"
  #             "button[class*=sign_in i]"
  #             "input[type=button i][name*=login i]"
  #             "input[type=button i][name*=log-in i]"
  #             "input[type=button i][name*=log_in i]"
  #             "input[type=button i][name*=signin i]"
  #             "input[type=button i][name*=sign-in i]"
  #             "input[type=button i][name*=sign_in i]"
  #             "input[type=button i][id*=login i]"
  #             "input[type=button i][id*=log-in i]"
  #             "input[type=button i][id*=log_in i]"
  #             "input[type=button i][id*=signin i]"
  #             "input[type=button i][id*=sign-in i]"
  #             "input[type=button i][id*=sign_in i]"
  #             "input[type=button i][class*=login i]"
  #             "input[type=button i][class*=log-in i]"
  #             "input[type=button i][class*=log_in i]"
  #             "input[type=button i][class*=signin i]"
  #             "input[type=button i][class*=sign-in i]"
  #             "input[type=button i][class*=sign_in i]"
  #           ]
  #           [
  #             preferSpecial
  #             inForms
  #           ];

  #       selectors = {
  #         username = usernameSelectors;
  #         # emailSelectors;
  #         email = emailSelectors;

  #         password = passwordSelectors;
  #         new-password = newPasswordSelectors;

  #         otp = otpSelectors;

  #         submit = submitSelectors;
  #       };
  #     in
  #     lib.concatStringsSep "\n" (
  #       lib.mapAttrsToList (n: v: "c.hints.selectors[${quote "'" n}] = ${builtins.toJSON v}") selectors
  #     );
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
