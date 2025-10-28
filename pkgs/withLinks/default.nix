# example:
# withLinks pkgs.bfs [
#   { target = "bin/bfs"; link = "bin/find"; }
#   { target = "share/man/man1/bfs.1.gz"; link = "share/man/man1/find.1.gz"; }
# ]
{
  lib,
  symlinkJoin,
  runCommandLocal,
}:
package: links:
assert (lib.isStorePath package);
assert (lib.isList links && links != [ ]);
assert ((lib.filter (link: lib.isString link.target && link.target != "") links) != [ ]);
symlinkJoin {
  name = "${package.pname}-with-links";
  paths = [
    package
    (runCommandLocal "links" { } (
      lib.concatLines (
        map (pair: ''
          mkdir -p $out/${lib.escapeShellArg (builtins.dirOf pair.link)}
          ln -s ${lib.escapeShellArg package}/${lib.escapeShellArg pair.target} $out/${lib.escapeShellArg pair.link}
        '') links
      )
    ))
  ];
}
