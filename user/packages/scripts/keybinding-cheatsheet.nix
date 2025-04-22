# user/packages/scripts/keybinding-cheatsheet.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userPackages.scripts.keybindingCheatsheet;

  # Create the script to extract and display keybindings
  keybindingScript = pkgs.writeShellScriptBin "keybinding-cheatsheet" ''
    #!/usr/bin/env bash

    # Keybinding Cheatsheet Generator
    # This script extracts and displays keybindings from Hyprland and application configs

    set -e

    # Configuration
    CONFIG_DIR="$HOME/.config"
    TEMP_FILE="/tmp/keybindings-cheatsheet.md"
    OUTPUT_FORMAT="''${1:-terminal}"  # Default to terminal output, can be "terminal", "wofi", or "markdown"

    # Function to extract Hyprland keybindings
    extract_hyprland_bindings() {
      echo "## Hyprland Window Manager"
      echo ""
      echo "| Keybinding | Action |"
      echo "| --- | --- |"
      
      # Parse Hyprland config for keybindings - this is a simplified approach
      # that works with the current keybinding format in hyprland.conf
      if [ -f "$CONFIG_DIR/hypr/hyprland.conf" ]; then
        grep -E "^bind\s?=" "$CONFIG_DIR/hypr/hyprland.conf" 2>/dev/null | while read -r binding; do
          # Clean up the binding string
          key=$(echo "$binding" | sed -E 's/bind\s?=\s?//g' | awk -F, '{print $1 " + " $2}' | sed 's/\$mainMod/Super/g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
          action=$(echo "$binding" | awk -F, '{$1=""; $2=""; print}' | sed 's/^,[[:space:]]*,[[:space:]]*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
          
          # Skip empty lines or malformed bindings
          if [ -n "$key" ] && [ -n "$action" ]; then
            echo "| $key | $action |"
          fi
        done
      else
        # For Hyprland config in a different location or format, we'll add some common defaults
        echo "| Super + Return | Open terminal |"
        echo "| Super + Q | Close active window |"
        echo "| Super + Space | Open application launcher |"
        echo "| Super + F | Toggle floating mode |"
        echo "| Super + 1-9 | Switch to workspace |"
        echo "| Super + Shift + 1-9 | Move window to workspace |"
      fi
      
      echo ""
    }

    # Function to extract Waybar click actions
    extract_waybar_bindings() {
      echo "## Waybar (Status Bar)"
      echo ""
      echo "| Element | Click | Action |"
      echo "| --- | --- | --- |"
      
      # These are hard-coded based on common configurations since
      # parsing JSON would be more complex and require jq
      echo "| Workspaces | Left-click | Switch to workspace |"
      echo "| Volume | Left-click | Toggle mute |"
      echo "| Volume | Right-click | Open volume control |"
      echo "| Network | Left-click | Toggle network menu |"
      echo "| Battery | Left-click | Show battery status |"
      echo "| Clock | Left-click | Show calendar |"
      
      # Use if statements with explicit test commands instead of parameter expansion
      if [ "${toString cfg.includeBluetooth}" = "true" ]; then
        echo "| Bluetooth | Left-click | Toggle Bluetooth on/off |"
        echo "| Bluetooth | Right-click | Open Bluetooth manager |"
      fi
      
      if [ "${toString cfg.includeTailscale}" = "true" ]; then
        echo "| Tailscale | Left-click | Connect to Tailscale |"
        echo "| Tailscale | Right-click | Disconnect from Tailscale |"
      fi
      
      if [ "${toString cfg.includePowerProfile}" = "true" ]; then
        echo "| Power Profile | Left-click | Switch power profile |"
      fi
      
      echo ""
    }

    # Function to extract application keybindings
    extract_application_bindings() {
      echo "## Common Applications"
      echo ""
      
      # Firefox
      echo "### Firefox"
      echo "| Keybinding | Action |"
      echo "| --- | --- |"
      echo "| Ctrl + T | New tab |"
      echo "| Ctrl + W | Close tab |"
      echo "| Ctrl + L | Focus address bar |"
      echo "| Ctrl + F | Find in page |"
      echo "| Ctrl + H | History |"
      echo "| Ctrl + Shift + P | Private browsing |"
      echo ""
      
      # Neovim (if configured)
      if command -v nvim &>/dev/null; then
        echo "### Neovim"
        echo "| Keybinding | Action |"
        echo "| --- | --- |"
        echo "| Space | Leader key |"
        echo "| Space + w | Save file |"
        echo "| Space + q | Quit |"
        echo "| Space + ff | Find files |"
        echo "| Space + fg | Find text |"
        echo "| gd | Go to definition |"
        echo "| K | Show documentation |"
        echo "| Space + lr | Rename symbol |"
        echo ""
      fi
      
      # Other applications can be added here
    }

    # Function to extract custom script keybindings
    extract_custom_bindings() {
      echo "## Utility Scripts"
      echo ""
      echo "| Keybinding | Action |"
      echo "| --- | --- |"
      
      # Screenshot tools
      echo "| Print | Capture full screen |"
      echo "| Alt + Print | Capture area |"
      echo "| Ctrl + Print | Capture window |"
      echo "| Shift + Print | Full screen with annotation |"
      
      # Use if statements with explicit test commands instead of parameter expansion
      if [ "${toString cfg.includeScreenRecording}" = "true" ]; then
        echo "| Super + Shift + R | Toggle screen recording |"
        echo "| Super + Shift + Alt + R | Record selected area |"
        echo "| Super + Ctrl + R | Record active window |"
      fi
      
      echo "| Super + X | Lock screen |"
      
      if [ "${toString cfg.includeClipboard}" = "true" ]; then
        echo "| Super + Shift + V | Open clipboard history |"
      fi
      
      # Add the keybinding cheatsheet itself
      echo "| ${cfg.keybinding} | Show this cheatsheet |"
      echo ""
    }

    # Function to generate the cheatsheet
    generate_cheatsheet() {
      echo "# Keybinding Cheatsheet"
      echo ""
      echo "This cheatsheet shows common keybindings for your system."
      echo ""
      
      extract_hyprland_bindings
      extract_waybar_bindings
      extract_application_bindings
      extract_custom_bindings
      
      echo "---"
      echo "Generated on $(date '+%Y-%m-%d %H:%M:%S')"
    }

    # Generate the cheatsheet content
    generate_cheatsheet > "$TEMP_FILE"

    # Display based on selected format
    case "$OUTPUT_FORMAT" in
      "terminal")
        # Use terminal pager to display the cheatsheet
        if command -v ${pkgs.glow}/bin/glow &>/dev/null; then
          ${pkgs.glow}/bin/glow "$TEMP_FILE"
        else
          # Fallback to cat if glow is not available
          cat "$TEMP_FILE"
        fi
        ;;
      "wofi")
        # Convert markdown to text and display in wofi as a menu
        if command -v ${pkgs.wofi}/bin/wofi &>/dev/null; then
          cat "$TEMP_FILE" | ${pkgs.wofi}/bin/wofi --show dmenu --width 1000 --height 800 --prompt "Keybindings"
        else
          echo "wofi is not installed. Displaying in terminal instead."
          cat "$TEMP_FILE"
        fi
        ;;
      "rofi")
        # Convert markdown to text and display in rofi as a menu
        if command -v ${pkgs.rofi-wayland}/bin/rofi &>/dev/null; then
          cat "$TEMP_FILE" | ${pkgs.rofi-wayland}/bin/rofi -dmenu -markup-rows -width 100 -i
        else
          echo "rofi is not installed. Displaying in terminal instead."
          cat "$TEMP_FILE"
        fi
        ;;
      "markdown")
        # Just output the markdown file path
        echo "Keybinding cheatsheet saved to: $TEMP_FILE"
        cp "$TEMP_FILE" "$HOME/keybindings.md"
        echo "Also copied to: $HOME/keybindings.md"
        ;;
      *)
        echo "Unknown output format: $OUTPUT_FORMAT"
        echo "Supported formats: terminal, wofi, rofi, markdown"
        exit 1
        ;;
    esac
  '';
in {
  options.userPackages.scripts.keybindingCheatsheet = {
    keybinding = mkOption {
      type = types.str;
      default = "SUPER, F1";
      description = "Keybinding to show the keybinding cheatsheet";
    };

    defaultFormat = mkOption {
      type = types.enum [ "terminal" "wofi" "rofi" "markdown" ];
      default = "wofi";
      description = "Default format for displaying the cheatsheet";
    };

    includeScreenRecording = mkOption {
      type = types.bool;
      default = config.userPackages.utilities.screenRecording.enable or false;
      description = "Whether to include screen recording keybindings";
    };

    includeClipboard = mkOption {
      type = types.bool;
      default = config.userPackages.utilities.clipboard.enable or false;
      description = "Whether to include clipboard keybindings";
    };

    includeBluetooth = mkOption {
      type = types.bool;
      default = (config.userPackages.utilities.bluetooth.enable or false)
        && (config.userPackages.utilities.bluetooth.waybar.enable or false);
      description = "Whether to include Bluetooth keybindings";
    };

    includeTailscale = mkOption {
      type = types.bool;
      default = (config.userPackages.utilities.tailscale.enable or false)
        && (config.userPackages.utilities.tailscale.waybar.enable or false);
      description = "Whether to include Tailscale keybindings";
    };

    includePowerProfile = mkOption {
      type = types.bool;
      default = (config.userPackages.utilities.powerManagement.enable or false)
        && (config.userPackages.utilities.powerManagement.indicator.enable or false);
      description = "Whether to include power profile keybindings";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ keybindingScript ];

    # Add keybinding to Hyprland if enabled
    wayland.windowManager.hyprland.extraConfig =
      mkIf config.wayland.windowManager.hyprland.enable ''
        # Keybinding cheatsheet
        bind = ${cfg.keybinding}, exec, keybinding-cheatsheet ${cfg.defaultFormat}
      '';
  };
}
