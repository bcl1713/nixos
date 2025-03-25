# user/packages/apps/development/git.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.apps.development.git;
in {
  options.userPackages.apps.development.git = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Git with configuration";
    };

    userName = mkOption {
      type = types.str;
      default = "Brian Lucas";
      description = "Git user name";
    };

    userEmail = mkOption {
      type = types.str;
      default = "bcl1713@gmail.com";
      description = "Git user email";
    };

    defaultBranch = mkOption {
      type = types.str;
      default = "main";
      description = "Default branch name for new repositories";
    };

    enableCommitTemplate = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable commit message template";
    };

    enableCommitHooks = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable commit message hooks";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      nodejs # Ensure nodejs is available for hooks
    ];

    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      extraConfig = {
        init.defaultBranch = cfg.defaultBranch;
        pull.rebase = true;
        rebase.autoStash = true;
        core.editor = "nvim";
        diff.colorMoved = "default";
        commit.template = mkIf cfg.enableCommitTemplate
          "${config.xdg.configHome}/git/commit-template";
        push.autoSetupRemote = true;
      };
    };

    # Create the commit message template file
    xdg.configFile = mkIf cfg.enableCommitTemplate {
      "git/commit-template".text = ''
        # <type>[(optional scope)]: <description>
        # |<---- Using a Maximum Of 50 Characters ---->|

        # [optional body]
        # |<---- Try To Limit Each Line to a Maximum Of 72 Characters ---->|

        # [optional footer(s)]
        # BREAKING CHANGE:

        # Types:
        #   feat     (new feature)
        #   fix      (bug fix)
        #   docs     (documentation changes)
        #   style    (formatting, missing semi colons, etc; no code change)
        #   refactor (refactoring production code)
        #   test     (adding missing tests, refactoring tests; no production code change)
        #   chore    (updating grunt tasks etc; no production code change)
        #   perf     (performance improvements)
        #   ci       (CI/CD related changes)
        #   build    (build system or external dependency changes)
        #   revert   (reverting a previous commit)
      '';
    };

    # Create git commit hook for validating commit messages
    home.file = mkIf cfg.enableCommitHooks {
      ".local/bin/git-commit-msg-hook" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # Simple conventional commit validator
          COMMIT_MSG_FILE=''${1}
          COMMIT_MSG=$(cat ''${COMMIT_MSG_FILE})

          # Remove comments from commit message
          COMMIT_MSG=$(echo "''${COMMIT_MSG}" | grep -v '^#')

          # Check for the pattern: type(scope): message
          REGEX="^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\([a-z0-9 -]+\))?!?: .+"

          if [[ ! ''${COMMIT_MSG} =~ ''${REGEX} ]]; then
            echo "ERROR: Commit message doesn't follow conventional commit format."
            echo ""
            echo "Please use the format: type(scope): message"
            echo ""
            echo "Valid types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
            echo ""
            echo "Example: feat(user-auth): add login form"
            echo ""
            exit 1
          fi

          # Check header length (50 chars max)
          HEADER=$(echo "''${COMMIT_MSG}" | head -n 1)
          if [ ''${#HEADER} -gt 50 ]; then
            echo "ERROR: Commit header too long (''${#HEADER} > 50 characters)"
            exit 1
          fi

          # Check body line length (72 chars max per line)
          BODY=$(echo "''${COMMIT_MSG}" | tail -n +2)
          if [ ! -z "''${BODY}" ]; then
            LONG_LINES=$(echo "''${BODY}" | grep -v "^#" | grep ".\{73,\}")
            if [ ! -z "''${LONG_LINES}" ]; then
              echo "ERROR: Some lines in commit body exceed 72 characters:"
              echo "''${LONG_LINES}"
              exit 1
            fi
          fi

          exit 0
        '';
      };
    };

    # Create the hooks directory and symlink the script
    home.activation.gitHooks = mkIf cfg.enableCommitHooks
      (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.local/bin/hooks
        $DRY_RUN_CMD ln -sf ${config.home.homeDirectory}/.local/bin/git-commit-msg-hook ${config.home.homeDirectory}/.local/bin/hooks/commit-msg
        $DRY_RUN_CMD ${pkgs.git}/bin/git config --global core.hooksPath ${config.home.homeDirectory}/.local/bin/hooks
      '');
  };
}
