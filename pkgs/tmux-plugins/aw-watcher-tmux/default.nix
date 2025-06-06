{
  lib,
  fetchFromGitHub,
  runtimeShell,
  activitywatch,
  curl,
  tmuxPlugins,
  makeWrapper,
}:
tmuxPlugins.mkTmuxPlugin rec {
  pluginName = "aw-watcher-tmux";
  version = "unstable-2023-10-17";

  src = fetchFromGitHub {
    owner = "akohlbecker";
    repo = "aw-watcher-tmux";
    rev = "efaa7610add52bd2b39cd98d0e8e082b1e126487";
    hash = "sha256-L6YLyEOmb+vdz6bJdB0m5gONPpBp2fV3i9PiLSNrZNM=";
  };

  runtimeInputs = [
    runtimeShell
    activitywatch
    curl
  ];

  rtpFilePath = "aw-watcher-tmux.tmux";

  postInstall = ''
    install -m 0755 -D "$src/scripts/monitor-session-activity.sh" "$out/lib/tmux/aw-watcher-tmux.sh"
    cat > "$rtpFilePath" <<EOF
    #!${runtimeShell}
    exec $out/lib/tmux/aw-watcher-tmux.sh "$@" &
    EOF
    chmod +x "$rtpFilePath"
  '';

  meta = with lib; {
    description = "Activity watcher for tmux";
    homepage = "https://github.com/akohlbecker/aw-watcher-tmux";
    license = licenses.mit;
    maintainers = with maintainers; [ somasis ];
    platforms = platforms.unix;
  };
}
