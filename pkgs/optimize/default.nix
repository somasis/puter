{
  lib,
  writeShellApplication,
  # pkgs,
  coreutils,
  file,
  gnugrep,
  oxipng,
  optipng,
  jpegoptim,
}:
writeShellApplication {
  name = "optimize";

  # TODO runtimeInputs = lib.somasis.nixShellPkgsToDrv ./optimize.bash pkgs;
  runtimeInputs = [
    coreutils
    file
    gnugrep

    oxipng
    optipng
    jpegoptim
  ];

  text = builtins.readFile ../../bin/optimize;

  meta = with lib; {
    description = "Losslessly optimize a file";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
    mainProgram = "optimize";
  };
}
