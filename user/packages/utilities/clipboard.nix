# user/packages/utilities/clipboard.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities.clipboard;
in {
  options.userPackages.utilities.clipboard = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable clipboard management";
    };

    historySize = mkOption {
      type = types.int;
      default = 15;
      description = "Number of clipboard items to store in history";
    };

    startInBackground = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to start the clipboard manager in background";
    };

    mimeTypeConfig = mkOption {
      type = types.bool;
      default = true;
      description =
        "Whether to enable MIME type handling for clipboard content";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      clipman
      file

      # Add Wayland to X11 clipboard bridge, but not xclip which causes a conflict
      wl-clipboard-x11

      # Add helper script for image copying
      (writeShellScriptBin "wl-image-copy" ''
        #!/usr/bin/env bash
        # Script to help with copying images to clipboard with proper MIME types

        if [ $# -lt 1 ]; then
          echo "Usage: wl-image-copy <image-file>"
          exit 1
        fi

        IMAGE_FILE="$1"
        MIME_TYPE=$(${file}/bin/file --mime-type -b "$IMAGE_FILE")

        if [[ $MIME_TYPE == image/* ]]; then
          # Copy the image with correct MIME type
          ${wl-clipboard}/bin/wl-copy --type "$MIME_TYPE" < "$IMAGE_FILE"
          echo "Copied $IMAGE_FILE ($MIME_TYPE) to clipboard"
        else
          echo "Error: $IMAGE_FILE is not an image file"
          exit 1
        fi
      '')

      # Add screenshot to clipboard utility
      (mkIf config.userPackages.utilities.screenshot.enable
        (writeShellScriptBin "screenshot-to-clipboard" ''
          #!/usr/bin/env bash
          # Take a screenshot and copy it to clipboard with proper MIME types

          TEMP_DIR="$(mktemp -d)"
          SCREENSHOT_FILE="$TEMP_DIR/screenshot.png"

          case "$1" in
            "area")
              ${grim}/bin/grim -g "$(${slurp}/bin/slurp)" "$SCREENSHOT_FILE"
              ;;
            "window")
              # Get active window geometry from Hyprland
              WINDOW_GEOMETRY=$(${hyprland}/bin/hyprctl activewindow -j | 
                             ${jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
              ${grim}/bin/grim -g "$WINDOW_GEOMETRY" "$SCREENSHOT_FILE"
              ;;
            *)
              ${grim}/bin/grim "$SCREENSHOT_FILE"
              ;;
          esac

          # Copy to clipboard with proper MIME type
          if [ -f "$SCREENSHOT_FILE" ]; then
            ${wl-clipboard}/bin/wl-copy --type image/png < "$SCREENSHOT_FILE"
            ${libnotify}/bin/notify-send -t 3000 -i camera "Screenshot" "Copied to clipboard"
            # Clean up
            rm -rf "$TEMP_DIR"
          else
            ${libnotify}/bin/notify-send -t 3000 -i dialog-error "Screenshot" "Failed to take screenshot"
          fi
        ''))
    ];

    # Create the systemd user service for clipman
    systemd.user.services.clipman = {
      Unit = {
        Description = "Clipboard manager service";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        # Updated command to properly handle content types
        ExecStart = if cfg.mimeTypeConfig then
          "${pkgs.clipman}/bin/clipman store --no-persist --max-items=${
            toString cfg.historySize
          } --histpath='${config.xdg.cacheHome}/clipman.json'"
        else
          "${pkgs.clipman}/bin/clipman store --no-persist";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = mkIf cfg.mimeTypeConfig [
          "CLIPMAN_PRIMARY=0"
          "CLIPMAN_PRESERVE_TYPES=1"
        ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    # Add X11<->Wayland clipboard bridge service
    systemd.user.services.wl-clipboard-x11 = {
      Unit = {
        Description = "Wayland to X11 clipboard bridge";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clipboard-x11}/bin/wl-clipboard-x11";
        Restart = "on-failure";
        RestartSec = 5;
        # Start another instance for primary selection as well
        ExecStartPost =
          "${pkgs.wl-clipboard-x11}/bin/wl-clipboard-x11 --primary";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    # Configure keybinding in Hyprland if enabled
    wayland.windowManager.hyprland.settings =
      mkIf config.wayland.windowManager.hyprland.enable {
        bind = [
          # Add clipboard history keybinding - using SUPER+SHIFT+V 
          "SUPER SHIFT, V, exec, ${pkgs.clipman}/bin/clipman pick --tool=wofi"
        ];
      };

    # Ensure wl-copy is used for capturing clipboard
    home.sessionVariables = {
      CM_SELECTIONS = "clipboard";
      CM_MAX_CLIPS = toString cfg.historySize;
      # Add MIME type preservation for clipboard
      CM_PRESERVE_TYPES = mkIf cfg.mimeTypeConfig "1";
    };

    # Make sure wl-clipboard captures clipboard content with MIME types
    systemd.user.services.wl-clipboard-watch = {
      Unit = {
        Description = "Watch clipboard for changes";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        # Updated command to include MIME type preservation
        ExecStart = if cfg.mimeTypeConfig then
          "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.clipman}/bin/clipman store --max-items=${
            toString cfg.historySize
          } --histpath='${config.xdg.cacheHome}/clipman.json'"
        else
          "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.clipman}/bin/clipman store --max-items=${
            toString cfg.historySize
          }";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = mkIf cfg.mimeTypeConfig [
          "CLIPMAN_PRIMARY=0"
          "CLIPMAN_PRESERVE_TYPES=1"
        ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    # Update Hyprland keybindings for screenshot-to-clipboard if screenshot is enabled
    wayland.windowManager.hyprland.extraConfig = mkIf (cfg.mimeTypeConfig
      && config.userPackages.utilities.screenshot.enable
      && config.wayland.windowManager.hyprland.enable) ''
        # Clipboard screenshot bindings
        bind = SUPER, Print, exec, screenshot-to-clipboard
        bind = SUPER ALT, Print, exec, screenshot-to-clipboard area
        bind = SUPER CTRL, Print, exec, screenshot-to-clipboard window
      '';
  };
}
