{
  pkgs,
  lib,
  config,
  ...
}:
let
  formatPrettier =
    prettierArgs:
    pkgs.writeShellScript "format-prettier" ''
      PATH=${lib.makeBinPath [ pkgs.nodePackages.prettier ]}

      stdin=$(</dev/stdin)

      original_args=("$@")

      if \
          stdout=$(
              prettier \
                  --stdin-filepath "$kak_buffile" \
                  --config-precedence prefer-file \
                  ${lib.cli.toGNUCommandLineShell { } prettierArgs} \
                  ''${kak_opt_indentwidth:+--tab-width "$kak_opt_indentwidth"} \
                  ''${kak_opt_autowrap_column:+--print-width "$kak_opt_autowrap_column"} \
                  "''${original_args[@]}" \
                  <<<"$stdin"
          ) \
          && [[ "$?" -eq 0 ]] \
          && [[ -n "$stdout" ]]; then
          :
      else
          stdout="$stdin"
      fi

      printf '%s' "$stdout"
    '';

  # CSS
  formatCSS = formatPrettier { parser = "css"; };

  # HTML
  formatHTML = formatPrettier { parser = "html"; };
  lintHTML = pkgs.writeShellScript "lint-html" ''
    : "''${kak_buffile:=}"
    ${pkgs.html-tidy}/bin/tidy \
        --markup no \
        --gnu-emacs yes \
        --quiet yes
        --write-back no \
        --tidy-mark no \
        "$1" 2>&1
  '';

  # XML
  formatXML = "${pkgs.xmlstarlet}/bin/xmlstarlet format -s %opt{tabstop}";
  # lintXML = pkgs.writeShellScript "lint-xml" ''
  #   ${pkgs.xmlstarlet}/bin/xmlstarlet validate -w
  # '';

  # JavaScript
  formatJavascript = formatPrettier { };
  lintJavascript = pkgs.writeShellScript "lint-javascript" ''
    : "''${kak_buffile:=}"

    PATH=${
      lib.makeBinPath [
        pkgs.quick-lint-js
        pkgs.coreutils
      ]
    }

    quick-lint-js \
        --stdin \
        --path-for-config-search="$kak_buffile" \
        < "$1" 2>&1 \
        | cut -d: -f2- \
        | while IFS= read -r line; do printf '%s:%s\n' "$kak_buffile" "$line"; done
  '';

  # JSON
  # formatJSON = "${config.programs.jq.package}/bin/jq --indent %opt{tabstop} -S .";
  formatJSON = formatPrettier { parser = "json"; };
  lintJSON = pkgs.writeShellScript "lint-json" ''
    PATH=${
      lib.makeBinPath [
        config.programs.jq.package
        pkgs.gawk
      ]
    }

    LC_ALL=C jq 'halt' "$1" 2>&1 \
        | awk -v filename="$1" '
            / at line [0-9]+, column [0-9]+$/ {
                line=$(NF - 2);
                column=$NF;
                sub(/ at line [0-9]+, column [0-9]+$/, "");
                printf "%s:%d:%d: error: %s", filename, line, column, $0;
            }
        '
  '';

  # Jq
  formatJq = "${pkgs.jqfmt}/bin/jqfmt";
in
{
  home.packages = [
    pkgs.nodePackages.prettier
    pkgs.quick-lint-js
    pkgs.yamllint
    pkgs.jqfmt
  ];

  programs.kakoune.config.hooks = [
    # Format: CSS
    {
      name = "WinSetOption";
      option = "filetype=css";
      commands = ''
        set-option window formatcmd "run() { ${formatCSS}; } && run"
      '';
      # set-option window lintcmd ${lintCSS}
    }

    # Format, lint: HTML
    {
      name = "WinSetOption";
      option = "filetype=html";
      commands = ''
        set-option window formatcmd "run() { ${formatHTML}; } && run"
        set-option window lintcmd ${lintHTML}
      '';
    }

    # Format, lint: JavaScript
    {
      name = "WinSetOption";
      option = "filetype=javascript";
      commands = ''
        # set-option window tabstop 2
        # set-option window indentwidth 2
        set-option window formatcmd "run() { ${formatJavascript}; } && run"
        set-option window lintcmd ${lintJavascript}
      '';
    }

    # Format, lint: JSON
    {
      name = "WinSetOption";
      option = "filetype=json";
      commands = ''
        # set-option window tabstop 2
        # set-option window indentwidth 2
        set-option window formatcmd "run() { ${formatJSON}; } && run"
        set-option window lintcmd ${lintJSON}
      '';
    }

    # Format, lint: jq
    {
      name = "WinSetOption";
      option = "filetype=jq";
      commands = ''
        # set-option window tabstop 2
        # set-option window indentwidth 2
        set-option window formatcmd "run() { ${formatJq}; } && run"
      '';
      # set-option window lintcmd ${lintJq}
    }

    # Format: XML
    {
      name = "WinSetOption";
      option = "filetype=xml";
      commands = ''
        set-option window formatcmd "run() { ${formatXML}; } && run"
      '';
    }
  ];

  editorconfig.settings =
    lib.genAttrs
      [
        "{*.yaml,*.yml}"
        "{*.html,*.htm}"
        "{*.css,*.scss}"
        "*.xml"
        "*.json"
        "*.js"
      ]
      (_: {
        indent_style = "space";
        indent_size = 2;
      });
}
