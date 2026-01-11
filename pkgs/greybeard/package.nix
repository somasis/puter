{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "greybeard";
  version = "1.0.0";

  srcs = [
    (fetchzip {
      url = "https://github.com/flowchartsman/greybeard/releases/download/v1.0.0/Greybeard-v1.0.0-pcf.zip";
      hash = "sha256-eIqpXYP2rtrZW+MVy5KkttZresnqMpUnbak5rL3o51g=";
      name = "pcf";
      stripRoot = false;
    })
    (fetchzip {
      url = "https://github.com/flowchartsman/greybeard/releases/download/v1.0.0/Greybeard-v1.0.0-ttf.zip";
      hash = "sha256-fiZshFQ3DADrw6tEQsBHnli4hWrwUl7UxyoslvEeWsg=";
      name = "ttf";
      stripRoot = false;
    })
  ];

  sourceRoot = ".";

  installPhase = ''
    find pcf/ -exec install -D -m644 --target $out/share/fonts/misc/ {} \;
    find ttf/ -exec install -D -m644 --target $out/share/fonts/truetype/ {} \;
  '';

  meta = {
    description = "A chunky monospaced bitmap programming font for old nerds that hate eyestrain";
    homepage = "https://github.com/flowchartsman/greybeard";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
    platforms = lib.platforms.all;
  };
}
