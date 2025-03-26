# user/packages/utilities/screen-recording.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userPackages.utilities.screenRecording;

  # Create script to toggle recording with notifications
  toggleRecordingScript = pkgs.writeShellScriptBin "toggle-screen-recording" ''
    #!/usr/bin/env bash

    # Configuration
    RECORDINGS_DIR="$HOME/Videos/Recordings"
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    RECORDING_FILE="$RECORDINGS_DIR/recording_$TIMESTAMP.mp4"
    PIDFILE="/tmp/screen-recording.pid"

    # Create recordings directory if it doesn't exist
    mkdir -p "$RECORDINGS_DIR"

    # Check if recording is already in progress
    if [ -f "$PIDFILE" ]; then
        # Recording is in progress, stop it
        PID=$(cat "$PIDFILE")
        if ps -p "$PID" > /dev/null; then
            # Gracefully stop wf-recorder
            kill -SIGINT "$PID"
            # Wait for it to finish
            wait "$PID" 2>/dev/null
            # Remove PID file
            rm "$PIDFILE"
            # Notify user
            ${pkgs.libnotify}/bin/notify-send -t 3000 -i video-display "Screen Recording" "Recording saved to $RECORDING_FILE"
        else
            # Process doesn't exist, clean up the PID file
            rm "$PIDFILE"
            ${pkgs.libnotify}/bin/notify-send -t 3000 -i dialog-error "Screen Recording" "Previous recording process not found"
        fi
    else
        # Start new recording
        ${pkgs.libnotify}/bin/notify-send -t 2000 -i video-display "Screen Recording" "Starting recording..."
        
        # Check if a specific area was requested
        if [ "$1" = "area" ]; then
            # Select area using slurp
            GEOMETRY=$(${pkgs.slurp}/bin/slurp)
            if [ -z "$GEOMETRY" ]; then
                ${pkgs.libnotify}/bin/notify-send -t 2000 -i dialog-error "Screen Recording" "Selection cancelled"
                exit 1
            fi
            # Start recording with selected geometry
            ${pkgs.wf-recorder}/bin/wf-recorder -g "$GEOMETRY" -f "$RECORDING_FILE" &
        elif [ "$1" = "window" ]; then
            # Get active window geometry from Hyprland
            WINDOW_ID=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.address')
            GEOMETRY=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r ".[] | select(.address == \"$WINDOW_ID\") | \"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"")
            
            if [ -z "$GEOMETRY" ] || [ "$GEOMETRY" = "null" ]; then
                ${pkgs.libnotify}/bin/notify-send -t 2000 -i dialog-error "Screen Recording" "No active window found"
                exit 1
            fi
            
            # Start recording active window
            ${pkgs.wf-recorder}/bin/wf-recorder -g "$GEOMETRY" -f "$RECORDING_FILE" &
        else
            # Start recording the entire screen
            ${pkgs.wf-recorder}/bin/wf-recorder -f "$RECORDING_FILE" &
        fi
        
        # Save PID to file
        echo $! > "$PIDFILE"
        
        # Update notification
        ${pkgs.libnotify}/bin/notify-send -t 3000 -i video-display "Screen Recording" "Recording in progress... Press ${cfg.keybinding} to stop"
    fi
  '';
in {
  options.userPackages.utilities.screenRecording = {
    enable = mkEnableOption "Enable screen recording functionality";

    keybinding = mkOption {
      type = types.str;
      default = "SUPER SHIFT, R";
      description = "Hyprland keybinding to toggle screen recording";
    };

    areaKeybinding = mkOption {
      type = types.str;
      default = "SUPER SHIFT ALT, R";
      description = "Hyprland keybinding to record a selected area";
    };

    windowKeybinding = mkOption {
      type = types.str;
      default = "SUPER CTRL, R";
      description = "Hyprland keybinding to record the active window";
    };

    audioSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable audio capture in recordings";
    };
  };

  config = mkIf cfg.enable {
    # Install required packages
    home.packages = with pkgs; [
      wf-recorder
      slurp # Area selection
      jq # JSON parsing for window selection
      libnotify
      toggleRecordingScript
    ];

    # Add Hyprland keybindings if Hyprland is enabled
    wayland.windowManager.hyprland.extraConfig =
      mkIf config.wayland.windowManager.hyprland.enable ''
        # Screen recording bindings
        bind = ${cfg.keybinding}, exec, toggle-screen-recording
        bind = ${cfg.areaKeybinding}, exec, toggle-screen-recording area
        bind = ${cfg.windowKeybinding}, exec, toggle-screen-recording window
      '';

    # Create Videos/Recordings directory
    home.activation.createRecordingsDir =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG $HOME/Videos/Recordings
      '';
  };
}
