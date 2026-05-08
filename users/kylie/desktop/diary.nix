{
  pkgs,
  ...
}:
{
  data.directories = [
    "diary"
  ];
  home.packages = [
    (pkgs.writeShellScriptBin "diary" ''
      exec ''${EDITOR:-vi} "$HOME/diary/$(date +%Y/%m/%d.txt)"
    '')
  ];
}
