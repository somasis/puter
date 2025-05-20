{ lib
, writeShellApplication
, coreutils
, file
, gnugrep
, oxipng
, optipng
, jpegoptim
,
}:
writeShellApplication {
  name = "optimize";

  runtimeInputs = [
    coreutils
    file
    gnugrep

    oxipng
    optipng
    jpegoptim
  ];

  text = builtins.readFile ./optimize.bash;

  meta = with lib; {
    description = "Losslessly optimize a file";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
    mainProgram = "optimize";
  };
}
