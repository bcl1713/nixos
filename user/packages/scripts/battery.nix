# user/packages/scripts/battery.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userPackages.scripts.battery;
  batteryScript = pkgs.writeShellScriptBin "battery-warning" ''
    #!/usr/bin/env bash

    echo "Starting battery check"

    LOW_THRESHOLD=${toString cfg.lowThreshold}
    CRITICAL_THRESHOLD=${toString cfg.criticalThreshold}

    if [ -e /sys/class/power_supply/BAT0 ]; then
      # Try /sys/class approach first
      if [ -e /sys/class/power_supply/BAT0/capacity ]; then
        BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
        CHARGING_STATUS=$(cat /sys/class/power_supply/BAT0/status | grep -c "Charging")
        echo "Battery level: $BATTERY_LEVEL%, Charging status: $CHARGING_STATUS"
      else
        echo "Cannot read battery capacity from sysfs"
        exit 1
      fi
    else
      # Fallback to acpi
      if command -v ${pkgs.acpi}/bin/acpi >/dev/null 2>&1; then
        # Fix: properly extract the battery percentage and ensure it's a single number
        BATTERY_LEVEL=$(${pkgs.acpi}/bin/acpi -b | grep -Po '[0-9]+(?=%)' | head -1)
        CHARGING_STATUS=$(${pkgs.acpi}/bin/acpi -b | grep -c "Charging")
        echo "Battery level (acpi): $BATTERY_LEVEL%, Charging status: $CHARGING_STATUS"
      else
        echo "Neither sysfs battery info nor acpi command is available"
        exit 1
      fi
    fi

    # Check if BATTERY_LEVEL is a number
    if [[ "$BATTERY_LEVEL" =~ ^[0-9]+$ ]]; then
      # Actual check with proper numeric comparison
      if [ "$BATTERY_LEVEL" -le $CRITICAL_THRESHOLD ] && [ "$CHARGING_STATUS" -eq 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical "Battery Critical!" "Battery level is $BATTERY_LEVEL%. Please connect charger immediately."
        echo "Critical battery notification sent"
      elif [ "$BATTERY_LEVEL" -le $LOW_THRESHOLD ] && [ "$CHARGING_STATUS" -eq 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical "Battery Low" "Battery level is $BATTERY_LEVEL%. Please connect charger."
        echo "Low battery notification sent"
      else
        echo "Battery level OK or charging"
      fi
    else
      echo "Error: Battery level is not a valid number: '$BATTERY_LEVEL'"
      exit 1
    fi
  '';
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ batteryScript acpi libnotify ];

    systemd.user.services.battery-warning = {
      Unit = { Description = "Low battery warning service"; };
      Service = {
        Type = "oneshot";
        ExecStart = "${batteryScript}/bin/battery-warning";
        Environment =
          "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus";
      };
    };

    systemd.user.timers.battery-warning = {
      Unit = { Description = "Low battery warning timer"; };
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "5m";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
