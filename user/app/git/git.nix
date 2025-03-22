# In git.nix
{ pkgs, userSettings, lib, config, ... }:

{
  home.packages = with pkgs; [ 
    git
    nodejs # Ensure nodejs is available
  ];
  
  programs.git = {
    enable = true;
    userName = userSettings.name;
    userEmail = userSettings.email;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      core.editor = "nvim";
      diff.colorMoved = "default";
      # Reference the template with proper path
      commit.template = "${config.xdg.configHome}/git/commit-template";
      push.autoSetupRemote = true;
    };
  };

  # Create the commit message template file
  xdg.configFile."git/commit-template".text = ''
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

# Create a simple commit-msg hook
home.file.".local/bin/git-commit-msg-hook" = {
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
  
 # Create the hooks directory and symlink the script - with explicit git path
  home.activation.gitHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.local/bin/hooks
    $DRY_RUN_CMD ln -sf ${config.home.homeDirectory}/.local/bin/git-commit-msg-hook ${config.home.homeDirectory}/.local/bin/hooks/commit-msg
    $DRY_RUN_CMD ${pkgs.git}/bin/git config --global core.hooksPath ${config.home.homeDirectory}/.local/bin/hooks
  '';
}
