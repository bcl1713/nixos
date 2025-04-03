# user/packages/utilities/disk-usage.nix
#
# This module provides tools for analyzing and managing disk usage with
# visualization capabilities and cleanup utilities.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userPackages.utilities.diskUsage;

  # Script to simplify disk usage actions
  diskManagerScript = pkgs.writeShellScriptBin "disk-manager" ''
    #!/usr/bin/env bash

    # A simple wrapper around disk usage tools with common operations

    set -e

    # Function to show help message
    show_help() {
      echo "Disk Manager - Simplify disk usage analysis and cleanup"
      echo ""
      echo "Usage: disk-manager [COMMAND]"
      echo ""
      echo "Commands:"
      echo "  analyze         Open ncdu for interactive disk usage analysis"
      echo "  visualize       Open baobab (disk usage analyzer) for graphical visualization"
      echo "  duplicates      Find duplicate files in the current directory"
      echo "  large-files     Find the largest files in your home directory"
      echo "  cleanup-temp    Clean temporary files from /tmp and ~/.cache"
      echo "  help            Show this help message"
      echo ""
    }

    # Check if a command was provided
    if [ $# -eq 0 ]; then
      show_help
      exit 1
    fi

    # Process commands
    case "$1" in
      "analyze")
        echo "Starting ncdu for interactive disk usage analysis..."
        # Start in home directory by default
        ncdu "$HOME"
        ;;
        
      "visualize")
        echo "Starting baobab for graphical disk usage analysis..."
        baobab &
        ;;
        
      "duplicates")
        echo "Finding duplicate files in the current directory..."
        echo "This may take some time depending on the number of files."
        SEARCH_DIR="."
        if [ $# -ge 2 ]; then
          SEARCH_DIR="$2"
        fi
        fdupes -r "$SEARCH_DIR"
        ;;
        
      "large-files")
        echo "Finding the largest files in your home directory..."
        MAX_FILES=20
        if [ $# -ge 2 ]; then
          MAX_FILES="$2"
        fi
        # Using find to locate files and pipe through sort to show largest first
        # Using PATH-based commands instead of hardcoded paths
        find "$HOME" -type f -print0 | xargs -0 du -h | sort -rh | head -n "$MAX_FILES"
        ;;
        
      "cleanup-temp")
        echo "Cleaning temporary files..."
        echo "Removing files from ~/.cache older than 30 days..."
        find ~/.cache -type f -atime +30 -delete 2>/dev/null || true
        
        if [ $# -ge 2 ] && [ "$2" = "--aggressive" ]; then
          echo "Aggressive cleanup requested."
          echo "Clearing all user cache files..."
          rm -rf ~/.cache/* 2>/dev/null || true
        fi
        
        echo "Done cleaning temporary files."
        ;;
        
      "help"|*)
        show_help
        ;;
    esac
  '';
in {
  options.userPackages.utilities.diskUsage = {
    enable = mkEnableOption "Enable disk usage analysis tools";

    interactiveTools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to enable terminal-based interactive disk usage tools";
      };
    };

    graphicalTools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to enable graphical disk usage visualization tools";
      };
    };

    duplicateFinder = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable duplicate file finder";
      };
    };

    cleanupTools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable disk cleanup utilities";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Terminal-based interactive disk usage tools
    (mkIf cfg.interactiveTools.enable {
      home.packages = with pkgs; [
        ncdu # NCurses Disk Usage - interactive terminal disk usage analyzer
        du-dust # A more intuitive version of du written in Rust
        dua # Another disk usage analyzer with an interactive interface
      ];
    })

    # Graphical disk usage visualization tools
    (mkIf cfg.graphicalTools.enable {
      home.packages = with pkgs; [
        baobab # Disk Usage Analyzer with graphical interface
        kdePackages.filelight # KDE disk usage visualizer (alternative)
      ];
    })

    # Duplicate file finder
    (mkIf cfg.duplicateFinder.enable {
      home.packages = with pkgs; [
        fdupes # Identifies duplicate files
        rmlint # More comprehensive tool to find and remove duplicates and other lint
      ];
    })

    # Cleanup tools
    (mkIf cfg.cleanupTools.enable {
      home.packages = with pkgs; [
        bleachbit # System cleaner to free disk space and maintain privacy
        findutils # Ensure find is available for scripts
        coreutils # Ensure du, sort, head, etc. are available
        diskManagerScript # Custom disk management script
      ];
    })
  ]);
}
