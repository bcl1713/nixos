# user/packages/utilities/screenshot.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userPackages.utilities.screenshot;

  # Create script for screenshots without clipboard functionality
  screenshotScript = pkgs.writeShellScriptBin "take-screenshot" ''
            #!/usr/bin/env bash

            # Configuration
            SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
            TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
            SCREENSHOT_FILE="$SCREENSHOTS_DIR/screenshot_$TIMESTAMP.png"

            # Create screenshots directory if it doesn't exist
            mkdir -p "$SCREENSHOTS_DIR"

            # Function to take and save screenshot
        capture_screenshot() {
          local mode=$1
          local file="$SCREENSHOT_FILE"
          local clipboard=$3  # New parameter for clipboard support
          
          # Take screenshot based on mode
          case "$mode" in
            "area")
              ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$file"
              ;;
            "window")
              # Get active window geometry from Hyprland
              WINDOW_GEOMETRY=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | 
                              ${pkgs.jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
              ${pkgs.grim}/bin/grim -g "$WINDOW_GEOMETRY" "$file"
              ;;
            "screen")
              ${pkgs.grim}/bin/grim "$file"
              ;;
            *)
              ${pkgs.libnotify}/bin/notify-send -t 3000 -i dialog-error "Screenshot" "Invalid mode: $mode"
              exit 1
              ;;
          esac
          
          # Check if screenshot was successful
          if [ ! -f "$file" ]; then
            ${pkgs.libnotify}/bin/notify-send -t 3000 -i dialog-error "Screenshot" "Failed to take screenshot"
            exit 1
          fi
          
          # Copy to clipboard if requested
          if [ "$clipboard" = "clipboard" ]; then
            ${pkgs.wl-clipboard}/bin/wl-copy --type image/png < "$file"
            ${pkgs.libnotify}/bin/notify-send -t 3000 -i camera "Screenshot" "Copied to clipboard and saved to $file"
          fi
          
          # Open with swappy for annotation if requested
          if [ "$2" == "annotate" ]; then
            ${pkgs.swappy}/bin/swappy -f "$file" -o "$file"
            
            # Copy to clipboard after annotation if requested
            if [ "$clipboard" = "clipboard" ]; then
              ${pkgs.wl-clipboard}/bin/wl-copy --type image/png < "$file"
              ${pkgs.libnotify}/bin/notify-send -t 3000 -i camera "Screenshot" "Annotated screenshot copied to clipboard and saved to $file"
            else
              ${pkgs.libnotify}/bin/notify-send -t 3000 -i camera "Screenshot" "Annotated screenshot saved to $file"
            fi
          elif [ "$clipboard" != "clipboard" ]; then
            ${pkgs.libnotify}/bin/notify-send -t 3000 -i camera "Screenshot" "Screenshot saved to $file"
          fi
        }

            # Parse arguments
            MODE="screen"  # Default to full screen
            ANNOTATE=""    # Default is not to annotate
            CLIPBOARD=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
        "area"|"window"|"screen")
          MODE="$1"
          shift
          ;;
        "annotate")
          ANNOTATE="annotate"
          shift
          ;;
        "clipboard")
          CLIPBOARD="clipboard"
          shift
          ;;
        *)
          ${pkgs.libnotify}/bin/notify-send -t 3000 -i dialog-error "Screenshot" "Unknown argument: $1"
          exit 1
          ;;
      esac
    done
            # Capture and save screenshot
            capture_screenshot "$MODE" "$ANNOTATE"
  '';
in {
  options.userPackages.utilities.screenshot = {
    enable = mkEnableOption "Enable screenshot tools with annotation";

    # Base keybindings (save to file)
    screenKeybinding = mkOption {
      type = types.str;
      default = ", Print";
      description = "Capture the entire screen and save to file";
    };

    areaKeybinding = mkOption {
      type = types.str;
      default = "ALT, Print";
      description = "Capture a selected area and save to file";
    };

    windowKeybinding = mkOption {
      type = types.str;
      default = "CTRL, Print";
      description = "Capture the active window and save to file";
    };

    # Annotation variants
    screenAnnotateKeybinding = mkOption {
      type = types.str;
      default = "SHIFT, Print";
      description = "Capture the entire screen and open for annotation";
    };

    areaAnnotateKeybinding = mkOption {
      type = types.str;
      default = "ALT SHIFT, Print";
      description = "Capture a selected area and open for annotation";
    };

    windowAnnotateKeybinding = mkOption {
      type = types.str;
      default = "CTRL SHIFT, Print";
      description = "Capture the active window and open for annotation";
    };
  };

  config = mkIf cfg.enable {
    # Install required packages
    home.packages = with pkgs; [
      grim # Screenshot utility
      slurp # Area selection
      swappy # Annotation tool
      jq # JSON processing
      libnotify # Notifications
      screenshotScript
    ];

    # Add Hyprland keybindings if Hyprland is enabled
    wayland.windowManager.hyprland.extraConfig =
      mkIf config.wayland.windowManager.hyprland.enable ''
        # Base screenshot bindings (save to file)
        bind = ${cfg.screenKeybinding}, exec, take-screenshot screen
        bind = ${cfg.areaKeybinding}, exec, take-screenshot area
        bind = ${cfg.windowKeybinding}, exec, take-screenshot window

        # Screenshot with annotation
        bind = ${cfg.screenAnnotateKeybinding}, exec, take-screenshot screen annotate
        bind = ${cfg.areaAnnotateKeybinding}, exec, take-screenshot area annotate
        bind = ${cfg.windowAnnotateKeybinding}, exec, take-screenshot window annotate
      '';

    # Create Screenshots directory
    home.activation.createScreenshotsDir =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG $HOME/Pictures/Screenshots
      '';
  };
}
