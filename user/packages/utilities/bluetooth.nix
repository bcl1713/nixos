# user/packages/utilities/bluetooth.nix
#
# This module provides Bluetooth device management with GUI and CLI tools
# for an improved user experience when working with Bluetooth devices.

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities.bluetooth;
in {
  options.userPackages.utilities.bluetooth = {
    enable = mkEnableOption "Enable Bluetooth device management";

    autostart = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to automatically start Bluetooth services on login";
      };
    };

    audio = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Bluetooth audio support";
      };
    };

    gui = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Bluetooth GUI management tools";
      };

      blueman = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to use Blueman for Bluetooth management";
        };
      };
    };

    waybar = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to add Bluetooth indicator to waybar";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install Bluetooth packages
    home.packages = with pkgs;
      [
        # CLI utilities
        bluez
        bluez-tools
      ] ++ (optionals cfg.gui.blueman.enable [ blueman ])
      ++ (optionals cfg.audio.enable [
        # Audio-related packages for Bluetooth that can be installed at user level
        pamixer
        pavucontrol # GUI for audio control including Bluetooth devices
      ]);

    # Create a script for toggling Bluetooth
    home.file.".local/bin/bluetooth-toggle" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Get current Bluetooth status
        BLUETOOTH_STATUS=$(${pkgs.bluez}/bin/bluetoothctl show | grep "Powered:" | awk '{print $2}')

        # Toggle Bluetooth status
        if [ "$BLUETOOTH_STATUS" = "yes" ]; then
          ${pkgs.bluez}/bin/bluetoothctl power off
          ${pkgs.libnotify}/bin/notify-send -i bluetooth-disabled "Bluetooth" "Bluetooth turned off"
        else
          ${pkgs.bluez}/bin/bluetoothctl power on
          ${pkgs.libnotify}/bin/notify-send -i bluetooth-active "Bluetooth" "Bluetooth turned on"
        fi
      '';
    };

    # Create a script for pairing devices with debugging
    home.file.".local/bin/bluetooth-pair" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Check if Bluetooth is powered on
        BLUETOOTH_STATUS=$(${pkgs.bluez}/bin/bluetoothctl show | grep "Powered:" | awk '{print $2}')
        if [ "$BLUETOOTH_STATUS" != "yes" ]; then
          ${pkgs.bluez}/bin/bluetoothctl power on
          ${pkgs.libnotify}/bin/notify-send -i bluetooth-active "Bluetooth" "Bluetooth turned on for pairing"
          sleep 1
        fi

        # Start pairing process
        ${pkgs.libnotify}/bin/notify-send -i bluetooth-active "Bluetooth" "Pairing mode activated. Make your device discoverable."

        # Check if blueman is installed
        if ${pkgs.blueman}/bin/blueman-manager --help &> /dev/null; then
          # Blueman is properly installed, use it for pairing
          # Launch blueman-manager for device management (more feature-rich than assistant)
          ${pkgs.blueman}/bin/blueman-manager &
        else
          # Fallback to CLI method with wofi
          # Put Bluetooth in discovery mode
          ${pkgs.bluez}/bin/bluetoothctl scan on &
          SCAN_PID=$!
          
          # Wait a bit to discover devices
          sleep 5
          
          # Get devices and let user select one
          DEVICE=$(${pkgs.bluez}/bin/bluetoothctl devices | ${pkgs.wofi}/bin/wofi --dmenu -p "Select device to pair:" | awk '{print $2}')
          
          # Stop scanning
          kill $SCAN_PID
          ${pkgs.bluez}/bin/bluetoothctl scan off
          
          if [ ! -z "$DEVICE" ]; then
            ${pkgs.bluez}/bin/bluetoothctl pair "$DEVICE"
            ${pkgs.bluez}/bin/bluetoothctl trust "$DEVICE"
            ${pkgs.bluez}/bin/bluetoothctl connect "$DEVICE"
            ${pkgs.libnotify}/bin/notify-send -i bluetooth-active "Bluetooth" "Pairing complete for $DEVICE"
          fi
        fi
      '';
    };

    # Create a script to help manage Bluetooth audio
    home.file.".local/bin/bluetooth-audio" = mkIf cfg.audio.enable {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # A helper script to manage Bluetooth audio devices

        # Function to check if PipeWire/PulseAudio is running
        check_audio_system() {
          if systemctl --user is-active --quiet pipewire.service; then
            echo "PipeWire is running"
            return 0
          elif systemctl --user is-active --quiet pulseaudio.service; then
            echo "PulseAudio is running"
            return 0
          else
            ${pkgs.libnotify}/bin/notify-send -i dialog-error "Bluetooth Audio" "Audio system not running"
            return 1
          fi
        }

        # Function to connect to a Bluetooth audio device
        connect_audio_device() {
          # List connected Bluetooth devices and filter for audio profiles
          DEVICE=$(${pkgs.bluez}/bin/bluetoothctl devices Connected | ${pkgs.wofi}/bin/wofi --dmenu -p "Select audio device:" | awk '{print $2}')
          if [ ! -z "$DEVICE" ]; then
            # Ensure device is connected
            ${pkgs.bluez}/bin/bluetoothctl connect "$DEVICE"
            # Open audio control panel to switch to the device
            ${pkgs.pavucontrol}/bin/pavucontrol &
            ${pkgs.libnotify}/bin/notify-send -i audio-headphones "Bluetooth Audio" "Connected to device. Use volume control to select it."
          fi
        }

        # Main logic
        case "$1" in
          "connect")
            if check_audio_system; then
              connect_audio_device
            fi
            ;;
          "launch-control")
            ${pkgs.pavucontrol}/bin/pavucontrol &
            ;;
          *)
            echo "Usage: bluetooth-audio [connect|launch-control]"
            echo "  connect: Connect to a Bluetooth audio device"
            echo "  launch-control: Launch the audio control panel"
            
            # If no arguments, launch the audio control panel by default
            ${pkgs.pavucontrol}/bin/pavucontrol &
            ;;
        esac
      '';
    };

    # Create an alias script to launch blueman-manager
    home.file.".local/bin/bluetooth-manager" = mkIf cfg.gui.blueman.enable {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pkgs.blueman}/bin/blueman-manager "$@"
      '';
    };

    # Waybar Bluetooth module - Simplified approach
    programs.waybar.settings.mainBar = mkIf cfg.waybar.enable {
      "modules-right" = [ "bluetooth" ];

      "bluetooth" = {
        format = "<span font='32px'>{icon}</span>";
        format-connected =
          "<span font='32px' foreground='#a6e3a1'>{icon}</span>";
        format-disabled =
          "<span font='32px' foreground='#6c7086'>{icon}</span>";
        format-icons = {
          enabled = "󰂯";
          disabled = "󰂲";
        };
        tooltip-format = "{status}";
        tooltip-format-connected = "{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}";
        on-click = "${pkgs.writeShellScript "bluetooth-toggle-wrapper" ''
          ${builtins.getEnv "HOME"}/.local/bin/bluetooth-toggle
        ''}";
        on-click-right = "${pkgs.writeShellScript "bluetooth-pair-wrapper" ''
          ${builtins.getEnv "HOME"}/.local/bin/bluetooth-manager
        ''}";
      };
    };

    # CSS Style for Waybar
    programs.waybar.style = mkIf cfg.waybar.enable ''
      #bluetooth {
        color: #89b4fa;
        border-bottom: 2px solid #89b4fa;
        margin-right: 10px;
      }

      #bluetooth.connected {
        color: #a6e3a1;
        border-bottom: 2px solid #a6e3a1;
      }

      #bluetooth.disabled {
        color: #6c7086;
        border-bottom: 2px solid #6c7086;
      }
    '';

    # Configure autostart for Bluetooth
    systemd.user.services.bluetooth-autostart = mkIf cfg.autostart.enable {
      Unit = {
        Description = "Bluetooth Auto-start Service";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bluez}/bin/bluetoothctl power on";
        RemainAfterExit = true;
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    # Add blueman-applet autostart if enabled
    systemd.user.services.blueman-applet =
      mkIf (cfg.gui.blueman.enable && cfg.autostart.enable) {
        Unit = {
          Description = "Blueman Applet";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.blueman}/bin/blueman-applet";
          Restart = "on-failure";
        };

        Install = { WantedBy = [ "graphical-session.target" ]; };
      };

    # Fix Hyprland keybindings by using the proper setting
    wayland.windowManager.hyprland.extraConfig =
      mkIf config.wayland.windowManager.hyprland.enable ''
        # Bluetooth keybindings
        bind = SUPER SHIFT, b, exec, bluetooth-manager
        bind = SUPER CTRL, b, exec, bluetooth-toggle
        bind = SUPER ALT, b, exec, bluetooth-audio
      '';
  };
}
