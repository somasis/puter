{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./gh.nix
    ./signing.nix
  ];

  cache.directories = [
    {
      directory = config.lib.somasis.xdgCacheDir "pre-commit";
      method = "symlink";
    }
    {
      directory = config.lib.somasis.xdgCacheDir "treefmt";
      method = "symlink";
    }
  ];

  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;

      userName = "Kylie McClain";
      userEmail = "kylie@somas.is";

      aliases = {
        addall = "add -Av";
        addp = "add -p";
        unadd = "reset HEAD --";

        com = "commit";
        amend = "commit --amend";
        amendall = "!git addall; >/dev/null EDITOR=cat git amend";

        commits = "log --reverse --oneline @{upstream}...HEAD";
        patches = "format-patch --stdout origin..HEAD";

        re = "rebase";
        ri = "rebase -i";
        rbe = "rebase --edit-todo";
        rbc = "rebase --continue";
        rbs = "rebase --skip";
        rba = "rebase --abort";

        ch = "cherry-pick";
        chc = "cherry-pick --continue";
        chs = "cherry-pick --skip";
        cha = "cherry-pick --abort";
      };

      difftastic = {
        enable = true;
        display = "inline";
      };

      extraConfig = {
        init.defaultBranch = "main";
        interactive.singlekey = true;

        pull.rebase = true;
        push = {
          default = "simple";
          rebase = true;

          autoSetupRemote = true;
        };

        fetch = {
          output = "compact";

          writeCommitGraph = true; # can help with performance

          # prune = true;
          # pruneTags = true;
        };

        log.abbrevCommit = false;

        branch = {
          autoSetupMerge = "simple";
          autoSetupRebase = "always";
        };

        # Sort branch and tag lists by the date they were modified/created.
        branch.sort = "-committerdate";
        tag.sort = "taggerdate";

        diff = {
          # Detect renames more aggressively.
          renames = "copies";

          # Detects moved chunks of lines better than the default algorithm.
          algorithm = "histogram";

          # Don't print a/ and b/ prefixes on diffs in `git log`.
          noprefix = true;
        };

        commit = {
          # Show a diff at the end of the commit message during editing.
          verbose = true;

          # Keep lines that start with comment indicators before the scissors line.
          cleanup = "scissors";
        };

        stash.showPatch = true;
        status = {
          showStash = true; # --show-stash
          branch = true; # -b, --branch
          short = true; # -s, --short
        };

        # Prefer origin's branches when switching without specifying a remote.
        checkout.defaultRemote = "origin";

        # Parallelize more things.
        checkout.workers = "-1";
        fetch.parallel = "0";
        submodule.fetchJobs = "0";

        # <https://github.com/NixOS/nixpkgs/issues/169193#issuecomment-1116090241>
        safe.directory = "*";

        url = {
          "github:".insteadOf = "ssh://git@github.com:";
          "git://github.com/".insteadOf = "ssh://git@github.com:";
          "https://github.com/".insteadOf = "ssh://git@github.com:";

          "gitlab:".insteadOf = "ssh://git@gitlab.com:";
          "git://gitlab.com/".insteadOf = "ssh://git@gitlab.com:";
          "https://gitlab.com/".insteadOf = "ssh://git@gitlab.com:";

          "sourcehut:".insteadOf = "ssh://git@git.sr.ht:";
          "git://git.sr.ht/".insteadOf = "ssh://git@git.sr.ht:";
          "https://git.sr.ht/".insteadOf = "ssh://git@git.sr.ht:";
        };
      };
    };

    bash.initExtra = ''
      _git_prompt() {
          [ -n "''${_git_prompt:=$(git rev-parse --abbrev-ref=loose HEAD 2>/dev/null)}" ] \
              && printf '%s ' "''${_git_prompt}"
          _git_prompt=
      }

      gitlukin() {
          set -- $(
              git log \
                  --color=always \
                  --no-merges \
                  --oneline \
                  --reverse "$@" \
              | sk \
                  --ansi \
                  --no-sort \
                  -d ' ' \
                  --preview='git log --color=always -1 --patch-with-stat {1}' \
                  --preview-window=down:75% \
              | cut -d' ' -f1
          )
          log --no-merges "$@"
      }
    '';

    kakoune.config.hooks = [
      # Show git diff on save
      {
        name = "BufCreate";
        option = ".*";
        commands = ''
          evaluate-commands %sh{ git rev-parse >/dev/null 2>&1 && echo git show-diff || : }
        '';
      }
      {
        name = "BufWritePost";
        option = ".*";
        commands = ''
          evaluate-commands %sh{ git rev-parse >/dev/null 2>&1 && echo git show-diff || : }
        '';
      }

      # Lightly enforce the 50/72 rule for git(1) commit summaries.
      {
        name = "WinSetOption";
        option = "filetype=git-commit";
        commands = ''
          # Commit title; everything over 50 is yellow.
          add-highlighter window/ regex \A\n*[^#\n]{50}([^\n]+) 1:black,yellow+f

          # Line following the title should be empty.
          add-highlighter window/ regex \A[^\n]*\n([^#\n]+) 1:white,red+b
        '';
      }

      # Wrap git commits to 72.
      {
        name = "WinSetOption";
        option = "filetype=git-.*";
        commands = ''set-option window autowrap_column 72'';
      }
    ];
  };

  home = {
    packages = [
      pkgs.pre-commit

      pkgs.git-open

      (pkgs.writeShellScriptBin "git-curlam" ''
        set -e

        b=$(git rev-parse HEAD)

        ${pkgs.curl}/bin/curl -Lf# "$@" \
            | ${config.programs.git.package}/bin/git am -q

        a=$(git rev-parse HEAD)

        git log --oneline --reverse "$b".."$a"
      '')
    ];

    shellAliases =
      {
        am = "git am";
        add = "git add -v";

        checkout = "git checkout";
        restore = "git restore";
        reset = "git reset";

        com = "git commit";
        amend = "git commit -v --amend";

        clone = "git clone -vv";
        push = "git push -vv";
        pull = "git pull -vv";

        log = "git log --patch-with-stat --summary";
        status = "git status";

        stash = "git stash";

        rebase = "git rebase";

        switch = "git switch";
        branch = "git branch -vv";
        branchoff = "git branchoff";
      }
      # Add git aliases to the shell
      // lib.mapAttrs (
        _: v: if lib.hasPrefix "!" v then lib.removePrefix "!" v else "git ${v}"
      ) config.programs.git.aliases;
  };
}
