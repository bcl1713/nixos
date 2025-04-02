# user/packages/utilities/system-monitoring.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities.system.monitoring;
in {
  options.userPackages.utilities.system.monitoring = {
    enable = mkEnableOption "Enable system resource monitoring tools";

    topTools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to enable interactive resource monitoring tools like htop, btop";
      };
    };

    graphical = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable graphical monitoring tools";
      };
    };

    waybar = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable waybar integration for monitoring";
      };

      cpu = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to show CPU metrics in waybar";
        };
      };

      memory = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to show memory metrics in waybar";
        };
      };

      disk = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to show disk metrics in waybar";
        };

        mountPoint = mkOption {
          type = types.str;
          default = "/";
          description = "Mount point to monitor disk usage";
        };
      };

      temperature = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to show temperature metrics in waybar";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Install top-like resource monitoring tools
    (mkIf cfg.topTools.enable {
      home.packages = with pkgs; [
        htop
        btop
        bottom # Modern alternative to htop with graphical capabilities
      ];
    })

    # Install graphical monitoring tools
    (mkIf cfg.graphical.enable {
      home.packages = with pkgs; [
        gnome-system-monitor
        lm_sensors # For temperature monitoring
        sysstat # System statistics
        glances # An eye on your system
      ];
    })

    # Waybar integration for resource monitoring
    (mkIf (cfg.waybar.enable && config.programs.waybar.enable) {
      programs.waybar.settings.mainBar = {
        # Add waybar modules for system monitoring
        "modules-right" = (if cfg.waybar.cpu.enable then [ "cpu" ] else [ ])
          ++ (if cfg.waybar.memory.enable then [ "memory" ] else [ ])
          ++ (if cfg.waybar.disk.enable then [ "disk" ] else [ ])
          ++ (if cfg.waybar.temperature.enable then [ "temperature" ] else [ ]);

        # CPU module configuration
        "cpu" = mkIf cfg.waybar.cpu.enable {
          format = "<span font='32px'>󰻠</span> {usage}%";
          tooltip = true;
          interval = 2;
        };

        # Memory module configuration
        "memory" = mkIf cfg.waybar.memory.enable {
          format = "<span font='32px'>󰍛</span> {percentage}%";
          tooltip-format = "{used:0.1f}GiB / {total:0.1f}GiB";
          interval = 5;
        };

        # Disk module configuration
        "disk" = mkIf cfg.waybar.disk.enable {
          interval = 30;
          format = "<span font='32px'>󰋊</span> {percentage_used}%";
          path = cfg.waybar.disk.mountPoint;
          tooltip-format =
            "{used} / {total} ({percentage_used}%) used on {path}";
        };

        # Temperature module configuration
        "temperature" = mkIf cfg.waybar.temperature.enable {
          format = "<span font='32px'>{icon}</span> {temperatureC}°C";
          format-icons = [ "󱃃" "󱃃" "󰔏" "󱃂" "󰸁" ];
          critical-threshold = 85;
          tooltip = true;
        };
      };

      # Add CSS styles for the monitoring modules
      programs.waybar.style = ''
        #cpu {
          color: @peach;
          border-bottom: 2px solid @peach;
          margin-right: 10px;
        }

        #memory {
          color: @mauve;
          border-bottom: 2px solid @mauve;
          margin-right: 10px;
        }

        #disk {
          color: @green;
          border-bottom: 2px solid @green;
          margin-right: 10px;
        }

        #temperature {
          color: @red;
          border-bottom: 2px solid @red;
          margin-right: 10px;
        }

        #temperature.critical {
          background-color: @red;
          color: @crust;
        }
      '';
    })

    # Create a simple script to show system stats in the terminal
    {
      home.packages = with pkgs;
        [
          (writeShellScriptBin "system-stats" ''
            #!/usr/bin/env bash

            # Print a header
            echo "===== System Resource Status ====="
            echo ""

            # CPU usage
            echo "CPU Usage:"
            top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "  " (100 - $1) "%"}'
            echo ""

            # Memory usage
            echo "Memory Usage:"
            free -m | awk 'NR==2{printf "  %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
            echo ""

            # Disk usage
            echo "Disk Usage:"
            df -h | grep -E '^/dev/' | awk '{print "  " $6 ": " $3 "/" $2 " (" $5 ")"}'
            echo ""

            # Temperature (if available)
            if command -v ${pkgs.lm_sensors}/bin/sensors &> /dev/null; then
              echo "Temperature:"
              ${pkgs.lm_sensors}/bin/sensors | grep -E 'Core|Package' | awk '{print "  " $1 " " $2 " " $3}'
              echo ""
            fi

            # List top processes by CPU
            echo "Top CPU Processes:"
            ps -eo pcpu,pmem,pid,user,args --sort=-pcpu | head -n 6 | tail -n 5
            echo ""

            # List top processes by memory
            echo "Top Memory Processes:"
            ps -eo pmem,pcpu,pid,user,args --sort=-pmem | head -n 6 | tail -n 5
            echo ""

            echo "============================="
          '')
        ];
    }
  ]);
}
