{ pkgs
, ...
}:
{
  programs.jq.enable = true;

  # not using writeJqScript, as it produces a shell script
  home.file.".jq".text = ''
    # <https://rosettacode.org/wiki/URL_decoding#jq>
    def uri_decode:
      # The helper function converts the input string written in the given
      # "base" to an integer
      def to_i(base):
        explode
        | reverse
        | map(if 65 <= . and . <= 90 then . + 32  else . end)   # downcase
        | map(if . > 96  then . - 87 else . - 48 end)  # "a" ~ 97 => 10 ~ 87
        | reduce .[] as $c
            # base: [power, ans]
            ([1,0]; (.[0] * base) as $b | [$b, .[1] + (.[0] * $c)]) | .[1];

      .  as $in
      | length as $length
      | [0, ""]  # i, answer
      | until ( .[0] >= $length;
          .[0] as $i
          |  if $in[$i:$i+1] == "%"
             then [ $i + 3, .[1] + ([$in[$i+1:$i+3] | to_i(16)] | implode) ]
             else [ $i + 1, .[1] + $in[$i:$i+1] ]
             end)
      | .[1];  # answer
  '';

  home.packages = with pkgs; [
    pastel

    ellipsis
    sqlite-interactive.bin
    frangipanni
    fx
    ijq
    json2nix
    patchutils

    lowdown

    html-tidy
    jqfmt
    pup
    xmlstarlet

    table
    ugrep

    ini2nix
    json2nix

    yq-go
    jc
  ];
}
