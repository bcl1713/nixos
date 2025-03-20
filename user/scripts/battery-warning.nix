# user/scripts/battery-warning.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeShellScriptBin "battery-warning" ''
      #!/usr/bin/env bash
      
      BATTERY_LEVEL=$(${pkgs.acpi}/bin/acpi -b | grep -P -o '[0-9]+(?=%)')
      CHARGING_STATUS=$(${pkgs.acpi}/bin/acpi -b | grep -c "Charging")
      
      if [ "$BATTERY_LEVEL" -le 15 ] && [ "$CHARGING_STATUS" -eq 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical "Battery Low" "Battery level is $BATTERY_LEVEL%. Please connect charger."
      fi
    '')
    # Add acpi as a dependency so it's available in your system
    acpi
  ];

  # Add a systemd timer to check battery periodically
  systemd.user.timers.battery-warning = {
    Unit = {
      Description = "Low battery warning timer";
    };
    Timer = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
  
  systemd.user.services.battery-warning = {
    Unit = {
      Description = "Low battery warning service";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScriptBin "battery-warning" ''
        #!/usr/bin/env bash
        
        BATTERY_LEVEL=$(${pkgs.acpi}/bin/acpi -b | grep -P -o '[0-9]+(?=%)')
        CHARGING_STATUS=$(${pkgs.acpi}/bin/acpi -b | grep -c "Charging")
        
        if [ "$BATTERY_LEVEL" -le 15 ] && [ "$CHARGING_STATUS" -eq 0 ]; then
          ${pkgs.libnotify}/bin/notify-send -u critical "Battery Low" "Battery level is $BATTERY_LEVEL%. Please connect charger."
        fi
      ''}/bin/battery-warning";
    };
  };
}
