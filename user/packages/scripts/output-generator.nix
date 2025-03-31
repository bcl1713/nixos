# user/packages/scripts/output-generator.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.scripts.outputGenerator;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "update-output-file" ''
        #!/usr/bin/env bash

        # update-output-file: Combines directory contents and fetches GitHub issues
        # 
        # This script:
        # 1. Verifies we're in a git repository root directory
        # 2. Checks for GitHub CLI and authentication
        # 3. Combines directory contents using combine-directory
        # 4. Fetches GitHub issues in JSON format and adds them to output.txt
        # 5. Provides status updates and error handling

        set -euo pipefail

        # Function to show usage
        show_usage() {
          echo "Usage: update-output-file [OPTIONS]"
          echo "Options:"
          echo "  -a, --all       Include hidden files and directories"
          echo "  -m, --milestone Specify GitHub milestone to fetch issues from (default: v0.4.0)"
          echo "  -o, --output    Specify output file (default: output.txt)"
          echo "  -h, --help      Show this help message"
        }

        # Default values
        INCLUDE_HIDDEN=0
        MILESTONE=""
        OUTPUT_FILE="output.txt"

        # Parse command line arguments
        while [[ $# -gt 0 ]]; do
          case $1 in
            -a|--all)
              INCLUDE_HIDDEN=1
              shift
              ;;
            -m|--milestone)
              MILESTONE="$2"
              shift 2
              ;;
            -o|--output)
              OUTPUT_FILE="$2"
              shift 2
              ;;
            -h|--help)
              show_usage
              exit 0
              ;;
            -*)
              echo "Error: Unknown option: $1"
              show_usage
              exit 1
              ;;
            *)
              echo "Error: Unexpected argument: $1"
              show_usage
              exit 1
              ;;
          esac
        done

        # Check if we're in a git repository
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
          echo "Error: Not in a git repository"
          exit 1
        fi

        # Check if we're in the root directory of the git repository
        REPO_ROOT=$(git rev-parse --show-toplevel)
        if [ "$PWD" != "$REPO_ROOT" ]; then
          echo "Error: Not in the root directory of the git repository"
          echo "Please run this script from: $REPO_ROOT"
          exit 1
        fi

        # Check if the GitHub CLI is installed
        if ! command -v gh &>/dev/null; then
          echo "Error: GitHub CLI not installed"
          echo "Please install it with your package manager"
          exit 1
        fi

        # Check if the GitHub CLI is authenticated
        if ! gh auth status &>/dev/null; then
          echo "Error: GitHub CLI not authenticated"
          echo "Please run: gh auth login"
          exit 1
        fi

        # Check if this repository has a GitHub remote
        if ! gh repo view &>/dev/null; then
          echo "Error: This repository doesn't appear to have a GitHub remote"
          echo "Please ensure your git remote is properly configured"
          exit 1
        fi

        # Check if combine-directory is available
        if ! command -v combine-directory &>/dev/null; then
          echo "Error: combine-directory script not found"
          echo "Please ensure the combine-directory script is in your PATH"
          exit 1
        fi

        echo "=== Updating $OUTPUT_FILE ==="

        # Step 1: Use combine-directory to create/update the output file
        echo "Combining directory contents..."
        if [ "$INCLUDE_HIDDEN" -eq 1 ]; then
          combine-directory --all . "$OUTPUT_FILE"
        else
          combine-directory . "$OUTPUT_FILE"
        fi

        # Step 2: Fetch GitHub issues for the specified milestone
        echo "Fetching GitHub issues for milestone: $MILESTONE..."

        # Create a header for the issues section
        cat >> "$OUTPUT_FILE" << EOF

        ========================================
        FILE: GITHUB-ISSUES.json
        ========================================

        EOF

        # Fetch issues and append to output file in JSON format
        gh issue list --milestone "$MILESTONE" --json number,title,body,labels,state,assignees --limit 100 >> "$OUTPUT_FILE"

        echo "Done! Updated $OUTPUT_FILE with directory contents and GitHub issues"
      '')

      git # Dependency for git commands
      gh # GitHub CLI
    ];
  };
}
