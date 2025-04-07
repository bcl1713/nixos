# user/packages/utilities/power-management.nix
#
# This module provides enhanced power management with customizable profiles
# for optimizing battery life and performance based on usage scenarios.
# It leverages power-profiles-daemon and other user-accessible tools.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userPackages.utilities.powerManagement;

  # Power profile descriptions for notifications and documentation
  profileDescriptions = {
    balanced = "Balanced power and performance for everyday use";
    performance = "Maximum performance for demanding workloads";
    powersave = "Maximum battery life for extended usage";
  };

  # Script to switch between power profiles
  switchProfileScript = pkgs.writeShellScriptBin "power-profile" ''
    #!/usr/bin/env bash
    set -e

    # Configuration
    CONFIG_DIR="$HOME/.config/power-profiles"
    CURRENT_PROFILE_FILE="$CONFIG_DIR/current_profile"
    NOTIFICATION_ID_FILE="$CONFIG_DIR/notification_id"

    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"

    # Function to display notification
    show_notification() {
      local profile="$1"
      local description="$2"
      local icon="preferences-system-power"
      
      case "$profile" in
        "balanced")
          icon="battery-good-symbolic"
          ;;
        "performance")
          icon="battery-full-charging-symbolic"
          ;;
        "powersave")
          icon="battery-low-symbolic"
          ;;
      esac
      
      # Check if we have a previous notification ID to replace
      local extra_args=""
      if [ -f "$NOTIFICATION_ID_FILE" ]; then
        local prev_id=$(cat "$NOTIFICATION_ID_FILE")
        if [ -n "$prev_id" ]; then
          extra_args="-r $prev_id"
        fi
      fi
      
      # Send notification and store the ID
      local id=$(${pkgs.libnotify}/bin/notify-send $extra_args -p -t 5000 -i "$icon" "Power Profile: $profile" "$description")
      echo "$id" > "$NOTIFICATION_ID_FILE"
    }

    # Function to check if power-profiles-daemon is available
    is_ppd_available() {
      if command -v ${pkgs.power-profiles-daemon}/bin/powerprofilesctl &> /dev/null; then
        # Check if it's running and can be contacted
        if ${pkgs.power-profiles-daemon}/bin/powerprofilesctl get &> /dev/null; then
          return 0
        fi
      fi
      return 1
    }

    # Function to get current profile
    get_current_profile() {
      # First try reading from our saved state
      if [ -f "$CURRENT_PROFILE_FILE" ]; then
        cat "$CURRENT_PROFILE_FILE"
        return
      fi
      
      # If power-profiles-daemon is available, use that
      if is_ppd_available; then
        local ppd_profile=$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get)
        echo "$ppd_profile"
        return
      fi
      
      # Default to balanced if we can't determine
      echo "balanced"
    }

    # Set profile function
    set_profile() {
      local profile="$1"
      local description=""
      
      case "$profile" in
        "balanced")
          description="${profileDescriptions.balanced}"
          ;;
        "performance")
          description="${profileDescriptions.performance}"
          ;;
        "powersave")
          description="${profileDescriptions.powersave}"
          ;;
        *)
          echo "Unknown profile: $profile"
          echo "Available profiles: balanced, performance, powersave"
          exit 1
          ;;
      esac
      
      # Try to set profile using power-profiles-daemon if available
      if is_ppd_available; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set "$profile"
      else
        # Fallback to manual settings if power-profiles-daemon is not available
        case "$profile" in
          "balanced")
            # Set screen brightness to moderate level if we have permission
            ${pkgs.brightnessctl}/bin/brightnessctl set 70% -q || true
            ;;
          "performance")
            # Set screen brightness to max
            ${pkgs.brightnessctl}/bin/brightnessctl set 100% -q || true
            ;;
          "powersave")
            # Reduce screen brightness to save power
            ${pkgs.brightnessctl}/bin/brightnessctl set 40% -q || true
            ;;
        esac
      fi
      
      # Save current profile
      echo "$profile" > "$CURRENT_PROFILE_FILE"
      
      # Show notification
      show_notification "$profile" "$description"
      # Signal waybar to update immediately
      pkill -RTMIN+8 waybar 2>/dev/null || true
    }

    # Switch profile function - cycle through profiles
    switch_profile() {
      local current=$(get_current_profile)
      
      case "$current" in
        "balanced")
          set_profile "performance"
          ;;
        "performance")
          set_profile "powersave"
          ;;
        "powersave"|*)
          set_profile "balanced"
          ;;
      esac
    }

    # Check command-line arguments
    if [ $# -eq 0 ]; then
      # No arguments, show current profile
      current=$(get_current_profile)
      
      case "$current" in
        "balanced")
          show_notification "balanced" "${profileDescriptions.balanced}"
          ;;
        "performance")
          show_notification "performance" "${profileDescriptions.performance}"
          ;;
        "powersave")
          show_notification "powersave" "${profileDescriptions.powersave}"
          ;;
        *)
          show_notification "$current" "Unknown profile: $current"
          ;;
      esac
    elif [ $# -eq 1 ]; then
      # One argument, set specific profile or switch
      if [ "$1" = "switch" ]; then
        switch_profile
      else
        set_profile "$1"
      fi
    else
      echo "Usage: power-profile [profile|switch]"
      echo "Available profiles: balanced, performance, powersave"
      echo "Use 'switch' to cycle between profiles"
      exit 1
    fi
  '';

  # Script to monitor power usage
  powerMonitorScript = pkgs.writeShellScriptBin "power-monitor" ''
    #!/usr/bin/env bash

    # Function to get battery status
    get_battery_status() {
      if command -v ${pkgs.acpi}/bin/acpi &> /dev/null; then
        ${pkgs.acpi}/bin/acpi -b
      elif [ -d /sys/class/power_supply/BAT0 ]; then
        CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "Unknown")
        STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
        echo "Battery $STATUS, $CAPACITY%"
      else
        echo "No battery found"
      fi
    }

    # Function to get current power profile
    get_power_profile() {
      CONFIG_DIR="$HOME/.config/power-profiles"
      CURRENT_PROFILE_FILE="$CONFIG_DIR/current_profile"
      
      if [ -f "$CURRENT_PROFILE_FILE" ]; then
        cat "$CURRENT_PROFILE_FILE"
      elif command -v ${pkgs.power-profiles-daemon}/bin/powerprofilesctl &> /dev/null; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl get 2>/dev/null || echo "unknown"
      else
        echo "unknown"
      fi
    }

    # Function to get CPU information
    get_cpu_info() {
      echo "CPU Load: $(${pkgs.coreutils}/bin/cat /proc/loadavg | cut -d' ' -f1-3)"
      
      # Try to get CPU frequency if available
      if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
        FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
        if [ -n "$FREQ" ]; then
          # Convert to MHz
          FREQ_MHZ=$(echo "$FREQ / 1000" | bc)
          echo "CPU Frequency: $FREQ_MHZ MHz"
        fi
      fi
      
      # Try to get CPU temperature if available
      if command -v ${pkgs.lm_sensors}/bin/sensors &> /dev/null; then
        TEMP=$(${pkgs.lm_sensors}/bin/sensors | grep -i 'core 0' | awk '{print $3}')
        if [ -n "$TEMP" ]; then
          echo "CPU Temperature: $TEMP"
        fi
      fi
    }

    # Print system information in a formatted way
    echo "===== Power Status ====="
    echo "Power Profile: $(get_power_profile)"
    echo "----------------------"
    echo "$(get_battery_status)"
    echo "----------------------"
    get_cpu_info
    echo "======================="

    # If running in a terminal, offer to switch profiles
    if [ -t 1 ]; then
      echo ""
      echo "Would you like to switch power profiles? [y/N] "
      read -r answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        power-profile switch
      fi
    fi
  '';

  # Waybar power profile module script
  waybarPowerProfileScript = pkgs.writeShellScriptBin "waybar-power-profile" ''
    #!/usr/bin/env bash

    CONFIG_DIR="$HOME/.config/power-profiles"
    CURRENT_PROFILE_FILE="$CONFIG_DIR/current_profile"

    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"

    # Function to check if power-profiles-daemon is available
    is_ppd_available() {
      if command -v ${pkgs.power-profiles-daemon}/bin/powerprofilesctl &> /dev/null; then
        if ${pkgs.power-profiles-daemon}/bin/powerprofilesctl get &> /dev/null; then
          return 0
        fi
      fi
      return 1
    }

    # Get current profile
    if [ -f "$CURRENT_PROFILE_FILE" ]; then
      PROFILE=$(cat "$CURRENT_PROFILE_FILE")
    elif is_ppd_available; then
      PROFILE=$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get)
    else
      PROFILE="balanced"
      echo "$PROFILE" > "$CURRENT_PROFILE_FILE"
    fi

    # Define tooltip based on profile
    case "$PROFILE" in
      "balanced")
        TOOLTIP="Balanced Power Profile"
        ;;
      "performance")
        TOOLTIP="Performance Power Profile"
        ;;
      "powersave")
        TOOLTIP="Battery Saver Power Profile"
        ;;
      *)
        TOOLTIP="Unknown Power Profile: $PROFILE"
        ;;
    esac

    # Output profile information in JSON format for waybar
    # Simpler output, just providing what we need
    echo '{"text": "'"$PROFILE"'", "tooltip": "'"$TOOLTIP"'", "class": "'"$PROFILE"'"}'
  '';

in {
  options.userPackages.utilities.powerManagement = {
    enable = mkEnableOption "Enable enhanced power management";

    defaultProfile = mkOption {
      type = types.enum [ "balanced" "performance" "powersave" ];
      default = "balanced";
      description = "Default power profile to use";
    };

    keybinding = mkOption {
      type = types.str;
      default = "SUPER, F7";
      description = "Keybinding to cycle between power profiles";
    };

    indicator = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Show power profile indicator in waybar";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install required packages
    home.packages = with pkgs; [
      # Power management tools
      brightnessctl # Adjust screen brightness without root
      acpi # Battery status reporting
      bc # For calculations in the script
      lm_sensors # For CPU temperature readings if available
      power-profiles-daemon # System power profiles (if available)

      # Our custom scripts
      switchProfileScript
      powerMonitorScript
      waybarPowerProfileScript
    ];

    # Add Hyprland keybinding for cycling power profiles if Hyprland is enabled
    wayland.windowManager.hyprland.extraConfig =
      mkIf config.wayland.windowManager.hyprland.enable ''
        # Power profile switching keybinding
        bind = ${cfg.keybinding}, exec, power-profile switch
      '';

    #Integrate with waybar if configured to use programs.waybar module
    programs.waybar =
      mkIf (cfg.indicator.enable && config.programs.waybar.enable) {
        settings.mainBar = {
          "modules-right" = [ "custom/power-profile" ];

          "custom/power-profile" = {
            exec = "waybar-power-profile";
            return-type = "json";
            interval = 5;
            on-click = "power-profile switch && pkill -RTMIN+8 waybar";
            signal = 8;

            # Default format (for balanced)
            format = "<span font='32px'>󰊚</span> {text}";

            # Different formats based on class
            format-performance = "<span font='32px'>󰡴</span> {text}";
            format-powersave = "<span font='32px'>󰡳</span> {text}";

            tooltip = true;
          };
        };

        style = ''
          #custom-power-profile {
              margin-right: 10px;
              border-bottom: 2px solid #f9e2af;
              color: #f9e2af;
          }

          #custom-power-profile.performance {
              border-bottom: 2px solid #f38ba8;
              color: #f38ba8;
          }

          #custom-power-profile.powersave {
              border-bottom: 2px solid #a6e3a1;
              color: #a6e3a1;
          }
        '';
      };

    # Set initial power profile
    home.activation.setInitialPowerProfile =
      (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Create power profiles directory
        $DRY_RUN_CMD mkdir -p "$HOME/.config/power-profiles"

        # Set initial power profile if not already set
        if [ ! -f "$HOME/.config/power-profiles/current_profile" ]; then
          $DRY_RUN_CMD echo "${cfg.defaultProfile}" > "$HOME/.config/power-profiles/current_profile"
        fi
      '');
  };
}
