# user/packages/scripts/wifi.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.scripts.wifi;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "wifi-menu" ''
        #!/usr/bin/env bash

        # Get a list of available WiFi networks with signal strength and security info
        networks=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list | awk -F: '
          # First group by SSID and find the highest signal strength for each
          {
            if ($1 != "") {
              # Store the highest signal value for this SSID
              if (!($1 in max_signal) || $3 > max_signal[$1]) {
                max_signal[$1] = $3;
                security[$1] = $2;
              }
            }
          }
          END {
            # Output the networks with highest signal strength
            for (ssid in max_signal) {
              signal = max_signal[ssid];
              
              # Create signal strength indicator
              if (signal >= 80) bars="▂▄▆█";
              else if (signal >= 60) bars="▂▄▆_";
              else if (signal >= 40) bars="▂▄__";
              else if (signal >= 20) bars="▂___";
              else bars="____";
              
              if (security[ssid] == "") {
                printf "%s [%s] [OPEN] (%d%%)\n", ssid, bars, signal;
              } else {
                printf "%s [%s] [SECURE] (%d%%)\n", ssid, bars, signal;
              }
            }
          }
        ' | sort -nr -k5 -t"(")

        # Use wofi to select a network
        selected=$(echo "$networks" | wofi --dmenu --insensitive --prompt "Select WiFi network")

        if [ -n "$selected" ]; then
          # Extract network name and trim whitespace
          network_name=$(echo "$selected" | sed 's/ \[.*\] \[.*\] (.*)$//' | xargs)
          is_open=$(echo "$selected" | grep -q "\[OPEN\]" && echo "true" || echo "false")
          
          # Check if network is already known
          if nmcli -g NAME connection show | grep -q "^$network_name$"; then
            nmcli connection up "$network_name"
            notify-send "WiFi" "Connected to $network_name"
          else
            if [ "$is_open" = "true" ]; then
              # Connect to open network without password
              nmcli device wifi connect "$network_name"
              notify-send "WiFi" "Connected to open network $network_name"
            else
              # Ask for password for secure network
              password=$(wofi --dmenu --password --prompt "Enter password for $network_name")
              if [ -n "$password" ]; then
                nmcli device wifi connect "$network_name" password "$password"
                notify-send "WiFi" "Connected to secured network $network_name"
              fi
            fi
          fi
        fi
      '')
      # Ensure we have libnotify for notifications
      libnotify
    ];
  };
}
