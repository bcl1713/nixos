# user/packages/scripts/tools.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.scripts.tools;
in {
  # Import the module definition for directory-combiner
  imports = [ ./directory-combiner.nix ];

  # No options should be defined here - they should all be in default.nix

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.directoryCombiner.enable {
      programs.directory-combiner = {
        enable = true;
        package = pkgs.writeShellScriptBin "combine-directory" ''
          #!/usr/bin/env bash

          # combine-directory: Recursively combines all files in a directory
          # with headers showing relative paths

          set -euo pipefail

          # Default configuration
          INCLUDE_HIDDEN=0

          # Function to show usage
          show_usage() {
            echo "Usage: combine-directory [OPTIONS] <directory> [output-file]"
            echo "Options:"
            echo "  -a, --all       Include hidden files and directories"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "If output-file is not specified, output goes to stdout"
          }

          # Parse command line arguments
          POSITIONAL_ARGS=()

          while [[ $# -gt 0 ]]; do
            case $1 in
              -a|--all)
                INCLUDE_HIDDEN=1
                shift
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
                POSITIONAL_ARGS+=("$1")
                shift
                ;;
            esac
          done

          # Restore positional parameters
          set -- "''${POSITIONAL_ARGS[@]}"

          if [ $# -lt 1 ]; then
            show_usage
            exit 1
          fi

          TARGET_DIR="$1"
          OUTPUT_FILE=""

          if [ $# -ge 2 ]; then
            OUTPUT_FILE="$2"
            # Clear the output file if it exists
            > "$OUTPUT_FILE"
          fi

          # Function to process files
          process_files() {
            local dir="$1"
            local rel_path="$2"
            
            # Get all files in the current directory
            # Exclude hidden files unless INCLUDE_HIDDEN is set
            if [ "$INCLUDE_HIDDEN" -eq 1 ]; then
              find_files_cmd="find \"$dir\" -maxdepth 1 -type f"
            else
              find_files_cmd="find \"$dir\" -maxdepth 1 -type f -not -path \"*/\\.*\""
            fi
            
            eval "$find_files_cmd" | sort | while read -r file; do
              filename=$(basename "$file")
              
              # Create the relative path for the header
              if [ -z "$rel_path" ]; then
                file_rel_path="$filename"
              else
                file_rel_path="$rel_path/$filename"
              fi
              
              # Create a nice header for the file
              header="\n\n========================================\n"
              header+="FILE: $file_rel_path\n"
              
              # Check if file is binary using the 'file' command
              if file --mime "$file" | grep -q "charset=binary"; then
                header+="[BINARY FILE - CONTENT EXCLUDED]\n"
                header+="========================================\n\n"
                
                # Output just the header without the binary content
                if [ -n "$OUTPUT_FILE" ]; then
                  echo -e "$header" >> "$OUTPUT_FILE"
                else
                  echo -e "$header"
                fi
              else
                header+="========================================\n\n"
                
                # Output the header and file content for text files
                if [ -n "$OUTPUT_FILE" ]; then
                  echo -e "$header" >> "$OUTPUT_FILE"
                  cat "$file" >> "$OUTPUT_FILE"
                else
                  echo -e "$header"
                  cat "$file"
                fi
              fi
            done
            
            # Process subdirectories recursively
            # Exclude hidden directories unless INCLUDE_HIDDEN is set
            if [ "$INCLUDE_HIDDEN" -eq 1 ]; then
              find_dirs_cmd="find \"$dir\" -maxdepth 1 -type d -not -path \"$dir\""
            else
              find_dirs_cmd="find \"$dir\" -maxdepth 1 -type d -not -path \"$dir\" -not -path \"*/\\.*\""
            fi
            
            eval "$find_dirs_cmd" | sort | while read -r subdir; do
              subdir_name=$(basename "$subdir")
              
              # Create new relative path for subdirectory
              if [ -z "$rel_path" ]; then
                new_rel_path="$subdir_name"
              else
                new_rel_path="$rel_path/$subdir_name"
              fi
              
              # Process the subdirectory
              process_files "$subdir" "$new_rel_path"
            done
          }

          # Check if the directory exists
          if [ ! -d "$TARGET_DIR" ]; then
            echo "Error: Directory '$TARGET_DIR' does not exist"
            exit 1
          fi

          # Start processing from the root directory
          if [ -n "$OUTPUT_FILE" ]; then
            echo "Combining files from '$TARGET_DIR' into '$OUTPUT_FILE'..."
            process_files "$TARGET_DIR" ""
            echo "Done! Output written to '$OUTPUT_FILE'"
          else
            process_files "$TARGET_DIR" ""
          fi
        '';
        extraOptions = { };
      };

      home.packages = with pkgs;
        [
          file # Add dependency on the 'file' command
        ];
    })

    (mkIf cfg.outputGenerator.enable {
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
          MILESTONE="v0.4.0"
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
    })
  ]);
}
