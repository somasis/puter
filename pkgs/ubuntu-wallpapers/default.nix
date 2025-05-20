{ lib
, fetchzip
, stdenvNoCC
, imagemagick
,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ubuntu-wallpapers";
  version = "25.04.2";

  src = fetchzip {
    url = "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/ubuntu-wallpapers/${version}/ubuntu-wallpapers_${version}.orig.tar.gz";
    hash = "sha256-Oqeqlp/hzOZZF84btphP6E653buoywo3CG3pZof0dt0=";
  };

  buildInputs = [ imagemagick ];

  installPhase = ''
        # GNOME
        mkdir -p $out/share/backgrounds/ubuntu
        for img in $src/*.jpg $src/*.png; do
            ln -s "$img" $out/share/backgrounds/ubuntu/
        done

        # KDE
        mkdir -p $out/share/wallpapers/ubuntu/contents/images
        for img in $src/*.jpg $src/*.png; do
            name=''${img##*/}
            name=''${name%.*}
            mkdir -p "$out/share/wallpapers/$name/contents/images"
            size=$(identify -ping -format '%wx%h' "$img")
            ln -s "$img" "$out/share/wallpapers/$name/contents/images"/''${size}.''${img##*.}
            cat >>"$out/share/wallpapers/$name/metadata.desktop" <<_EOF
    [Desktop Entry]
    Name=$name
    X-KDE-PluginInfo-Name=$name
    _EOF
        done
  '';
}
