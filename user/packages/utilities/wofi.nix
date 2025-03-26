# user/packages/utilities/wofi.nix
#
# This module provides Wofi as an application launcher with
# multiple modes including emoji picker and Catppuccin theming.

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities.wofi;
in {
  options.userPackages.utilities.wofi = {
    enable = mkEnableOption "Enable Wofi application launcher";

    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Terminal to use for terminal commands";
    };

    theme = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Catppuccin theming for Wofi";
      };

      borderRadius = mkOption {
        type = types.int;
        default = 8;
        description = "Border radius for Wofi windows";
      };
    };

    modes = {
      drun = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable application launcher mode";
        };

        keybinding = mkOption {
          type = types.str;
          default = "SUPER, space";
          description = "Hyprland keybinding for application launcher mode";
        };
      };

      window = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable window switcher mode";
        };

        keybinding = mkOption {
          type = types.str;
          default = "SUPER, Tab";
          description = "Hyprland keybinding for window switcher mode";
        };
      };

      emoji = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable emoji picker mode";
        };

        keybinding = mkOption {
          type = types.str;
          default = "SUPER SHIFT, e";
          description = "Hyprland keybinding for emoji picker mode";
        };

        skinTone = mkOption {
          type = types.enum [
            "neutral"
            "light"
            "medium-light"
            "medium"
            "medium-dark"
            "dark"
          ];
          default = "neutral";
          description = "Default skin tone for emoji selection";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Install Wofi and related packages
    home.packages = with pkgs; [
      wofi
      rofimoji # Required for emoji picker functionality
      wl-clipboard # Required for clipboard operations
      jq # Required for window switcher functionality
    ];

    # Create Wofi configuration directory if it doesn't exist
    home.file.".config/wofi/.keep".text = "";

    # Create Wofi configuration files
    xdg.configFile = {
      "wofi/config".text = ''
        mode=drun
        allow_images=true
        allow_markup=true
        insensitive=true
        prompt=Applications
        width=500
        height=400
        always_parse_args=true
        show_all=true
        print_command=true
        layer=overlay
        term=${cfg.terminal}
      '';

      # Style configuration with Catppuccin theme
      "wofi/style.css" = mkIf cfg.theme.enable {
        text = ''
          /* Catppuccin Mocha Theme for Wofi */

          window {
            margin: 0px;
            border-radius: ${toString cfg.theme.borderRadius}px;
            background-color: #1e1e2e;
            font-family: "FiraCode Nerd Font";
            font-size: 13px;
          }

          #input {
            margin: 5px;
            border: 2px solid #89b4fa;
            border-radius: ${toString (cfg.theme.borderRadius - 2)}px;
            background-color: #313244;
            color: #cdd6f4;
          }

          #input:focus {
            border: 2px solid #cba6f7;
          }

          #inner-box {
            margin: 5px;
            background-color: #1e1e2e;
            color: #cdd6f4;
          }

          #outer-box {
            margin: 5px;
            border: none;
            background-color: #1e1e2e;
          }

          #scroll {
            margin: 5px;
          }

          #text {
            margin: 5px;
            color: #cdd6f4;
          }

          #text:selected {
            color: #f5e0dc;
          }

          #entry {
            padding: 5px;
            border-radius: ${toString (cfg.theme.borderRadius - 4)}px;
          }

          #entry:selected {
            background-color: #45475a;
          }
        '';
      };
    };

    # Create emoji picker script
    home.file.".local/bin/wofi-emoji" = mkIf cfg.modes.emoji.enable {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Launch rofimoji with Wofi as the selector
        ${pkgs.rofimoji}/bin/rofimoji --action copy --skin-tone ${cfg.modes.emoji.skinTone} --selector wofi
      '';
    };

    # Create window switcher script for Wofi
    home.file.".local/bin/wofi-window" = mkIf cfg.modes.window.enable {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Get list of windows and display in Wofi
        windows=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | "\(.address) \(.title)"')

        # Show window list in Wofi
        selected=$(echo "$windows" | ${pkgs.wofi}/bin/wofi --dmenu --insensitive --prompt "Windows" | awk '{print $1}')

        # Focus the selected window
        if [ -n "$selected" ]; then
          ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow address:$selected
        fi
      '';
    };

    # Update Hyprland keybindings if Hyprland is enabled
    wayland.windowManager.hyprland.extraConfig =
      mkIf config.wayland.windowManager.hyprland.enable (
        # Add all enabled wofi bindings
        (if cfg.modes.drun.enable then ''
          bind = ${cfg.modes.drun.keybinding}, exec, wofi --show drun
        '' else
          "") + (if cfg.modes.window.enable then ''
            bind = ${cfg.modes.window.keybinding}, exec, ~/.local/bin/wofi-window
          '' else
            "") + (if cfg.modes.emoji.enable then ''
              bind = ${cfg.modes.emoji.keybinding}, exec, ~/.local/bin/wofi-emoji
            '' else
              ""));
  };
}
