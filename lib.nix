{
  sources ? (import ./npins),
  nixpkgs ? (
    let
      channel = builtins.tryEval <nixpkgs>;
    in
    if channel.success then channel.value else sources.nixpkgs
  ),
  pkgs ? import nixpkgs { },
  lib ? pkgs.lib,
  config ? (
    lib.warn
      "No NixOS `config` argument provided to `somasis/puter/lib.nix`, so this function probably will not function properly"
      { }
  ),
  ...
}:
with lib;
rec {
  nixShellPkgsToDrvs =
    textPath:
    pipe (readFile textPath) [
      (splitString "\n")
      (x: filter (hasPrefix "#! nix-shell") x)
      (x: concatStrings (map (replaceStrings [ ''#! nix-shell -i bash -p '' ] [ "" ]) x))
      (splitString " ")
      (map (pkgAttr: getAttrFromPath ([ "pkgs" ] ++ (splitString "." pkgAttr)) pkgs))
    ];

  sshKeysForGroups =
    groups:
    assert (isList groups);
    flatten (
      map (
        group:
        mapAttrsToList (_: userInGroup: userInGroup.openssh.authorizedKeys.keys) (
          filterAttrs (_: user: builtins.elem group user.extraGroups) config.users.users
        )
      ) groups
    );

  # Make an absolute path that is refers to a location under $HOME... be relative to $HOME.
  relativeToHome =
    path:
    lib.strings.removePrefix "./" (
      builtins.toString (
        lib.path.removePrefix (/. + config.home.homeDirectory) (/. + (lib.strings.removePrefix "~/" path))
      )
    );

  # Give XDG paths that are relative to $HOME, mainly for use in impermanence settings
  xdgConfigDir = x: (relativeToHome config.xdg.configHome) + "/" + x;
  xdgCacheDir = x: (relativeToHome config.xdg.cacheHome) + "/" + x;
  xdgDataDir = x: (relativeToHome config.xdg.dataHome) + "/" + x;
  xdgStateDir = x: (relativeToHome config.xdg.stateHome) + "/" + x;

  # Convert a float to an integer.
  #
  # Really, we just treat it as a double. We first make it a string
  # (losing accuracy), split the string into its whole and fractional
  # parts, convert those to integers, cut trailing zeros from the
  # fractional part, and if the fractional part is >=5, we return the
  # whole number + 1, and if not, we just return the whole.
  #
  # Type: floatToInt :: float -> int
  floatToInt =
    float:
    let
      inherit (builtins)
        split
        toString
        ;
      inherit (lib)
        flatten
        isFloat
        pipe
        remove
        toInt
        ;

      splitFloat = pipe float [
        toString
        (split "(.+)[.](.+)")
        (remove "")
        flatten
      ];

      whole = pipe (elemAt splitFloat 0) [
        toString
        toInt
      ];

      fractional = pipe (elemAt splitFloat 1) [
        toString
        (split "0+$")
        (remove "")
        flatten
        toString

        # Handle fractional == 0. The `split` produced a bunch of
        # empty strings if it's just 0.
        (x: if x == "" then "0" else x)
        toInt
      ];
    in
    assert (isFloat float);
    if fractional >= 5 then whole + 1 else whole;

  # Pick a random valid, non-root port (>1024 && <=65535) based on a seed string.
  #
  # # Inputs
  #
  # `seed`
  # : A string to be used as a seed for determining a port number.
  #
  # # Type
  #
  # ```
  # randomPort :: string -> int
  # ```
  #
  # # Future
  #
  # This could definitely be done purely in Nix, but as of now that would be
  # a task. You can do the MD5 hashing in Nix, but the problem then becomes
  # converting the MD5 hash from hexadecimal to decimal, for which there is
  # no syntax and no builtin function that will do it yet. There are library
  # functions floating around on GitHub that can convert it though.
  #
  randomPort =
    seed:
    assert (isString seed);
    assert (seed != "");
    let
      port = toInt (
        fileContents (
          pkgs.runCommandLocal "random-port" { inherit seed; } ''
            port=$(${pkgs.coreutils}/bin/tr -d '\n' <<<"$seed" | ${pkgs.coreutils}/bin/md5sum)
            port=''${port%% *}
            port=$(( 0x''${port} ))
            port=''${port#-}
            port=$(( port % (65535 - 1025) ))
            port=$(( port + 1025 ))

            printf '%i' "$port" > "$out"
          ''
        )
      );
    in
    assert (port > 1024);
    assert (port <= 65535);
    port;

  # Create a comma,separated,string from a list.
  #
  # Type: commaList :: list -> str
  commaList = concatMapStringsSep "," (lib.escape [ "," ]);

  # Convert a camelCaseString to a SCREAMING_SNAKE_CASE_STRING.
  #
  # Type: camelCaseToScreamingSnakeCase :: str -> str
  camelCaseToScreamingSnakeCase =
    x:
    if toLower x == x then
      toUpper x
    else
      replaceStrings (upperChars ++ lowerChars) ((map (c: "_${c}") upperChars) ++ upperChars) x;

  # Convert a camelCaseString to a snake_case_string.
  #
  # Type: camelCaseToSnakeCase :: str -> str
  camelCaseToSnakeCase =
    x:
    if toLower x == x then
      x
    else
      replaceStrings (upperChars ++ lowerChars) ((map (c: "_${c}") lowerChars) ++ lowerChars) x;

  # Convert a camelCaseString to a kebab-case-string.
  #
  # Type: camelCaseToKebabCase :: str -> str
  camelCaseToKebabCase =
    x:
    if toLower x == x then
      x
    else
      replaceStrings (upperChars ++ lowerChars) ((map (c: "-${c}") lowerChars) ++ lowerChars) x;

  # Convert a camelCaseString to a KEBAB-CASE-STRING.
  #
  # Type: camelCaseToScreamingKebabCase :: str -> str
  camelCaseToScreamingKebabCase =
    x:
    if toLower x == x then
      x
    else
      replaceStrings (upperChars ++ lowerChars) ((map (c: "-${c}") upperChars) ++ upperChars) x;

  # Convert a snake_case_string to a camelCaseString.
  #
  # Type: snakeCaseToCamelCase :: str -> str
  snakeCaseToCamelCase =
    x:
    let
      x' = replaceStrings (map (x: "_${x}") (lowerChars ++ upperChars)) (upperChars ++ lowerChars) x;
    in
    "${toLower (builtins.substring 0 1 x)}${builtins.substring 1 ((builtins.stringLength x') - 1) x'}";

  # Get the program name and path using the same logic as `nix run`.
  #
  # Type: getExeName :: derivation -> string
  getExeName = x: builtins.baseNameOf (lib.getExe x);

  # Remove "# comments" from a given string input.
  #
  # Type: removeComments :: (string | path) -> string
  removeComments =
    string:
    let
      withCommentsRemoved =
        pkgs.runCommandLocal "removeComments"
          {
            string =
              if lib.isString string then
                pkgs.writeText "with-comments" string
              # if lib.isStorePath string then
              else
                string;
          }
          ''
            sed -E \
                -e '/^[[:space:]]*#/d' \
                -e 's/[[:space:]]+# .*//' \
                "$string" \
                > "$out"
          '';
    in
    if lib.isString string then builtins.readFile withCommentsRemoved else withCommentsRemoved;

  generators = {
    # Generate XML from an attrset.
    #
    # The XML makes a roundtrip as JSON, and is validated during generation.
    #
    # Type: toXML :: attrset -> string
    toXML =
      _: attrs:
      let
        xml =
          if (builtins.length (builtins.attrNames attrs)) == 1 then
            pkgs.runCommandLocal "xml" { json = pkgs.writeText "xml.json" (builtins.toJSON attrs); } ''
              ${pkgs.yq-go}/bin/yq \
                  --indent 0 \
                  --input-format json \
                  --output-format xml \
                  --xml-strict-mode \
                  < "$json" \
                  > xml.xml

              ${pkgs.xmlstarlet}/bin/xmlstarlet validate -e -b xml.xml

              ${pkgs.xmlstarlet}/bin/xmlstarlet c14n xml.xml > canonical.xml
              ${pkgs.xmlstarlet}/bin/xmlstarlet format -n canonical.xml > "$out"
            ''
          else
            abort "generators.toXML: only one root element is allowed";
      in
      lib.fileContents xml;
  };

  colors = rec {
    # Output a given color (any `pastel` format accepted) in a given format, as
    # accepted by `pastel`.
    #
    # Type: :: str -> str
    format =
      format: color:
      assert (lib.isString format);
      assert (lib.isString color);

      lib.fileContents (
        pkgs.runCommandLocal "color" { inherit color format; }
          # strip out the spaces because some things don't support spaces in rgb/hsl/etc.
          # type formats, and the things that do support spaces tend to allow no spaces.
          ''${lib.getExe pkgs.pastel} format "$format" "$color" > "$out" | tr -d " "''
      );

    # Format a given color to hexadecimal ("#ffffff").
    #
    # Type: :: str -> str
    hex = format "hex";

    # Format a given color to an RGB color ("rgb(255,255,255)").
    #
    # Type: :: str -> str
    rgb = format "rgb";

    kde = x: lib.replaceStrings [ "rgb(" ")" ", " ] [ "" "" "," ] (format "rgb" x);

    # Execute a given `pastel` operation on a given color, accepting a given amount as an argument.
    #
    # Type: :: str -> str
    amountOp =
      operation: amount: color:
      assert (lib.isString operation);
      assert (lib.isFloat amount);
      assert (lib.isString color);

      lib.fileContents (
        pkgs.runCommandLocal "color" {
          inherit operation amount color;
        } ''${lib.getExe pkgs.pastel} "$operation" "$amount" "$color" > "$out"''
      );

    # Saturate, with a given amount, a given color.
    #
    # Type: :: str -> str
    saturate = amountOp "saturate";

    # Desaturate, with a given amount, a given color.
    #
    # Type: :: str -> str
    desaturate = amountOp "desaturate";

    # Lighten, with a given amount, a given color.
    #
    # Type: :: str -> str
    lighten = amountOp "lighten";

    # Darken, with a given amount, a given color.
    #
    # Type: :: str -> str
    darken = amountOp "darken";
  };

  types.color =
    format:
    let
      inherit (builtins) elem;

      pastelTypes = [
        "rgb"
        "rgb-float"
        "hex"
        "hsl"
        "hsl-hue"
        "hsl-saturation"
        "hsl-lightness"
        "lch"
        "lch-lightness"
        "lch-chroma"
        "lch-hue"
        "lab"
        "lab-a"
        "lab-b"
        "luminance"
        "brightness"
        "ansi-8bit"
        "ansi-24bit"
        "ansi-8bit-escapecode"
        "ansi-24bit-escapecode"
        "cmyk"
        "name"
      ];
    in
    assert (elem format pastelTypes);
    mkOptionType {
      name = "color";
      merge = lib.options.mergeDefaultOption;

      description = ''
        a color, as understood by `pastel` (see `pastel format --help` for more information)
      '';
      descriptionClass = "noun";

      check =
        value:
        (
          lib.fileContents (
            pkgs.runCommandLocal "check-value" { inherit value; } ''
              set -x
              e=0
              ${lib.getExe pkgs.pastel} color "$value" >/dev/null || e=$?
              echo "$e" > "$out"
              exit 0
            ''
          ) == "0"
        );
    };

  mkColorOption =
    {
      format,
      default ? null,
      description ? null, # , type ? (types.color format)
    }:
    mkOption {
      type = types.color format;
      apply = colors.format format;

      inherit default description;
    };

  # Convert an argument (either a path, or a path-like string) into a derivation
  # by reading the path into a text file. If passed a derivation, the function
  # does nothing and simply returns the argument.
  #
  # Type: :: (derivation|str|path) -> derivation
  drvOrPath =
    x: if !lib.isDerivation x then pkgs.writeText (builtins.baseNameOf x) (builtins.readFile x) else x;

  # jhide can handle multiple lists, but the memory usage is much better
  # if you have a script per list.
  greasemonkey.jhide =
    excludeDomains: lists:
    assert (lib.isList excludeDomains);
    assert (lib.isString lists || lib.isList lists);

    let
      lists' = if lib.isList lists then lists else [ lists ];

      allowList = lib.optionalString (
        excludeDomains != [ ]
      ) ''--whitelist ${lib.escapeShellArg (lib.concatStringsSep "," excludeDomains)}'';

      # Create a hash of all lists' hashes combined together.
      hash = builtins.hashString "sha256" (
        lib.concatStringsSep "," (map (builtins.hashFile "sha256") lists')
      );
    in
    pkgs.runCommandLocal "jhide-${hash}.user.js" { } ''
      ${lib.getExe pkgs.jhide} -o $out ${allowList} ${lib.escapeShellArgs lists'}
    '';

  # Return from a flake argument, a string suitable for use as a package version.
  #
  # Type: :: flake -> str
  flakeModifiedDateToVersion =
    flake:
    let
      year = builtins.substring 0 4 flake.lastModifiedDate;
      month = builtins.substring 4 2 flake.lastModifiedDate;
      day = builtins.substring 6 2 flake.lastModifiedDate;
    in
    "unstable-${year}-${month}-${day}";
}
