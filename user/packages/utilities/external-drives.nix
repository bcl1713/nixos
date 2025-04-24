# user/packages/utilities/external-drives.nix
#
# This module provides tools for managing external drives and removable media
# with automounting capabilities, GUI tools, and notifications.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userPackages.utilities.externalDrives;

  driveMenuScript = pkgs.writeShellScriptBin "drive-menu" ''
    #!/usr/bin/env bash

    # A menu for external drive operations

    # Show menu with wofi
    CHOICE=$(echo -e "Mount all\nUnmount all\nShow drives\nDisk utility" | ${pkgs.wofi}/bin/wofi --show dmenu --prompt "Select action" --width 300 --height 200)

    # Process the choice
    case "$CHOICE" in
      "Mount all")
        ${pkgs.udiskie}/bin/udiskie-mount -a
        ${pkgs.libnotify}/bin/notify-send "Drive Management" "Mounting all drives"
        ;;
      "Unmount all")
        ${pkgs.udiskie}/bin/udiskie-umount -a
        ${pkgs.libnotify}/bin/notify-send "Drive Management" "Unmounting all drives"
        ;;
      "Show drives")
        ${pkgs.kitty}/bin/kitty -e list-drives
        ;;
      "Disk utility")
        ${pkgs.gnome-disk-utility}/bin/gnome-disks
        ;;
    esac
  '';

  # Helper script for safely unmounting drives
  unmountScript = pkgs.writeShellScriptBin "safe-unmount" ''
    #!/usr/bin/env bash

    # A simple script to safely unmount and optionally eject drives
    # Usage: safe-unmount [--eject] <mount-point or device>

    set -e

    EJECT=false
    DEVICE=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
      case $1 in
        --eject)
          EJECT=true
          shift
          ;;
        *)
          DEVICE="$1"
          shift
          ;;
      esac
    done

    if [ -z "$DEVICE" ]; then
      echo "Error: No device or mount point specified"
      echo "Usage: safe-unmount [--eject] <mount-point or device>"
      exit 1
    fi

    # Check if input is a mount point
    if [ -d "$DEVICE" ]; then
      MOUNT_POINT="$DEVICE"
      DEVICE=$(findmnt -n -o SOURCE --target "$MOUNT_POINT")
      echo "Found device $DEVICE for mount point $MOUNT_POINT"
    fi

    # Unmount the device
    echo "Unmounting $DEVICE..."
    udisksctl unmount -b "$DEVICE"

    # Eject if requested and possible
    if [ "$EJECT" = true ]; then
      echo "Ejecting $DEVICE..."
      udisksctl power-off -b "$DEVICE" || {
        echo "Warning: Could not power off the device. It may be safe to remove now anyway."
      }
    fi

    ${pkgs.libnotify}/bin/notify-send -t 5000 -i drive-removable-media "Drive unmounted" "The drive has been safely unmounted and can be removed."
  '';

  # Script to show mounted external drives
  listDrivesScript = pkgs.writeShellScriptBin "list-drives" ''
    #!/usr/bin/env bash

    # List all mounted external drives
    echo "Mounted External Drives:"
    echo "------------------------"

    # Get only removable drives
    ${pkgs.util-linux}/bin/lsblk -o NAME,SIZE,MOUNTPOINT,LABEL,MODEL,HOTPLUG | grep '1$' | awk '{print $1, "("$2")", "mounted at", $3, "-", $4, $5}'

    # Alternative, show all mounted external drives
    echo -e "\nAll Mounted Drives:"
    echo "------------------------"
    ${pkgs.udisks2}/bin/udisksctl status | grep -A 100 "Mounted Filesystems:" | grep -v "Mounted Filesystems:"

    # Keep the terminal open until a key is pressed
    echo -e "\nPress any key to close this window..."
    read -n 1
  '';

in {
  options.userPackages.utilities.externalDrives = {
    enable = mkEnableOption "Enable external drive management tools";

    autoMount = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable automatic mounting of external drives";
      };
    };

    gui = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable graphical tools for drive management";
      };
    };

    notifications = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to show notifications for drive events";
      };
    };

    terminal = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to enable terminal utilities for drive management";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install required packages
    home.packages = with pkgs;
      [
        # Core utilities
        udisks2
        udiskie

        # Scripts
        unmountScript
        listDrivesScript
        driveMenuScript
      ] ++ (optionals cfg.gui.enable [
        # GUI tools
        gnome-disk-utility # GNOME Disks
        (lib.mkIf config.wayland.windowManager.hyprland.enable
          xfce.thunar-volman) # Thunar volume manager if using Hyprland
      ]) ++ (optionals cfg.terminal.enable [
        # Terminal utilities
        parted
        gparted
        smartmontools
        ntfs3g
        exfat
        dosfstools
      ]);

    # Create a basic configuration file for udiskie
    xdg.configFile."udiskie/config.json".text = builtins.toJSON {
      program_options = {
        automount = cfg.autoMount.enable;
        notify = cfg.notifications.enable;
        tray = false;
      };
      notifications = {
        timeout = 5;
        device_added = cfg.notifications.enable;
        device_removed = cfg.notifications.enable;
      };
    };

    # Set up udiskie for automounting if enabled
    systemd.user.services.udiskie = mkIf cfg.autoMount.enable {
      Unit = {
        Description = "Automount service for removable media";
        After = [ "graphical-session-pre.target" "dbus.service" ];
        PartOf = [ "graphical-session.target" ];
        Wants = [ "dbus.service" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.udiskie}/bin/udiskie ${
            if cfg.notifications.enable then "--notify" else "--no-notify"
          }";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = [
          "DISPLAY=:0"
          "WAYLAND_DISPLAY=wayland-0"
          "XDG_CURRENT_DESKTOP=Hyprland"
          "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
        ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
    # Set up notification configuration
    # This relies on mako or other notification daemon configured elsewhere
    systemd.user.services.external-drive-notifier =
      mkIf cfg.notifications.enable {
        Unit = {
          Description = "External drive notification service";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = toString
            (pkgs.writeShellScript "drive-notification-monitor" ''
              #!/usr/bin/env bash

              ${pkgs.inotify-tools}/bin/inotifywait -m /dev -e create -e delete |
                while read path action file; do
                  if [[ "$file" =~ ^sd[a-z][0-9]?$ || "$file" =~ ^nvme[0-9]n[0-9]p[0-9]$ ]]; then
                    if [ "$action" = "CREATE" ]; then
                      ${pkgs.libnotify}/bin/notify-send -t 5000 -i drive-removable-media "Drive connected" "A new drive has been connected"
                    elif [ "$action" = "DELETE" ]; then
                      ${pkgs.libnotify}/bin/notify-send -t 5000 -i drive-removable-media "Drive removed" "A drive has been removed"
                    fi
                  fi
                done
            '');
          Restart = "on-failure";
        };

        Install = { WantedBy = [ "graphical-session.target" ]; };
      };

    # Add a keybinding for mounting/unmounting in Hyprland if it's enabled
    wayland.windowManager.hyprland.extraConfig =
      mkIf config.wayland.windowManager.hyprland.enable ''
        # External drive management
        bind = SUPER, U, exec, drive-menu
      '';
  };
}
