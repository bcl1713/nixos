# user/packages/utilities/system-updates.nix
#
# This module provides an enhanced wrapper around NixOS's system.autoUpgrade
# with additional features for Home Manager updates, notifications, and
# a more user-friendly interface.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userPackages.utilities.systemUpdates;

  # Format for OnCalendar in systemd timer
  formatCalendar = weekday: time:
    if weekday == "daily" then
      "*-*-* ${time}"
    else if weekday == "weekly" then
      "Sun *-*-* ${time}"
    else if weekday == "monthly" then
      "*-*-01 ${time}"
    else
      "${weekday} *-*-* ${time}";

  # Get the full path for scripts
  scriptPath = "${config.home.homeDirectory}/.local/bin";
in {
  options.userPackages.utilities.systemUpdates = {
    enable = mkEnableOption "Enable enhanced system update management";

    homeManager = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable automatic Home Manager updates";
      };

      frequency = {
        time = mkOption {
          type = types.str;
          default = "04:30";
          description = "Time to run Home Manager updates (24-hour format)";
        };

        weekday = mkOption {
          type = types.enum [
            "daily"
            "weekly"
            "monthly"
            "Mon"
            "Tue"
            "Wed"
            "Thu"
            "Fri"
            "Sat"
            "Sun"
          ];
          default = "weekly";
          description =
            "Update frequency (daily, weekly, monthly, or specific day)";
        };
      };
    };

    system = {
      # These mirror system.autoUpgrade settings but allow them to be
      # configured via Home Manager for better integration
      allowReboot = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to allow reboots after system updates";
      };

      rebootWindow = {
        lower = mkOption {
          type = types.str;
          default = "01:00";
          description = "Lower bound for reboot window (24-hour format)";
        };

        upper = mkOption {
          type = types.str;
          default = "05:00";
          description = "Upper bound for reboot window (24-hour format)";
        };
      };
    };

    notifications = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable update notifications";
      };

      beforeUpdate = mkOption {
        type = types.bool;
        default = true;
        description = "Notify before starting updates";
      };

      afterUpdate = mkOption {
        type = types.bool;
        default = true;
        description = "Notify when updates are complete";
      };
    };

    maintenance = {
      garbageCollection = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable automatic garbage collection";
        };

        maxAge = mkOption {
          type = types.int;
          default = 30;
          description = "Maximum age of generations to keep (in days)";
        };

        frequency = mkOption {
          type = types.enum [
            "daily"
            "weekly"
            "monthly"
            "Mon"
            "Tue"
            "Wed"
            "Thu"
            "Fri"
            "Sat"
            "Sun"
          ];
          default = "weekly";
          description = "How often to run garbage collection";
        };
      };

      optimizeStore = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to optimize the Nix store after garbage collection";
      };
    };
  };

  config = mkIf cfg.enable {
    # Installation of required packages
    home.packages = with pkgs;
      [
        # Notification tools for update notifications
        libnotify
      ];

    # Create update notification script
    home.file.".local/bin/system-update-notify" =
      mkIf cfg.notifications.enable {
        executable = true;
        text = ''
          #!${pkgs.bash}/bin/bash

          # Script to send notifications about system updates

          ACTION="$1"
          TYPE="$2"  # Can be "system" or "home"

          ICON="system-software-update"
          if [ "$TYPE" = "home" ]; then
            TITLE="Home Manager Update"
          elif [ "$TYPE" = "system" ]; then
            TITLE="NixOS System Update"
          else
            TITLE="System Update"
          fi

          case "$ACTION" in
            "before")
              ${pkgs.libnotify}/bin/notify-send -i $ICON "$TITLE" "Updates will begin shortly" -t 10000
              ;;
            "after")
              ${pkgs.libnotify}/bin/notify-send -i $ICON "$TITLE" "Updates completed successfully" -t 10000
              ;;
            "error")
              ${pkgs.libnotify}/bin/notify-send -i dialog-error "$TITLE" "An error occurred during updates" -t 10000
              ;;
            *)
              echo "Usage: system-update-notify [before|after|error] [system|home]"
              exit 1
              ;;
          esac
        '';
      };

    # Create home-manager update script
    home.file.".local/bin/update-home-manager" = mkIf cfg.homeManager.enable {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash

        # Script to update home-manager configuration

        set -e

        # Define the full path to the notification script
        NOTIFY_SCRIPT="${scriptPath}/system-update-notify"

        # Check if notifications are enabled
        NOTIFY=${if cfg.notifications.enable then "true" else "false"}

        # Send notification before update if enabled
        if [ "$NOTIFY" = "true" ] && [ "${
          toString cfg.notifications.beforeUpdate
        }" = "1" ]; then
          "$NOTIFY_SCRIPT" before home
        fi

        # Run the update
        echo "[$(date)] Starting Home Manager update..."
        ${pkgs.home-manager}/bin/home-manager switch --flake ~/.dotfiles/ || {
          ERROR=$?
          echo "[$(date)] Home Manager update failed with exit code $ERROR"
          # Send error notification if enabled
          if [ "$NOTIFY" = "true" ]; then
            "$NOTIFY_SCRIPT" error home
          fi
          exit $ERROR
        }

        echo "[$(date)] Home Manager update completed successfully"

        # Send notification after update if enabled
        if [ "$NOTIFY" = "true" ] && [ "${
          toString cfg.notifications.afterUpdate
        }" = "1" ]; then
          "$NOTIFY_SCRIPT" after home
        fi
      '';
    };

    # Create user-level garbage collection script
    home.file.".local/bin/nix-gc" =
      mkIf cfg.maintenance.garbageCollection.enable {
        executable = true;
        text = ''
          #!${pkgs.bash}/bin/bash

          # Script to run Nix garbage collection safely

          echo "[$(date)] Running Nix garbage collection..."

          # Use nix-collect-garbage for the user's profile only
          ${pkgs.nix}/bin/nix-collect-garbage -d

          echo "[$(date)] User garbage collection completed successfully"

          # Ask to run with sudo for system garbage collection
          echo "Do you want to run system-wide garbage collection? (requires sudo) [y/N]"
          read -r response
          if [[ "$response" =~ ^[Yy]$ ]]; then
            sudo ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than ${
              toString cfg.maintenance.garbageCollection.maxAge
            }d
            
            if [ "${toString cfg.maintenance.optimizeStore}" = "1" ]; then
              echo "[$(date)] Optimizing Nix store..."
              sudo ${pkgs.nix}/bin/nix-store --optimize
            fi
            
            echo "[$(date)] System garbage collection completed successfully"
          else
            echo "[$(date)] System garbage collection skipped"
          fi
        '';
      };

    # Create combined update script
    home.file.".local/bin/update-system" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash

        # Script to update both NixOS and Home Manager

        set -e

        # Define the full path to the notification script
        NOTIFY_SCRIPT="${scriptPath}/system-update-notify"
        HOME_UPDATE_SCRIPT="${scriptPath}/update-home-manager"

        # Parse arguments
        SYSTEM_ONLY=false
        HOME_ONLY=false
        NO_REBOOT=true

        while [[ $# -gt 0 ]]; do
          case $1 in
            --system-only)
              SYSTEM_ONLY=true
              shift
              ;;
            --home-only)
              HOME_ONLY=true
              shift
              ;;
            --reboot)
              NO_REBOOT=false
              shift
              ;;
            *)
              echo "Unknown option: $1"
              echo "Usage: update-system [--system-only] [--home-only] [--reboot]"
              exit 1
              ;;
          esac
        done

        # Check if notifications are enabled
        NOTIFY=${if cfg.notifications.enable then "true" else "false"}

        # Update NixOS system
        if [ "$HOME_ONLY" = "false" ]; then
          if [ "$NOTIFY" = "true" ] && [ "${
            toString cfg.notifications.beforeUpdate
          }" = "1" ]; then
            "$NOTIFY_SCRIPT" before system
          fi
          
          echo "[$(date)] Starting NixOS system update..."
          # Use sudo command directly without hardcoded path
          sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ~/.dotfiles/ || {
            ERROR=$?
            echo "[$(date)] NixOS update failed with exit code $ERROR"
            if [ "$NOTIFY" = "true" ]; then
              "$NOTIFY_SCRIPT" error system
            fi
            exit $ERROR
          }
          
          echo "[$(date)] NixOS system update completed successfully"
          
          if [ "$NOTIFY" = "true" ] && [ "${
            toString cfg.notifications.afterUpdate
          }" = "1" ]; then
            "$NOTIFY_SCRIPT" after system
          fi
        fi

        # Update Home Manager
        if [ "$SYSTEM_ONLY" = "false" ] && [ "${
          toString cfg.homeManager.enable
        }" = "1" ]; then
          echo "[$(date)] Starting Home Manager update..."
          "$HOME_UPDATE_SCRIPT"
        fi

        # Run user-level garbage collection if enabled
        if [ "${
          toString cfg.maintenance.garbageCollection.enable
        }" = "1" ]; then
          echo "[$(date)] Running user-level Nix garbage collection..."
          ${pkgs.nix}/bin/nix-collect-garbage -d
          echo "[$(date)] User-level garbage collection completed"
          
          echo "Do you want to run system-wide garbage collection? (requires sudo) [y/N]"
          read -r response
          if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "[$(date)] Running system-level garbage collection..."
            sudo ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than ${
              toString cfg.maintenance.garbageCollection.maxAge
            }d
            
            if [ "${toString cfg.maintenance.optimizeStore}" = "1" ]; then
              echo "[$(date)] Optimizing Nix store..."
              sudo ${pkgs.nix}/bin/nix-store --optimize
            fi
            
            echo "[$(date)] System-level garbage collection completed"
          else
            echo "[$(date)] System-level garbage collection skipped"
          fi
        fi

        # Reboot if requested and allowed
        if [ "$NO_REBOOT" = "false" ] && [ "${
          toString cfg.system.allowReboot
        }" = "1" ]; then
          echo "[$(date)] Rebooting system..."
          # Ask for confirmation before rebooting
          echo "System will reboot. Continue? [y/N]"
          read -r response
          if [[ "$response" =~ ^[Yy]$ ]]; then
            sudo ${pkgs.systemd}/bin/systemctl reboot
          else
            echo "[$(date)] Reboot cancelled"
          fi
        fi

        echo "[$(date)] All updates completed successfully"
      '';
    };

    # Set up systemd timer for automatic Home Manager updates
    systemd.user.services.home-manager-update = mkIf cfg.homeManager.enable {
      Unit = {
        Description = "Automatic Home Manager configuration update";
        Wants = "network-online.target";
        After = "network-online.target";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${scriptPath}/update-home-manager";
      };
    };

    systemd.user.timers.home-manager-update = mkIf cfg.homeManager.enable {
      Unit = { Description = "Timer for automatic Home Manager updates"; };

      Timer = {
        OnCalendar = formatCalendar cfg.homeManager.frequency.weekday
          cfg.homeManager.frequency.time;
        Persistent = true;
        RandomizedDelaySec = 1800; # 30 minute randomized delay
      };

      Install = { WantedBy = [ "timers.target" ]; };
    };

    # Set up systemd timer for garbage collection
    systemd.user.services.nix-garbage-collect =
      mkIf cfg.maintenance.garbageCollection.enable {
        Unit = { Description = "Nix garbage collection service"; };

        Service = {
          Type = "oneshot";
          # Use our new script that only does user-level garbage collection by default
          ExecStart = "${scriptPath}/nix-gc";
        };
      };

    systemd.user.timers.nix-garbage-collect =
      mkIf cfg.maintenance.garbageCollection.enable {
        Unit = { Description = "Timer for Nix garbage collection"; };

        Timer = {
          OnCalendar =
            formatCalendar cfg.maintenance.garbageCollection.frequency "03:00";
          Persistent = true;
          RandomizedDelaySec = 1800; # 30 minute randomized delay
        };

        Install = { WantedBy = [ "timers.target" ]; };
      };

    # Add bash/zsh aliases for convenience with full paths
    programs.bash.shellAliases = {
      update-all = "${scriptPath}/update-system";
      update-home = "${scriptPath}/update-system --home-only";
      update-nixos = "${scriptPath}/update-system --system-only";
    };

    programs.zsh.shellAliases = {
      update-all = "${scriptPath}/update-system";
      update-home = "${scriptPath}/update-system --home-only";
      update-nixos = "${scriptPath}/update-system --system-only";
    };

    # Add ~/.local/bin to PATH if it's not already there
    home.sessionVariables = { PATH = "$HOME/.local/bin:$PATH"; };
  };
}
