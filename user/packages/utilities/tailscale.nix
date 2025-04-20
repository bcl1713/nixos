# user/packages/utilities/tailscale.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities.tailscale;
in {
  options.userPackages.utilities.tailscale = {
    enable = mkEnableOption "Enable Tailscale VPN client";

    autoConnect = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to automatically connect to Tailscale on startup";
      };

      authKeyFile = mkOption {
        type = types.str;
        default = "";
        description =
          "Path to the file containing the Tailscale auth key for automatic authentication";
      };
    };

    useExitNode = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use an exit node for all traffic";
    };

    exitNode = mkOption {
      type = types.str;
      default = "";
      description = "Hostname of the exit node to use (if useExitNode is true)";
    };

    acceptRoutes = mkOption {
      type = types.bool;
      default = true;
      description =
        "Whether to accept advertised routes from other tailnet nodes";
    };

    waybar = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to add Tailscale status indicator to waybar";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install Tailscale package
    home.packages = with pkgs; [ tailscale ];

    # Create Tailscale connection script with authentication
    home.file.".local/bin/tailscale-connect" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Check if Tailscale is already running
        if systemctl is-active --quiet tailscaled; then
          CURRENT_STATUS=$(tailscale status --json | ${pkgs.jq}/bin/jq -r '.BackendState')
          if [ "$CURRENT_STATUS" = "Running" ]; then
            # Already connected
            echo "Tailscale is already connected."
            exit 0
          fi
        else
          echo "Tailscale daemon not running. Please make sure the service is enabled."
          exit 1
        fi

        # Try to connect
        ${optionalString
        (cfg.autoConnect.enable && cfg.autoConnect.authKeyFile != "") ''
          if [ -f "${cfg.autoConnect.authKeyFile}" ]; then
            AUTH_KEY=$(cat "${cfg.autoConnect.authKeyFile}")
            # Connect with the authentication key
            sudo tailscale up --authkey="$AUTH_KEY" ${
              optionalString cfg.acceptRoutes "--accept-routes"
            } ${
              optionalString (cfg.useExitNode && cfg.exitNode != "")
              "--exit-node=${cfg.exitNode}"
            }
          else
            echo "Auth key file not found: ${cfg.autoConnect.authKeyFile}"
            # Fall back to interactive login
            sudo tailscale up ${
              optionalString cfg.acceptRoutes "--accept-routes"
            } ${
              optionalString (cfg.useExitNode && cfg.exitNode != "")
              "--exit-node=${cfg.exitNode}"
            }
          fi
        ''}

        ${optionalString
        (!cfg.autoConnect.enable || cfg.autoConnect.authKeyFile == "") ''
          # Interactive login
          sudo tailscale up ${
            optionalString cfg.acceptRoutes "--accept-routes"
          } ${
            optionalString (cfg.useExitNode && cfg.exitNode != "")
            "--exit-node=${cfg.exitNode}"
          }
        ''}
      '';
    };

    # Create Tailscale disconnect script
    home.file.".local/bin/tailscale-disconnect" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        sudo tailscale down
      '';
    };

    # Create script for toggling exit node
    home.file.".local/bin/tailscale-toggle-exit" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        if [ -z "${cfg.exitNode}" ]; then
          echo "No exit node specified in configuration"
          exit 1
        fi

        CURRENT_EXIT_NODE=$(tailscale status --json | ${pkgs.jq}/bin/jq -r '.ExitNode')

        if [ "$CURRENT_EXIT_NODE" = "null" ] || [ -z "$CURRENT_EXIT_NODE" ]; then
          echo "Enabling exit node: ${cfg.exitNode}"
          sudo tailscale up --exit-node=${cfg.exitNode}
        else
          echo "Disabling exit node"
          sudo tailscale up --exit-node=
        fi
      '';
    };

    # Create script for checking Tailscale status
    home.file.".local/bin/tailscale-status" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        tailscale status
      '';
    };

    # Create Waybar script for showing Tailscale status
    home.file.".local/bin/waybar-tailscale" = mkIf cfg.waybar.enable {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Get Tailscale status
        if ! command -v tailscale &>/dev/null; then
          echo '{"text": "<span font=\"32px\" foreground=\"#f38ba8\">󰖂</span> TS", "tooltip": "Tailscale not installed", "class": "disconnected"}'
          exit 0
        fi

        # Check if Tailscale daemon is running
        if ! systemctl is-active --quiet tailscaled; then
          echo '{"text": "<span font=\"32px\" foreground=\"#f38ba8\">󰖂</span> TS", "tooltip": "Tailscale daemon not running", "class": "disconnected"}'
          exit 0
        fi

        # Get current status and IP
        STATUS_JSON=$(tailscale status --json 2>/dev/null)
        if [ $? -ne 0 ]; then
          echo '{"text": "<span font=\"32px\" foreground=\"#f38ba8\">󰖂</span> TS", "tooltip": "Error getting Tailscale status", "class": "error"}'
          exit 0
        fi

        BACKEND_STATE=$(echo $STATUS_JSON | ${pkgs.jq}/bin/jq -r '.BackendState')
        TAILSCALE_IP=$(echo $STATUS_JSON | ${pkgs.jq}/bin/jq -r '.Self.TailscaleIPs[0]')

        # Check if we're using an exit node
        EXIT_NODE=$(echo $STATUS_JSON | ${pkgs.jq}/bin/jq -r '.ExitNode')
        EXIT_NODE_STATUS=""
        if [ "$EXIT_NODE" != "null" ] && [ -n "$EXIT_NODE" ]; then
          EXIT_NODE_STATUS="(Exit node enabled)"
        fi

        if [ "$BACKEND_STATE" = "Running" ]; then
          echo "{\"text\": \"<span font=\\\"32px\\\" foreground=\\\"#a6e3a1\\\">󰖂</span> TS\", \"tooltip\": \"Connected: $TAILSCALE_IP $EXIT_NODE_STATUS\", \"class\": \"connected\"}"
        else
          echo "{\"text\": \"<span font=\\\"32px\\\" foreground=\\\"#f38ba8\\\">󰖂</span> TS\", \"tooltip\": \"Disconnected: $BACKEND_STATE\", \"class\": \"disconnected\"}"
        fi
      '';
    };

    # Auto-connect on startup if enabled
    systemd.user.services.tailscale-autoconnect = mkIf cfg.autoConnect.enable {
      Unit = {
        Description = "Automatically connect to Tailscale";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${config.home.homeDirectory}/.local/bin/tailscale-connect";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };

    # Add waybar configuration if enabled
    programs.waybar =
      mkIf (cfg.waybar.enable && config.programs.waybar.enable) {
        settings.mainBar = {
          "modules-right" = [ "custom/tailscale" ];

          "custom/tailscale" = {
            format = "{}";
            return-type = "json";
            interval = 10;
            exec = "${config.home.homeDirectory}/.local/bin/waybar-tailscale";
            on-click = "tailscale-connect";
            on-click-right = "tailscale-disconnect";
          };
        };

        style = ''
          #custom-tailscale {
            padding: 0 10px;
            margin-right: 10px;
            color: #f9e2af;
          }

          #custom-tailscale.connected {
            color: #a6e3a1;
            border-bottom: 2px solid #a6e3a1;
          }

          #custom-tailscale.disconnected {
            color: #f38ba8;
            border-bottom: 2px solid #f38ba8;
          }

          #custom-tailscale.error {
            color: #f38ba8;
            border-bottom: 2px solid #f38ba8;
          }
        '';
      };

    # Shell aliases for convenience
    programs.bash.shellAliases = {
      ts-status = "tailscale status";
      ts-up = "tailscale-connect";
      ts-down = "tailscale-disconnect";
      ts-exit = "tailscale-toggle-exit";
    };

    programs.zsh.shellAliases = {
      ts-status = "tailscale status";
      ts-up = "tailscale-connect";
      ts-down = "tailscale-disconnect";
      ts-exit = "tailscale-toggle-exit";
    };
  };
}
